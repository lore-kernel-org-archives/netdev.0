From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [Kernel-janitors] Re: [patch 8/8] prism54/islpci_dev: replace schedule_timeout() with msleep()
Date: Thu, 2 Sep 2004 16:23:01 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040902162301.GB1944@us.ibm.com>
References: <200409021135.57632.margitsw@t-online.de> <20040902100322.GD1876@stro.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Margit Schubert-While <margitsw@t-online.de>, netdev@oss.sgi.com,
        kj <kernel-janitors@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040902100322.GD1876@stro.at>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Sep 02, 2004 at 12:03:22PM +0200, maximilian attems wrote:
> On Thu, 02 Sep 2004, Margit Schubert-While wrote:
> 
> > On Thu, 02 Sep 2004, Maximilian scribeth:
> > > it shouldn't hinder 2.6 in it's progression.
> > I consider this a regression.
> > As schedule_timeout is used elesewhere in the prism54 code,
> > we are using a consistent and documented method.

A grep of drivers/net/wireless/prism54 for schedule_timeout showed three
occurrences (in 2.6.9-rc1-bk7):

islpci_dev.c:   schedule_timeout(50*HZ/1000);
islpci_dev.c:           remaining = schedule_timeout(HZ);
islpci_mgt.c:           timeleft = schedule_timeout(wait_cycle_jiffies);

The first is removed by my patch.

The second & third are potentially bugs as there is no
set_current_state() preceding the call to schedule_timeout(). As per the
source:

/**
 * schedule_timeout - sleep until timeout
 * @timeout: timeout value in jiffies
 *
 * Make the current task sleep until @timeout jiffies have
 * elapsed. The routine will return immediately unless
 * the current task state has been set (see set_current_state()).

Therefore, in the current code, the schedule_timeout() call does not
have the desired effect (the same information is available in
kernel-hacking.ps).

Both of these calls should probably be fixed, but I'm not sure if you
wish to sleep in TASK_INTERUPTIBLE or TASK_UNINTERRUPTIBLE. Keep in mind
that msleep_interruptible() is also (hopefully) being pushed to the
kernel soon.

As to consistency or documentation . . . I have no evidence to suggest
that msleep() is inconsistent. And I don't think there is any need for
more documentation than the source in this case:

/**
 * msleep - sleep safely even with waitqueue interruptions
 * @msecs: Time in milliseconds to sleep for
 */

Hope this helps clear things up.

-Nish
