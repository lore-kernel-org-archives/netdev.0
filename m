From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH] - vxlan: gro not effective for intel 82599
Date: Fri, 26 Jun 2015 10:24:46 -0700
Message-ID: <CALx6S34F1WTH=+2LZT483KAi3CC5uK3aniTHuufi=gzch-b6vQ@mail.gmail.com>
References: <5981772fe36e64f8fec5997a4c7aa08f@imap.linux.ibm.com>
	<CALx6S36JQaPg9Otg4pv5ah16JGaEXzo1xDL4jXKBdziUTVvXmw@mail.gmail.com>
	<0b2eff60824ac7b7d3a672da9be9bf99@imap.linux.ibm.com>
	<CALx6S35o-KgViFy6dU5FXA=B2wCJFQjaGPxp22MMhUWP94ZS=A@mail.gmail.com>
	<1435295749.4110.51.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ramu Ramamurthy <sramamur@linux.vnet.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Jiri Benc <jbenc@redhat.com>, James Morris <jmorris@namei.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	pradeeps@linux.vnet.ibm.com, J Kidambi <jkidambi@us.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:36911 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751717AbbFZRYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 13:24:47 -0400
Received: by igblr2 with SMTP id lr2so17817912igb.0
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2015 10:24:47 -0700 (PDT)
In-Reply-To: <1435295749.4110.51.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 25, 2015 at 10:15 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2015-06-25 at 19:57 -0700, Tom Herbert wrote:
>
>> That may be, but this change would affect all uses of GRO with UDP
>> encapsulation not just for intel 10G NICs. For instance, pushing a lot
>> of checksum calculation into the napi for a single queue device could
>> overwhelm the corresponding CPU-- this is the motivation for the
>> restriction in the first place. We need to do a little more diligence
>> here.
>
> We made the choice of computing checksums years ago when GRO was enabled
> for GRE packets, as many NIC are not able to validate TCP checksums with
> this configuration.
>
But we only started computed checksums for GRE in the device napi with
Jerry's patch:

commit bf5a755f5e9186406bbf50f4087100af5bd68e40
Author: Jerry Chu <hkchu@google.com>
Date:   Tue Jan 7 10:23:19 2014 -0800

    net-gre-gro: Add GRE support to the GRO stack

Or's patch to support GRO for UDP encapsulation which included a check
for checksum complete was accepted a mere 13 days later :-)

We have the option of performing GRO at the tunnel interface and that
is good if we need to do checksum calculation since it is post packet
steering and could heat up cache for an application. If we remove the
checksum check in the udp_gro_receive then the only way to push the
GRO to be done in the tunnel interface would be to disable GRO for
everyone on the Ethernet device. I suspect Ramu's results are without
GRO enabled on the tunnel interface and getting no GRO at all can be
very expensive of course.

Anyway, I am looking at solutions and trying to repro the results.

Tom








> Sure, in some cases this can increase load on softirq handlers, but
> there are some ways to spread load on multi queue NIC.
>
>
