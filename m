From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: Re: [PATCH] net_tx_action: Call trace_consume_skb() instead of
 trace_kfree_skb()
Date: Wed, 12 Sep 2012 08:20:55 -0500
Message-ID: <20120912132055.GA2884@BohrerMBP.rgmadvisors.com>
References: <1347406098-22071-1-git-send-email-sbohrer@rgmadvisors.com>
 <1347435199.13103.690.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org, sanagi.koki@jp.fujitsu.com,
	davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog116.obsmtp.com ([74.125.149.240]:36469 "EHLO
	na3sys009aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754924Ab2ILNVC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 09:21:02 -0400
Received: by obbuo13 with SMTP id uo13so2579517obb.19
        for <netdev@vger.kernel.org>; Wed, 12 Sep 2012 06:21:01 -0700 (PDT)
In-Reply-To: <1347435199.13103.690.camel@edumazet-glaptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 12, 2012 at 09:33:19AM +0200, Eric Dumazet wrote:
> On Tue, 2012-09-11 at 18:28 -0500, Shawn Bohrer wrote:
> > Call trace_consume_skb() instead of trace_kfree_skb() as skbs are
> > removed from the completion_queue during transmit.  This avoids false
> > positives from dropwatch/drop_monitor making them more useful.
> > 
> > Signed-off-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
> > ---
> > 
> > In my case I seem to hit this tracepoint for every packet I transmit so
> > these appear to be false positives to me.  Perhaps there are cases where
> > you could hit this and it is a real packet drop?
> > 
> >  net/core/dev.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index 8398836..00774ce 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -3015,7 +3015,7 @@ static void net_tx_action(struct softirq_action *h)
> >  			clist = clist->next;
> >  
> >  			WARN_ON(atomic_read(&skb->users));
> > -			trace_kfree_skb(skb, net_tx_action);
> > +			trace_consume_skb(skb);
> >  			__kfree_skb(skb);
> >  		}
> >  	}
> > -- 
> > 1.7.7.6
> > 
> > 
> 
> 
> Problem here is : we dont know if caller of dev_kfree_skb_irq(skb)
> wanted to drop or consume skb.
> 
> (We dont have a dev_consume_skb_irq(skb) function)
> 
> For example, drivers/infiniband/ulp/ipoib/ipoib_main.c function
> path_free() does :
> 
> while ((skb = __skb_dequeue(&path->queue)))
> 	dev_kfree_skb_irq(skb);
> 
> Are these packets dropped or consumed, I dont really know...

Thanks Eric, that is what I was afraid of.

> Note : NAPI drivers dont use dev_kfree_skb_irq(skb).
> 
> What is the NIC driver you are using, I thought it was mellanox (wich is
> NAPI) ?

Yes this should be mlx4_en. For the record here are the call stacks to
the tracepoints I see:

    md_connector-7067  [010]   367.831826: kfree_skb:            skbaddr=0xffff8805d2d0c700 protocol=2048 location=0xffffffff813e3cc0
    md_connector-7067  [010]   367.831831: kernel_stack:         <stack trace>
=> __do_softirq (ffffffff8103e690)
=> call_softirq (ffffffff8149ca4c)
=> do_softirq (ffffffff81003ef5)
=> local_bh_enable (ffffffff8103e2c4)
=> dev_queue_xmit (ffffffff813e55f3)
=> ip_finish_output (ffffffff8141b2cb)
=> ip_output (ffffffff8141bda6)
=> ip_local_out (ffffffff8141b529)
=> ip_send_skb (ffffffff8141c80b)
=> udp_send_skb (ffffffff8143ec16)
=> udp_sendmsg (ffffffff8143fd61)
=> inet_sendmsg (ffffffff8144a614)
=> sock_sendmsg (ffffffff813cc647)
=> __sys_sendmsg (ffffffff813cde16)
=> sys_sendmsg (ffffffff813cfab9)
=> system_call_fastpath (ffffffff8149b712)

But I guess your question is who puts the skb on the completion_queue.
In my case it looks like:

dev_kfree_skb_irq()
dev_kfree_skb_any()
mlx4_en_free_tx_desc()
mlx4_en_process_tx_cq()
mlx4_en_xmit()
dev_hard_start_xmit()
# from here up the stack there seems to be several paths one of which is
dev_queue_xmit()
ip_finish_output()
ip_output()
ip_local_out()
ip_send_skb()
udp_send_skb()
udp_sendmsg()
inet_sendmsg()
sock_sendmsg()
__sys_sendmsg()
sys_sendmsg()

Does this answer your question about how I'm hitting this tracepoint?

Thanks,
Shawn

-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.
