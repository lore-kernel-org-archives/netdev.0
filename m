From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH 3/4] Phonet: cleanup pipe enable socket option
Date: Fri,  8 Oct 2010 17:02:02 +0300
Message-ID: <1286546523-3340-3-git-send-email-remi@remlab.net>
References: <1286546523-3340-1-git-send-email-remi@remlab.net>
 <1286546523-3340-2-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>,
	Kumar Sanghvi <kumar.sanghvi@stericsson.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:47820 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758122Ab0JHOCF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Oct 2010 10:02:05 -0400
In-Reply-To: <1286546523-3340-2-git-send-email-remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

The current code works like this:

  int garbage, status;
  socklen_t len =3D sizeof(status);

  /* enable pipe */
  setsockopt(fd, SOL_PNPIPE, PNPIPE_ENABLE, &garbage, sizeof(garbage));
  /* disable pipe */
  setsockopt(fd, SOL_PNPIPE, PNPIPE_DISABLE, &garbage, sizeof(garbage))=
;
  /* get status */
  getsockopt(fd, SOL_PNPIPE, PNPIPE_INQ, &status, &len);

=2E..which does not follow the usual socket option pattern. This patch
merges all three "options" into a single gettable&settable option,
before Linux 2.6.37 gets out:

  int status;
  socklen_t len =3D sizeof(status);

  /* enable pipe */
  status =3D 1;
  setsockopt(fd, SOL_PNPIPE, PNPIPE_ENABLE, &status, sizeof(status));
  /* disable pipe */
  status =3D 0;
  setsockopt(fd, SOL_PNPIPE, PNPIPE_ENABLE, &status, sizeof(status));
  /* get status */
  getsockopt(fd, SOL_PNPIPE, PNPIPE_ENABLE, &status, &len);

This also fixes the error code from EFAULT to ENOTCONN.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
Cc: Kumar Sanghvi <kumar.sanghvi@stericsson.com>
---
 Documentation/networking/phonet.txt |   15 +------
 include/linux/phonet.h              |    3 +-
 net/phonet/pep.c                    |   72 ++++++++++++++-------------=
-------
 3 files changed, 34 insertions(+), 56 deletions(-)

diff --git a/Documentation/networking/phonet.txt b/Documentation/networ=
king/phonet.txt
index cccf5ff..2d9bc2b 100644
--- a/Documentation/networking/phonet.txt
+++ b/Documentation/networking/phonet.txt
@@ -213,12 +213,9 @@ The implementation adds socket options at SOL_PNPI=
PE level:
 	It then updates the pipe state associated with the sequenced socket t=
o
 	be PIPE_DISABLED.
=20
-  PNPIPE_ENABLE
-	It follows the same sequence as above for enabling a pipe by sending
-	PNS_PEP_ENABLE_REQ initially and then sending PNS_PEP_ENABLED_IND aft=
er
-	getting responses from sequenced socket and remote-pep.
-	It will also update the pipe state associated with the sequenced sock=
et
-	to PIPE_ENABLED.
+  PNPIPE_ENABLE accepts one integer value (int). If set to zero, the p=
ipe
+    is disabled. If the value is non-zero, the pipe is enabled. If the=
 pipe
+    is not (yet) connected, ENOTCONN is error is returned.
=20
    PNPIPE_DESTROY
 	This will send out PNS_PEP_DISCONNECT_REQ on the sequenced socket and
@@ -226,12 +223,6 @@ The implementation adds socket options at SOL_PNPI=
PE level:
 	It will also update the pipe state associated with the sequenced sock=
et
 	to PIPE_IDLE
=20
-   PNPIPE_INQ
-	This getsocktopt allows the user-space running on the sequenced socke=
t
-	to examine the pipe state associated with that socket ie. whether the
-	pipe is created (PIPE_DISABLED) or enabled (PIPE_ENABLED) or disabled
-	(PIPE_DISABLED) or no pipe exists (PIPE_IDLE).
-
 After a pipe has been created and enabled successfully, the Pipe data =
can be
 exchanged between the host-pep and remote-pep (modem).
=20
diff --git a/include/linux/phonet.h b/include/linux/phonet.h
index 96f5625..e27cbf9 100644
--- a/include/linux/phonet.h
+++ b/include/linux/phonet.h
@@ -38,9 +38,8 @@
 #define PNPIPE_IFINDEX		2
 #define PNPIPE_CREATE           3
 #define PNPIPE_ENABLE           4
-#define PNPIPE_DISABLE          5
+/* unused slot */
 #define PNPIPE_DESTROY          6
-#define PNPIPE_INQ              7
=20
 #define PNADDR_ANY		0
 #define PNADDR_BROADCAST	0xFC
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index aa3d870..f818f76 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -327,29 +327,20 @@ static int pipe_handler_send_ind(struct sock *sk,=
 u16 dobj, u8 utid,
 	return pn_skb_send(sk, skb, &spn);
 }
=20
-static int pipe_handler_enable_pipe(struct sock *sk, int cmd)
+static int pipe_handler_enable_pipe(struct sock *sk, int enable)
 {
-	int ret;
 	struct pep_sock *pn =3D pep_sk(sk);
-
-	switch (cmd) {
-	case PNPIPE_ENABLE:
-		ret =3D pipe_handler_send_req(sk, pn->pn_sk.sobject,
-				PNS_PIPE_ENABLE_UTID, PNS_PEP_ENABLE_REQ,
-				pn->pipe_handle, GFP_ATOMIC);
-		break;
-
-	case PNPIPE_DISABLE:
-		ret =3D pipe_handler_send_req(sk, pn->pn_sk.sobject,
-				PNS_PIPE_DISABLE_UTID, PNS_PEP_DISABLE_REQ,
-				pn->pipe_handle, GFP_ATOMIC);
-		break;
-
-	default:
-		ret =3D -EINVAL;
+	int utid, req;
+
+	if (enable) {
+		utid =3D PNS_PIPE_ENABLE_UTID;
+		req =3D PNS_PEP_ENABLE_REQ;
+	} else {
+		utid =3D PNS_PIPE_DISABLE_UTID;
+		req =3D PNS_PEP_DISABLE_REQ;
 	}
-
-	return ret;
+	return pipe_handler_send_req(sk, pn->pn_sk.sobject, utid, req,
+			pn->pipe_handle, GFP_ATOMIC);
 }
=20
 static int pipe_handler_create_pipe(struct sock *sk, int pipe_handle, =
int cmd)
@@ -1187,23 +1178,6 @@ static int pep_setsockopt(struct sock *sk, int l=
evel, int optname,
 			break;
 		}
=20
-	case PNPIPE_ENABLE:
-		if (pn->pipe_state !=3D PIPE_DISABLED) {
-			err =3D -EFAULT;
-			break;
-		}
-		err =3D pipe_handler_enable_pipe(sk, PNPIPE_ENABLE);
-		break;
-
-	case PNPIPE_DISABLE:
-		if (pn->pipe_state !=3D PIPE_ENABLED) {
-			err =3D -EFAULT;
-			break;
-		}
-
-		err =3D pipe_handler_enable_pipe(sk, PNPIPE_DISABLE);
-		break;
-
 	case PNPIPE_DESTROY:
 		if (pn->pipe_state < PIPE_DISABLED) {
 			err =3D -EFAULT;
@@ -1239,6 +1213,17 @@ static int pep_setsockopt(struct sock *sk, int l=
evel, int optname,
 			err =3D 0;
 		}
 		goto out_norel;
+
+#ifdef CONFIG_PHONET_PIPECTRLR
+	case PNPIPE_ENABLE:
+		if (pn->pipe_state <=3D PIPE_IDLE) {
+			err =3D -ENOTCONN;
+			break;
+		}
+		err =3D pipe_handler_enable_pipe(sk, val);
+		break;
+#endif
+
 	default:
 		err =3D -ENOPROTOOPT;
 	}
@@ -1264,15 +1249,18 @@ static int pep_getsockopt(struct sock *sk, int =
level, int optname,
 		val =3D pn->ifindex ? PNPIPE_ENCAP_IP : PNPIPE_ENCAP_NONE;
 		break;
=20
+	case PNPIPE_IFINDEX:
+		val =3D pn->ifindex;
+		break;
+
 #ifdef CONFIG_PHONET_PIPECTRLR
-	case PNPIPE_INQ:
-		val =3D pn->pipe_state;
+	case PNPIPE_ENABLE:
+		if (pn->pipe_state <=3D PIPE_IDLE)
+			return -ENOTCONN;
+		val =3D pn->pipe_state !=3D PIPE_DISABLED;
 		break;
 #endif
=20
-	case PNPIPE_IFINDEX:
-		val =3D pn->ifindex;
-		break;
 	default:
 		return -ENOPROTOOPT;
 	}
--=20
1.7.0.4

