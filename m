From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 6/6, revised] drivers/net/pppol2tp.c: remove null pointer
 dereference
Date: Mon, 12 May 2008 22:21:25 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0805122220350.27663@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, jchapman@katalix.com,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758728AbYELUVo@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

If session is NULL, it is not possible to access its name field.  So I have
split apart the printing of the error message to drop the printing of the
name field in this case.

The macro PRINTK actually only evaluates its arguments starting with the
third one if the bitwise conjunction of the first two is non-zero.
Normally, this conjunction would only be non-zero if debugging mode were
turned on, but when session is NULL, the first argument in both the old and
new code is -1, and thus the bitwise conjunction is true.  Perhaps a
different strategy is desired, such as using tunnel->debug, which
session->debug is initialized to, but tunnel can also be NULL, so this does
not completely solve the problem.


This problem was found using the following semantic match
(http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@@
expression E, E1;
identifier f;
statement S1,S2,S3;
@@

* if (E == NULL)
{
  ... when != if (E == NULL) S1 else S2
      when != E = E1
* E->f
  ... when any
  return ...;
}
else S3
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---

diff -u -p a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
--- a/drivers/net/pppol2tp.c	2008-05-09 16:46:57.000000000 +0200
+++ b/drivers/net/pppol2tp.c	2008-05-12 15:30:52.000000000 +0200
@@ -1621,9 +1621,16 @@ out_no_ppp:
 end:
 	release_sock(sk);
 
-	if (error != 0)
-		PRINTK(session ? session->debug : -1, PPPOL2TP_MSG_CONTROL, KERN_WARNING,
-		       "%s: connect failed: %d\n", session->name, error);
+	if (error != 0) {
+		if (session)
+			PRINTK(session->debug,
+				PPPOL2TP_MSG_CONTROL, KERN_WARNING,
+				"%s: connect failed: %d\n",
+				session->name, error);
+		else
+			PRINTK(-1, PPPOL2TP_MSG_CONTROL, KERN_WARNING,
+				"connect failed: %d\n", error);
+	}
 
 	return error;
 }
