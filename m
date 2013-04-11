From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net-next 4/5] netback: set transport header before passing it
 to kernel
Date: Thu, 11 Apr 2013 14:37:02 +0800
Message-ID: <51665A0E.7080607@redhat.com>
References: <1364278799-37285-1-git-send-email-jasowang@redhat.com>  <1364278799-37285-5-git-send-email-jasowang@redhat.com> <1365600803.27868.60.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mst@redhat.com" <mst@redhat.com>,
	Eric Dumazet <edumazet@google.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1365600803.27868.60.camel@zakaz.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/10/2013 09:33 PM, Ian Campbell wrote:
> On Tue, 2013-03-26 at 06:19 +0000, Jason Wang wrote:
>> Currently, for the packets receives from netback, before doing header check,
>> kernel just reset the transport header in netif_receive_skb() which pretends non
>> l4 header. This is suboptimal for precise packet length estimation (introduced
>> in 1def9238: net_sched: more precise pkt_len computation) which needs correct l4
>> header for gso packets.
>>
>> The patch just reuse the header probed by netback for partial checksum packets
>> and tries to use skb_flow_dissect() for other cases, if both fail, just pretend
>> no l4 header.
>>
>> Cc: Eric Dumazet <edumazet@google.com>
>> Cc: Ian Campbell <ian.campbell@citrix.com>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>> ---
>>  drivers/net/xen-netback/netback.c |   12 ++++++++++++
>>  1 files changed, 12 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
>> index aa28550..fc8faa7 100644
>> --- a/drivers/net/xen-netback/netback.c
>> +++ b/drivers/net/xen-netback/netback.c
>> @@ -39,6 +39,7 @@
>>  #include <linux/udp.h>
>>  
>>  #include <net/tcp.h>
>> +#include <net/flow_keys.h>
>>  
>>  #include <xen/xen.h>
>>  #include <xen/events.h>
>> @@ -1184,6 +1185,7 @@ static int checksum_setup(struct xenvif *vif, struct sk_buff *skb)
>>  	if (th >= skb_tail_pointer(skb))
>>  		goto out;
>>  
>> +	skb_set_transport_header(skb, 4 * iph->ihl);
>>  	skb->csum_start = th - skb->head;
> Should the use of th here (and perhaps above) be replaced with
> skb_transport_header() too?

Yes, and furthermore looks like we can use skb_partial_csum_set() here,
will send a patch.

Thanks
>>  	switch (iph->protocol) {
>>  	case IPPROTO_TCP:
>> @@ -1495,6 +1497,7 @@ static void xen_netbk_tx_submit(struct xen_netbk *netbk)
>>  
>>  		skb->dev      = vif->dev;
>>  		skb->protocol = eth_type_trans(skb, skb->dev);
>> +		skb_reset_network_header(skb);
>>  
>>  		if (checksum_setup(vif, skb)) {
>>  			netdev_dbg(vif->dev,
>> @@ -1503,6 +1506,15 @@ static void xen_netbk_tx_submit(struct xen_netbk *netbk)
>>  			continue;
>>  		}
>>  
>> +		if (!skb_transport_header_was_set(skb)) {
>> +			struct flow_keys keys;
>> +
>> +			if (skb_flow_dissect(skb, &keys))
>> +				skb_set_transport_header(skb, keys.thoff);
>> +			else
>> +				skb_reset_transport_header(skb);
>> +		}
>> +
>>  		vif->dev->stats.rx_bytes += skb->len;
>>  		vif->dev->stats.rx_packets++;
>>  
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
