From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] tcp: use correct counters in CA_CWR state too
Date: Thu, 14 Oct 2010 14:52:09 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1010141450290.26447@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-1444993615-1287057129=:26447"
To: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:55938 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753357Ab0JNLwK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 07:52:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1444993615-1287057129=:26447
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT

As CWR is stronger than CA_Disorder state, we can miscount
SACK/Reno failure into other timeouts. Not a bad problem as
it can happen only due to ECN, FRTO detecting spurious RTO
or xmit error which are the only callers of tcp_enter_cwr.
And even then losses and RTO must still follow thereafter
to actually end up into the relevant code paths.

Compile tested.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_timer.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 74c54b3..16e591e 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -365,18 +365,19 @@ void tcp_retransmit_timer(struct sock *sk)
 	if (icsk->icsk_retransmits == 0) {
 		int mib_idx;
 
-		if (icsk->icsk_ca_state == TCP_CA_Disorder) {
-			if (tcp_is_sack(tp))
-				mib_idx = LINUX_MIB_TCPSACKFAILURES;
-			else
-				mib_idx = LINUX_MIB_TCPRENOFAILURES;
-		} else if (icsk->icsk_ca_state == TCP_CA_Recovery) {
+		if (icsk->icsk_ca_state == TCP_CA_Recovery) {
 			if (tcp_is_sack(tp))
 				mib_idx = LINUX_MIB_TCPSACKRECOVERYFAIL;
 			else
 				mib_idx = LINUX_MIB_TCPRENORECOVERYFAIL;
 		} else if (icsk->icsk_ca_state == TCP_CA_Loss) {
 			mib_idx = LINUX_MIB_TCPLOSSFAILURES;
+		} else if ((icsk->icsk_ca_state == TCP_CA_Disorder) ||
+			   tp->sacked_out) {
+			if (tcp_is_sack(tp))
+				mib_idx = LINUX_MIB_TCPSACKFAILURES;
+			else
+				mib_idx = LINUX_MIB_TCPRENOFAILURES;
 		} else {
 			mib_idx = LINUX_MIB_TCPTIMEOUTS;
 		}
-- 
1.5.6.3

--8323329-1444993615-1287057129=:26447--
