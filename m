From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [RFC PATCH 2/5] net: split unix_bind()
Date: Wed, 15 Aug 2012 20:22:09 +0400
Message-ID: <20120815162209.7598.68428.stgit@localhost.localdomain>
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

This patch moves UNIX socket insert into separated function, because this code
will be used for unix_fbind() too.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 net/unix/af_unix.c |   52 +++++++++++++++++++++++++++++-----------------------
 1 files changed, 29 insertions(+), 23 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index bc90ddb..b26200d 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -814,11 +814,38 @@ fail:
 	return NULL;
 }
 
+static int __unix_add_sock(struct path *path, struct sock *sk,
+			 struct unix_address *addr, int hash)
+{
+	struct net *net = sock_net(sk);
+	struct unix_sock *u = unix_sk(sk);
+	struct sockaddr_un *sunaddr = addr->name;
+	char *sun_path = sunaddr->sun_path;
+	struct hlist_head *list;
+
+	if (!sun_path[0]) {
+		if (__unix_find_socket_byname(net, sunaddr, addr->len,
+					      sk->sk_type, hash)) {
+			unix_release_addr(addr);
+			return -EADDRINUSE;
+		}
+
+		list = &unix_socket_table[addr->hash];
+	} else {
+		list = &unix_socket_table[path->dentry->d_inode->i_ino & (UNIX_HASH_SIZE-1)];
+		u->path = *path;
+	}
+
+	__unix_remove_socket(sk);
+	u->addr = addr;
+	__unix_insert_socket(list, sk);
+	return 0;
+
+}
 
 static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 {
 	struct sock *sk = sock->sk;
-	struct net *net = sock_net(sk);
 	struct unix_sock *u = unix_sk(sk);
 	struct sockaddr_un *sunaddr = (struct sockaddr_un *)uaddr;
 	char *sun_path = sunaddr->sun_path;
@@ -827,7 +854,6 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	int err;
 	unsigned int hash;
 	struct unix_address *addr;
-	struct hlist_head *list;
 
 	err = -EINVAL;
 	if (sunaddr->sun_family != AF_UNIX)
@@ -893,27 +919,7 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	}
 
 	spin_lock(&unix_table_lock);
-
-	err = -EADDRINUSE;
-	if (!sun_path[0]) {
-		if (__unix_find_socket_byname(net, sunaddr, addr->len,
-					      sk->sk_type, hash)) {
-			unix_release_addr(addr);
-			goto out_unlock;
-		}
-
-		list = &unix_socket_table[addr->hash];
-	} else {
-		list = &unix_socket_table[path.dentry->d_inode->i_ino & (UNIX_HASH_SIZE-1)];
-		u->path = path;
-	}
-
-	err = 0;
-	__unix_remove_socket(sk);
-	u->addr = addr;
-	__unix_insert_socket(list, sk);
-
-out_unlock:
+	err = __unix_add_sock(&path, sk, addr, hash);
 	spin_unlock(&unix_table_lock);
 out_up:
 	mutex_unlock(&u->readlock);
