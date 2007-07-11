From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 8736] New: New TC deadlock scenario
Date: Wed, 11 Jul 2007 20:31:12 +0200
Message-ID: <469521F0.1010803@trash.net>
References: <bug-8736-10286@http.bugzilla.kernel.org/> <20070711111803.f8f97d98.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@kernel-bugs.osdl.org>
To: ranko@spidernet.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59333 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755311AbXGKSbP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 14:31:15 -0400
In-Reply-To: <20070711111803.f8f97d98.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
>>http://bugzilla.kernel.org/show_bug.cgi?id=8736
>>
>>Here is another scenario I bumped onto - qdisc_watchdog_cancel() and
>>qdisc_restart() deadlock.
>>
>>CPU#0
>>qdisc_watchdog() fires and gets dev->queue_lock
>>qdisc_run()...qdisc_restart()... 
>>-> releases dev->queue_lock and enters dev_hard_start_xmit()
>>
>>CPU#1
>>tc del qdisc dev ...
>>qdisc_graft()...dev_graft_qdisc()...dev_deactivate()...
>>-> grabs dev->queue_lock ... 
>>qdisc_reset()...{cbq,hfsc,htb,netem,tbf}_reset()...qdisc_watchdog_cancel()...
>>-> hrtimer_cancel() - waiting for the qdisc_watchdog() to exit, while still
>>holding dev->queue_lock
>>
>>CPU#0
>>dev_hard_start_xmit() returns ... 
>>-> wants to get dev->queue_lock(!)
>>
>>DEADLOCK!


Good catch.

Please try reverting commit 1936502d00ae6c2aa3931c42f6cf54afaba094f2,
that should fix it.

