From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] wireless: fix 64K kernel heap content leak via ioctl
Date: Mon, 30 Aug 2010 10:47:38 +0200
Message-ID: <1283158058.3691.10.camel@jlt3.sipsolutions.net>
References: <20100827210240.GC4703@outflux.net>
	 <20100827212254.GB32275@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kees Cook <kees.cook@canonical.com>, linux-kernel@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Joe Perches <joe@perches.com>, Tejun Heo <tj@kernel.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: jt@hpl.hp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100827212254.GB32275@bougret.hpl.hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2010-08-27 at 14:22 -0700, Jean Tourrilhes wrote:

> 	Would you mind validating the following patch ? I've just
> verified that it compiles and I believe it does what you are asking in
> a much more predictable way.
> 	Regards,


> @@ -800,9 +800,12 @@ static int ioctl_standard_iw_point(struc
>                         goto out;
>                 }
>  
> -               if (copy_to_user(iwp->pointer, extra,
> -                                iwp->length *
> -                                descr->token_size)) {
> +               /* Verify how much we should return. Some driver
> +                * may abuse iwp->length... */
> +               if((iwp->length * descr->token_size) < extra_size)
> +                       extra_size = iwp->length * descr->token_size;
> +
> +               if (copy_to_user(iwp->pointer, extra, extra_size)) {
>                         err = -EFAULT;
>                         goto out;

Based on the code _before_ this hunk, I believe this patch to be wrong
(the goto out matches):

        /* If we have something to return to the user */
        if (!err && IW_IS_GET(cmd)) {
                /* Check if there is enough buffer up there */
                if (user_length < iwp->length) {
                        err = -E2BIG;
                        goto out;
                }

Thus, apparently drivers were intended to be allowed to return more
information than userspace had allocated space for (which also matches
the initial extra_size calculation in this function), so your comment is
wrong, and your check is also wrong because you actually put the burden
on the driver, contrary to the apparent intention of this code.

I believe the below patch is a much better fix as it allows the -E2BIG
code path to be invoked which is more informative to users than
truncated information (which, in your code, may even be truncated in the
middle of a token!!)

johannes

---
 net/wireless/wext-core.c |   23 ++++++++++-------------
 1 file changed, 10 insertions(+), 13 deletions(-)

--- wireless-testing.orig/net/wireless/wext-core.c	2010-08-30 10:35:33.000000000 +0200
+++ wireless-testing/net/wireless/wext-core.c	2010-08-30 10:46:45.000000000 +0200
@@ -738,26 +738,23 @@ static int ioctl_standard_iw_point(struc
 		/* Save user space buffer size for checking */
 		user_length = iwp->length;
 
-		/* Don't check if user_length > max to allow forward
-		 * compatibility. The test user_length < min is
-		 * implied by the test at the end.
-		 */
-
 		/* Support for very large requests */
-		if ((descr->flags & IW_DESCR_FLAG_NOMAX) &&
-		    (user_length > descr->max_tokens)) {
+		if (descr->flags & IW_DESCR_FLAG_NOMAX) {
 			/* Allow userspace to GET more than max so
 			 * we can support any size GET requests.
-			 * There is still a limit : -ENOMEM.
-			 */
-			extra_size = user_length * descr->token_size;
-
-			/* Note : user_length is originally a __u16,
+			 * There is still a limit: 64k records of
+			 * token_size (since a u16 is used).
+			 *
+			 * Note: user_length is originally a u16,
 			 * and token_size is controlled by us,
 			 * so extra_size won't get negative and
 			 * won't overflow...
 			 */
-		}
+			if (user_length > descr->max_tokens) {
+				extra_size = user_length * descr->token_size;
+		} else
+			user_length = min_t(int, user_length,
+						 descr->max_tokens);
 	}
 
 	/* kzalloc() ensures NULL-termination for essid_compat. */
