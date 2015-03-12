From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next 0/4] bonding work-queues, try_rtnl() &
 notifications
Date: Thu, 12 Mar 2015 15:20:23 -0400 (EDT)
Message-ID: <20150312.152023.288579610581649568.davem@redhat.com>
References: <1426139673-26995-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, andy@greyhouse.net, vfalico@gmail.com,
	nikolay@redhat.com, maze@google.com, netdev@vger.kernel.org,
	edumazet@google.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56658 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755083AbbCLTUd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Mar 2015 15:20:33 -0400
In-Reply-To: <1426139673-26995-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Wed, 11 Mar 2015 22:54:33 -0700

> This patch series tries to address the issue discovered in various work-
> queues and the way these handlers deal with the RTNL. Especially for 
> notification handling. If RTNL can not be acquired, these handlers ignore
> sending notifications and just re-arm the timer. This could be very 
> problematic if the re-arm timer has larger value (e.g. in minutes).

Any timeout selected is completely arbitrary, and if the RTNL semaphore
is really being held for a non-trivial amount of time, you're going to
just thrash and potentially even steal cycles and cache lines from
the thing that's taking so long.

Please do something more sane, perhaps similar to the
netdev_run_todo() function which is invoked at rtnl_unlock() time.

You'll need a different synchronization scheme that that which
netdev_run_todo() uses, but that shouldn't be too hard.

This way, when the RTNL mutex is dropped your notifications will get
generated promptly, and without all of the thrashing side-effects
and arbitrary timeouts.

Thanks.
