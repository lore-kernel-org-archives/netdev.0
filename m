From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Mon, 30 Nov 2015 22:33:54 -0800
Message-ID: <CAKgT0UdjsLZrmLj2NCwUVEkdNQD57bVaH+QSG=RaaDyJEXgSyg@mail.gmail.com>
References: <CALx6S36vQhx+iKP9VcpqPBnN7VjBsgd_dYFOfZ+YHyVa97-ajA@mail.gmail.com>
	<20151129.222243.2290113258075462913.davem@davemloft.net>
	<C40BE8378EF49C44B9184714DBC8EF2993A70447@ORSMSX115.amr.corp.intel.com>
	<20151130.224843.112081502554527779.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	Tom Herbert <tom@herbertland.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>, jesse@kernel.org,
	Netdev <netdev@vger.kernel.org>,
	Kiran Patil <kiran.patil@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:37099 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbbLAGdz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 01:33:55 -0500
Received: by igcto18 with SMTP id to18so89263893igc.0
        for <netdev@vger.kernel.org>; Mon, 30 Nov 2015 22:33:54 -0800 (PST)
In-Reply-To: <20151130.224843.112081502554527779.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 30, 2015 at 7:48 PM, David Miller <davem@davemloft.net> wrote:
> From: "Singhai, Anjali" <anjali.singhai@intel.com>
> Date: Mon, 30 Nov 2015 21:42:37 +0000
>
>> The reason for receive being different than transmit is, on TX side
>> driver can provide the meta data for where the checksum field is and
>> what is the length that needs to be check summed to the HW on a per
>> packet basis. On Rx the HW parser has to parse the packet to
>> identify the tunnel type and based on that figure out the checksum
>> locations and length in the packet, so definitely HW has to parse
>> the packet and it can parse only based on next header type
>> information or in case of udp tunnels based on udp port mapping to a
>> particular protocol. I am not sure why you say it doesn't need to
>> parse the packet, maybe I am miss- understanding something.
>> Although it's not difficult to reduce protocol ossification on the
>> RX side but it is certainly different and particularly in case of
>> udp-tunnels it needs the port to protocol mapping.
>
> You're just proving more and more why doing anything other than 2's
> complement checksum provision in the RX descriptor is stupid.
>
> Let me know when you guys enter this century.
>
> I'll tell you right now that your arguments are akin to trying to
> climb up a wall which is vertical.  I can assure you that you will not
> reach your destination, so save your self some scratching and clawing
> and accept reality.
>
> Doing anything other than providing 2's complement checksums in the RX
> descriptor doesn't work.  We know this.

While I fully agree that the 2's compliment is the way to go we still
have to deal with all of the legacy hardware out there.  In addition
while the 2's compliment bit works for the checksums what are vendors
expected to do about other offloads that will need to parse inner
headers such as RSS, LRO, or network flow classificiation?  The
problem is that at some point the hardware does need to know how to
parse the tunnel headers for the purposes of doing offloads besides
checksum.

> So we will not add to our core architecture and frameworks anything
> that directly facilitates designs which we know are suboptimal.  And
> protocol specific support for tunnel offloading is suboptimal and not
> the way forward.
>
> I completly agree with Tom, his goals, his vision, and his priorities
> when it comes to handling this stuff.  Don't fight it.

I have to disagree here.  I really feel that going beyond
check-summing what Tom has proposed might be a step backwards.

We end up needing some sort of mechanism for identifying what the
tunnel frames will look like when doing any sort of Rx parsing.  Just
applying a generic offload for everything only really works on things
that are truly generic such as the 2's compliment checksum.  Tom had
mentioned possibly using something like the ntuple/nfc interface.  I
would argue that is kind of the direction this is going in but with a
few flaws.   For example, the notifier probably should pass a pointer
to the udp_port_cfg structure instead of just the family and port.
This way if a given UDP tunnel has IP endpoints it would be possible
to setup an ntuple/nfc style filter rule to only offload that tunnel
instead generically just basing things off of the port and family.

In addition it might be worthwhile to add a type field similar to what
is already in the fou_cfg block to the udp_port_cfg.  It could
probably just be moved from fou_cfg into udp_port_cfg for use by the
other tunnels, you might even move the protocol field while you are at
it.  Then they could be treated as a type of "action" indication to
the drivers that the given attributes will be associated with this
type of tunnel.  I would want to make sure that we give each unique
tunnel type its own value for the "action" so that if for example in
the future someone decided to offload fou, gue, l2tp, or whatever in
hardware they would have a way of identifying the incoming frames as
such and parse the inner headers.

Anyway that is my $0.02 on this.

- Alex
