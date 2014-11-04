From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: [PATCH net v2] vxlan: Do not reuse sockets for a different address family
Date: Tue,  4 Nov 2014 15:03:20 -0200
Message-ID: <e7e226e9bef6f03ac249bc8e5ebf0938944ace3c.1415120464.git.mleitner@redhat.com>
Cc: stephen@networkplumber.org, sergei.shtylyov@cogentembedded.com,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45662 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751124AbaKDRDi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2014 12:03:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, we only match against local port number in order to reuse
socket. But if this new vxlan wants an IPv6 socket and a IPv4 one bound
to that port, vxlan will reuse an IPv4 socket as IPv6 and a panic will
follow. The following steps reproduce it:

   # ip link add vxlan6 type vxlan id 42 group 229.10.10.10 \
       srcport 5000 6000 dev eth0
   # ip link add vxlan7 type vxlan id 43 group ff0e::110 \
       srcport 5000 6000 dev eth0
   # ip link set vxlan6 up
   # ip link set vxlan7 up
   <panic>

[    4.187481] BUG: unable to handle kernel NULL pointer dereference at 0000000000000058
[    4.187509] IP: [<ffffffff81667c98>] ipv6_sock_mc_join+0x88/0x630
...
[    4.188076] Call Trace:
[    4.188085]  [<ffffffff81667c4a>] ? ipv6_sock_mc_join+0x3a/0x630
[    4.188098]  [<ffffffffa05a6ad6>] vxlan_igmp_join+0x66/0xd0 [vxlan]
[    4.188113]  [<ffffffff810a3430>] process_one_work+0x220/0x710
[    4.188125]  [<ffffffff810a33c4>] ? process_one_work+0x1b4/0x710
[    4.188138]  [<ffffffff810a3a3b>] worker_thread+0x11b/0x3a0
[    4.188149]  [<ffffffff810a3920>] ? process_one_work+0x710/0x710

So address family must also match in order to reuse a socket.

Reported-by: Jean-Tsung Hsiao <jhsiao@redhat.com>
Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
---
 drivers/net/vxlan.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index ca309820d39e1ba7995f38d3a2f9bacbd1c1f857..2877f8f637a22d0f241e31641cdfc8f34f2c7bf8 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -281,7 +281,8 @@ static struct vxlan_sock *vxlan_find_sock(struct net *net, __be16 port)
 	struct vxlan_sock *vs;
 
 	hlist_for_each_entry_rcu(vs, vs_head(net, port), hlist) {
-		if (inet_sk(vs->sock->sk)->inet_sport == port)
+		if (inet_sk(vs->sock->sk)->inet_sport == port &&
+		    inet_sk(vs->sock->sk)->sk.sk_family == family)
 			return vs;
 	}
 	return NULL;
-- 
1.9.3
