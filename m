From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH net-next-2.6] Phonet: remove dangling pipe if an endpoint is closed early
Date: Thu, 16 Sep 2010 01:19:53 +0300
Message-ID: <1284589193-26089-1-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:36390 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751778Ab0IOW1H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Sep 2010 18:27:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Closing a pipe endpoint is not normally allowed by the Phonet pipe,
other than as a side after-effect of removing the pipe between two
endpoints. But there is no way to prevent Linux userspace processes
from being killed or suffering from bugs, so this can still happen.
We might as well forcefully close Phonet pipe endpoints then.

The cellular modem supports only a few existing pipes at a time. So we
really should not leak them. This change instructs the modem to destroy
the pipe if either of the pipe's endpoint (Linux socket) is closed too
early.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/net/phonet/pep.h |    5 +++++
 net/phonet/pep.c         |   27 ++++++++++++++++++++++++++-
 2 files changed, 31 insertions(+), 1 deletions(-)

diff --git a/include/net/phonet/pep.h b/include/net/phonet/pep.h
index 35672b1..37f23dc 100644
--- a/include/net/phonet/pep.h
+++ b/include/net/phonet/pep.h
@@ -77,6 +77,11 @@ static inline struct pnpipehdr *pnp_hdr(struct sk_bu=
ff *skb)
 #define MAX_PNPIPE_HEADER (MAX_PHONET_HEADER + 4)
=20
 enum {
+	PNS_PIPE_CREATE_REQ =3D 0x00,
+	PNS_PIPE_CREATE_RESP,
+	PNS_PIPE_REMOVE_REQ,
+	PNS_PIPE_REMOVE_RESP,
+
 	PNS_PIPE_DATA =3D 0x20,
 	PNS_PIPE_ALIGNED_DATA,
=20
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index 04e3419..d0e7eb2 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -620,6 +620,28 @@ drop:
 	return err;
 }
=20
+static int pipe_do_remove(struct sock *sk)
+{
+	struct pep_sock *pn =3D pep_sk(sk);
+	struct pnpipehdr *ph;
+	struct sk_buff *skb;
+
+	skb =3D alloc_skb(MAX_PNPIPE_HEADER, GFP_KERNEL);
+	if (!skb)
+		return -ENOMEM;
+
+	skb_reserve(skb, MAX_PNPIPE_HEADER);
+	__skb_push(skb, sizeof(*ph));
+	skb_reset_transport_header(skb);
+	ph =3D pnp_hdr(skb);
+	ph->utid =3D 0;
+	ph->message_id =3D PNS_PIPE_REMOVE_REQ;
+	ph->pipe_handle =3D pn->pipe_handle;
+	ph->data[0] =3D PAD;
+
+	return pn_skb_send(sk, skb, &pipe_srv);
+}
+
 /* associated socket ceases to exist */
 static void pep_sock_close(struct sock *sk, long timeout)
 {
@@ -638,7 +660,10 @@ static void pep_sock_close(struct sock *sk, long t=
imeout)
 		sk_for_each_safe(sknode, p, n, &pn->ackq)
 			sk_del_node_init(sknode);
 		sk->sk_state =3D TCP_CLOSE;
-	}
+	} else if ((1 << sk->sk_state) & (TCPF_SYN_RECV|TCPF_ESTABLISHED))
+		/* Forcefully remove dangling Phonet pipe */
+		pipe_do_remove(sk);
+
 	ifindex =3D pn->ifindex;
 	pn->ifindex =3D 0;
 	release_sock(sk);
--=20
1.7.0.4

