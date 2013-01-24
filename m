From: Ben Greear <greearb@candelatech.com>
Subject: Re: 3.7.3+:  Bad paging request in ip_rcv_finish while running NFS
 traffic.
Date: Wed, 23 Jan 2013 16:51:36 -0800
Message-ID: <51008598.4000603@candelatech.com>
References: <50FDADF4.3060601@candelatech.com>  <50FDDE35.7070806@candelatech.com>  <1358829606.3464.3151.camel@edumazet-glaptop>  <50FE2A57.3040804@candelatech.com>  <50FEC796.5090404@candelatech.com>  <1358875020.3464.4006.camel@edumazet-glaptop>  <1358875607.3464.4020.camel@edumazet-glaptop>  <50FF102F.2050008@candelatech.com> <50FF4BC9.1060206@candelatech.com>  <5100785D.8040101@candelatech.com>  <1358985688.12374.1247.camel@edumazet-glaptop>  <51007CA8.2050105@candelatech.com>  <1358987031.12374.1276.camel@edumazet-glaptop>  <51008294.2010201@candelatech.com> <1358988358.12374.1303.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:35945 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751885Ab3AXAvi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 19:51:38 -0500
In-Reply-To: <1358988358.12374.1303.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/23/2013 04:45 PM, Eric Dumazet wrote:
> On Wed, 2013-01-23 at 16:38 -0800, Ben Greear wrote:
>> On 01/23/2013 04:23 PM, Eric Dumazet wrote:
>>> On Wed, 2013-01-23 at 16:13 -0800, Ben Greear wrote:
>>>> On 01/23/2013 04:01 PM, Eric Dumazet wrote:
>>
>>>> I was worried that the dev_seq_stop might be called
>>>> incorrectly causing an asymetric unlock.  I have no
>>>> idea how that might happened, but several crashes
>>>> have that dev_seq_stop method listed, so it got me suspicious.
>>>
>>> dev_seq_stop() is some word in the kernel stack, result of a prior
>>> system call. Stack is not cleanup.
>>>
>>> Each function reserves an amount of stack but not always write on all
>>> reserved space (some automatic variables might be not set)
>>>
>>> Note the "? " before the name : linux printed the symbol but this was
>>> not a call site for this particular call graph. Its only an extra
>>> indication, that can be useful sometimes.
>>
>> Ahh, thanks for that info...I'd never quite pieced that together
>> before.
>>
>> Here's another crash.  Interestingly, the dst is bad before the rcu-read-lock()
>> (the bug is from the first of the 'deadbeef' debugging code below)
>>
>> Perhaps other useful info:  The skb->dev claims to be 'lo'.  The dst 'pointer'
>> in the skb has 0x1 set, so it is the 'noref' variant.
>>
>>
>> static int __netif_receive_skb(struct sk_buff *skb)
>> {
>> 	struct packet_type *ptype, *pt_prev;
>> 	rx_handler_func_t *rx_handler;
>> 	struct net_device *orig_dev;
>> 	struct net_device *null_or_dev;
>> 	bool deliver_exact = false;
>> 	int ret = NET_RX_DROP;
>> 	__be16 type;
>> 	unsigned long pflags = current->flags;
>>
>> 	net_timestamp_check(!netdev_tstamp_prequeue, skb);
>>
>> 	trace_netif_receive_skb(skb);
>>
>> 	/*
>> 	 * PFMEMALLOC skbs are special, they should
>> 	 * - be delivered to SOCK_MEMALLOC sockets only
>> 	 * - stay away from userspace
>> 	 * - have bounded memory usage
>> 	 *
>> 	 * Use PF_MEMALLOC as this saves us from propagating the allocation
>> 	 * context down to all allocation sites.
>> 	 */
>> 	if (sk_memalloc_socks() && skb_pfmemalloc(skb))
>> 		current->flags |= PF_MEMALLOC;
>>
>> 	/* if we've gotten here through NAPI, check netpoll */
>> 	if (netpoll_receive_skb(skb))
>> 		goto out;
>>
>> 	orig_dev = skb->dev;
>>
>> 	skb_reset_network_header(skb);
>> 	skb_reset_transport_header(skb);
>> 	skb_reset_mac_len(skb);
>>
>> 	pt_prev = NULL;
>>
>> 	if (skb_dst(skb)) {
>> 		if (skb_dst(skb)->input == 0xdeadbeef) {
>> 			printk("bad dst: %lu, skb->dev: %s  len: %i\n",
>> 			       skb->_skb_refdst, skb->dev->name, skb->len);
>> 			BUG_ON(1);
>> 		}
>> 	}
>> 	
>
> You should add your debuging code in netif_rx() so that we know the
> caller
>
> by the way you could only add
>
> BUG_ON(skb->_skb_refdst & SKB_DST_NOREF)

Ok, will add that.

I was poking around in drivers/net/loopback.c.  Maybe it needs
to clean up the skb_dst() before calling the rx logic in the
loopback_xmit method?


Thanks,
ben

>
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
