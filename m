From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] route: fix breakage after moving lwtunnel state
Date: Fri, 28 Aug 2015 12:20:42 +0200
Message-ID: <20150828102042.GF32206@pox.localdomain>
References: <a80cafb781c91314f90613c3e7d2ed4268eb4f06.1440153500.git.jbenc@redhat.com>
 <20150823.165103.2104601245219561984.davem@davemloft.net>
 <20150826181926.0444240f@griffin>
 <20150826221330.GB31292@pox.localdomain>
 <CALx6S36+e7O_n+UKvFO89goKoE2QV2EDa5CrzEU9eAoD13e-EQ@mail.gmail.com>
 <20150827210058.GB32206@pox.localdomain>
 <CALx6S35+g1WG9AERJ5p9Fx41fXvBAdSf9YDjYW0wgAjtgdq2XQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Benc <jbenc@redhat.com>, David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:38333 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751728AbbH1KUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 06:20:44 -0400
Received: by wibgu7 with SMTP id gu7so4900608wib.1
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 03:20:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S35+g1WG9AERJ5p9Fx41fXvBAdSf9YDjYW0wgAjtgdq2XQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/27/15 at 02:20pm, Tom Herbert wrote:
> I'm doing:
> 
> ip route add 3333:0:0:1:5555:0:2:0/128 encap ila 2001:0:0:2 via
> 2401:db00:20:911a:face:0:27:0
> 
> so that 2401:db00:20:911a:face:0:27:0 is the next hop route for
> destination 2001:0:0:2:5555:0:2:0. The dst_output for lwt just calls
> the original dest_output after transforming the packet without the use
> of any additional routes. So in this way ILA LWT is just acting as a
> "pass-through" packet transformation mechanism. Such a model might
> have additional utility: LWT occurs before iptables so that iptables
> sees the translated or encapsulated packet (davem mentioned this is
> probably what we want), we may want to defer translation until IP
> fragmentation (Roopa mentioned she needs this for MPLS).
> 
> > The IP metadata encap at FIB level is currently encap agnostic
> > and requires an intermediate encap device which then defines the
> > actual encap protocol:
> >
> >         ip route overlay/prefix encap ip dst 10.1.1.1 dev vxlan0
> >         ip route 10.1.1.1/prefix dev eth0
> >
> But then your outputting through another device, multiple routes are
> involved, performance drops :-( What not just set the route through
> VXLAN in that case?

The problem with having a single route is that it doesn't allow to
separate management of overlay and underlay. It is common to manage
the underlay with Quagga, bird or even static routes and defer the
overlay to Neutron or a fancy container orchestration system.

Caching of the 10.1.1.1 nexthop route in the overlay route would
essentially lead to the same behaviour without requiring to hardcode
the nexthop. I should have patches to demonstrate this in a bit.

> > I like it because we don't have to embed all the options as metadata
> > and can still set the through the device. An option would also be
> > to allow for both and add the following alternative:
> >
> >         ip route overlay/prefix encap ip type vxlan dst 10.1.1.1 dev eth0
> 
> Better, we should be able to send encapsulated packets with needing a device.

Why is the device itself bad? I understand that we want to minimize
overhead but why is a single logical device to keep common config and
stats undesirable?
