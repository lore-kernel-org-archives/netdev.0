From: "Eric Lemoine" <eric.lemoine@gmail.com>
Subject: Re: [sungem] proposal for a new locking strategy
Date: Sun, 5 Nov 2006 21:11:34 +0100
Message-ID: <5cac192f0611051211t55e4c724w3eea5043dfc53db6@mail.gmail.com>
References: <5cac192f0611050500m19f72209vc349f235680023a1@mail.gmail.com>
	 <1162731940.28571.245.camel@localhost.localdomain>
	 <5cac192f0611050517q297f5b04w7931788f6dfef3fc@mail.gmail.com>
	 <20061105090254.66710154@localhost.localdomain>
	 <5cac192f0611050928w50127396l2a88978bf97b2bff@mail.gmail.com>
	 <20061105094136.75677aa4@localhost.localdomain>
	 <5cac192f0611050952w443e6042r11c6c66b0e84685d@mail.gmail.com>
	 <20061105104955.2d9a9473@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Benjamin Herrenschmidt" <benh@kernel.crashing.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:49278 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1161693AbWKEULh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Nov 2006 15:11:37 -0500
Received: by nf-out-0910.google.com with SMTP id c2so475466nfe
        for <netdev@vger.kernel.org>; Sun, 05 Nov 2006 12:11:35 -0800 (PST)
To: "Stephen Hemminger" <shemminger@osdl.org>
In-Reply-To: <20061105104955.2d9a9473@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/5/06, Stephen Hemminger <shemminger@osdl.org> wrote:
> On Sun, 5 Nov 2006 18:52:45 +0100
> "Eric Lemoine" <eric.lemoine@gmail.com> wrote:
>
> > On 11/5/06, Stephen Hemminger <shemminger@osdl.org> wrote:
> > > On Sun, 5 Nov 2006 18:28:33 +0100
> > > "Eric Lemoine" <eric.lemoine@gmail.com> wrote:
> > >
> > > > > You could also just use net_tx_lock() now.
> > > >
> > > > You mean netif_tx_lock()?
> > > >
> > > > Thanks for letting me know about that function. Yes, I may need it.
> > > > tg3 and bnx2 use it to wake up the transmit queue:
> > > >
> > > >          if (unlikely(netif_queue_stopped(tp->dev) &&
> > > >                       (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH))) {
> > > >                  netif_tx_lock(tp->dev);
> > > >                  if (netif_queue_stopped(tp->dev) &&
> > > >                      (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH))
> > > >                          netif_wake_queue(tp->dev);
> > > >                  netif_tx_unlock(tp->dev);
> > > >          }
> > > >
> > > > 2.6.17 didn't use it. Was it a bug?
> > > >
> > > > Thanks,
> > >
> > > No, it was introduced in 2.6.18. The functions are just a wrapper
> > > around the network device transmit lock that is normally held.
> > >
> > > If the device does not need to acquire the lock during IRQ, it
> > > is a good alternative and avoids a second lock.
> > >
> > > For transmit locking there are three common alternatives:
> > >
> > > Method A: dev->queue_xmit_lock and per-device tx_lock
> > >         send: dev->xmit_lock held by caller
> > >             dev->hard_start_xmit acquires netdev_priv(dev)->tx_lock
> > >
> > >         irq:  netdev_priv(dev)->tx_lock acquired
> > >
> > > Method B: dev->queue_xmit_lock only
> > >         send: dev->xmit_lock held by caller
> > >         irq:  schedules softirq (NAPI)
> > >         napi_poll: calls netif_tx_lock() which acquires dev->xmit_lock
> > >
> > > Method C: LLTX
> > >         set dev->features LLTX
> > >         send: no locks held by caller
> > >                 dev->hard_start_xmit acquires netdev_priv(dev)->tx_lock
> > >         irq: netdev_priv(dev)->tx_lock acquired
> > >
> > > Method A is the only one that works with 2.4 and early (2.6.8?) kernels.
> > >
> >
> > Current sungem does Method C, and uses two locks: lock and tx_lock.
> > What I was planning to do is Method B (which current tg3 uses). It
> > seems to me that Method B is better than Method C. What do you think?
>
> B is better than C because the transmit logic doesn't have to
> spin in the case of lock contention, but it is not a big difference.

Current sungem does C but uses try_lock() to acquire its private
tx_lock. So it doesn't spin either in case of contention.

> You can only use B if you do Tx completion outside of hard IRQ.

Because qdisk_restart() is called with bh disabled *but* with irq
enabled, right?


-- 
Eric
