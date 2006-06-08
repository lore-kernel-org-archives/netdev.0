From: Matt Mackall <mpm@selenic.com>
Subject: Re: Using netconsole for debugging suspend/resume
Date: Thu, 8 Jun 2006 16:07:02 -0500
Message-ID: <20060608210702.GD24227@waste.org>
References: <44886381.9050506@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([64.81.244.121]:45009 "EHLO waste.org")
	by vger.kernel.org with ESMTP id S965013AbWFHVQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 17:16:36 -0400
To: Jeremy Fitzhardinge <jeremy@goop.org>
Content-Disposition: inline
In-Reply-To: <44886381.9050506@goop.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 08, 2006 at 10:50:57AM -0700, Jeremy Fitzhardinge wrote:
> I've been trying to get suspend/resume working well on my new laptop.  
> In general, netconsole has been pretty useful for extracting oopses and 
> other messages, but it is of more limited help in debugging the actual 
> suspend/resume cycle.  The problem looks like the e1000 driver won't 
> suspend while netconsole is using it, so I have to rmmod/modprobe 
> netconsole around the actual suspend/resume.

That's odd. Netpoll holds a reference to the device, of course, but so
does a normal "up" interface. So that shouldn't be the problem.
Another possibility is that outgoing packets from printks in the
driver are causing difficulty. Not sure what can be done about that.

> This is a big problem during resume because the screen is also blank, so 
> I get no useful clue as to what went wrong when things go wrong.  I'm 
> wondering if there's some way to keep netconsole alive to the last 
> possible moment during suspend, and re-woken as soon as possible during 
> resume.  It would be nice to have a clean solution, but I'm willing to 
> use a bletcherous hack if that's what it takes.

It's generally going to suck, because unlike a polled serial port, the
device needs to be put to sleep. But if you're doing suspend to RAM,
you might be able to do something like this:

- unhook net device from suspend machinery (possibly just return success)
- bounce out of suspend before the final call to ACPI is made

Net effect is you do OS-level suspend and resume of everything but the
NIC without actually powering down the core. Which should let you
debug just about everything.

-- 
Mathematics is the supreme nostalgia of our time.
