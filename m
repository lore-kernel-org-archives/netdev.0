From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH] net: socket: don't set sk_uid to garbage value in ->setattr()
Date: Fri, 30 Dec 2016 17:42:32 -0600
Message-ID: <20161230234232.4221-1-ebiggers3@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Lorenzo Colitti <lorenzo@google.com>,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Eric Biggers <ebiggers@google.com>
To: netdev@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Biggers <ebiggers@google.com>

->setattr() was recently implemented for socket files to sync the socket
inode's uid to the new 'sk_uid' member of struct sock.  It does this by
copying over the ia_uid member of struct iattr.  However, ia_uid is
actually only valid when ATTR_UID is set in ia_valid, indicating that
the uid is being changed, e.g. by chown.  Other metadata operations such
as chmod or utimes leave ia_uid uninitialized.  Therefore, sk_uid could
be set to a "garbage" value from the stack.

Fix this by only copying the uid over when ATTR_UID is set.

Fixes: 86741ec25462 ("net: core: Add a UID field to struct sock.")
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 net/socket.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/socket.c b/net/socket.c
index 8487bf136e5c..a8c2307590b8 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -537,7 +537,7 @@ int sockfs_setattr(struct dentry *dentry, struct iattr *iattr)
 {
 	int err = simple_setattr(dentry, iattr);
 
-	if (!err) {
+	if (!err && (iattr->ia_valid & ATTR_UID)) {
 		struct socket *sock = SOCKET_I(d_inode(dentry));
 
 		sock->sk->sk_uid = iattr->ia_uid;
-- 
2.11.0

