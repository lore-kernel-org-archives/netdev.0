From: "=?UTF-8?q?Bendik=20R=C3=B8nning=20Opstad?=" <bro.devel@gmail.com>
Subject: [PATCH net-next] tcp: Fix CWV being too strict on thin streams
Date: Sat, 19 Sep 2015 01:38:23 +0200
Message-ID: <1442619503-2282-1-git-send-email-bro.devel+kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	=?UTF-8?q?Bendik=20R=C3=B8nning=20Opstad?=
	<bro.devel+kernel@gmail.com>, Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	Jonas Markussen <jonassm@ifi.uio.no>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:35210 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752217AbbIRXjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 19:39:41 -0400
Received: by lagj9 with SMTP id j9so39369610lag.2
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 16:39:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Application limited streams such as thin streams, that transmit small
amounts of payload in relatively few packets per RTT, are prevented fro=
m
growing the CWND after experiencing loss. This leads to increased
sojourn times for data segments in streams that often transmit
time-dependent data.

After the CWND is reduced due to loss, and an ACK has made room in the
send window for more packets to be transmitted, the CWND will not grow
unless there is more unsent data buffered in the output queue than the
CWND permits to be sent. That is because tcp_cwnd_validate(), which
updates tp->is_cwnd_limited, is only called in tcp_write_xmit() when at
least one packet with new data has been sent. However, if all the
buffered data in the output queue was sent within the current CWND,
is_cwnd_limited will remain false even when there is no more room in th=
e
CWND. While the CWND is fully utilized, any new data put on the output
queue will be held back (i.e. limited by the CWND), but
tp->is_cwnd_limited will not be updated as no packets were transmitted.

=46ix by updating tp->is_cwnd_limited if no packets are sent due to the
CWND being fully utilized.

Cc: Andreas Petlund <apetlund@simula.no>
Cc: Carsten Griwodz <griff@simula.no>
Cc: Jonas Markussen <jonassm@ifi.uio.no>
Cc: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Signed-off-by: Bendik R=C3=B8nning Opstad <bro.devel+kernel@gmail.com>
---
 net/ipv4/tcp_output.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index d0ad355..7096b8b 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2145,6 +2145,11 @@ repair:
 		tcp_cwnd_validate(sk, is_cwnd_limited);
 		return false;
 	}
+	/* We are prevented from transmitting because we are limited
+	 * by the CWND, so update tcp sock with correct value.
+	 */
+	if (is_cwnd_limited)
+		tp->is_cwnd_limited =3D is_cwnd_limited;
 	return !tp->packets_out && tcp_send_head(sk);
 }
=20
--=20
1.9.1
