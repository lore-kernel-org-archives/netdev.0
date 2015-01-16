From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 3/3] genetlink: synchronize socket closing and
 family removal
Date: Fri, 16 Jan 2015 17:20:46 -0500 (EST)
Message-ID: <20150116.172046.1636627616122565664.davem@davemloft.net>
References: <1421404634-8973-1-git-send-email-johannes@sipsolutions.net>
	<1421404634-8973-3-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff.layton@primarydata.com,
	sedat.dilek@gmail.com, johannes.berg@intel.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34304 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751676AbbAPWUs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 17:20:48 -0500
In-Reply-To: <1421404634-8973-3-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Fri, 16 Jan 2015 11:37:14 +0100

> From: Johannes Berg <johannes.berg@intel.com>
> 
> In addition to the problem Jeff Layton reported, I looked at the code
> and reproduced the same warning by subscribing and removing the genl
> family with a socket still open. This is a fairly tricky race which
> originates in the fact that generic netlink allows the family to go
> away while sockets are still open - unlike regular netlink which has
> a module refcount for every open socket so in general this cannot be
> triggered.
> 
> Trying to resolve this issue by the obvious locking isn't possible as
> it will result in deadlocks between unregistration and group unbind
> notification (which incidentally lockdep doesn't find due to the home
> grown locking in the netlink table.)
> 
> To really resolve this, introduce a "closing socket" reference counter
> (for generic netlink only, as it's the only affected family) in the
> core netlink code and use that in generic netlink to wait for all the
> sockets that are being closed at the same time as a generic netlink
> family is removed.
> 
> This fixes the race that when a socket is closed, it will should call
> the unbind, but if the family is removed at the same time the unbind
> will not find it, leading to the warning. The real problem though is
> that in this case the unbind could actually find a new family that is
> registered to have a multicast group with the same ID, and call its
> mcast_unbind() leading to confusing.
> 
> Also remove the warning since it would still trigger, but is now no
> longer a problem.
> 
> This also moves the code in af_netlink.c to before unreferencing the
> module to avoid having the same problem in the normal non-genl case.
> 
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Applied.
