From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: "ADDRCONF(NETDEV_UP): eth0: link is not ready" with IPv6
Date: Tue, 3 Jul 2012 16:55:09 +0100
Message-ID: <1341330909.4852.151.camel@deadeye.wl.decadent.org.uk>
References: <4FED14C2.9020200@xdin.com>
	 <1340983473.3066.6.camel@bwh-desktop.uk.solarflarecom.com>
	 <4FF313F6.7010600@xdin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: Arvid Brodin <Arvid.Brodin@xdin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:63449 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752339Ab2GCPzR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 11:55:17 -0400
In-Reply-To: <4FF313F6.7010600@xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-03 at 15:47 +0000, Arvid Brodin wrote:
> (Added MACB "patch" contact Nicolas Ferre to CC list.)
> 
> On 2012-06-29 17:24, Ben Hutchings wrote:
> > On Fri, 2012-06-29 at 02:36 +0000, Arvid Brodin wrote:
> >> Hi,
> >>
> >> After 'ip link set eth0 up' on an avr32 board (network driver macb), the device ends up in
> >> operational mode "UNKNOWN":
> >>
> >> # ip link
> >> 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN qlen 1000
> >>     link/ether 00:24:74:00:17:9d brd ff:ff:ff:ff:ff:ff
> >>
> >> Unplugging and plugging in the network cable gets the device to mode "UP".
> >>
> >> This is a problem for me because I'm trying to use this device as a "slave" device (for a
> >> virtual HSR device*) and I need to be able to decide if the slave device is operational or
> >> not.
> >>
> >> Following Stephen's advice here:
> >> http://kerneltrap.org/mailarchive/linux-netdev/2008/9/24/3398834 I checked the macb.c code
> >> and noticed they do not call netif_carrier_off() neither before register_netdev() nor in
> >> dev_open().
> > 
> > It should be called after register_netdev() and before the driver's
> > ndo_open implementation returns.
> 
> I'm guessing this allows linkwatch to do netif_carrier_on() some time after the dev_open()?

No, the driver is always responsible for calling
netif_carrier_{on,off}() in a timely manner.  link_watch takes care of
stopping the software TX queues if the link goes down.

> Besides not calling netif_carrier_off() in dev_open(), the Cadence/MACB driver calls
> netif_carrier_off() in dev_close(). Is this correct?

Unnecessary but harmless.

> How should I handle carrier state for a virtual device? The device should have "carrier"
> as long as at least one of the underlying physical interfaces is operational (which I
> guess means operational state UP). Would it be correct to watch NETDEV_CHANGE and DOWN/UP
> events of the slaves and call netif_carrier_on()/off() on the virtual device depending on
> the slaves' states?
[...]

That sounds about right.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
