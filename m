From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: /proc/sys/net/ipv[46]/conf/ issue unsolved
Date: Tue, 13 Feb 2007 15:10:06 -0500
Message-ID: <20070213201006.GG25362@hmsreliant.homelinux.net>
References: <200702131529.04708.hasso@estpak.ee> <20070213185820.GB25362@hmsreliant.homelinux.net> <9c46321e0702131124q33b4e263ybc38555cf1544769@mail.gmail.com> <20070213194538.GF25362@hmsreliant.homelinux.net> <9c46321e0702131149j4b9b642cvfe397d5bd2a30038@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hasso Tepper <hasso@estpak.ee>, netdev@vger.kernel.org
To: Hugo Santos <hugosantos@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3425 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750921AbXBMUKm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Feb 2007 15:10:42 -0500
Content-Disposition: inline
In-Reply-To: <9c46321e0702131149j4b9b642cvfe397d5bd2a30038@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 13, 2007 at 07:49:50PM +0000, Hugo Santos wrote:
> >Yes, I understand that, but until the IFF_UP flag is set on the interface, 
> >it
> >doesn't really have any effect on the system as a whole.  You should be 
> >able to
> >undo any default setting that you want before you call ifup on the 
> >interface, or
> >am I missing something?
> 
>  If i understand what you are proposing, in that context you can't
> undo before you set IFF_UP because the sysfs entries do not exist yet,
> and undoing later is too late as in the case of auto-configuration for
> instance the kernel might already have sent a RtSol.
> 

It was my understanding, from what I can see, that this is the order of events:

1) Kernel network driver X detects that it has hardware to drive, and
consequently calls register_netdev.  This creates the network interface and
registers all the appropriate proc and sysfs files, which are now accessible in
user space.

2) The kernel, as a result of (1), also sends an event to userspace indicating a
new interface has been created

3) The udev daemon receives this message in userspace, and looks the event up in
its udev rules configuration.

4) Most distros have a udev rule for new interface creation that amount to, in
summary, /sbin/ifup $DEVICE

5) the ifup $DEVICE from (4) goes through the network interface bring up
process, and consequently sends the ioctl SIOCSIFFLAGS to the kernel, setting
the IFF_UP flag on the appropriate interface, kicking of whatever default
processes need to be as defined by the settings found in
/proc/sys/net/conf/<interface>/*

if I understand the issue correctly (and perhaps I still don't), the concern is
that steps 3 4 and 5 have no logic in them that allow the override of the
defaults for specific interfaces, and as such manual intervention is prone to
race (i.e. the previous example in which addrconf may start and complete before
you have the opportunity to manually disable it).

As has been seen, one place to fix this is by adding logic to the ifup scripts
for the appropriate protocol to issue sysctl -w commands to set configs prior to
issuing the ifconfig up or ip link up commands.  Another approach (the one I'm
recommending here), is to add logic to the udev rules to determine if there are
any specific interface settings that need to be set prior to issuing the ifup
command at all.

All that being said, this is all moot if there is a in-kernel process that gets
started at device creation time, which also has a knob to configure it.  If that is
the case then none of these solutions will work and the process and knob
themselves are broken, since there is no way for userspace to interviene and
configure the process at all prior to it being started.

Regards
Neil

