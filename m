From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: Re: Increased multicast packet drops in 3.4
Date: Thu, 6 Sep 2012 23:00:43 -0500
Message-ID: <20120907040043.GA2714@BohrerMBP.rgmadvisors.com>
References: <20120906001108.GA6035@BohrerMBP.rgmadvisors.com>
 <1346912560.13121.175.camel@edumazet-glaptop>
 <20120906130316.GA2310@BohrerMBP.gateway.2wire.net>
 <1346937667.2484.33.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog127.obsmtp.com ([74.125.149.107]:47003 "EHLO
	na3sys009aog127.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750703Ab2IGEAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 00:00:52 -0400
Received: by oago6 with SMTP id o6so70301oag.19
        for <netdev@vger.kernel.org>; Thu, 06 Sep 2012 21:00:50 -0700 (PDT)
In-Reply-To: <1346937667.2484.33.camel@edumazet-glaptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 06, 2012 at 03:21:07PM +0200, Eric Dumazet wrote:
> kfree_skb() can free a list of skb, and we use a generic function to do
> so, without forwarding the drop/notdrop status. So its unfortunate, but
> adding extra parameters just for the sake of drop_monitor is not worth
> it.  skb_drop_fraglist() doesnt know if the parent skb is dropped or
> only freed, so it calls kfree_skb(), not consume_skb() or kfree_skb()

I understand that this means that dropwatch or the skb:kfree_skb
tracepoint won't know if the packet was really dropped, but do we
know in this case from the context of the stack trace?  I'm assuming
since we didn't receive an error that the packet was delivered and
these aren't real drops.

> Are you receiving fragmented UDP frames ?

I looked at the sending application and it yes it is possible it is
sending fragmented frames.

> I ask this because with latest kernels (linux-3.5), we should no longer
> build a list of skb, but a single skb with page fragments.
> 
> commit 3cc4949269e01f39443d0fcfffb5bc6b47878d45
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Sat May 19 03:02:20 2012 +0000
> 
>     ipv4: use skb coalescing in defragmentation
>     
>     ip_frag_reasm() can use skb_try_coalesce() to build optimized skb,
>     reducing memory used by them (truesize), and reducing number of cache
>     line misses and overhead for the consumer.
>     
>     Signed-off-by: Eric Dumazet <edumazet@google.com>
>     Cc: Alexander Duyck <alexander.h.duyck@intel.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>

I'll have to give 3.5 a try tomorrow and see if it has the same
problem.  After backporting all of your patches to convert kfree_skb()
to consume_skb() to 3.4 I actually don't have that many different
places hitting the skb:kfree_skb tracepoint at the time of the drop.
Here are some of the ones I have left that might be relevant.

          <idle>-0     [001] 11933.738797: kfree_skb:            skbaddr=0xffff8805ebcf9500 protocol=2048 location=0xffffffff81404e33
          <idle>-0     [001] 11933.738801: kernel_stack:         <stack trace>
=> ip_rcv (ffffffff81404e33)
=> __netif_receive_skb (ffffffff813ce123)
=> netif_receive_skb (ffffffff813d0da1)
=> process_responses (ffffffffa018486c)
=> napi_rx_handler (ffffffffa0185606)
=> net_rx_action (ffffffff813d2449)
=> __do_softirq (ffffffff8103bfd0)
=> call_softirq (ffffffff8148a14c)
=> do_softirq (ffffffff81003e85)
=> irq_exit (ffffffff8103c3a5)
=> do_IRQ (ffffffff8148a693)
=> ret_from_intr (ffffffff814814a7)
=> cpu_idle (ffffffff8100ac16)
=> start_secondary (ffffffff81af5e66)

My IPSTATS_MIB_INHDRERRORS, IPSTATS_MIB_INDISCARDS, and
IPSTATS_MIB_INTRUNCATEDPKTS counters are all 0 so maybe this is from
skb->pkt_type == PACKET_OTHERHOST?

          <idle>-0     [001] 11933.937378: kfree_skb:            skbaddr=0xffff8805ebcf8c00 protocol=2048 location=0xffffffff81404660
          <idle>-0     [001] 11933.937385: kernel_stack:         <stack trace>
=> ip_rcv_finish (ffffffff81404660)
=> ip_rcv (ffffffff81404f61)
=> __netif_receive_skb (ffffffff813ce123)
=> netif_receive_skb (ffffffff813d0da1)
=> process_responses (ffffffffa018486c)
=> napi_rx_handler (ffffffffa0185606)
=> net_rx_action (ffffffff813d2449)
=> __do_softirq (ffffffff8103bfd0)
=> call_softirq (ffffffff8148a14c)
=> do_softirq (ffffffff81003e85)
=> irq_exit (ffffffff8103c3a5)
=> do_IRQ (ffffffff8148a693)
=> ret_from_intr (ffffffff814814a7)
=> cpu_idle (ffffffff8100ac16)
=> start_secondary (ffffffff81af5e66)

I see two places here that I might be hitting that don't increment any
counters.  I can try instrumenting these to see which one I hit.

          <idle>-0     [003] 11932.454375: kfree_skb:            skbaddr=0xffff880584843700 protocol=4 location=0xffffffffa00492d4
          <idle>-0     [003] 11932.454382: kernel_stack:         <stack trace>
=> llc_rcv (ffffffffa00492d4)
=> __netif_receive_skb (ffffffff813ce123)
=> netif_receive_skb (ffffffff813d0da1)
=> process_responses (ffffffffa018486c)
=> napi_rx_handler (ffffffffa0185606)
=> net_rx_action (ffffffff813d2449)
=> __do_softirq (ffffffff8103bfd0)
=> call_softirq (ffffffff8148a14c)
=> do_softirq (ffffffff81003e85)
=> irq_exit (ffffffff8103c3a5)
=> do_IRQ (ffffffff8148a693)
=> ret_from_intr (ffffffff814814a7)
=> cpu_idle (ffffffff8100ac16)
=> start_secondary (ffffffff81af5e66)

This is protocol=4 so I don't know if it is really relevant but then
again I don't know what this is.

          <idle>-0     [003] 11914.266635: kfree_skb:            skbaddr=0xffff880584843b00 protocol=2048 location=0xffffffff8143bfa8
          <idle>-0     [003] 11914.266641: kernel_stack:         <stack trace>
=> igmp_rcv (ffffffff8143bfa8)
=> ip_local_deliver_finish (ffffffff814049ed)
=> ip_local_deliver (ffffffff81404d1a)
=> ip_rcv_finish (ffffffff814046ad)
=> ip_rcv (ffffffff81404f61)
=> __netif_receive_skb (ffffffff813ce123)
=> netif_receive_skb (ffffffff813d0da1)
=> mlx4_en_process_rx_cq (ffffffffa010a4fe)
=> mlx4_en_poll_rx_cq (ffffffffa010a9ef)
=> net_rx_action (ffffffff813d2449)
=> __do_softirq (ffffffff8103bfd0)
=> call_softirq (ffffffff8148a14c)
=> do_softirq (ffffffff81003e85)
=> irq_exit (ffffffff8103c3a5)
=> do_IRQ (ffffffff8148a693)
=> ret_from_intr (ffffffff814814a7)
=> cpu_idle (ffffffff8100ac16)
=> start_secondary (ffffffff81af5e66)

Also don't know if this one is relevant.  This looks like an igmp
packet so probably not my drop, but I am receiving multicast packets
in this case so maybe it is somehow related.

If any of these spark any ideas let me know otherwise I'll keep
digging and try 3.5/3.6 tomorrow.

Thanks,
Shawn


-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.
