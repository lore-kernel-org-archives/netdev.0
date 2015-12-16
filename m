From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] hv_netvsc: Use simple parser for IPv4 and v6
 headers
Date: Wed, 16 Dec 2015 13:19:32 -0800
Message-ID: <1450300772.8474.96.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1450289022-9958-1-git-send-email-haiyangz@microsoft.com>
 <1450285688.8474.86.camel@edumazet-glaptop2.roam.corp.google.com>
 <BN1PR0301MB0770A1CB185D1AB82D5F9E44CAEF0@BN1PR0301MB0770.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Haiyang Zhang <haiyangz@microsoft.com>, Tom Herbert <tom@herbertland.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <BN1PR0301MB0770A1CB185D1AB82D5F9E44CAEF0@BN1PR0301MB0770.namprd03.prod.outlook.com>
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

On Wed, 2015-12-16 at 19:20 +0000, Haiyang Zhang wrote:
> > -----Original Message-----
> > From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> > Sent: Wednesday, December 16, 2015 12:08 PM
> > 
> > This looks very very wrong to me.
> > 
> > How many times this is called per second, for the 'one flow' case ?
> > 
> > Don't you use TSO in this driver ?
> > 
> > What about encapsulation ?
> > 
> > I suspect you have a quite different issue here.
> > 
> > You simply could use skb_get_hash() since local TCP flows will provide a
> > l4 skb->hash and you have no further flow dissection to do.
> 
> In our test, we have bisected and found the following patch introduced big 
> overhead into skb_flow_dissect_flow_keys(), and caused performance 
> regression:
> commit: d34af823
> net: Add VLAN ID to flow_keys

Adding Tom Herbert <tom@herbertland.com>

Your driver was assuming things about "struct flow_keys" layout.
This is not permitted.

Magic numbers like 12 and 8 are really bad...

static bool netvsc_set_hash(u32 *hash, struct sk_buff *skb)
{
        struct flow_keys flow;
        int data_len;

        if (!skb_flow_dissect_flow_keys(skb, &flow, 0) ||
            !(flow.basic.n_proto == htons(ETH_P_IP) ||
              flow.basic.n_proto == htons(ETH_P_IPV6)))
                return false;

        if (flow.basic.ip_proto == IPPROTO_TCP)
                data_len = 12;
        else
                data_len = 8;

        *hash = comp_hash(netvsc_hash_key, HASH_KEYLEN, &flow, data_len);

        return true;
}


> This patch didn't add too many instructions, but we think the change to 
> the size of struct flow_keys may cause different cache missing rate...
> 
> To avoid affecting other drivers using this function, our patch limits the 
> change inside our driver to fix this performance regression.
> 
> Regarding your suggestion on skb_get_hash(), I looked at the code and ran 
> some tests, and found the skb->l4_hash and skb->sw_hash bits are not set, 
> so it calls __skb_get_hash() which eventually calls 
> skb_flow_dissect_flow_keys(). So it still includes the performance 
> overhead mentioned above.

Okay, but have you tried this instead of just guessing ?

Are you forwarding traffic, or is the traffic locally generated ?

TCP stack does set skb->l4_hash for sure in current kernels.

Your 'basic flow dissection' is very buggy and a step backward.

Just call skb_get_hash() : Not only your perf problem will vanish, but
your driver will correctly work with all possible malformed packets
(like pretending to be TCP packets but too small to even contain one
byte of TCP header) and well formed ones, with all encapsulations.
