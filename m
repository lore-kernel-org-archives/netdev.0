From: Kees Cook <kees.cook@canonical.com>
Subject: [PATCH] wireless: fix 64K kernel heap content leak via ioctl
Date: Fri, 27 Aug 2010 14:02:41 -0700
Message-ID: <20100827210240.GC4703@outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Joe Perches <joe@perches.com>, Jean Tourrilhes <jt@hpl.hp.com>,
	Tejun Heo <tj@kernel.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This problem was originally tracked down by Brad Spengler.

When calling wireless ioctls, if a driver does not correctly
validate/shrink iwp->length, the resulting copy_to_user can leak up to
64K of kernel heap contents.

It seems that this is triggerable[1] in 2.6.32 at least on ath5k, but
I was not able to track down how. The twisty maze of ioctl handlers
stumped me. :) Other drivers I checked did not appear to have any problems,
but the potential remains. I'm not sure if this patch is the right approach;
it was fixed differently[2] in grsecurity.

[1] http://forums.grsecurity.net/viewtopic.php?f=3&t=2290&start=0
[2] http://grsecurity.net/~spender/wireless-infoleak-fix2.patch

Reported-by: Brad Spengler <spender@grsecurity.net>
Signed-off-by: Kees Cook <kees.cook@canonical.com>
---
 include/net/iw_handler.h |    1 -
 net/wireless/wext-core.c |   26 ++------------------------
 2 files changed, 2 insertions(+), 25 deletions(-)

diff --git a/include/net/iw_handler.h b/include/net/iw_handler.h
index 3afdb21..6c81f29 100644
--- a/include/net/iw_handler.h
+++ b/include/net/iw_handler.h
@@ -277,7 +277,6 @@
 #define IW_DESCR_FLAG_EVENT	0x0002	/* Generate an event on SET */
 #define IW_DESCR_FLAG_RESTRICT	0x0004	/* GET : request is ROOT only */
 				/* SET : Omit payload from generated iwevent */
-#define IW_DESCR_FLAG_NOMAX	0x0008	/* GET : no limit on request size */
 /* Driver level flags */
 #define IW_DESCR_FLAG_WAIT	0x0100	/* Wait for driver event */
 
diff --git a/net/wireless/wext-core.c b/net/wireless/wext-core.c
index 0ef17bc..55b1fd9 100644
--- a/net/wireless/wext-core.c
+++ b/net/wireless/wext-core.c
@@ -82,7 +82,6 @@ static const struct iw_ioctl_description standard_ioctl[] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= sizeof(struct iw_priv_args),
 		.max_tokens	= 16,
-		.flags		= IW_DESCR_FLAG_NOMAX,
 	},
 	[IW_IOCTL_IDX(SIOCSIWSTATS)] = {
 		.header_type	= IW_HEADER_TYPE_NULL,
@@ -134,7 +133,6 @@ static const struct iw_ioctl_description standard_ioctl[] = {
 		.token_size	= sizeof(struct sockaddr) +
 				  sizeof(struct iw_quality),
 		.max_tokens	= IW_MAX_AP,
-		.flags		= IW_DESCR_FLAG_NOMAX,
 	},
 	[IW_IOCTL_IDX(SIOCSIWSCAN)] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
@@ -146,7 +144,6 @@ static const struct iw_ioctl_description standard_ioctl[] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= 1,
 		.max_tokens	= IW_SCAN_MAX_DATA,
-		.flags		= IW_DESCR_FLAG_NOMAX,
 	},
 	[IW_IOCTL_IDX(SIOCSIWESSID)] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
@@ -737,28 +734,9 @@ static int ioctl_standard_iw_point(struct iw_point *iwp, unsigned int cmd,
 			return -EFAULT;
 		/* Save user space buffer size for checking */
 		user_length = iwp->length;
-
-		/* Don't check if user_length > max to allow forward
-		 * compatibility. The test user_length < min is
-		 * implied by the test at the end.
-		 */
-
-		/* Support for very large requests */
-		if ((descr->flags & IW_DESCR_FLAG_NOMAX) &&
-		    (user_length > descr->max_tokens)) {
-			/* Allow userspace to GET more than max so
-			 * we can support any size GET requests.
-			 * There is still a limit : -ENOMEM.
-			 */
-			extra_size = user_length * descr->token_size;
-
-			/* Note : user_length is originally a __u16,
-			 * and token_size is controlled by us,
-			 * so extra_size won't get negative and
-			 * won't overflow...
-			 */
-		}
 	}
+	/* Support for very large requests */
+	extra_size = max(extra_size, iwp->length * descr->token_size);
 
 	/* kzalloc() ensures NULL-termination for essid_compat. */
 	extra = kzalloc(extra_size, GFP_KERNEL);
-- 
1.7.1


-- 
Kees Cook
Ubuntu Security Team
