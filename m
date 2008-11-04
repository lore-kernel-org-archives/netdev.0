From: David Miller <davem@davemloft.net>
Subject: Re: xfrm_policy_kill: inconsistent {softirq-on-W} ->
 {in-softirq-W} usage
Date: Mon, 03 Nov 2008 19:12:10 -0800 (PST)
Message-ID: <20081103.191210.149092227.davem@davemloft.net>
References: <490F3C08.6000209@simon.arlott.org.uk>
	<20081103205726.GA3589@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: simon@fire.lp0.eu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39128
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751348AbYKDDMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 22:12:35 -0500
In-Reply-To: <20081103205726.GA3589@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Mon, 3 Nov 2008 23:57:26 +0300

> If it's easily reproducible, try this patch:
> 
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -315,9 +315,9 @@ static void xfrm_policy_kill(struct xfrm_policy *policy)

This looks clearly like the correct fix for this lockdep
warning, so I'm adding it to net-2.6 as follows even though
Simon can't readily test it.

Thanks.

commit bbb770e7ab9a436752babfc8765e422d7481be1f
Author: Alexey Dobriyan <adobriyan@gmail.com>
Date:   Mon Nov 3 19:11:29 2008 -0800

    xfrm: Fix xfrm_policy_gc_lock handling.
    
    From: Alexey Dobriyan <adobriyan@gmail.com>
    
    Based upon a lockdep trace by Simon Arlott.
    
    xfrm_policy_kill() can be called from both BH and
    non-BH contexts, so we have to grab xfrm_policy_gc_lock
    with BH disabling.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 2587274..058f04f 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -315,9 +315,9 @@ static void xfrm_policy_kill(struct xfrm_policy *policy)
 		return;
 	}
 
-	spin_lock(&xfrm_policy_gc_lock);
+	spin_lock_bh(&xfrm_policy_gc_lock);
 	hlist_add_head(&policy->bydst, &xfrm_policy_gc_list);
-	spin_unlock(&xfrm_policy_gc_lock);
+	spin_unlock_bh(&xfrm_policy_gc_lock);
 
 	schedule_work(&xfrm_policy_gc_work);
 }
