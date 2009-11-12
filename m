From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RACE] net: in process_backlog
Date: Thu, 12 Nov 2009 08:57:39 -0800
Message-ID: <20091112085739.1137f690@nehalam>
References: <412e6f7f0911120050w740377c7j2cdf24ef9fd2ca59@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:32947 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752280AbZKLQ6J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Nov 2009 11:58:09 -0500
In-Reply-To: <412e6f7f0911120050w740377c7j2cdf24ef9fd2ca59@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Nov 2009 16:50:53 +0800
Changli Gao <xiaosuo@gmail.com> wrote:

> Dear Stephen:
> 
> I don't think this change
> http://git.kernel.org/?p=linux/kernel/git/next/linux-next.git;a=commitdiff;h=6e583ce5242f32e925dcb198f7123256d0798370
> is correct.
> 
>                         local_irq_enable();
>                         break;
>                 }
> -
>                 local_irq_enable();
> 
> -               dev = skb->dev;
> -
> on MP system, flush_backlog() will be called here, and after that
> skb->dev will be invalid, if we access it, sth. unexpected may
> happens.
> 
>                 netif_receive_skb(skb);
> -
> -               dev_put(dev);
>         } while (++work < quota && jiffies == start_time);
> 
>         return work;

There is are a couple of issues here, but it is not what you thought
you saw.

The receive process is always done in soft IRQ context. The backlog queue's
are per-cpu. When a device is deleted an IPI is sent to all cpu's to
scan there backlog queue.  What should protect the skb is the fact that
the network device destruction process waits for an RCU grace period.
So skb->dev points to valid data. 

BUT the flush_backlog is run too late in the device destruction process.
It should be moved out of netdev_run_todo, to right after dev_shutdown().
Also adding a check for skb->dev->reg_state in netif_receive_skb would
be wise to drop packets.


-- 
