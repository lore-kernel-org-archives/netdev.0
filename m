From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Tue, 27 Jun 2006 12:10:12 -0400
Message-ID: <44A15864.6000408@garzik.org>
References: <20060626212547.GE30706@tuxdriver.com> <200606271530.06749.mb@bu3sch.de> <44A13C81.2050503@garzik.org> <200606271636.08473.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de,
	Larry Finger <Larry.Finger@lwfinger.net>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38792 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1161137AbWF0QKT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2006 12:10:19 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200606271636.08473.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> On Tuesday 27 June 2006 16:11, Jeff Garzik wrote:
>> Overall, bcm43xx is _really really bad_ about this sort of thing.  Just 
>> grepping for udelay in bcm43xx_radio.c shows some of the worst 
>> offenders.  bcm43xx_radio_init2060() and bcm43xx_radio_selectchannel() 
>> both look like candidates for using msleep() rather than udelay().
> 
> This is _all_ at initialization time.
> select_channel.... How often do you select a channel?

That question is irrelevant, because you have no idea what -else- is 
going on in the system, at the point when bcm43xx chooses to spin the 
CPU heavily.

Initialization time means you are definitely not in a hot path, and can 
therefore sleep.


> I recently reworked the periodically exectuted workhandlers,
> so that they are preemptible.

Major classes of users run their kernels without preempt.  Please don't 
depend on that to avoid bad behavior.


> mac_suspend():
> It is always called in atomic context with IRQs disabled.
> We need to wait for the device here to signal "OK, MAC is down
> now and you can count on it". This takes a few usecs. I guess
> it sends out all queued packets, or whatever. We don't know
> really.
> I can actually measure how long it takes, if you really desire
> it.
> We _need_ to wait there. It is something like synchronize_irq(), or
> whatever. It is a synchronizing function and we need it to be
> synchronizing.
> And I don't think it is worth the pain to insert a preemption
> point there (or doing even fancier things with workqueues and
> completions).
> 
> Overall, I don't think bcm43xx is still so bad at
> wasting CPU. Maybe we should still insert some voluntary
> preemption points, if the bcm43xx user does not run a fully
> preemptible kernel. But if a fully preemptible kernel is run,
> I think it is all OK.

Never assume a preemptible kernel will clean up problems for you :)

	Jeff



