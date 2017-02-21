From: Maxime Jayat <maxime.jayat@mobile-devices.fr>
Subject: [PATCH] net: socket: fix recvmmsg not returning error from sock_error
Date: Tue, 21 Feb 2017 18:35:51 +0100
Message-ID: <20170221173551.3471-1-maxime.jayat@mobile-devices.fr>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Maxime Jayat <maxime.jayat@mobile-devices.fr>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 34b88a68f26a ("net: Fix use after free in the recvmmsg exit path"),
changed the exit path of recvmmsg to always return the datagrams
variable and modified the error paths to set the variable to the error
code returned by recvmsg if necessary.

However in the case sock_error returned an error, the error code was
then ignored, and recvmmsg returned 0.

Change the error path of recvmmsg to correctly return the error code
of sock_error.

The bug was triggered by using recvmmsg on a CAN interface which was
not up. Linux 4.6 and later return 0 in this case while earlier
releases returned -ENETDOWN.

Fixes: 34b88a68f26a ("net: Fix use after free in the recvmmsg exit path")
Signed-off-by: Maxime Jayat <maxime.jayat@mobile-devices.fr>
---
 net/socket.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/socket.c b/net/socket.c
index b7a63d5bc915..2c1e8677ff2d 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2228,8 +2228,10 @@ int __sys_recvmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 		return err;
 
 	err = sock_error(sock->sk);
-	if (err)
+	if (err) {
+		datagrams = err;
 		goto out_put;
+	}
 
 	entry = mmsg;
 	compat_entry = (struct compat_mmsghdr __user *)mmsg;
-- 
2.9.3
