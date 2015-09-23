From: "=?UTF-8?q?Bendik=20R=C3=B8nning=20Opstad?=" <bro.devel@gmail.com>
Subject: [PATCH v2 net-next] tcp: Fix CWV being too strict on thin streams
Date: Wed, 23 Sep 2015 18:49:53 +0200
Message-ID: <1443026993-12358-1-git-send-email-bro.devel+kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Bendik=20R=C3=B8nning=20Opstad?=
	<bro.devel+kernel@gmail.com>, Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	Jonas Markussen <jonassm@ifi.uio.no>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>,
	Mads Johannessen <madsjoh@ifi.uio.no>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:35406 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbbIWQuN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 12:50:13 -0400
Received: by lagj9 with SMTP id j9so58217213lag.2
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 09:50:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Application limited streams such as thin streams, that transmit small
amounts of payload in relatively few packets per RTT, can be prevented
from growing the CWND when in congestion avoidance. This leads to
increased sojourn times for data segments in streams that often transmi=
t
time-dependent data.

Currently, a connection is considered CWND limited only after having
successfully transmitted at least one packet with new data, while at th=
e
same time failing to transmit some unsent data from the output queue
because the CWND is full. Applications that produce small amounts of
data may be left in a state where it is never considered to be CWND
limited, because all unsent data is successfully transmitted each time
an incoming ACK opens up for more data to be transmitted in the send
window.

=46ix by always testing whether the CWND is fully used after successful
packet transmissions, such that a connection is considered CWND limited
whenever the CWND has been filled. This is the correct behavior as
specified in RFC2861 (section 3.1).

Cc: Andreas Petlund <apetlund@simula.no>
Cc: Carsten Griwodz <griff@simula.no>
Cc: Jonas Markussen <jonassm@ifi.uio.no>
Cc: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Cc: Mads Johannessen <madsjoh@ifi.uio.no>
Signed-off-by: Bendik R=C3=B8nning Opstad <bro.devel+kernel@gmail.com>
---
Changes in v2:
 - Instead of updating tp->is_cwnd_limited after failing to send
   any packets, test whether CWND is full after successfull packet
   transmissions.
 - Updating commit message according to changes.

 net/ipv4/tcp_output.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 4cd0b50..57a586f 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1827,7 +1827,7 @@ static bool tcp_tso_should_defer(struct sock *sk,=
 struct sk_buff *skb,
=20
 	/* Ok, it looks like it is advisable to defer. */
=20
-	if (cong_win < send_win && cong_win < skb->len)
+	if (cong_win < send_win && cong_win <=3D skb->len)
 		*is_cwnd_limited =3D true;
=20
 	return true;
@@ -2060,7 +2060,6 @@ static bool tcp_write_xmit(struct sock *sk, unsig=
ned int mss_now, int nonagle,
=20
 		cwnd_quota =3D tcp_cwnd_test(tp, skb);
 		if (!cwnd_quota) {
-			is_cwnd_limited =3D true;
 			if (push_one =3D=3D 2)
 				/* Force out a loss probe pkt. */
 				cwnd_quota =3D 1;
@@ -2142,6 +2141,7 @@ repair:
 		/* Send one loss probe per tail loss episode. */
 		if (push_one !=3D 2)
 			tcp_schedule_loss_probe(sk);
+		is_cwnd_limited |=3D (tcp_packets_in_flight(tp) >=3D tp->snd_cwnd);
 		tcp_cwnd_validate(sk, is_cwnd_limited);
 		return false;
 	}
--=20
1.9.1
