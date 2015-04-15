From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net] bnx2x: Fix busy_poll vs netpoll
Date: Wed, 15 Apr 2015 03:05:51 -0700
Message-ID: <1429092351.7346.71.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1429018513-9553-1-git-send-email-Yuval.Mintz@qlogic.com>
	 ,<1429023140.7346.33.camel@edumazet-glaptop2.roam.corp.google.com>
	 <B5657A6538887040AD3A81F1008BEC63CF5830@AVMB1.qlogic.org>
	 ,<1429033912.7346.47.camel@edumazet-glaptop2.roam.corp.google.com>
	 <B5657A6538887040AD3A81F1008BEC63CF58CE@AVMB1.qlogic.org>
	 <1429035897.7346.49.camel@edumazet-glaptop2.roam.corp.google.com>
	 ,<1429062300.7346.64.camel@edumazet-glaptop2.roam.corp.google.com>
	 <B5657A6538887040AD3A81F1008BEC63CF5B1E@AVMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, "bind@enas.net" <bind@enas.net>,
	"peter@hurleysoftware.com" <peter@hurleysoftware.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Willem de Bruijn <willemb@google.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:34853 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276AbbDOKFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 06:05:54 -0400
Received: by obbfy7 with SMTP id fy7so14584340obb.2
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2015 03:05:53 -0700 (PDT)
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63CF5B1E@AVMB1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-04-15 at 04:05 +0000, Yuval Mintz wrote:
> >  #ifdef CONFIG_NET_RX_BUSY_POLL
> > -static inline void bnx2x_fp_init_lock(struct bnx2x_fastpath *fp)
> > +
> > +enum bnx2x_fp_state {
> > +       BNX2X_STATE_FP_NAPI     = BIT(0), /* NAPI handler owns the queue */
> > +
> > +       BNX2X_STATE_FP_NAPI_REQ_BIT = 1, /* NAPI would like to own the queue */
> > +       BNX2X_STATE_FP_NAPI_REQ = BIT(1),
> > +
> > +       BNX2X_STATE_FP_POLL_BIT = 2,
> > +       BNX2X_STATE_FP_POLL     = BIT(2), /* busy_poll owns the queue */
> > +
> > +       BNX2X_STATE_FP_DISABLE_BIT = 3, /* queue is dismantled */
> > +};
> 
> ...
> 
> > /* called from the device poll routine to get ownership of a FP */
> > static inline bool bnx2x_fp_lock_napi(struct bnx2x_fastpath *fp)
> >  {
> > +       unsigned long prev, old = READ_ONCE(fp->busy_poll_state);
> > +
> > +       while (1) {
> > +               switch (old) {
> > +               case BNX2X_STATE_FP_POLL:
> > +                       /* make sure bnx2x_fp_lock_poll() wont starve us */
> > +                       set_bit(BNX2X_STATE_FP_NAPI_REQ_BIT,
> > +                               &fp->busy_poll_state);
> > +                       /* fallthrough */
> > +               case BNX2X_STATE_FP_POLL | BNX2X_STATE_FP_NAPI_REQ:
> > +                       return false;
> > +               default:
> > +                       break;
> > +               }
> > +               prev = cmpxchg(&fp->busy_poll_state, old, BNX2X_STATE_FP_NAPI);
> 
> Wouldn't this override the disabled status? Shouldn't we return 'false'
> if BNX2X_STATE_FP_DISABLE_BIT is set?

My reasoning is that at this point BNX2X_STATE_FP_DISABLE_BIT cannot be
set.

BNX2X_STATE_FP_DISABLE_BIT is set only after a call to napi_disable()


	napi_disable(&bnx2x_fp(bp, i, napi)); 
	while (!bnx2x_fp_ll_disable(&bp->fp[i]))
		usleep_range(1000, 2000);


It is important to assume this, otherwise bnx2x_fp_unlock_napi() could
not be a simple write, but would need a locked operation.

Also note that napi_disable() itself sets NAPI_STATE_DISABLE
so that napi_poll() can shortcut the napi->poll() at one point
and break a potential infinite loop under rx pressure.

	set_bit(NAPI_STATE_DISABLE, &n->state);
> 
> > +               if (unlikely(prev != old)) {
> > +                       old = prev;
> > +                       continue;
> > +               }
> > +               return true;
> >       }
> >  }
> 
> BTW, this looks quite generic - isn't it possible to take it out of the
> driver and push it into the networking core, uniforming it in the process?

Yes, this is the plan I have in mind, once net-next is opened again ;)

Thanks !
