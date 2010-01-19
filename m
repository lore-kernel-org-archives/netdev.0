From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: Re: [PATCH 2/5] tracing/events: add tracepoint to IP protocol
Date: Tue, 19 Jan 2010 15:23:30 +0800
Message-ID: <4B555DF2.3090104@cn.fujitsu.com>
References: <4B541B8F.8080801@jp.fujitsu.com> <4B555B27.5030505@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	izumi.taku@jp.fujitsu.com, kaneshige.kenji@jp.fujitsu.com
To: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61712 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754713Ab0ASHWt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jan 2010 02:22:49 -0500
In-Reply-To: <4B555B27.5030505@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yang Hongyang wrote:
> Koki Sanagi wrote:
>> This patch adds tracepoints at IP protocol, skb_clone and locations where
>> copy user data to skb.
>>
>> skb_clone               chase the cloned skb
>> senddata_copy_skb       copy userdata to skb for transmit
>> ip_queue_xmit           entry of IP layer(TCP transmit)
>> ip_push_pending_frames  entry of IP layer(UDP transmit)
>> ip_output               entry of IP layer(RAW transmit)
>> ip_frag_queue           aggregate fragmented packet
>> ip_frag_reasm           reasemble fragmented packet
>> ip_rcv                  entry of IP layer(receive)
>>
>> Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
>> ---
>>  include/trace/events/skb.h |  188 ++++++++++++++++++++++++++++++++++++++++++++
>>  net/core/skbuff.c          |    1 +
>>  net/ipv4/ip_fragment.c     |    3 +
>>  net/ipv4/ip_input.c        |    3 +
>>  net/ipv4/ip_output.c       |   11 +++
>>  5 files changed, 206 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/trace/events/skb.h b/include/trace/events/skb.h
>> index d732f07..a33893f 100644
>> --- a/include/trace/events/skb.h
>> +++ b/include/trace/events/skb.h
>> @@ -6,8 +6,154 @@
>>  
>>  #include <linux/skbuff.h>
>>  #include <linux/netdevice.h>
>> +#include <linux/ip.h>
>>  #include <linux/tracepoint.h>
>>  
>> +#define FORMAT_IPADDR(x) ((unsigned char *)&x)[3],\
>> +			 ((unsigned char *)&x)[2],\
>> +			 ((unsigned char *)&x)[1],\
>> +			 ((unsigned char *)&x)[0]
> 
> I think you should use ntohl() to convert Big endian to Little endian.
> Otherwise you will have problems on some other platforms.

Sorry,Please ignore this comment.I didn't notice that you have use ntohl in TP_fast_assign.

> 
>> +
>> +TRACE_EVENT(ip_queue_xmit,
>> +
>> +	TP_PROTO(struct sk_buff *skb),
>> +
>> +	TP_ARGS(skb),
>> +
>> +	TP_STRUCT__entry(
>> +		__field(	const void *,	skbaddr	)
>> +		__field(	unsigned int,	saddr	)
>> +		__field(	unsigned int,	daddr	)
>> +       ),
>> +
>> +	TP_fast_assign(
>> +		__entry->skbaddr = skb;
>> +		__entry->saddr	 = ntohl(ip_hdr(skb)->saddr);
>> +		__entry->daddr	 = ntohl(ip_hdr(skb)->daddr);
>> +	),
>> +
>> +	TP_printk("skbaddr=%p saddr=%u.%u.%u.%u daddr=%u.%u.%u.%u",
>> +		__entry->skbaddr,
>> +		FORMAT_IPADDR(__entry->saddr),
>> +		FORMAT_IPADDR(__entry->daddr)
> 
> Just as I said above,use "FORMAT_IPADDR(ntohl(__entry->daddr))" instead.
> Same on other places.
> 
>> +	)
>> +);
>> +
>> +TRACE_EVENT(ip_push_pending_frames,
>> +
>> +	TP_PROTO(struct sk_buff *skb),
>> +
>> +	TP_ARGS(skb),
>> +
>> +	TP_STRUCT__entry(
>> +		__field(	const void *,	skbaddr	)
>> +		__field(	unsigned int,	saddr	)
>> +		__field(	unsigned int,	daddr	)
>> +       ),
>> +
>> +	TP_fast_assign(
>> +		__entry->skbaddr = skb;
>> +		__entry->saddr = ntohl(((struct iphdr *)skb->data)->saddr);
>> +		__entry->daddr = ntohl(((struct iphdr *)skb->data)->daddr);
>> +	),
>> +
>> +	TP_printk("skbaddr=%p saddr=%u.%u.%u.%u daddr=%u.%u.%u.%u",
>> +		__entry->skbaddr,
>> +		FORMAT_IPADDR(__entry->saddr),
>> +		FORMAT_IPADDR(__entry->daddr)
>> +	)
>> +);
>> +
>> +TRACE_EVENT(ip_output,
>> +
>> +	TP_PROTO(struct sk_buff *skb),
>> +
>> +	TP_ARGS(skb),
>> +
>> +	TP_STRUCT__entry(
>> +		__field(	const void *,	skbaddr	)
>> +		__field(	unsigned int,	saddr	)
>> +		__field(	unsigned int,	daddr	)
>> +       ),
>> +
>> +	TP_fast_assign(
>> +		__entry->skbaddr = skb;
>> +		__entry->saddr	 = ntohl(ip_hdr(skb)->saddr);
>> +		__entry->daddr	 = ntohl(ip_hdr(skb)->daddr);
>> +	),
>> +
>> +	TP_printk("skbaddr=%p saddr=%u.%u.%u.%u daddr=%u.%u.%u.%u",
>> +		__entry->skbaddr,
>> +		FORMAT_IPADDR(__entry->saddr),
>> +		FORMAT_IPADDR(__entry->daddr)
>> +	)
>> +);
>> +
>> +TRACE_EVENT(ip_rcv,
>> +
>> +	TP_PROTO(struct sk_buff *skb),
>> +
>> +	TP_ARGS(skb),
>> +
>> +	TP_STRUCT__entry(
>> +		__field(	const void *,	skbaddr	)
>> +		__field(	unsigned int,	saddr	)
>> +		__field(	unsigned int,	daddr	)
>> +       ),
>> +
>> +	TP_fast_assign(
>> +		__entry->skbaddr = skb;
>> +		__entry->saddr = ntohl(ip_hdr(skb)->saddr);
>> +		__entry->daddr = ntohl(ip_hdr(skb)->daddr);
>> +	),
>> +
>> +	TP_printk("skbaddr=%p saddr=%u.%u.%u.%u daddr=%u.%u.%u.%u",
>> +		__entry->skbaddr,
>> +		FORMAT_IPADDR(__entry->saddr),
>> +		FORMAT_IPADDR(__entry->daddr)
>> +	)
>> +);
>> +
>> +TRACE_EVENT(ip_frag_queue,
>> +
>> +	TP_PROTO(struct sk_buff *skb, struct sk_buff *prev),
>> +
>> +	TP_ARGS(skb, prev),
>> +
>> +	TP_STRUCT__entry(
>> +		__field(	const void *,	skbaddr		)
>> +		__field(	const void *,	prevaddr	)
>> +       ),
>> +
>> +	TP_fast_assign(
>> +		__entry->skbaddr = skb;
>> +		__entry->prevaddr = prev;
>> +	),
>> +
>> +	TP_printk("skbaddr=%p prev=%p",
>> +		__entry->skbaddr, __entry->prevaddr)
>> +);
>> +
>> +TRACE_EVENT(ip_frag_reasm,
>> +
>> +	TP_PROTO(struct sk_buff *head),
>> +
>> +	TP_ARGS(head),
>> +
>> +	TP_STRUCT__entry(
>> +		__field(	const void *,	skbaddr	)
>> +		__field(	unsigned int,	len	)
>> +       ),
>> +
>> +	TP_fast_assign(
>> +		__entry->skbaddr = head;
>> +		__entry->len = head->len;
>> +	),
>> +
>> +	TP_printk("head=%p len=%u",
>> +		__entry->skbaddr, __entry->len)
>> +);
>> +
>>  TRACE_EVENT(dev_queue_xmit,
>>  
>>  	TP_PROTO(struct sk_buff *skb,
>> @@ -77,6 +223,48 @@ TRACE_EVENT(netdev_receive_skb,
>>  		__get_str(name), __entry->skbaddr, __entry->len)
>>  );
>>  
>> +TRACE_EVENT(senddata_copy_skb,
>> +
>> +	TP_PROTO(struct sock *sk, struct sk_buff *skb, int len),
>> +
>> +	TP_ARGS(sk, skb, len),
>> +
>> +	TP_STRUCT__entry(
>> +		__field(	const void *,	skaddr	)
>> +		__field(	const void *,	skbaddr	)
>> +		__field(	int,		len	)
>> +       ),
>> +
>> +	TP_fast_assign(
>> +		__entry->skaddr = sk;
>> +		__entry->skbaddr = skb;
>> +		__entry->len = len;
>> +	),
>> +
>> +	TP_printk("sk=%p skbaddr=%p len=%d",
>> +		__entry->skaddr, __entry->skbaddr, __entry->len)
>> +);
>> +
>> +TRACE_EVENT(skb_clone,
>> +
>> +	TP_PROTO(struct sk_buff *original_skb, struct sk_buff *clone_skb),
>> +
>> +	TP_ARGS(original_skb, clone_skb),
>> +
>> +	TP_STRUCT__entry(
>> +		__field(	const void *,	original_skbaddr	)
>> +		__field(	const void *,	clone_skbaddr		)
>> +       ),
>> +
>> +	TP_fast_assign(
>> +		__entry->original_skbaddr = original_skb;
>> +		__entry->clone_skbaddr = clone_skb;
>> +	),
>> +
>> +	TP_printk("original=%p clone=%p",
>> +		__entry->original_skbaddr, __entry->clone_skbaddr)
>> +);
>> +
>>  /*
>>   * Tracepoint for free an sk_buff:
>>   */
>> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>> index 93c4e06..1712416 100644
>> --- a/net/core/skbuff.c
>> +++ b/net/core/skbuff.c
>> @@ -649,6 +649,7 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
>>  		kmemcheck_annotate_bitfield(n, flags2);
>>  		n->fclone = SKB_FCLONE_UNAVAILABLE;
>>  	}
>> +	trace_skb_clone(skb, n);
>>  
>>  	return __skb_clone(n, skb);
>>  }
>> diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
>> index 86964b3..c7e683c 100644
>> --- a/net/ipv4/ip_fragment.c
>> +++ b/net/ipv4/ip_fragment.c
>> @@ -42,6 +42,7 @@
>>  #include <linux/udp.h>
>>  #include <linux/inet.h>
>>  #include <linux/netfilter_ipv4.h>
>> +#include <trace/events/skb.h>
>>  
>>  /* NOTE. Logic of IP defragmentation is parallel to corresponding IPv6
>>   * code now. If you change something here, _PLEASE_ update ipv6/reassembly.c
>> @@ -428,6 +429,7 @@ static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
>>  
>>  	/* Insert this fragment in the chain of fragments. */
>>  	skb->next = next;
>> +	trace_ip_frag_queue(skb, prev);
>>  	if (prev)
>>  		prev->next = skb;
>>  	else
>> @@ -492,6 +494,7 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
>>  
>>  	WARN_ON(head == NULL);
>>  	WARN_ON(FRAG_CB(head)->offset != 0);
>> +	trace_ip_frag_reasm(head);
>>  
>>  	/* Allocate a new buffer for the datagram. */
>>  	ihlen = ip_hdrlen(head);
>> diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
>> index c29de98..6fbbd34 100644
>> --- a/net/ipv4/ip_input.c
>> +++ b/net/ipv4/ip_input.c
>> @@ -144,6 +144,8 @@
>>  #include <linux/mroute.h>
>>  #include <linux/netlink.h>
>>  
>> +#include <trace/events/skb.h>
>> +
>>  /*
>>   *	Process Router Attention IP option
>>   */
>> @@ -383,6 +385,7 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
>>  	/* When the interface is in promisc. mode, drop all the crap
>>  	 * that it receives, do not try to analyse it.
>>  	 */
>> +	trace_ip_rcv(skb);
>>  	if (skb->pkt_type == PACKET_OTHERHOST)
>>  		goto drop;
>>  
>> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
>> index 3451799..3dac18c 100644
>> --- a/net/ipv4/ip_output.c
>> +++ b/net/ipv4/ip_output.c
>> @@ -80,6 +80,8 @@
>>  #include <linux/netlink.h>
>>  #include <linux/tcp.h>
>>  
>> +#include <trace/events/skb.h>
>> +
>>  int sysctl_ip_default_ttl __read_mostly = IPDEFTTL;
>>  
>>  /* Generate a checksum for an outgoing IP datagram. */
>> @@ -300,6 +302,7 @@ int ip_output(struct sk_buff *skb)
>>  {
>>  	struct net_device *dev = skb_dst(skb)->dev;
>>  
>> +	trace_ip_output(skb);
>>  	IP_UPD_PO_STATS(dev_net(dev), IPSTATS_MIB_OUT, skb->len);
>>  
>>  	skb->dev = dev;
>> @@ -378,6 +381,7 @@ packet_routed:
>>  	iph->saddr    = rt->rt_src;
>>  	iph->daddr    = rt->rt_dst;
>>  	/* Transport layer set skb->h.foo itself. */
>> +	trace_ip_queue_xmit(skb);
>>  
>>  	if (opt && opt->optlen) {
>>  		iph->ihl += opt->optlen >> 2;
>> @@ -991,6 +995,7 @@ alloc_new_skb:
>>  			/*
>>  			 * Put the packet on the pending queue.
>>  			 */
>> +			trace_senddata_copy_skb(sk, skb, copy);
>>  			__skb_queue_tail(&sk->sk_write_queue, skb);
>>  			continue;
>>  		}
>> @@ -1008,6 +1013,7 @@ alloc_new_skb:
>>  				err = -EFAULT;
>>  				goto error;
>>  			}
>> +			trace_senddata_copy_skb(sk, skb, copy);
>>  		} else {
>>  			int i = skb_shinfo(skb)->nr_frags;
>>  			skb_frag_t *frag = &skb_shinfo(skb)->frags[i-1];
>> @@ -1054,6 +1060,7 @@ alloc_new_skb:
>>  			skb->data_len += copy;
>>  			skb->truesize += copy;
>>  			atomic_add(copy, &sk->sk_wmem_alloc);
>> +			trace_senddata_copy_skb(sk, skb, copy);
>>  		}
>>  		offset += copy;
>>  		length -= copy;
>> @@ -1171,6 +1178,7 @@ ssize_t	ip_append_page(struct sock *sk, struct page *page,
>>  			/*
>>  			 * Put the packet on the pending queue.
>>  			 */
>> +			trace_senddata_copy_skb(sk, skb, len);
>>  			__skb_queue_tail(&sk->sk_write_queue, skb);
>>  			continue;
>>  		}
>> @@ -1200,6 +1208,7 @@ ssize_t	ip_append_page(struct sock *sk, struct page *page,
>>  		atomic_add(len, &sk->sk_wmem_alloc);
>>  		offset += len;
>>  		size -= len;
>> +		trace_senddata_copy_skb(sk, skb, len);
>>  	}
>>  	return 0;
>>  
>> @@ -1291,6 +1300,8 @@ int ip_push_pending_frames(struct sock *sk)
>>  	iph->saddr = rt->rt_src;
>>  	iph->daddr = rt->rt_dst;
>>  
>> +	trace_ip_push_pending_frames(skb);
>> +
>>  	skb->priority = sk->sk_priority;
>>  	skb->mark = sk->sk_mark;
>>  	/*
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
> 
> 


-- 
Regards
Yang Hongyang
