From: "Dmitry Torokhov" <dmitry.torokhov@gmail.com>
Subject: Re: [RFC] RF Kill
Date: Thu, 26 Apr 2007 08:52:55 -0400
Message-ID: <d120d5000704260552l62fe10e8s84f36d9adabe21a9@mail.gmail.com>
References: <200704100158.58451.dtor@insightbb.com>
	 <200704100229.32393.dtor@insightbb.com>
	 <20070426.004951.85412315.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ivdoorn@gmail.com, linville@tuxdriver.com,
	akpm@linux-foundation.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.225]:13765 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754654AbXDZMw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 08:52:56 -0400
Received: by nz-out-0506.google.com with SMTP id o1so709776nzf
        for <netdev@vger.kernel.org>; Thu, 26 Apr 2007 05:52:55 -0700 (PDT)
In-Reply-To: <20070426.004951.85412315.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/26/07, David Miller <davem@davemloft.net> wrote:
> From: Dmitry Torokhov <dtor@insightbb.com>
> Date: Tue, 10 Apr 2007 02:29:31 -0400
>
> > On Tuesday 10 April 2007 01:58, Dmitry Torokhov wrote:
> > > Hi,
> > >
> > > This is a modified version of rfkill patch that provides infrastructure
> > > for controlling state of RF transmitters found on various cards.
> >
> > Well, Andrew found bunch of issues with the patch so here is an
> > updated version...
>
> Patch applied, although one part of the locking is slightly
> suspect:
>
> > +static void rfkill_task_handler(struct work_struct *work)
> > +{
> > +     struct rfkill_task *task = container_of(work, struct rfkill_task, work);
> > +     enum rfkill_state state;
> > +
> > +     mutex_lock(&task->mutex);
> > +
> > +     spin_lock_irq(&task->lock);
> > +     state = task->desired_state;
> > +     spin_unlock_irq(&task->lock);
> > +
> > +     if (state != task->current_state) {
> > +             rfkill_switch_all(task->type, state);
> > +             task->current_state = state;
> > +     }
> > +
> > +     mutex_unlock(&task->mutex);
> > +}
>
> I applied this, but...
>
> That lock around the read doesn't make any sense, reads
> are atomic on all SMP processors. You're not going to
> see a partial word-update if you take away that lock so
> it isn't doing anything.
>

Ah, OK. I was always concerned with partial word updates but if we
have this guarantee this makes things simplier. I will remove the lock
there and I will add a comment that a temp is still needed since
desired_state may be changed from other thread.

> If locking is really needed here, it probably need to protect
> the whole read-modify-write operation transferring the
> desired_state to the current_state.
>
> In another code block, this ->desired_state thing is
> treated like a boolean instead of the enumeration that
> it is supposed to be:

It is boolean enumeration with values of 0 and 1 ;) and so state =
!state should work.

-- 
Dmitry
