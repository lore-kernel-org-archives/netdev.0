From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] vmxnet3: avoid calling pskb_may_pull with interrupts
 disabled
Date: Fri, 11 Mar 2016 18:09:57 -0500
Message-ID: <20160311230957.GA16117@hmsreliant.think-freely.org>
References: <1457116848-6753-1-git-send-email-nhorman@tuxdriver.com>
 <20160307.151614.818719625382924245.davem@davemloft.net>
 <20160308143146.GA26031@hmsreliant.think-freely.org>
 <201603112222.CDG97029.OJFHQOtVOLFMFS@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.02.1603111141020.7592@shri-linux.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	davem@davemloft.net, netdev@vger.kernel.org, pv-drivers@vmware.com
To: Shrikrishna Khare <skhare@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56928 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932457AbcCKXKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 18:10:20 -0500
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1603111141020.7592@shri-linux.eng.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 11, 2016 at 11:41:42AM -0800, Shrikrishna Khare wrote:
> 
> 
> On Fri, 11 Mar 2016, Tetsuo Handa wrote:
> 
> > Neil Horman wrote:
> > > On Mon, Mar 07, 2016 at 03:16:14PM -0500, David Miller wrote:
> > > > From: Neil Horman <nhorman@tuxdriver.com>
> > > > Date: Fri,  4 Mar 2016 13:40:48 -0500
> > 
> > This patch is calling spin_unlock_irqrestore() without spin_lock_irqsave().
> > 
> > In file included from include/linux/seqlock.h:35:0,
> >                  from include/linux/time.h:5,
> >                  from include/linux/stat.h:18,
> >                  from include/linux/module.h:10,
> >                  from drivers/net/vmxnet3/vmxnet3_drv.c:27:
> > drivers/net/vmxnet3/vmxnet3_drv.c: In function 'vmxnet3_xmit_frame':
> > include/linux/spinlock.h:246:30: warning: 'flags' may be used uninitialized in this function [-Wmaybe-uninitialized]
> >    _raw_spin_unlock_irqrestore(lock, flags); \
> >                               ^
> > drivers/net/vmxnet3/vmxnet3_drv.c:977:16: note: 'flags' was declared here
> >   unsigned long flags;
> >                 ^
> > 
> > vmxnet3_tq_xmit(struct sk_buff *skb, struct vmxnet3_tx_queue *tq,
> >                 struct vmxnet3_adapter *adapter, struct net_device *netdev)
> > {
> > (...snipped...)
> > 		goto hdr_too_big;
> > (...snipped...)
> > 	spin_lock_irqsave(&tq->tx_lock, flags);
> > (...snipped...)
> > 	spin_unlock_irqrestore(&tq->tx_lock, flags);
> > (...snipped...)
> > 	return NETDEV_TX_OK;
> > (...snipped...)
> > hdr_too_big:
> >         tq->stats.drop_oversized_hdr++;
> > unlock_drop_pkt:
> >         spin_unlock_irqrestore(&tq->tx_lock, flags);
> > (...snipped...)
> > 	return NETDEV_TX_OK;
> > }
> > 
> Thank you for reporting this. Will send out a fix later today.
> 
Shoot, sorry about that, I'm traveling today, but the fix looks easy.  If you
can send it out please Shrikrishna, I'd appreciate it.
Neil
