From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Fri, 4 Dec 2015 22:50:19 -0800
Message-ID: <CAKgT0Ufr9pCKdKR2jVa8UKUXGWQ8_gJv=hxFWnLfQvi6rkT3Cg@mail.gmail.com>
References: <1449259145.6236.458303617.55CF2C4E@webmail.messagingengine.com>
	<20151204.150633.1744714566987717806.davem@davemloft.net>
	<CAKgT0UepW=VehhXncrAM=tvqrVDD_KOdVJBpwEU+hYTAdMz_dg@mail.gmail.com>
	<20151204.235036.1511254463749836388.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Tom Herbert <tom@herbertland.com>,
	John Linville <linville@tuxdriver.com>, jesse@kernel.org,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Netdev <netdev@vger.kernel.org>,
	Kiran Patil <kiran.patil@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:33538 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751718AbbLEGuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 01:50:20 -0500
Received: by igcmv3 with SMTP id mv3so50154641igc.0
        for <netdev@vger.kernel.org>; Fri, 04 Dec 2015 22:50:19 -0800 (PST)
In-Reply-To: <20151204.235036.1511254463749836388.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 4, 2015 at 8:50 PM, David Miller <davem@davemloft.net> wrote:
> From: Alexander Duyck <alexander.duyck@gmail.com>
> Date: Fri, 4 Dec 2015 14:44:00 -0800
>
>> I actually tried to push the generic checksum idea for fm10k back
>> during hardware development but ended up losing that battle.
>
> This chips already have a circuit calculating the 1's complement sum
> over the data as is passed through the FIFO in the RTL, it's merely a
> matter of putting the result it in the descriptor.

Actually it is a bit trickier than that.  The problem is the L4
checksum doesn't include all of the L3 header in the pseudo header.
So in order to add this feature and maintain the current feature you
have to essentially compute two checksums.  One with the pseudo header
and one with the entire L3 header.  In addition there are the fiddly
little details like what to do about VLAN headers since I think they
were included in the checksum if you leave them in the header, but you
have to exclude them if they aren't.  There is also the matter of if
we include the L2 header or not.  Basically there are number of odd
corner cases and such where this really starts to become a pain.

> Relatively speaking, the feature would be almost free.

Right.  I made similar arguments.  The problem is the RTL they have
works, and they don't want to change it unless they have to.  Having a
couple engineers write the RTL, then have some validation engineers
test it, and some driver developer code it up costs money.  In
addition there is risk involved if some flaw slips through one of the
validation efforts resulting in a silicon spin, or even worse if some
flaw ends up being released.

What it comes down to is that from the engineering side we likely
won't be able to influence any change on the hardware design.  We have
to convince the sales and marketing folks for one of the vendors that
implementing this feature would be beneficial to their bottom line if
we want to see any actual change.  Without that impetus there is no
motivation on the vendors side to risk any of their capital trying to
implement a feature that a few of us kernel engineers think would be a
really good idea.

- Alex
