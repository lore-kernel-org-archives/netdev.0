From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: Re: [PATCH] wait_for_completion_timeout does not return < 0
Date: Wed, 31 Dec 2014 16:20:18 +0530
Message-ID: <20141231105018.GA26258@sudip-PC>
References: <1420016643-19707-1-git-send-email-der.herr@hofr.at>
 <20141231103157.GA20842@sudip-PC>
 <20141231103711.GA30533@opentech.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>,
	linux-wimax@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nicholas Mc Guire <der.herr@hofr.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:51726 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbaLaKvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 05:51:22 -0500
Content-Disposition: inline
In-Reply-To: <20141231103711.GA30533@opentech.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 31, 2014 at 11:37:11AM +0100, Nicholas Mc Guire wrote:
> On Wed, 31 Dec 2014, Sudip Mukherjee wrote:
> 
> > On Wed, Dec 31, 2014 at 04:04:03AM -0500, Nicholas Mc Guire wrote:
> > > This is only removing the comment which is misleading as
> > > wait_for_completion_timeout does not return < 0 thus there
> > > never is anything to be passed on.
> > 
> > a small doubt - 
> > i am seeing that:
> > unsigned long wait_for_completion_timeout() is calling
> > long wait_for_common()  which is again calling 
> > long __wait_for_common which is again calling
> > long do_wait_for_common()
> > 
> > now the return value from do_wait_for_common can be -ERESTARTSYS,
> > so then what happens when wait_for_completion_timeout return this -ERESTARTSYS as an unsigned value ?
> > it becomes a positive value, and ultimately ctx.result (which is 0) is returned.
> > so then are we just ignoring the error value from do_wait_for_common() ?
> >
>  
> ESTARTSYS only can be returned if state matches in do_wait_for_common
> but wait_for_completion_timemout passes TASK_UNINTERRUPTIBLE
> so signal_pending_state will return 0 and thus it will never
> return -ERESTARTSYS.
> 
> my understanding of the callchain is:
> wait_for_completion_timemout which is uninterruptible
>   -> wait_for_common(...TASK_UNINTERRUPTIBLE)
>     -> __wait_for_common(...TASK_UNINTERRUPTIBLE)
>       -> do_wait_for_common(...TASK_UNINTERRUPTIBLE)
>         -> signal_pending_state(TASK_UNINTERRUPTIBLE...)
> 
> static inline int signal_pending_state(long state, struct task_struct *p)
> {
>         if (!(state & (TASK_INTERRUPTIBLE | TASK_WAKEKILL)))
>                 return 0;
> 
> so wait_for_completion_timemout should return >=0 only

doubt cleared.

thanks
sudip
> 
> thx!
> hofrat
> 
> > > 
> > > patch is against linux-next 3.19.0-rc1 -next-20141226
> > > 
> > > Signed-off-by: Nicholas Mc Guire <der.herr@hofr.at>
> > > ---
> > >  drivers/net/wimax/i2400m/driver.c |    1 -
> > >  1 file changed, 1 deletion(-)
> > > 
> > > diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
> > > index 9c78090..0a6384e 100644
> > > --- a/drivers/net/wimax/i2400m/driver.c
> > > +++ b/drivers/net/wimax/i2400m/driver.c
> > > @@ -197,7 +197,6 @@ int i2400m_op_reset(struct wimax_dev *wimax_dev)
> > >  		result = -ETIMEDOUT;
> > >  	else if (result > 0)
> > >  		result = ctx.result;
> > > -	/* if result < 0, pass it on */
> > >  	mutex_lock(&i2400m->init_mutex);
> > >  	i2400m->reset_ctx = NULL;
> > >  	mutex_unlock(&i2400m->init_mutex);
> > > -- 
> > > 1.7.10.4
> > > 
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > > Please read the FAQ at  http://www.tux.org/lkml/
