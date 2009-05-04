From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-next] tcp: extend ECN sysctl to allow server-side only
 ECN
Date: Mon, 4 May 2009 18:12:26 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0905041542100.10088@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-1272433139-1241441049=:10088"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48509 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756156AbZEDPM1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 11:12:27 -0400
Content-ID: <Pine.LNX.4.64.0905041810300.10088@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1272433139-1241441049=:10088
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0905041810301.10088@wrl-59.cs.helsinki.fi>

This should be very safe compared with full enabled, so I see
no reason why it shouldn't be done right away. As ECN can only
be negotiated if the SYN sending party is also supporting it,
somebody in the loop probably knows what he/she is doing. If
SYN does not ask for ECN, the server side SYN-ACK is identical
to what it is without ECN. Thus it's quite safe.

The chosen value is safe w.r.t to existing configs which
choose to currently set manually either 0 or 1 but
silently upgrades those who have not explicitly requested
ECN off.

Whether to just enable both sides comes up time to time but
unless that gets done now we can at least make the servers
aware of ECN already. As there are some known problems to occur
if ECN is enabled, it's currently questionable whether there's
any real gain from enabling clients as servers mostly won't
support it anyway (so we'd hit just the negative sides). After
enabling the servers and getting that deployed, the client end
enable really has some potential gain too.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>

---
 Documentation/networking/ip-sysctl.txt |   11 ++++++++++-
 net/ipv4/tcp_input.c                   |    2 +-
 net/ipv4/tcp_output.c                  |    2 +-
 3 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index ec5de02..7f98aa3 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -168,7 +168,16 @@ tcp_dsack - BOOLEAN
 	Allows TCP to send "duplicate" SACKs.
 
 tcp_ecn - BOOLEAN
-	Enable Explicit Congestion Notification in TCP.
+	Enable Explicit Congestion Notification (ECN) in TCP. ECN is only
+	used when both ends of the TCP flow support it. It is useful to
+	avoid losses due to congestion (when the bottleneck router supports
+	ECN).
+	Possible values are:
+		0 disable ECN
+		1 ECN enabled
+		2 Only server-side ECN enabled. If the other end does
+		  not support ECN, behavior is like with ECN disabled.
+	Default: 2
 
 tcp_fack - BOOLEAN
 	Enable FACK congestion avoidance and fast retransmission.
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c96a6bb..56dcf97 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -77,7 +77,7 @@ int sysctl_tcp_window_scaling __read_mostly = 1;
 int sysctl_tcp_sack __read_mostly = 1;
 int sysctl_tcp_fack __read_mostly = 1;
 int sysctl_tcp_reordering __read_mostly = TCP_FASTRETRANS_THRESH;
-int sysctl_tcp_ecn __read_mostly;
+int sysctl_tcp_ecn __read_mostly = 2;
 int sysctl_tcp_dsack __read_mostly = 1;
 int sysctl_tcp_app_win __read_mostly = 31;
 int sysctl_tcp_adv_win_scale __read_mostly = 2;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 59aec60..79c39dc 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -288,7 +288,7 @@ static inline void TCP_ECN_send_syn(struct sock *sk, struct sk_buff *skb)
 	struct tcp_sock *tp = tcp_sk(sk);
 
 	tp->ecn_flags = 0;
-	if (sysctl_tcp_ecn) {
+	if (sysctl_tcp_ecn == 1) {
 		TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_ECE | TCPCB_FLAG_CWR;
 		tp->ecn_flags = TCP_ECN_OK;
 	}
-- 
tg: (accc5b4..) ecn (depends on: origin/master)
---696208474-1272433139-1241441049=:10088--
