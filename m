From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] inet_diag: fix inet_diag_bc_audit()
Date: Fri, 17 Jun 2011 22:19:50 +0200
Message-ID: <1308341990.3539.27.camel@edumazet-laptop>
References: <1306942849.3150.10.camel@dan>
	 <BANLkTin9fqYSxq4ne5hV_ri-zKeMZ9mE_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Rosenberg <drosenberg@vsecurity.com>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org, security@kernel.org,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eugene Teo <eugeneteo@kernel.sg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40816 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756796Ab1FQUT4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 16:19:56 -0400
Received: by wyb38 with SMTP id 38so555865wyb.19
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2011 13:19:55 -0700 (PDT)
In-Reply-To: <BANLkTin9fqYSxq4ne5hV_ri-zKeMZ9mE_g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 03 juin 2011 =C3=A0 14:55 +0800, Eugene Teo a =C3=A9crit :
> Cc'ed acme.
>=20
> On Wed, Jun 1, 2011 at 11:40 PM, Dan Rosenberg <drosenberg@vsecurity.=
com> wrote:
> > It seems to me that the auditing performed by inet_diag_bc_audit() =
is
> > insufficient to prevent pathological INET_DIAG bytecode from doing =
bad
> > things.
> >
> > Firstly, it's possible to cause an infinite loop in inet_diag_bc_au=
dit()
> > with a INET_DIAG_BC_JMP opcode with a "yes" value of 0.  The valid_=
cc()
> > function, also called from here, seems suspicious as well.
> >
> > Once the bytecode is actually run in inet_diag_bc_run(), it looks l=
ike
> > more infinite loops are possible, if appropriate "yes" or "no" valu=
es
> > are set to zero and weren't validated by the audit.
> >
> > Finally, I can't seem to find any validation that the reported leng=
th of
> > the netlink message header doesn't exceed the skb length, as checke=
d in
> > some other netlink receive functions, which could result in reading
> > beyond the bounds of the socket data.  I could just be missing some=
thing
> > here though.
> >
> > Regards,
> > Dan
> >

Thanks guys, here is the patch I cooked to address this problem, sorry
for the long delay again.

[PATCH] inet_diag: fix inet_diag_bc_audit()

A malicious user or buggy application can inject code and trigger an
infinite loop in inet_diag_bc_audit()

Also make sure each instruction is aligned on 4 bytes boundary, to avoi=
d
unaligned accesses.

Reported-by: Dan Rosenberg <drosenberg@vsecurity.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Stephen Hemminger <shemminger@vyatta.com>
CC: Arnaldo Carvalho de Melo <acme@infradead.org>
CC: Eugene Teo <eugeneteo@kernel.sg>
CC: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
---
 net/ipv4/inet_diag.c |   14 ++++++--------
 1 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 6ffe94c..3267d38 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -437,7 +437,7 @@ static int valid_cc(const void *bc, int len, int cc=
)
 			return 0;
 		if (cc =3D=3D len)
 			return 1;
-		if (op->yes < 4)
+		if (op->yes < 4 || op->yes & 3)
 			return 0;
 		len -=3D op->yes;
 		bc  +=3D op->yes;
@@ -447,11 +447,11 @@ static int valid_cc(const void *bc, int len, int =
cc)
=20
 static int inet_diag_bc_audit(const void *bytecode, int bytecode_len)
 {
-	const unsigned char *bc =3D bytecode;
+	const void *bc =3D bytecode;
 	int  len =3D bytecode_len;
=20
 	while (len > 0) {
-		struct inet_diag_bc_op *op =3D (struct inet_diag_bc_op *)bc;
+		const struct inet_diag_bc_op *op =3D bc;
=20
 //printk("BC: %d %d %d {%d} / %d\n", op->code, op->yes, op->no, op[1].=
no, len);
 		switch (op->code) {
@@ -462,22 +462,20 @@ static int inet_diag_bc_audit(const void *bytecod=
e, int bytecode_len)
 		case INET_DIAG_BC_S_LE:
 		case INET_DIAG_BC_D_GE:
 		case INET_DIAG_BC_D_LE:
-			if (op->yes < 4 || op->yes > len + 4)
-				return -EINVAL;
 		case INET_DIAG_BC_JMP:
-			if (op->no < 4 || op->no > len + 4)
+			if (op->no < 4 || op->no > len + 4 || op->no & 3)
 				return -EINVAL;
 			if (op->no < len &&
 			    !valid_cc(bytecode, bytecode_len, len - op->no))
 				return -EINVAL;
 			break;
 		case INET_DIAG_BC_NOP:
-			if (op->yes < 4 || op->yes > len + 4)
-				return -EINVAL;
 			break;
 		default:
 			return -EINVAL;
 		}
+		if (op->yes < 4 || op->yes > len + 4 || op->yes & 3)
+			return -EINVAL;
 		bc  +=3D op->yes;
 		len -=3D op->yes;
 	}


