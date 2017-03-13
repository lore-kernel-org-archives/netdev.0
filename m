From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] r8152: fix NULL pointer dereference in r8152_poll
Date: Mon, 13 Mar 2017 08:46:41 -0700
Message-ID: <1489420001.28631.87.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170313124727.4681-1-petr.vorel@gmail.com>
         <1489411084.28631.78.camel@edumazet-glaptop3.roam.corp.google.com>
         <1489411184.28631.80.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170313153745.wu7cf254obh2x2gn@dell5510>
         <1489419849.28631.85.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hayeswang@realtek.com, davem@davemloft.net
To: Petr Vorel <petr.vorel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33083 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753415AbdCMPqo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 11:46:44 -0400
Received: by mail-pf0-f195.google.com with SMTP id v190so19401550pfb.0
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 08:46:43 -0700 (PDT)
In-Reply-To: <1489419849.28631.85.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-03-13 at 08:44 -0700, Eric Dumazet wrote:
> On Mon, 2017-03-13 at 16:37 +0100, Petr Vorel wrote:
> > Hi Eric,
> > 
> > > > The proper work around is to enclose the napi_schedule() in a
> > > > local_bh_enable()/local_bh_disable()  pair.
> > 
> > > Something like :
> > > --- a/drivers/net/usb/r8152.c
> > > +++ b/drivers/net/usb/r8152.c
> > > @@ -3703,8 +3703,10 @@ static int rtl8152_resume(struct usb_interface *intf)
> > >  			napi_enable(&tp->napi);
> > >  			clear_bit(SELECTIVE_SUSPEND, &tp->flags);
> > >  			smp_mb__after_atomic();
> > > +			local_bh_disable();
> > >  			if (!list_empty(&tp->rx_done))
> > >  				napi_schedule(&tp->napi);
> > > +			local_bh_enable();
> > 
> > Unfortunately this doesn't work. Code in r8152.c doesn't use
> > local_bh_enable()/local_bh_disable(). I tried to lock it with
> > spin_lock_bh()/spin_unlock_bh() and with mutex_lock()/mutex_unlock()
> > but neither work.
> 
> The local_bh_disable() / local_bh_enable() definitely is the right
> answer to the issue you described.
> 
> It does not matter what code in r8152.c currently does.
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/commit/?id=8cf699ec849f4ca1413cea01289bd7d37dbcc626


You also have to protect other napi_schedule(), like the ones in
rtl_work_func_t() or rtl8152_post_reset()
