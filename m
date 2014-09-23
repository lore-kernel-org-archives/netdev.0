From: Itzcak Pechtalt <itzcak@flashnetworks.com>
Subject: [PATCH net] tcp: Fix TLP implementation in case receive window limits
 send
Date: Tue, 23 Sep 2014 16:28:56 +0000
Message-ID: <6cbd68ba1ef44c5ca4b21bd3f65846af@AM3PR06MB388.eurprd06.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0082.outbound.protection.outlook.com ([157.55.234.82]:37453
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751883AbaIWQ3E convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 12:29:04 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Itzcak Pechtalt <itzcak@flashnetworks.com>

TCP Tail loss probe (TLP) algorithm implementation has some problem.
According to paper (draft-dukkipati-tcpm-tcp-loss-probe-0 ):
In case recive window of receiver limits send of new packet in probe ti=
me than
a retransmit of last packet send should be done.

Actually, return code from tcp_write_xmit is not checked and only RTO i=
s
scheduled,
So, it will take more time for reovery in this case than without TLP.

Signed-off-by: Itzcak Pechtalt <itzcak@flashnetworks.com>
---
net/ipv4/tcp_output.c=A0 |=A0=A0=A0 2 +-
1 file changed, 1 insertions(+),=A0 1 deletions(-)

diff -up a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c=A0=A0=A0=A0 2014-09-23 18:35:37.113771694 +=
0300
+++ b/net/ipv4/tcp_output.c=A0=A0=A0=A0 2014-09-23 18:39:58.207726420 +=
0300
@@ -2100,7 +2100,8 @@ void tcp_send_loss_probe(struct sock *sk

=A0=A0=A0=A0=A0=A0=A0 if (tcp_send_head(sk) !=3D NULL) {
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 err =3D tcp_write_xmit(sk=
, mss, TCP_NAGLE_OFF, 2, GFP_ATOMIC);
-=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 goto rearm_timer;
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (!err)
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0got=
o rearm_timer;
=A0=A0=A0=A0=A0=A0=A0 }

=A0=A0=A0=A0=A0=A0=A0 /* At most one outstanding TLP retransmission. */
