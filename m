From: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [patch] sunrpc: silence uninitialized variable warning
Date: Sun, 19 Feb 2017 00:34:59 +0300
Message-ID: <20170218213459.GA32320@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Anna Schumaker <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
        "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
        Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

kstrtouint() can return a couple different error codes so the check for
"ret == -EINVAL" is wrong and static analysis tools correctly complain
that we can use "num" without initializing it.  It's not super harmful
because we check the bounds.  But it's also easy enough to fix.

Signed-off-by: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 956c7bce80d1..311ce92384b7 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -3209,7 +3209,9 @@ static int param_set_uint_minmax(const char *val,
 	if (!val)
 		return -EINVAL;
 	ret = kstrtouint(val, 0, &num);
-	if (ret == -EINVAL || num < min || num > max)
+	if (ret)
+		return ret;
+	if (num < min || num > max)
 		return -EINVAL;
 	*((unsigned int *)kp->arg) = num;
 	return 0;
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
