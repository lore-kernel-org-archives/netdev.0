From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] net: unix: allow bind to fail on mutex lock
Date: Fri, 13 Dec 2013 10:54:22 -0500
Message-ID: <1386950062-19020-1-git-send-email-sasha.levin@oracle.com>
Cc: edumazet@google.com, netdev@vger.kernel.org, xemul@parallels.com,
	linux-kernel@vger.kernel.org, Sasha Levin <sasha.levin@oracle.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is similar to the set_peek_off patch where calling bind while the
socket is stuck in unix_dgram_recvmsg() will block and cause a hung task
spew after a while.

This is also the last place that did a straightforward mutex_lock(), so
there shouldn't be any more of these patches.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 net/unix/af_unix.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 7edbcd9..800ca61 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -720,7 +720,9 @@ static int unix_autobind(struct socket *sock)
 	int err;
 	unsigned int retries = 0;
 
-	mutex_lock(&u->readlock);
+	err = mutex_lock_interruptible(&u->readlock);
+	if (err)
+		return err;
 
 	err = 0;
 	if (u->addr)
@@ -879,7 +881,9 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		goto out;
 	addr_len = err;
 
-	mutex_lock(&u->readlock);
+	err = mutex_lock_interruptible(&u->readlock);
+	if (err)
+		goto out;
 
 	err = -EINVAL;
 	if (u->addr)
-- 
1.7.10.4
