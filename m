From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [linux-pm] QUESTION: How to fix race between .suspend routine
 and watchdog timer
Date: Thu, 25 Oct 2007 13:02:12 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.0710251259230.7029-100000@netrider.rowland.org>
References: <200710250612.44296.maximlevitsky@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, <netdev@vger.kernel.org>,
	<linux-pm@lists.linux-foundation.org>
To: Maxim Levitsky <maximlevitsky@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757222AbXJYRCY@vger.kernel.org>
In-Reply-To: <200710250612.44296.maximlevitsky@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 25 Oct 2007, Maxim Levitsky wrote:

> Hi,
> 
> Recently, trying to fix saa7134 suspend/resume problems I found that there 
> is a race between IRQ handler and .suspend , and that I cant let driver access the device
> while its in D3 since it can lock up some systems.
> 
> Now I am looking to fix those issues in two drivers that have my .suspend/.resume routines.
> the saa7134 capture chip and dmfe, the davicom network driver.
> 
> Looking through the dmfe code, I noticed yet another possible race.
> A race between the .suspend, and a timer that serves both as a watchdog, and link state detector.
> Again I need to prevent it from running during the suspend/resume, but how?
> 
> I can use del_timer in .suspend, and mod_timer in .resume, but that doesn't protect against
> race with already running timer.
> I can use del_timer_sync, but it states that it is useless if timer re-enables itself, and I agree with that.
> In dmfe case the timer does re-enable itself.

That comment isn't right.  del_timer_sync works perfectly well even if
the timer routine re-enables itself, provided it stops doing so after a
small number of iterations.

> I can put checks in the timer for ->insuspend, and don't re enable it if set,
> but that opens a new can of worms with memory barriers, etc...

You don't have to worry about any of that stuff.  Just check the 
insuspend flag and don't re-enable the timer if it is set.  Even 
without any memory barriers, the timer routine won't iterate more than 
once or twice.

Alan Stern
