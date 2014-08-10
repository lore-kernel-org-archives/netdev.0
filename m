From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Use CAP_NET_ADMIN and alias netdev-nlmon instead
Date: Sat, 9 Aug 2014 17:03:44 -0700
Message-ID: <20140809170344.0352b16c@haswell.linuxnetplumber.net>
References: <7B1A5F4E-7DCD-4054-9E8C-E5511AF64CE3@holtmann.org>
	<53E67742.9080405@redhat.com>
	<09B6E85F-9B01-435B-B18B-71730DBD450D@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36942 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751482AbaHJADs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Aug 2014 20:03:48 -0400
Received: by mail-pa0-f51.google.com with SMTP id ey11so9150842pad.38
        for <netdev@vger.kernel.org>; Sat, 09 Aug 2014 17:03:48 -0700 (PDT)
In-Reply-To: <09B6E85F-9B01-435B-B18B-71730DBD450D@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 9 Aug 2014 13:23:24 -0700
Marcel Holtmann <marcel@holtmann.org> wrote:

> Hi Daniel,
> 
> >> so I am running this command sequence:
> >> 
> >> 	ip link add name nlmon type nlmon
> >> 	ip link set dev nlmon up
> >> 
> >> With that I get this message in dmesg:
> >> 
> >> Loading kernel module for a network device with CAP_SYS_MODULE (deprecated).
> > > Use CAP_NET_ADMIN and alias netdev-nlmon instead.
> >> 
> >> The kernel section producing this is dev_load() from net/core/dev_ioctl.c:
> >> 
> >>         no_module = !dev;
> >>         if (no_module && capable(CAP_NET_ADMIN))
> >>                 no_module = request_module("netdev-%s", name);
> >>         if (no_module && capable(CAP_SYS_MODULE)) {
> >>                 if (!request_module("%s", name))
> >>                         pr_warn("Loading kernel module for a network device with CAP_SYS_MODULE (deprecated).  Use CAP_NET_ADMIN and alias netdev-%s instead.\n",
> >>                                 name);
> >>         }
> >> 
> >> Since I am explicitly giving the name from userspace, I have no idea why the
> > > kernel bugs me in providing netdev-nlmon alias. It makes no sense to me. What
> > > is the reasoning behind this?
> > 
> > Could it just be that your process doesn't have CAP_NET_ADMIN set
> > but CAP_SYS_MODULE instead thus triggering this pr_warn()?
> > 
> > grep Cap /proc/$$/status ?
> > 
> > Hm, I don't think this is nlmon related, above works fine on my side.
> 
> so I have not nlmon.ko loaded or compiled into the kernel. This means the ip command will trigger the autoloading. Command is either run with sudo or as root. So this is not a capability issue.
> 
> I think this is just a wrong check when handling loading of modules. I still do not understand how a netdev-%s alias makes any sense. Or even trying to load module nlmon.ko since I created interface nlmon.
> 
> The real module loading should also be done in the type and not the name.
> 
> Regards
> 
> Marcel
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


The netdev module alias is a hold over from the past. For normal device people
used to create a alias eth0 to and point it to the type of network device used, that
was back in the bad old ISA days before real discovery.

Also, the tunnels create module alias for the control device and ip used to use
this to autoload the tunnel device.

The message is bogus and should just be removed, I also see it in a couple of other cases
where tap devices are renamed for  other usese.
