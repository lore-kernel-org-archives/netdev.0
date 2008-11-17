From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: make /proc/net/protocols namespace aware
Date: Mon, 17 Nov 2008 11:53:43 +0100
Message-ID: <49214D37.2090502@cosmosbay.com>
References: <49214C74.3020303@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050906060206080301070306"
Cc: "Denis V. Lunev" <den@openvz.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:43714 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751945AbYKQKxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 05:53:53 -0500
In-Reply-To: <49214C74.3020303@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050906060206080301070306
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

Eric Dumazet a =E9crit :
> Converting /proc/net/protocols to be namespace aware is quite easy
> and permits us to use sock_prot_inuse_get().
>=20
> This provides seperate counters for each protocol. For example
> we can really count TCPv6 sockets and TCPv4 sockets, while previously,
> we had the same value, and this value was not namespace aware.
>=20
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> ---
> net/core/sock.c |   27 +++++++++++++++++++++++----
> 1 files changed, 23 insertions(+), 4 deletions(-)
>=20

Oops wrong attached file... sorry

[PATCH] net: make /proc/net/protocols namespace aware

Converting /proc/net/protocols to be namespace aware is quite easy
and permits us to use sock_prot_inuse_get().

This provides seperate counters for each protocol. For example
we can really count TCPv6 sockets and TCPv4 sockets, while previously,
we had the same value, and this value was not namespace aware.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
net/core/sock.c |   27 +++++++++++++++++++++++----
1 files changed, 23 insertions(+), 4 deletions(-)=20


--------------050906060206080301070306
Content-Type: text/plain;
 name="protocols_pernet.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="protocols_pernet.patch"

diff --git a/net/core/sock.c b/net/core/sock.c
index 38de9c3..566eb82 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2176,7 +2176,7 @@ static void proto_seq_printf(struct seq_file *seq, struct proto *proto)
 			"%2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c\n",
 		   proto->name,
 		   proto->obj_size,
-		   proto->sockets_allocated != NULL ? atomic_read(proto->sockets_allocated) : -1,
+		   sock_prot_inuse_get(seq_file_net(seq), proto),
 		   proto->memory_allocated != NULL ? atomic_read(proto->memory_allocated) : -1,
 		   proto->memory_pressure != NULL ? *proto->memory_pressure ? "yes" : "no" : "NI",
 		   proto->max_header,
@@ -2230,7 +2230,8 @@ static const struct seq_operations proto_seq_ops = {
 
 static int proto_seq_open(struct inode *inode, struct file *file)
 {
-	return seq_open(file, &proto_seq_ops);
+	return seq_open_net(inode, file, &proto_seq_ops,
+			    sizeof(struct seq_net_private));
 }
 
 static const struct file_operations proto_seq_fops = {
@@ -2241,10 +2242,28 @@ static const struct file_operations proto_seq_fops = {
 	.release	= seq_release,
 };
 
+static __net_init int proto_init_net(struct net *net)
+{
+	if (!proc_net_fops_create(net, "protocols", S_IRUGO, &proto_seq_fops))
+		return -ENOMEM;
+
+	return 0;
+}
+
+static __net_exit void proto_exit_net(struct net *net)
+{
+	proc_net_remove(net, "protocols");
+}
+
+
+static __net_initdata struct pernet_operations proto_net_ops = {
+	.init = proto_init_net,
+	.exit = proto_exit_net,
+};
+
 static int __init proto_init(void)
 {
-	/* register /proc/net/protocols */
-	return proc_net_fops_create(&init_net, "protocols", S_IRUGO, &proto_seq_fops) == NULL ? -ENOBUFS : 0;
+	return register_pernet_subsys(&proto_net_ops);
 }
 
 subsys_initcall(proto_init);

--------------050906060206080301070306--
