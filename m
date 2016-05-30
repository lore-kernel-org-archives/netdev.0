From: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>
Subject: Re: [PATCH v2 03/10] nl80211: Prefer ether_addr_copy
Date: Sun, 29 May 2016 23:50:18 -0700
Message-ID: <CAA-b7a8v8q5VnPxWw+o6Vj96KxeVhgfmZbre8+9rLRcB7-emyg@mail.gmail.com>
References: <cover.1464576022.git.kirtika.ruchandani@gmail.com>
	<49c03996365360077fe7317d108072c30354b555.1464576022.git.kirtika.ruchandani@gmail.com>
	<CAGRGNgVRJm3zSokQ2wxb8Kwd4UEzx7ZjRCHAmnA02cB89Usy-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Johannes Berg <johannes@sipsolutions.net>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Tina Ruchandani <ruchandani.tina@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Julian Calaby <julian.calaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f51.google.com ([209.85.215.51]:36426 "EHLO
	mail-lf0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753988AbcE3GuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2016 02:50:20 -0400
In-Reply-To: <CAGRGNgVRJm3zSokQ2wxb8Kwd4UEzx7ZjRCHAmnA02cB89Usy-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This looks right to me, but doesn't ether_addr_copy() have alignment
> requirements? Could someone more familiar with that review these
> changes to ensure they're met?

Thanks for catching this.
The requirement is to be __aligned(2). I've added 4 instances of
ether_addr_copy with 8 addresses as arguments.  Of these, the 4
src arguments are really the same type (i.e. nla_data acting on a
const nlattr*), so I'll try to reason about the 5 total cases below -
1. cfg->dst_mac should be 16-bit aligned due to the layout of
struct cfg80211_wowlan_tcp. Its offset is 10 or 12 bytes in the
structure depending on the system.
2 and 3. For mac_addr and mac_addr_mask, nl80211_parse_random_mac
takes these in as u8* (and hence does not guarantee alignment?)
Both the callers of this function today pass in arguments that are
explicitly __aligned(2). But this cannot be said of future potential callers
- so perhaps my patch introduces a bug?
4. Based on struct cfg80211_acl_data, acl->mac_addrs[i] should be not
guaranteed to be __aligned(2).
5. For all the nla_data src arguments, the nla_data function returns
((char*) foo + 5) for pointer foo. So likely not __aligned(2).

Based on 3, 4 and 5, this patch should be revoked, but it would be nice
to have a confirmation from someone else.
