From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: infinite spin in RT when booting with DHCP on
Date: Wed, 8 Feb 2012 21:41:13 +0100 (CET)
Message-ID: <alpine.LFD.2.02.1202082112460.2794@ionos>
References: <4F292FE0.7090302@digi.com>    <201202021338.44950.tim.sander@hbm.com>    <20120202201336.GF25594@pengutronix.de> <4F2BB59C.4080206@digi.com>    <20120203103520.GI25594@pengutronix.de> <4F2C07EE.10408@digi.com>   <1328287427.5882.159.camel@gandalf.stny.rr.com>
  <4F2C1885.8030301@digi.com> <1328290789.5882.166.camel@gandalf.stny.rr.com>  <4F2F9478.10809@digi.com> <1328534873.5882.227.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Hector Palacios <hector.palacios@digi.com>,
	=?ISO-8859-15?Q?Uwe_Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>, Tim Sander <tim.sander@hbm.com>,
	"linux-rt-users@vger.kernel.org" <linux-rt-users@vger.kernel.org>,
	"lclaudio@uudg.org" <lclaudio@uudg.org>,
	"efault@gmx.de" <efault@gmx.de>, netdev@veger.kernel.org,
	Shawn Guo <shawn.guo@linaro.org>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <1328534873.5882.227.camel@gandalf.stny.rr.com>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 6 Feb 2012, Steven Rostedt wrote:

> On Mon, 2012-02-06 at 09:51 +0100, Hector Palacios wrote:
> > On 02/03/2012 06:39 PM, Steven Rostedt wrote:
> > > Note that you see that this causes a hang in the system if ksoftirqd is
> > > a real time task.
> > 
> > This is true.
> > 
> > > Not to mention, that ksoftirqd spins in an infinite
> > > loop if the cable isn't connected (regardless of ksoftirqd's priority).
> > 
> > This is not true. The infinite loop is only hit when ksoftirqd is a real time task. I 
> > think you got confused by the different patches we tried. That dirty hack of yours 
> > with the workqueue was the one hanging with the cable disconnected. ;o)
> > 
> 
> I didn't say it was going to hang the box, I said it was going to spin.
> 
> With the cable disconnected, did you run top to see if ksoftirqd was
> running at near 100%?  It wont lock up the box because ksoftirqd is not
> a real time task in mainline.

NETDEV_TX_BUSY has always been a source of trouble and we carry a
bunch of patches in RT which handle the obvious candidates since we
encountered the first spinning lockup on RT.

Mainline does not notice as it falls back to the SCHED_OTHER softirq
thread after trying to reschedule the same thing over and
over.

NETDEV_TX_BUSY simply should die. It's a bad design decision (invented
for mitigation of SMP lock contention problems) and it's abuse by
driver writers to bridge the gap of hardware bringup is just a
consequence of that decision.

        if (!fep->link) {
                /* Link is down or autonegotiation is in progress. */
                return NETDEV_TX_BUSY;
        }

So instead of handling link down and autonegotiation gracefully this
code relies on the fact that a 2 seconds spinning loop goes unnoticed
in mainline because ksoftirqd runs with SCHED_OTHER.

Oh well,

	tglx
