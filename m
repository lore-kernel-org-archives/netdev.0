From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 8/8] af_unix: Allow connecting to sockets in other network namespaces.
Date: Sun, 13 Jun 2010 06:35:48 -0700
Message-ID: <m11vcbgimj.fsf@fess.ebiederm.org>
References: <m1hbl7hxo3.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Serge Hallyn <serue@us.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	<netdev@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:48093 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753745Ab0FMNfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jun 2010 09:35:52 -0400
In-Reply-To: <m1hbl7hxo3.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Sun\, 13 Jun 2010 06\:25\:32 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Remove the restriction that only allows connecting to a unix domain
socket identified by unix path that is in the same network namespace.

Crossing network namespaces is always tricky and we did not support
this at first, because of a strict policy of don't mix the namespaces.
Later after Pavel proposed this we did not support this because no one
had performed the audit to make certain using unix domain sockets
across namespaces is safe.

What fundamentally makes connecting to af_unix sockets in other
namespaces is safe is that you have to have the proper permissions on
the unix domain socket inode that lives in the filesystem.  If you
want strict isolation you just don't create inodes where unfriendlys
can get at them, or with permissions that allow unfriendlys to open
them.  All nicely handled for us by the mount namespace and other
standard file system facilities.

I looked through unix domain sockets and they are a very controlled
environment so none of the work that goes on in dev_forward_skb to
make crossing namespaces safe appears needed, we are not loosing
controll of the skb and so do not need to set up the skb to look like
it is comming in fresh from the outside world.  Further the fields in
struct unix_skb_parms should not have any problems crossing network
namespaces.

Now that we handle SCM_CREDENTIALS in a way that gives useable values
across namespaces.  There does not appear to be any operational
problems with encouraging the use of unix domain sockets across
containers either.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/unix/af_unix.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 78d412a..4aaff40 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -282,7 +282,7 @@ static inline struct sock *unix_find_socket_byname(struct net *net,
 	return s;
 }
 
-static struct sock *unix_find_socket_byinode(struct net *net, struct inode *i)
+static struct sock *unix_find_socket_byinode(struct inode *i)
 {
 	struct sock *s;
 	struct hlist_node *node;
@@ -292,9 +292,6 @@ static struct sock *unix_find_socket_byinode(struct net *net, struct inode *i)
 		    &unix_socket_table[i->i_ino & (UNIX_HASH_SIZE - 1)]) {
 		struct dentry *dentry = unix_sk(s)->dentry;
 
-		if (!net_eq(sock_net(s), net))
-			continue;
-
 		if (dentry && dentry->d_inode == i) {
 			sock_hold(s);
 			goto found;
@@ -757,7 +754,7 @@ static struct sock *unix_find_other(struct net *net,
 		err = -ECONNREFUSED;
 		if (!S_ISSOCK(inode->i_mode))
 			goto put_fail;
-		u = unix_find_socket_byinode(net, inode);
+		u = unix_find_socket_byinode(inode);
 		if (!u)
 			goto put_fail;
 
-- 
1.6.5.2.143.g8cc62

