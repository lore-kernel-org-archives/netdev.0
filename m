From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] Remove unnecessary locks from rtnetlink
Date: Tue, 05 Feb 2008 17:53:37 -0800 (PST)
Message-ID: <20080205.175337.266368079.davem@davemloft.net>
References: <12018820194128-git-send-email-panther@balabit.hu>
	<12018820542721-git-send-email-panther@balabit.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: panther@balabit.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33163
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759362AbYBFBxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 20:53:08 -0500
In-Reply-To: <12018820542721-git-send-email-panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Laszlo Attila Toth <panther@balabit.hu>
Date: Fri,  1 Feb 2008 17:07:33 +0100

> The do_setlink() function is protected by rtnl, additional locks are unnecessary.
> and the set_operstate() function is called from protected parts. Locks removed
> from both functions.
> 
> The set_operstate() is also called from rtnl_create_link() and from no other places.
> In rtnl_create_link() none of the changes is protected by set_lock_bh() except
> inside set_operstate(), different locking scheme is not necessary
> for the operstate.
> 
> Signed-off-by: Laszlo Attila Toth <panther@balabit.hu>

The protection using dev_base_lock() is needed.

When analyzing cases like this you need to also look at other code
paths outside of rtnetlink that access ->operstate and ->link_mode,
you obviously didn't do this.

For example, net/core/net-sysfs.c takes a read lock on dev_base_lock
in order to fetch a stable copy of both netif_running() and
dev->operstate at the same time.

Similar write locking to protect dev->operstate is made by
net/core/link_watch.c:rfc2863_policy(), for the same reason rtnetlink
has to make this locking.

You therefore cannot remove it.

This invalidates your second patch so I'm dropping that as well.
