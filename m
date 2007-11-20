From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [PATCH]: Fix WEXT userland corruption on 64-bit
Date: Tue, 20 Nov 2007 03:33:47 -0800 (PST)
Message-ID: <20071120.033347.197068845.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, shaddy_baddah-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


This bug affects WEXT usage on all 64-bit platforms, compat mode or
not.  It overwrites 8 bytes past the end of the userland iwreq.

I've checked the following patch into my net-2.6 tree and will queue
it up for -stable too.

Shaddy, this should fix the "encryption key is too long" iwconfig
issue.

I'll try to figure out why iwlist gets a bus error and
the zd1211rw driver generates all of those unaligned
access errors next.

commit 0a06ea87185531705e4417e3a051f81b64f210c1
Author: David S. Miller <davem-xgOahHnHvIuGfricDzPwBeTW4wlIGRCZ@public.gmane.org>
Date:   Tue Nov 20 03:29:53 2007 -0800

    [WIRELESS] WEXT: Fix userspace corruption on 64-bit.
    
    On 64-bit systems sizeof(struct ifreq) is 8 bytes larger than
    sizeof(struct iwreq).
    
    For GET calls, the wireless extension code copies back into userspace
    using sizeof(struct ifreq) but userspace and elsewhere only allocates
    a "struct iwreq".  Thus, this copy writes past the end of the iwreq
    object and corrupts whatever sits after it in memory.
    
    Fix the copy_to_user() length.
    
    This particularly hurts the compat case because the wireless compat
    code uses compat_alloc_userspace() and right after this allocated
    buffer is the current bottom of the user stack, and that's what gets
    overwritten by the copy_to_user() call.
    
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

diff --git a/net/wireless/wext.c b/net/wireless/wext.c
index 85e5f9d..47e80cc 100644
--- a/net/wireless/wext.c
+++ b/net/wireless/wext.c
@@ -1094,7 +1094,7 @@ int wext_handle_ioctl(struct net *net, struct ifreq *ifr, unsigned int cmd,
 	rtnl_lock();
 	ret = wireless_process_ioctl(net, ifr, cmd);
 	rtnl_unlock();
-	if (IW_IS_GET(cmd) && copy_to_user(arg, ifr, sizeof(struct ifreq)))
+	if (IW_IS_GET(cmd) && copy_to_user(arg, ifr, sizeof(struct iwreq)))
 		return -EFAULT;
 	return ret;
 }
