From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: [PATCH v2] carl9170: Remove redundant protection check
Date: Sat, 23 Aug 2014 03:36:21 +0200
Message-ID: <1605815.Y77AiltE7C@debian64>
References: <20140822191431.GA5827@ada> <1931285.KsvFbLZH2Q@debian64> <1408749799.5604.38.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Andreea-Cristina Bernat <bernat.ada@gmail.com>,
	linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	paulmck@linux.vnet.ibm.com, j@w1.fi
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:57174 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751653AbaHWBg1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 21:36:27 -0400
In-Reply-To: <1408749799.5604.38.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, August 22, 2014 04:23:19 PM Eric Dumazet wrote:
> On Fri, 2014-08-22 at 23:53 +0200, Christian Lamparter wrote:
> 
> > The sta_info->agg[tid] check is not needed (for reference, see [0]).
> > (There is already a check in mac80211 which prevents the leak of
> > sta_info->agg[tid] [1]).
> > 
> > Regards
> > Christian
> > 
> > [0] <https://lkml.org/lkml/2014/8/20/725>
> > [1] <http://lxr.free-electrons.com/source/net/mac80211/agg-tx.c#L583>
> > 
> 
> Hmpfff... this code is quite confusing. 
That's true. Furthermore, parts of the logic are also embedded in
the mac80211-stack and above. So, it's very hard to see the whole
big picture, just by looking at the driver code.

> RCU is used both in tricky way (carl9170_ampdu_gc() is an example)
> and a talisman (the part you remove)
I know that game ;-). But fair enough: if you have concerns about
the complexity of the code in question: I'm willing to help you
and explain the quirks in detail if necessary. I think this is a
valuable addition, since "external consultants" are hard to come
by.

> Why is rcu_assign_pointer(sta_info->agg[tid], tid_info);
> done inside the spinlock protected region, I don't know.
The pointer in sta_info->agg[tid] is used exclusively by 
the tx.c code... It is queried only if an outgoing frame
has the IEEE80211_TX_CTL_AMPDU flag set. 

But for this flag to be set, the aggregation session has
to be operational. This requires two calls to ampdu_action [0].
(first with: IEEE80211_AMPDU_TX_START and later with:
IEEE80211_AMPDU_TX_OPERATIONAL).

=> If you want to make a patch to move this rcu_assign_pointer(...)
after the spin_unlock_bh() - Then: Yes, GO FOR IT!
 
> If this code relies on external protection, a comment would help its
> comprehension for sure.
> 
> For example, you could add a 
> BUG_ON(rcu_access_pointer(sta_info->agg[tid]));
> so that we are sure requirements are not changed
> in the callers one day.
Maybe, but then: Is a "specific driver" the right place for this?
Other drivers may also depend on ampdu_action not changing.
As for the logic: The AMPDU handshake itself is part of the 802.11
spec. If you are interested you can get 802.11-2012 [1] and look 
into Section 9.21 "Block Acknowledgment". It contains a message
sequence chart and details about the setup and tear down procedures
for aggregation session [which is at the heart of the ampdu_action
callback issue].

Note: mac80211 has a "software simulator" mac80211_hwsim [2].
It can be (and is) used to test most of the mac80211 functionality.
So what do you think?

Regards
Christian 

[0] <https://www.kernel.org/doc/htmldocs/80211/aggregation.html>
[1] <http://standards.ieee.org/findstds/standard/802.11-2012.html>
[2] <http://wireless.kernel.org/en/users/Drivers/mac80211_hwsim>
