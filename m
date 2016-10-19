From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net] tipc: Guard against tiny MTU in tipc_msg_build()
Date: Wed, 19 Oct 2016 03:16:54 +0100
Message-ID: <20161019021654.GD2773@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="d9ADC0YsG2v16Js0"
Cc: netdev@vger.kernel.org, Qian Zhang <zhangqian-c@360.cn>,
        Eric Dumazet <edumazet@google.com>
To: Jon Maloy <jon.maloy@ericsson.com>,
        Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51147 "EHLO
        shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752677AbcJSCRD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 22:17:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--d9ADC0YsG2v16Js0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Qian Zhang (=E5=BC=A0=E8=B0=A6) reported a potential socket buffer overflow=
 in
tipc_msg_build().  The minimum fragment length needs to be checked
against the maximum packet size, which is based on the link MTU.

Reported-by: Qian Zhang (=E5=BC=A0=E8=B0=A6) <zhangqian-c@360.cn>
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
This is untested, but I think it fixes the issue reported.  Ideally
tipc_l2_device_event() would also disable use of TIPC on devices with
too small an MTU, like several other protocols do.

Ben.

 net/tipc/msg.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 17201aa8423d..b9124ac82c29 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -274,6 +274,10 @@ int tipc_msg_build(struct tipc_msg *mhdr, struct msghd=
r *m,
 		goto error;
 	}
=20
+	/* Check that fragment and message header will fit */
+	if (INT_H_SIZE + mhsz > pktmax)
+		return -EMSGSIZE;
+
 	/* Prepare reusable fragment header */
 	tipc_msg_init(msg_prevnode(mhdr), &pkthdr, MSG_FRAGMENTER,
 		      FIRST_FRAGMENT, INT_H_SIZE, msg_destnode(mhdr));

--d9ADC0YsG2v16Js0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUBWAbXlue/yOyVhhEJAQoHPRAAsSsA6IuUS4u2Hm+dt/y9zKSYpZOY8iCu
j4WWf0BNrScoMH4HpNDI4cmCIvDudVMcInbbWDTw+joI+IxTYitxdrIOo9AroPSu
XGjfHzF7s0ZBUdZKTC+jduYuOe6C25ASVDQgz/2Fz1mxBRQrKD7rN7AFkl/4c6/n
Kr3xQJbBYpZZESChvqd0EGTfwVStv4OhHzWAEHYNd+WkcY4Y/GC82TQ2gYBhhdAh
RAGc8mfZ1pqzvZi6CbAQp7U0fgr5JsdZA/anwJJrffPzbHpsV3ct3uLk0r8OccnS
5ZmKWn+Sj6wWCfkPNPQVvF4qBMYt2KNzfvPOKGxds4tWjjmTrNo6euIOp+ss3bRS
0GAb1HrNe8ABC8tNedON71AZnFK2zOVmNnTn19vLT0ll3/H4t5zA4eFPtxX3+PGp
fCzV6uuWDx1ONoNxKhwPggVvi3MNcdMoAdC+OXX27ATamtR3E/erbn/PJ2tjiqpy
w/YfLiqPLr3zL6v4/ytltWzZGzP7c9mnFrpn1ZxKSIZAUE2ztlFAFqS98+dcbuwE
ODZT9BXaUrTrbpHGDGY+3ErZR1pRm3akREprGD9K1nZDdJE6pLrilqhKJUk4MIkQ
rvrcVEYRrAF7IkozpcOzuiBNFAQAjOZoXIdGLzv6CwDXBQaKPgMiKH3QgiZ9ds0W
yDO3AcP34HY=
=sDld
-----END PGP SIGNATURE-----

--d9ADC0YsG2v16Js0--
