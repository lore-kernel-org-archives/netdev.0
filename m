From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH 1/1] tun: change speed from 10M to dynamically configured
Date: Fri, 20 Feb 2015 22:07:55 -0500
Message-ID: <20150221030755.GB1332@gospo.home.greyhouse.net>
References: <20150216120345.4dfd9950@uryu.home.lan>
 <20150219.154041.184372158520813993.davem@davemloft.net>
 <20150220023500.GK580@gospo.home.greyhouse.net>
 <20150220.150749.2049007912029090161.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stephen@networkplumber.org, Yanjun.Zhu@windriver.com,
	romieu@fr.zoreil.com, netdev@vger.kernel.org, mst@redhat.com,
	jasowang@redhat.com, viro@zeniv.linux.org.uk,
	sergei.shtylyov@cogentembedded.com, jonathon.reinhart@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f49.google.com ([209.85.216.49]:35059 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755029AbbBUDIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 22:08:00 -0500
Received: by mail-qa0-f49.google.com with SMTP id w8so15178193qac.8
        for <netdev@vger.kernel.org>; Fri, 20 Feb 2015 19:07:59 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150220.150749.2049007912029090161.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 20, 2015 at 03:07:49PM -0500, David Miller wrote:
> From: Andy Gospodarek <gospo@cumulusnetworks.com>
> Date: Thu, 19 Feb 2015 21:35:00 -0500
> 
> > On Thu, Feb 19, 2015 at 03:40:41PM -0500, David Miller wrote:
> >> I see three realistic options:
> >> 
> >> 1) Create a link state indication which means "I am a software device,
> >>    so I don't really have a link state in the traditional sense"
> >> 
> >> 2) Don't implement the link set/get operations at all on software
> >>    devices.
> >> 
> >>    People can use ETHTOOL_GLINK to see if the thing is "up"
> >> 
> >> 3) Propagate the ultimate physical transport parameters into what
> >>    the software device advertises.
> >> 
> >> It's important to carefully pick one of these, and consistently apply
> >> it to all of our software devices.
> >> 
> >> I don't want TUN doing one thing, ipv4 tunnels doing another, etc.
> > 
> > I would prefer option #3 as it relates to the ability to transport
> > offload statistics and parameters to software devices.  This could be
> > useful for hardware with some form of offload vxlan/gre/etc that may be
> > backed by hardare statistics (a callback to the upper device's ndo op
> > could be made by the native hardware driver) or any other device without
> > a proper in-kernel driver like a userspace user of tuntap that might be
> > backed by something like OpenVPN.
> > 
> > That might help provide some more detailed, ethtool-like statistics in
> > the format that is more easily readable by common monitoring tools
> > without the need to have those applications look at anything except an
> > ethtool/kernel interface.
> 
> netdev_feature_t like propagation is tricky because offloading
> depends upon whether the device can do the offload "even in the
> presence of encapsulation X".  So I don't see it as useful for
> that.
> 
> But for things that are largely advisory types of information like
> "physical link state", it works in a much more straightforward manner.
> 
> Link duplex and speed being wrong on a software device doesn't stop
> communication, but incorrect hw offload feature flags might.

Ah yes, that is an excellent point.  Trying to get too fancy is probably
a bad idea when thinking about the exception cases.  In my example the
driver for the vxlan offload device should be the one tracking this
rather than propagating information up to a upper-layer software device.

The software devices that may not have any true hardware backing in the
kernel (OpenVPN, etc) are the best consumers for this type of
infrastructure.
