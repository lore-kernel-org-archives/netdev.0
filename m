From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 2/2] unix: Add /proc/net/unix_peers file
Date: Thu, 01 Dec 2011 21:42:06 +0400
Message-ID: <4ED7BC6E.3040600@parallels.com>
References: <4ED7BC37.2030805@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:42351 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755861Ab1LARmN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Dec 2011 12:42:13 -0500
In-Reply-To: <4ED7BC37.2030805@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently it's not possible to find out what processes are connected
to each other via a unix socket. In the proposed proc file a socket
inode number and its peer inode number are shown. With these two at
hands it's possible to determine the unix connections endpoints.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 net/unix/af_unix.c |   55 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 55 insertions(+), 0 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 4b83a9c..4ce425a 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2305,6 +2305,33 @@ static int unix_seq_show(struct seq_file *seq, void *v)
 	return 0;
 }
 
+static int unix_peers_seq_show(struct seq_file *seq, void *v)
+{
+	struct sock *s = v, *peer;
+	unsigned long ino, peer_ino = 0;
+
+	if (v == SEQ_START_TOKEN)
+		return 0;
+
+	unix_state_lock(s);
+	ino = sock_i_ino(s);
+	peer = unix_peer(s);
+	if (peer)
+		sock_hold(peer);
+	unix_state_unlock(s);
+
+	if (peer) {
+		unix_state_lock(peer);
+		peer_ino = sock_i_ino(peer);
+		unix_state_unlock(peer);
+
+		sock_put(peer);
+	}
+
+	seq_printf(seq, "%5lu %5lu\n", ino, peer_ino);
+	return 0;
+}
+
 static const struct seq_operations unix_seq_ops = {
 	.start  = unix_seq_start,
 	.next   = unix_seq_next,
@@ -2326,18 +2353,46 @@ static const struct file_operations unix_seq_fops = {
 	.release	= seq_release_net,
 };
 
+static const struct seq_operations unix_peers_seq_ops = {
+	.start  = unix_seq_start,
+	.next   = unix_seq_next,
+	.stop   = unix_seq_stop,
+	.show   = unix_peers_seq_show,
+};
+
+static int unix_peers_seq_open(struct inode *inode, struct file *file)
+{
+	return seq_open_net(inode, file, &unix_peers_seq_ops,
+			    sizeof(struct unix_iter_state));
+}
+
+static const struct file_operations unix_peers_seq_fops = {
+	.owner		= THIS_MODULE,
+	.open		= unix_peers_seq_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release_net,
+};
+
 static int unix_proc_create(struct net *net)
 {
 	if (!proc_net_fops_create(net, "unix", 0, &unix_seq_fops))
 		goto out;
 
+	if (!proc_net_fops_create(net, "unix_peers", 0, &unix_peers_seq_fops))
+		goto out_peers;
+
 	return 0;
+
+out_peers:
+	proc_net_remove(net, "unix");
 out:
 	return -ENOMEM;
 }
 
 static void unix_proc_destroy(struct net *net)
 {
+	proc_net_remove(net, "unix_peers");
 	proc_net_remove(net, "unix");
 }
 #else
-- 
1.5.5.6
