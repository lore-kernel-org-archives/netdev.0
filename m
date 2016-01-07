From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH net-next] hv_netvsc: don't make assumptions on struct
 flow_keys layout
Date: Thu, 07 Jan 2016 14:28:26 +0100
Message-ID: <877fjlfrid.fsf@vitty.brq.redhat.com>
References: <1452159189-11473-1-git-send-email-vkuznets@redhat.com>
 <1452171150.8255.207.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Cc: Tom Herbert <tom@herbertland.com>, Haiyang Zhang <haiyangz@microsoft.com>,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
 devel@linuxdriverproject.org, David Miller <davem@davemloft.net>
To: Simon Xiao <sixiao@microsoft.com>, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1452171150.8255.207.camel@edumazet-glaptop2.roam.corp.google.com>
 (Eric Dumazet's message of "Thu, 07 Jan 2016 04:52:30 -0800")
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

--=-=-=
Content-Type: text/plain

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Thu, 2016-01-07 at 10:33 +0100, Vitaly Kuznetsov wrote:
>> Recent changes to 'struct flow_keys' (e.g commit d34af823ff40 ("net: Add
>>  VLAN ID to flow_keys")) introduced a performance regression in netvsc
>> driver. Is problem is, however, not the above mentioned commit but the
>> fact that netvsc_set_hash() function did some assumptions on the struct
>> flow_keys data layout and this is wrong. We need to extract the data we
>> need (src/dst addresses and ports) after the dissect.
>> 
>> The issue could also be solved in a completely different way: as suggested
>> by Eric instead of our own homegrown netvsc_set_hash() we could use
>> skb_get_hash() which does more or less the same. Unfortunately, the
>> testing done by Simon showed that Hyper-V hosts are not happy with our
>> Jenkins hash, selecting the output queue with the current algorithm based
>> on Toeplitz hash works significantly better.
>
> Were tests done on IPv6 traffic ?
>

Simon, could you please test this patch for IPv6 and show us the numbers?

> Toeplitz hash takes at least 100 ns to hash 12 bytes (one iteration per
> bit : 96 iterations)
>
> For IPv6 it is 3 times this, since we have to hash 36 bytes.
>
> I do not see how it can compete with skb_get_hash() that directly gives
> skb->hash for local TCP flows.
>

My guess is that this is not the bottleneck, something is happening
behind the scene with out packets in Hyper-V host (e.g. re-distributing
them to hardware queues?) but I don't know the internals, Microsoft
folks could probably comment.


> See commits b73c3d0e4f0e1961e15bec18720e48aabebe2109
> ("net: Save TX flow hash in sock and set in skbuf on xmit")
> and 877d1f6291f8e391237e324be58479a3e3a7407c
> ("net: Set sk_txhash from a random number")
>
> I understand Microsoft loves Toeplitz, but this looks not well placed
> here.
>
> I suspect there is another problem.
>
> Please share your numbers and test methodology, and the alternative
> patch Simon tested so that we can double check it.
>

Alternative patch which uses skb_get_hash() attached. Simon, could you
please share the rest (environment, metodology, numbers) with us here?
Thanks!

> Thanks.
>
> PS: For the time being this patch can probably be applied on -net tree,
> as it fixes a real bug.

-- 
  Vitaly


--=-=-=
Content-Type: text/x-patch
Content-Disposition: inline;
 filename=0001-hv_netvsc-use-skb_get_hash-instead-of-a-homegrown-im.patch

>From 0040e79c1303bd225ddbbce679ea944ea11ad0bd Mon Sep 17 00:00:00 2001
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Date: Wed, 6 Jan 2016 12:14:10 +0100
Subject: [PATCH] hv_netvsc: use skb_get_hash() instead of a homegrown
 implementation

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
 drivers/net/hyperv/netvsc_drv.c | 67 ++---------------------------------------
 1 file changed, 3 insertions(+), 64 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 409b48e..038bf4f 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -195,65 +195,6 @@ static void *init_ppi_data(struct rndis_message *msg, u32 ppi_size,
 	return ppi;
 }
 
-union sub_key {
-	u64 k;
-	struct {
-		u8 pad[3];
-		u8 kb;
-		u32 ka;
-	};
-};
-
-/* Toeplitz hash function
- * data: network byte order
- * return: host byte order
- */
-static u32 comp_hash(u8 *key, int klen, void *data, int dlen)
-{
-	union sub_key subk;
-	int k_next = 4;
-	u8 dt;
-	int i, j;
-	u32 ret = 0;
-
-	subk.k = 0;
-	subk.ka = ntohl(*(u32 *)key);
-
-	for (i = 0; i < dlen; i++) {
-		subk.kb = key[k_next];
-		k_next = (k_next + 1) % klen;
-		dt = ((u8 *)data)[i];
-		for (j = 0; j < 8; j++) {
-			if (dt & 0x80)
-				ret ^= subk.ka;
-			dt <<= 1;
-			subk.k <<= 1;
-		}
-	}
-
-	return ret;
-}
-
-static bool netvsc_set_hash(u32 *hash, struct sk_buff *skb)
-{
-	struct flow_keys flow;
-	int data_len;
-
-	if (!skb_flow_dissect_flow_keys(skb, &flow, 0) ||
-	    !(flow.basic.n_proto == htons(ETH_P_IP) ||
-	      flow.basic.n_proto == htons(ETH_P_IPV6)))
-		return false;
-
-	if (flow.basic.ip_proto == IPPROTO_TCP)
-		data_len = 12;
-	else
-		data_len = 8;
-
-	*hash = comp_hash(netvsc_hash_key, HASH_KEYLEN, &flow, data_len);
-
-	return true;
-}
-
 static u16 netvsc_select_queue(struct net_device *ndev, struct sk_buff *skb,
 			void *accel_priv, select_queue_fallback_t fallback)
 {
@@ -266,11 +207,9 @@ static u16 netvsc_select_queue(struct net_device *ndev, struct sk_buff *skb,
 	if (nvsc_dev == NULL || ndev->real_num_tx_queues <= 1)
 		return 0;
 
-	if (netvsc_set_hash(&hash, skb)) {
-		q_idx = nvsc_dev->send_table[hash % VRSS_SEND_TAB_SIZE] %
-			ndev->real_num_tx_queues;
-		skb_set_hash(skb, hash, PKT_HASH_TYPE_L3);
-	}
+	hash = skb_get_hash(skb);
+	q_idx = nvsc_dev->send_table[hash % VRSS_SEND_TAB_SIZE] %
+		ndev->real_num_tx_queues;
 
 	return q_idx;
 }
-- 
2.4.3


--=-=-=
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
devel mailing list
devel@linuxdriverproject.org
http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel

--=-=-=--
