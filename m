From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH  v2] sctp: fix missing send up SCTP_SENDER_DRY_EVENT when
 subscribe it
Date: Sun, 03 Jul 2011 03:28:04 +0800
Message-ID: <4E0F7144.4060009@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	=?GB2312?B?TWljaGE=?= =?GB2312?B?ZWwgVKi5eGVu?=
	<Michael.Tuexen@lurchi.franken.de>,
	Robin Seggelmann <seggelmann@fh-muenster.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:52184 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753201Ab1GBL2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2011 07:28:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Wei Yongjun <yjwei@cn.fujitsu.com>

We forgot to send up SCTP_SENDER_DRY_EVENT notification when
user app subscribes to this event, and there is no data to be
sent or retransmit.

This is required by the Socket API and used by the DTLS/SCTP
implementation.

Reported-by: Michael T=A8=B9xen <Michael.Tuexen@lurchi.franken.de>
Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Tested-by: Robin Seggelmann <seggelmann@fh-muenster.de>

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 6766913..99e25de 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2073,10 +2073,33 @@ static int sctp_setsockopt_disable_fragments(st=
ruct sock *sk,
 static int sctp_setsockopt_events(struct sock *sk, char __user *optval=
,
 				  unsigned int optlen)
 {
+	struct sctp_association *asoc;
+	struct sctp_ulpevent *event;
+
 	if (optlen > sizeof(struct sctp_event_subscribe))
 		return -EINVAL;
 	if (copy_from_user(&sctp_sk(sk)->subscribe, optval, optlen))
 		return -EFAULT;
+
+	/*=20
+	 * At the time when a user app subscribes to SCTP_SENDER_DRY_EVENT,
+	 * if there is no data to be sent or retransmit, the stack will
+	 * immediately send up this notification.
+	 */
+	if (sctp_ulpevent_type_enabled(SCTP_SENDER_DRY_EVENT,
+				       &sctp_sk(sk)->subscribe)) {
+		asoc =3D sctp_id2assoc(sk, 0);
+
+		if (asoc && sctp_outq_is_empty(&asoc->outqueue)) {
+			event =3D sctp_ulpevent_make_sender_dry_event(asoc,
+					GFP_ATOMIC);
+			if (!event)
+				return -ENOMEM;
+
+			sctp_ulpq_tail_event(&asoc->ulpq, event);
+		}
+	}
+
 	return 0;
 }
=20
--=20
1.7.5.1


