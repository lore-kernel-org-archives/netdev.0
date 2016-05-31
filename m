From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2 03/10] nl80211: Prefer ether_addr_copy
Date: Tue, 31 May 2016 12:34:47 +0200
Message-ID: <1464690887.3076.24.camel@sipsolutions.net>
References: <cover.1464576022.git.kirtika.ruchandani@gmail.com>
	 <49c03996365360077fe7317d108072c30354b555.1464576022.git.kirtika.ruchandani@gmail.com>
	 <CAGRGNgVRJm3zSokQ2wxb8Kwd4UEzx7ZjRCHAmnA02cB89Usy-A@mail.gmail.com>
	 <CAA-b7a8v8q5VnPxWw+o6Vj96KxeVhgfmZbre8+9rLRcB7-emyg@mail.gmail.com>
	 (sfid-20160530_085018_965596_090D7309)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	Tina Ruchandani <ruchandani.tina@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>,
	Julian Calaby <julian.calaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:40638 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750824AbcEaKeu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 May 2016 06:34:50 -0400
In-Reply-To: <CAA-b7a8v8q5VnPxWw+o6Vj96KxeVhgfmZbre8+9rLRcB7-emyg@mail.gmail.com> (sfid-20160530_085018_965596_090D7309)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> The requirement is to be __aligned(2). I've added 4 instances of
> ether_addr_copy with 8 addresses as arguments.=C2=A0=C2=A0Of these, t=
he 4
> src arguments are really the same type (i.e. nla_data acting on a
> const nlattr*), so I'll try to reason about the 5 total cases below -
> 1. cfg->dst_mac should be 16-bit aligned due to the layout of
> struct cfg80211_wowlan_tcp. Its offset is 10 or 12 bytes in the
> structure depending on the system.

I wouldn't want to rely on that, since internal structures can be
changed pretty easily. If necessary, add __aligned(2) to the struct
members where appropriate.

> 2 and 3. For mac_addr and mac_addr_mask, nl80211_parse_random_mac
> takes these in as u8* (and hence does not guarantee alignment?)
> Both the callers of this function today pass in arguments that are
> explicitly __aligned(2). But this cannot be said of future potential
> callers
> - so perhaps my patch introduces a bug?

That should be documented, but it's also pretty tricky to
review/maintain that.

I general, I don't really see much reason to use ether_addr_copy() in
any of these code paths - it's not really a performance thing (in part
due to the alignment, ether_addr_copy can be faster)

> 4. Based on struct cfg80211_acl_data, acl->mac_addrs[i] should be not
> guaranteed to be __aligned(2).

See above.

> 5. For all the nla_data src arguments, the nla_data function returns
> ((char*) foo + 5) for pointer foo. So likely not __aligned(2).

Those should be aligned since the data is copied into an SKB, and +5
doesn't seem right - nla_data() should be +4.

johannes
