From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] bridge: disable softirqs around br_fdb_update
 to avoid lockup
Date: Sun, 07 Jun 2015 19:45:12 -0700 (PDT)
Message-ID: <20150607.194512.2301839969251363199.davem@davemloft.net>
References: <1433490777-22880-1-git-send-email-nikolay@cumulusnetworks.com>
	<1433598540-13814-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wkok@cumulusnetworks.com,
	stephen@networkplumber.org
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49464 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751081AbbFHCpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2015 22:45:13 -0400
In-Reply-To: <1433598540-13814-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Sat,  6 Jun 2015 06:49:00 -0700

> br_fdb_update() can be called in process context in the following way:
> br_fdb_add() -> __br_fdb_add() -> br_fdb_update() (if NTF_USE flag is set)
> so we need to disable softirqs because there are softirq users of the
> hash_lock. One easy way to reproduce this is to modify the bridge utility
> to set NTF_USE, enable stp and then set maxageing to a low value so
> br_fdb_cleanup() is called frequently and then just add new entries in
> a loop. This happens because br_fdb_cleanup() is called from timer/softirq
> context. The spin locks in br_fdb_update were _bh before commit f8ae737deea1
> ("[BRIDGE]: forwarding remove unneeded preempt and bh diasables")
> and at the time that commit was correct because br_fdb_update() couldn't be
> called from process context, but that changed after commit:
> 292d1398983f ("bridge: add NTF_USE support")
> Using local_bh_disable/enable around br_fdb_update() allows us to keep
> using the spin_lock/unlock in br_fdb_update for the fast-path.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Fixes: 292d1398983f ("bridge: add NTF_USE support")
> ---
> v2: new patch, uses local_bh_disable/enable instead of _bh variant
>     of spinlocks to keep the fast-path optimization. Please drop
>     "bridge: use _bh spinlock variant for br_fdb_update to avoid lockup"
>     in favor of this one.

Ok, I accidently applied v1, so I reverted that and applied and queued
this one instead for -stable.

Thanks.
