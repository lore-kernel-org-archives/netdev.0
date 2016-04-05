From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [RFC PATCH 3/6] ppp: don't lock ppp_mutex while handling PPPIOCDETACH
Date: Tue, 5 Apr 2016 02:56:25 +0200
Message-ID: <df33707939a7caaad78548b76e08916624b11741.1459807527.git.g.nault@alphalink.fr>
References: <cover.1459807527.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-ppp@vger.kernel.org, Paul Mackerras <paulus@samba.org>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1459807527.git.g.nault@alphalink.fr>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Once set, file->private_data remains constant. So it's safe to access
it without holding ppp_mutex.
The PPP unit fields accessed while handling PPPIOCDETACH (pf->kind and
ppp->owner) are also constant and have been set before
file->private_data got assigned. So these too can be read without
holding ppp_mutex.
Finally, ppp_release() is called only if we're the only user of the
unit.

Therefore, we can avoid locking ppp_mutex completely for handling
PPPIOCDETACH. This removes locking dependency between ppp_mutex and
rtnl_mutex, which will allow holding ppp_mutex from an rtnetlink
context.

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 drivers/net/ppp/ppp_generic.c | 21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 7329c72..c81e257 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -592,15 +592,11 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 					    cmd, arg);
 	}
 
-	mutex_lock(&ppp_mutex);
-
-	pf = file->private_data;
-	if (!pf) {
-		err = -ENOTTY;
-		goto out;
-	}
-
 	if (cmd == PPPIOCDETACH) {
+		pf = file->private_data;
+		if (!pf)
+			return -ENOTTY;
+
 		/*
 		 * We have to be careful here... if the file descriptor
 		 * has been dup'd, we could have another process in the
@@ -626,6 +622,15 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		} else
 			pr_warn("PPPIOCDETACH file->f_count=%ld\n",
 				atomic_long_read(&file->f_count));
+
+		return err;
+	}
+
+	mutex_lock(&ppp_mutex);
+
+	pf = file->private_data;
+	if (!pf) {
+		err = -ENOTTY;
 		goto out;
 	}
 
-- 
2.8.0.rc3

