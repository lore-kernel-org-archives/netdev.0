From: Eugene Surovegin <ebs@ebshome.net>
Subject: [IPSEC] add missing flow_cache_genid update to xfrm_policy_delete()
Date: Thu, 5 Aug 2004 00:14:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040805071459.GA31551@gate.ebshome.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi!

I think there is a missing atomic_inc(&flow_cache_genid) in 
xfrm_policy.c::xfrm_policy_delete().

We were experiencing system lockups I think I tracked down to the stale 
xfrm policy in the flow cache. 

Here is our scenario:

policy timer expired -> xfrm_policy_timer() -> xfrm_policy_delete() -> 
xfrm_policy_kill() (here policy->dead is set to 1).

Note that none of these calls increment flow_cache_genid.

Some time later xfrm_lookup() is called (in my case it happened in softirq 
context). flow_cache_lookup() returns policy from the flow cache (i.e. 
resolver xfrm_policy_lookup() is NOT called) and this policy happens to be 
the one previously killed (i.e. dead == 1). This will cause infinite loop 
in xfrm_lookup().

Attached patch is against recent 2.6 BK, although I debugged this problem 
on 2.4 + IPSec backport. From quick look 2.6 still needs this fix (but I 
couldn't test 2.6 on our hw).

Also, I think xfrm_sk_policy_insert() doesn't require similar change, but 
I'm not 100% sure. Could IPSec gurus confirm this? 

Signed-off-by: Eugene Surovegin <ebs@ebshome.net>

===== net/xfrm/xfrm_policy.c 1.52 vs edited =====
--- 1.52/net/xfrm/xfrm_policy.c	2004-07-23 13:23:33 -07:00
+++ edited/net/xfrm/xfrm_policy.c	2004-08-04 18:18:45 -07:00
@@ -536,8 +536,10 @@
 	write_lock_bh(&xfrm_policy_lock);
 	pol = __xfrm_policy_unlink(pol, dir);
 	write_unlock_bh(&xfrm_policy_lock);
-	if (pol)
+	if (pol){
+		atomic_inc(&flow_cache_genid);
 		xfrm_policy_kill(pol);
+	}	
 }
 
 int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol)
