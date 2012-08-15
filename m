From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [RFC PATCH 1/5] net: cleanup unix_bind() a little
Date: Wed, 15 Aug 2012 20:22:04 +0400
Message-ID: <20120815162204.7598.6975.stgit@localhost.localdomain>
References: <20120815161141.7598.16682.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: thierry.reding@avionic-design.de, bfields@redhat.com,
	eric.dumazet@gmail.com, xemul@parallels.com, neilb@suse.de,
	netdev@vger.kernel.org, x86@kernel.org,
	linux-kernel@vger.kernel.org, paul.gortmaker@windriver.com,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	akpm@linux-foundation.org, tim.c.chen@linux.intel.com,
	devel@openvz.org, ebiederm@xmission.com
To: tglx@linutronix.de, mingo@redhat.com, davem@davemloft.net,
	hpa@zytor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120815161141.7598.16682.stgit@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This will simplify further changes for unix_fbind().
---
 net/unix/af_unix.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 641f2e4..bc90ddb 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -880,10 +880,8 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		if (err)
 			goto out_mknod_dput;
 		err = security_path_mknod(&path, dentry, mode, 0);
-		if (err)
-			goto out_mknod_drop_write;
-		err = vfs_mknod(path.dentry->d_inode, dentry, mode, 0);
-out_mknod_drop_write:
+		if (!err)
+			err = vfs_mknod(path.dentry->d_inode, dentry, mode, 0);
 		mnt_drop_write(path.mnt);
 		if (err)
 			goto out_mknod_dput;
@@ -896,9 +894,9 @@ out_mknod_drop_write:
 
 	spin_lock(&unix_table_lock);
 
+	err = -EADDRINUSE;
 	if (!sun_path[0]) {
-		err = -EADDRINUSE;
-		if (__unix_find_socket_byname(net, sunaddr, addr_len,
+		if (__unix_find_socket_byname(net, sunaddr, addr->len,
 					      sk->sk_type, hash)) {
 			unix_release_addr(addr);
 			goto out_unlock;
@@ -906,7 +904,7 @@ out_mknod_drop_write:
 
 		list = &unix_socket_table[addr->hash];
 	} else {
-		list = &unix_socket_table[dentry->d_inode->i_ino & (UNIX_HASH_SIZE-1)];
+		list = &unix_socket_table[path.dentry->d_inode->i_ino & (UNIX_HASH_SIZE-1)];
 		u->path = path;
 	}
 
