From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] route: fix breakage after moving lwtunnel state
Date: Thu, 27 Aug 2015 23:00:58 +0200
Message-ID: <20150827210058.GB32206@pox.localdomain>
References: <a80cafb781c91314f90613c3e7d2ed4268eb4f06.1440153500.git.jbenc@redhat.com>
 <20150823.165103.2104601245219561984.davem@davemloft.net>
 <20150826181926.0444240f@griffin>
 <20150826221330.GB31292@pox.localdomain>
 <CALx6S36+e7O_n+UKvFO89goKoE2QV2EDa5CrzEU9eAoD13e-EQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Benc <jbenc@redhat.com>, David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:35369 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231AbbH0VBB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 17:01:01 -0400
Received: by wicne3 with SMTP id ne3so3682331wic.0
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 14:01:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S36+e7O_n+UKvFO89goKoE2QV2EDa5CrzEU9eAoD13e-EQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/27/15 at 12:47pm, Tom Herbert wrote:
> On Wed, Aug 26, 2015 at 3:13 PM, Thomas Graf <tgraf@suug.ch> wrote:
> > On 08/26/15 at 06:19pm, Jiri Benc wrote:
> >> might be a noise. However, there's definitely room for performance
> >> improvement here, the lwtunnel vxlan throughput is at about ~40% of the
> >> non-vxlan throughput. I did not spend too much time on analyzing this, yet,
> >> but it's clear the dst_entry layout is not our biggest concern here.
> >
> > I'm currently working on reducing the overhead for VXLAN and Gre and
> > effectively Geneve once Pravin's work is in. The main disadvantage
> > of lwt based flow tunneling is the additional fib_lookup() performed
> > for each packet. It seems tempting to cache the tunnel endpoint dst in
> > the lwt state of the overlay route. It will usually point to the same
> > dst for every packet. The cache behaviour if dependant on no fib rules
> > are and the route is a single nexthop route.
> >
> Or set nexthop appropriately. This what we do for ILA. Works great
> without any other dst references, but might put to much weight in the
> administrator to configure nexthop per encapsulating destination.

I assume you mean something like this, right?

        ip route [...] encap vxlan dst 10.1.1.1 dev eth0

The IP metadata encap at FIB level is currently encap agnostic
and requires an intermediate encap device which then defines the
actual encap protocol:

        ip route overlay/prefix encap ip dst 10.1.1.1 dev vxlan0
        ip route 10.1.1.1/prefix dev eth0

I like it because we don't have to embed all the options as metadata
and can still set the through the device. An option would also be
to allow for both and add the following alternative:

        ip route overlay/prefix encap ip type vxlan dst 10.1.1.1 dev eth0
