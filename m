From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] net: Fix references to out-of-scope variables in
 put_cmsg_compat()
Date: Sun, 22 Jul 2012 23:37:20 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1207222335200.31033@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In net/compat.c::put_cmsg_compat() we may assign 'data' the address of
either the 'ctv' or 'cts' local variables inside the 'if
(!COMPAT_USE_64BIT_TIME)' branch.

Those variables go out of scope at the end of the 'if' statement, so
when we use 'data' further down in 'copy_to_user(CMSG_COMPAT_DATA(cm),
data, cmlen - sizeof(struct compat_cmsghdr))' there's no telling what
it may be refering to - not good.

Fix the problem by simply giving 'ctv' and 'cts' function scope.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 net/compat.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/compat.c b/net/compat.c
index 1b96281..74ed1d7 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -221,6 +221,8 @@ int put_cmsg_compat(struct msghdr *kmsg, int level, int type, int len, void *dat
 {
 	struct compat_cmsghdr __user *cm = (struct compat_cmsghdr __user *) kmsg->msg_control;
 	struct compat_cmsghdr cmhdr;
+	struct compat_timeval ctv;
+	struct compat_timespec cts[3];
 	int cmlen;
 
 	if (cm == NULL || kmsg->msg_controllen < sizeof(*cm)) {
@@ -229,8 +231,6 @@ int put_cmsg_compat(struct msghdr *kmsg, int level, int type, int len, void *dat
 	}
 
 	if (!COMPAT_USE_64BIT_TIME) {
-		struct compat_timeval ctv;
-		struct compat_timespec cts[3];
 		if (level == SOL_SOCKET && type == SCM_TIMESTAMP) {
 			struct timeval *tv = (struct timeval *)data;
 			ctv.tv_sec = tv->tv_sec;
-- 
1.7.11.2


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
