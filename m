From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2.6.28 1/1] cxgb3 - fix race in EEH
Date: Thu, 2 Oct 2008 18:00:11 -0700
Message-ID: <20081002180011.16254a4e.akpm@linux-foundation.org>
References: <20080926000528.11959.63712.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49541 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753906AbYJCBA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 21:00:26 -0400
In-Reply-To: <20080926000528.11959.63712.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Sep 2008 17:05:28 -0700
Divy Le Ray <divy@chelsio.com> wrote:

> A SGE queue set timer might access registers while in EEH recovery,
> triggering an EEH error loop. Stop all timers early in EEH process.

<looks>

It's deeply weird that t3_reset_qset() does

	memset(&q->tx_reclaim_timer, 0, sizeof(q->tx_reclaim_timer));

There are lots of things in the timer_list which the driver has no
business modifying.  For example, this might break the metadata in
Thomas's debugobjects stuff, which attempts to catch things being done
in the wrong order (I don't think it will, but still...).

Rerunning init_timer() should repair the damage, but I suspect a simple

	q->tx_reclaim_timer.function = NULL;	/* explanation goes here */

would suffice here.


t3_sge_alloc_qset() could use the newer setup_timer().
