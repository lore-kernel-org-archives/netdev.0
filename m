From: Ani Sinha <ani@arista.com>
Subject: Re: [PATCH 1/1] commit c6825c0976fa7893692e0e43b09740b419b23c09 upstream.
Date: Mon, 2 Nov 2015 12:48:15 -0800
Message-ID: <CAOxq_8N+HMgPyyzoWu9fGgRFjjcG5mzON6G8APGC0FU1HpnxsQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ani Sinha <ani@anirban.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:35369 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752670AbbKBUsf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 15:48:35 -0500
Received: by iofz202 with SMTP id z202so156577321iof.2
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2015 12:48:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Thu, Oct 29, 2015 at 6:21 PM, Neal P. Murphy
> <neal.p.murphy@alum.wpi.edu> wrote:
> > On Thu, 29 Oct 2015 17:01:24 -0700
> > Ani Sinha <ani@arista.com> wrote:
> >
> >> On Wed, Oct 28, 2015 at 11:40 PM, Neal P. Murphy
> >> <neal.p.murphy@alum.wpi.edu> wrote:
> >> > On Wed, 28 Oct 2015 02:36:50 -0400
> >> > "Neal P. Murphy" <neal.p.murphy@alum.wpi.edu> wrote:
> >> >
> >> >> On Mon, 26 Oct 2015 21:06:33 +0100
> >> >> Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> >> >>
> >> >> > Hi,
> >> >> >
> >> >> > On Mon, Oct 26, 2015 at 11:55:39AM -0700, Ani Sinha wrote:
> >> >> > > netfilter: nf_conntrack: fix RCU race in nf_conntrack_find_get
> >> >> >
> >> >> > Please, no need to Cc everyone here. Please, submit your Netfilter
> >> >> > patches to netfilter-devel@vger.kernel.org.
> >> >> >
> >> >> > Moreover, it would be great if the subject includes something
> >> >> > descriptive on what you need, for this I'd suggest:
> >> >> >
> >> >> > [PATCH -stable 3.4,backport] netfilter: nf_conntrack: fix RCU race in nf_conntrack_find_get
> >> >> >
> >> >> > I'm including Neal P. Murphy, he said he would help testing these
> >> >> > backports, getting a Tested-by: tag usually speeds up things too.
> >> >>
> >> >
> >> > I've probably done about as much seat-of-the-pants testing as I can. All opening/closing the same destination IP/port.
> >> >
> >> > Host: Debian Jessie, 8-core Vishera 8350 at 4.4 GHz, 16GiB RAM at (I think) 2100MHz.
> >> >
> >> > Traffic generator 1: 6-CPU KVM running 64-bit Smoothwall Express 3.1 (linux 3.4.109 without these patches), with 8GiB RAM and 9GiB swap. Packets sent across PURPLE (to bypass NAT and firewall).
> >> >
> >> > Traffic generator 2: 32-bit KVM running Smoothwall Express 3.1 (linux 3.4.110 with these patches), 3GiB RAM and minimal swap.
> >> >
> >> > In the first set of tests, generator 1's traffic passed through Generator 2 as a NATting firewall, to the host's web server. In the second set of tests, generator 2's traffic went through NAT to the host's web server.
> >> >
> >> > The load tests:
> >> >   - 2500 processes using 2500 addresses and random src ports
> >> >   - 2500 processes using 2500 addresses and the same src port
> >> >   - 2500 processes using the same src address and port
> >> >
> >> > I also tested using stock NF timeouts and using 1 second timeouts.
> >> >
> >> > Bandwidth used got as high as 16Mb/s for some tests.
> >> >
> >> > Conntracks got up to 200 000 or so or bounced between 1 and 2, depending on the test and the timeouts.
> >> >
> >> > I did not reproduce the problem these patches solve. But more importantly, I saw no problems at all. Each time I terminated a test, RAM usage returned to about that of post-boot; so there were no apparent memory leaks. No kernel messages and no netfilter messages appeared during the tests.
> >> >
> >> > If I have time, I suppose I could run another set of tests: 2500 source processes using 2500 addresses times 200 ports to connect to 2500 addresses times 200 ports on a destination system. Each process opens 200 sockets, then closes them. And repeats ad infinitum. But I might have to be clever since I can't run 500 000 processes; but I could run 20 VMs; that would get it down to about 12 000 processes per VM. And I might have to figure out how to allow allow processes on the destination system to open hundreds or thousands of sockets.
> >>
> >> Should I resend the patch with a Tested-by: tag?
> >
> > ... Oh, wait. Not yet. The dawn just broke over ol' Marblehead here. I only tested TCP; I need to hammer UDP, too.
> >
> > Can I set the timeouts to zero? Or is one as low as I can go?
>
> Any progress with testing ?

I applied the 'hammer' through a firewall with the patch. I used TCP,
UDP and ICMP.

I don't know if the patch fixes the problem. But I'm reasonably sure
that it did not break normal operations.

To test a different problem I fixed (a memory leak in my 64-bit
counter patch for xt_ACCOUNT), I tested 60,000 addresses (most of a
/16) through the firewall. Again, no troubles.

I only observed two odd things which are likely completely unrelated
to your patch. When I started the TCP test, then added the UDP test,
only TCP would come through. If I stopped and restarted the TCP test,
only UDP would come through. I suspect this is due to buffering. It's
just a behaviour I haven't encountered since I started using Linux
many years ago (around '98). The second, when I started the test, the
firewall would lose contact with the upstream F/W's apcupsd daemon;
again, this is likely due to the nature of the test: it likely floods
input and output queues.


I'd say you can probably resend with Tested-by.

Neal
