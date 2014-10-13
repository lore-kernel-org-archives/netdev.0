From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next RFC 3/3] virtio-net: conditionally enable tx
	interrupt
Date: Mon, 13 Oct 2014 14:02:42 +0800
Message-ID: <543B6B02.5000404@redhat.com>
References: <1413011806-3813-1-git-send-email-jasowang@redhat.com>	
	<1413011806-3813-4-git-send-email-jasowang@redhat.com>
	<1413038899.9362.43.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-api@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1413038899.9362.43.camel@edumazet-glaptop2.roam.corp.google.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 10/11/2014 10:48 PM, Eric Dumazet wrote:
> On Sat, 2014-10-11 at 15:16 +0800, Jason Wang wrote:
>> We free transmitted packets in ndo_start_xmit() in the past to get better
>> performance in the past. One side effect is that skb_orphan() needs to be
>> called in ndo_start_xmit() which makes sk_wmem_alloc not accurate in
>> fact. For TCP protocol, this means several optimization could not work well
>> such as TCP small queue and auto corking. This can lead extra low
>> throughput of small packets stream.
>>
>> Thanks to the urgent descriptor support. This patch tries to solve this
>> issue by enable the tx interrupt selectively for stream packets. This means
>> we don't need to orphan TCP stream packets in ndo_start_xmit() but enable
>> tx interrupt for those packets. After we get tx interrupt, a tx napi was
>> scheduled to free those packets.
>>
>> With this method, sk_wmem_alloc of TCP socket were more accurate than in
>> the past which let TCP can batch more through TSQ and auto corking.
>>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>> ---
>>  drivers/net/virtio_net.c | 164 ++++++++++++++++++++++++++++++++++++-----------
>>  1 file changed, 128 insertions(+), 36 deletions(-)
>>
>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>> index 5810841..b450fc4 100644
>> --- a/drivers/net/virtio_net.c
>> +++ b/drivers/net/virtio_net.c
>> @@ -72,6 +72,8 @@ struct send_queue {
>>  
>>  	/* Name of the send queue: output.$index */
>>  	char name[40];
>> +
>> +	struct napi_struct napi;
>>  };
>>  
>>  /* Internal representation of a receive virtqueue */
>> @@ -217,15 +219,40 @@ static struct page *get_a_page(struct receive_queue *rq, gfp_t gfp_mask)
>>  	return p;
>>  }
>>  
>> +static int free_old_xmit_skbs(struct send_queue *sq, int budget)
>> +{
>> +	struct sk_buff *skb;
>> +	unsigned int len;
>> +	struct virtnet_info *vi = sq->vq->vdev->priv;
>> +	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
>> +	int sent = 0;
>> +
>> +	while (sent < budget &&
>> +	       (skb = virtqueue_get_buf(sq->vq, &len)) != NULL) {
>> +		pr_debug("Sent skb %p\n", skb);
>> +
>> +		u64_stats_update_begin(&stats->tx_syncp);
>> +		stats->tx_bytes += skb->len;
>> +		stats->tx_packets++;
>> +		u64_stats_update_end(&stats->tx_syncp);
>> +
>> +		dev_kfree_skb_any(skb);
>> +		sent++;
>> +	}
>> +
> You could accumulate skb->len in a totlen var, and perform a single
>
> 	u64_stats_update_begin(&stats->tx_syncp);
> 	stats->tx_bytes += totlen;
> 	stats->tx_packets += sent;
> 	u64_stats_update_end(&stats->tx_syncp);
>
> after the loop.
>

Yes, will do this in a separated patch.
>> +	return sent;
>> +}
>> +
> ...
>
>> +
>> +static bool virtnet_skb_needs_intr(struct sk_buff *skb)
>> +{
>> +	union {
>> +		unsigned char *network;
>> +		struct iphdr *ipv4;
>> +		struct ipv6hdr *ipv6;
>> +	} hdr;
>> +	struct tcphdr *th = tcp_hdr(skb);
>> +	u16 payload_len;
>> +
>> +	hdr.network = skb_network_header(skb);
>> +
>> +	/* Only IPv4/IPv6 with TCP is supported */
> 	Oh well, yet another packet flow dissector :)
>
> 	If most packets were caught by your implementation, you could use it
> for fast patj and fallback to skb_flow_dissect() for encapsulated
> traffic.
>
> 	struct flow_keys keys;   
>
> 	if (!skb_flow_dissect(skb, &keys)) 
> 		return false;
>
> 	if (keys.ip_proto != IPPROTO_TCP)
> 		return false;
>
> 	then check __skb_get_poff() how to get th, and check if there is some
> payload...
>
>

Yes, but we don't know if most of packets were TCP or encapsulated TCP,
it depends on userspace application. If not, looks like
skb_flow_dissect() can bring some overhead, or it could be ignored?

skb_flow_dissect
