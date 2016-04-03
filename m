From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Subject: [PATCH v3 net-next 2/8] tcp: accept SOF_TIMESTAMPING_OPT_ID for passive TFO
Date: Sat,  2 Apr 2016 23:08:07 -0400
Message-ID: <1459652893-14207-3-git-send-email-soheil.kdev@gmail.com>
References: <1459652893-14207-1-git-send-email-soheil.kdev@gmail.com>
Cc: willemb@google.com, edumazet@google.com, ycheng@google.com,
	ncardwell@google.com, kafai@fb.com,
	Soheil Hassas Yeganeh <soheil@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f68.google.com ([209.85.192.68]:35235 "EHLO
	mail-qg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751692AbcDCDIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Apr 2016 23:08:24 -0400
Received: by mail-qg0-f68.google.com with SMTP id b32so13849697qgf.2
        for <netdev@vger.kernel.org>; Sat, 02 Apr 2016 20:08:24 -0700 (PDT)
In-Reply-To: <1459652893-14207-1-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil@google.com>

SOF_TIMESTAMPING_OPT_ID is set to get data-independent IDs
to associate timestamps with send calls. For TCP connections,
tp->snd_una is used as the starting point to calculate
relative IDs.

This socket option will fail if set before the handshake on a
passive TCP fast open connection with data in SYN or SYN/ACK,
since setsockopt requires the connection to be in the
ESTABLISHED state.

To address these, instead of limiting the option to the
ESTABLISHED state, accept the SOF_TIMESTAMPING_OPT_ID option as
long as the connection is not in LISTEN or CLOSE states.

Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
Acked-by: Willem de Bruijn <willemb@google.com>
Acked-by: Yuchung Cheng <ycheng@google.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 net/core/sock.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 66976f8..0a64fe2 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -832,7 +832,8 @@ set_rcvbuf:
 		    !(sk->sk_tsflags & SOF_TIMESTAMPING_OPT_ID)) {
 			if (sk->sk_protocol == IPPROTO_TCP &&
 			    sk->sk_type == SOCK_STREAM) {
-				if (sk->sk_state != TCP_ESTABLISHED) {
+				if ((1 << sk->sk_state) &
+				    (TCPF_CLOSE | TCPF_LISTEN)) {
 					ret = -EINVAL;
 					break;
 				}
-- 
2.8.0.rc3.226.g39d4020
