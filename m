From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next] route: fix breakage after moving lwtunnel state
Date: Thu, 27 Aug 2015 14:20:15 -0700
Message-ID: <CALx6S35+g1WG9AERJ5p9Fx41fXvBAdSf9YDjYW0wgAjtgdq2XQ@mail.gmail.com>
References: <a80cafb781c91314f90613c3e7d2ed4268eb4f06.1440153500.git.jbenc@redhat.com>
	<20150823.165103.2104601245219561984.davem@davemloft.net>
	<20150826181926.0444240f@griffin>
	<20150826221330.GB31292@pox.localdomain>
	<CALx6S36+e7O_n+UKvFO89goKoE2QV2EDa5CrzEU9eAoD13e-EQ@mail.gmail.com>
	<20150827210058.GB32206@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Benc <jbenc@redhat.com>, David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:32999 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625AbbH0VUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 17:20:16 -0400
Received: by iods203 with SMTP id s203so72553286iod.0
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 14:20:15 -0700 (PDT)
In-Reply-To: <20150827210058.GB32206@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 27, 2015 at 2:00 PM, Thomas Graf <tgraf@suug.ch> wrote:
> On 08/27/15 at 12:47pm, Tom Herbert wrote:
>> On Wed, Aug 26, 2015 at 3:13 PM, Thomas Graf <tgraf@suug.ch> wrote:
>> > On 08/26/15 at 06:19pm, Jiri Benc wrote:
>> >> might be a noise. However, there's definitely room for performance
>> >> improvement here, the lwtunnel vxlan throughput is at about ~40% of the
>> >> non-vxlan throughput. I did not spend too much time on analyzing this, yet,
>> >> but it's clear the dst_entry layout is not our biggest concern here.
>> >
>> > I'm currently working on reducing the overhead for VXLAN and Gre and
>> > effectively Geneve once Pravin's work is in. The main disadvantage
>> > of lwt based flow tunneling is the additional fib_lookup() performed
>> > for each packet. It seems tempting to cache the tunnel endpoint dst in
>> > the lwt state of the overlay route. It will usually point to the same
>> > dst for every packet. The cache behaviour if dependant on no fib rules
>> > are and the route is a single nexthop route.
>> >
>> Or set nexthop appropriately. This what we do for ILA. Works great
>> without any other dst references, but might put to much weight in the
>> administrator to configure nexthop per encapsulating destination.
>
> I assume you mean something like this, right?
>
>         ip route [...] encap vxlan dst 10.1.1.1 dev eth0
>
I'm doing:

ip route add 3333:0:0:1:5555:0:2:0/128 encap ila 2001:0:0:2 via
2401:db00:20:911a:face:0:27:0

so that 2401:db00:20:911a:face:0:27:0 is the next hop route for
destination 2001:0:0:2:5555:0:2:0. The dst_output for lwt just calls
the original dest_output after transforming the packet without the use
of any additional routes. So in this way ILA LWT is just acting as a
"pass-through" packet transformation mechanism. Such a model might
have additional utility: LWT occurs before iptables so that iptables
sees the translated or encapsulated packet (davem mentioned this is
probably what we want), we may want to defer translation until IP
fragmentation (Roopa mentioned she needs this for MPLS).

> The IP metadata encap at FIB level is currently encap agnostic
> and requires an intermediate encap device which then defines the
> actual encap protocol:
>
>         ip route overlay/prefix encap ip dst 10.1.1.1 dev vxlan0
>         ip route 10.1.1.1/prefix dev eth0
>
But then your outputting through another device, multiple routes are
involved, performance drops :-( What not just set the route through
VXLAN in that case?

> I like it because we don't have to embed all the options as metadata
> and can still set the through the device. An option would also be
> to allow for both and add the following alternative:
>
>         ip route overlay/prefix encap ip type vxlan dst 10.1.1.1 dev eth0

Better, we should be able to send encapsulated packets with needing a device.

Tom
