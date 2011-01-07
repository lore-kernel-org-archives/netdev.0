From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 3/3] dccp: make upper bound for seq_window consistent on 32/64 bit
Date: Fri,  7 Jan 2011 12:35:30 +0100
Message-ID: <1294400130-5604-4-git-send-email-gerrit@erg.abdn.ac.uk>
References: <0110107112837.GA5315@gerrit.erg.abdn.ac.uk>
 <1294400130-5604-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1294400130-5604-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1294400130-5604-3-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:57452 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752073Ab1AGLfq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jan 2011 06:35:46 -0500
In-Reply-To: <1294400130-5604-3-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 'seq_window' sysctl sets the initial value for the DCCP Sequence Window,
which may range from 32..2^46-1 (RFC 4340, 7.5.2). The patch sets the upper
bound consistently to 2^32-1 on both 32 and 64 bit systems, which should be
sufficient - with a RTT of 1sec and 1-byte packets, a seq_window of 2^32-1
corresponds to a link speed of 34 Gbps.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 Documentation/networking/dccp.txt |    1 +
 net/dccp/sysctl.c                 |    4 +++-
 2 files changed, 4 insertions(+), 1 deletions(-)

--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -167,6 +167,7 @@ rx_ccid = 2
 seq_window = 100
 	The initial sequence window (sec. 7.5.2) of the sender. This influences
 	the local ackno validity and the remote seqno validity windows (7.5.1).
+	Values in the range Wmin = 32 (RFC 4340, 7.5.2) up to 2^32-1 can be set.
 
 tx_qlen = 5
 	The size of the transmit buffer in packets. A value of 0 corresponds
--- a/net/dccp/sysctl.c
+++ b/net/dccp/sysctl.c
@@ -21,7 +21,8 @@
 /* Boundary values */
 static int		zero     = 0,
 			u8_max   = 0xFF;
-static unsigned long	seqw_min = 32;
+static unsigned long	seqw_min = DCCPF_SEQ_WMIN,
+			seqw_max = 0xFFFFFFFF;		/* maximum on 32 bit */
 
 static struct ctl_table dccp_default_table[] = {
 	{
@@ -31,6 +32,7 @@ static struct ctl_table dccp_default_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_doulongvec_minmax,
 		.extra1		= &seqw_min,		/* RFC 4340, 7.5.2 */
+		.extra2		= &seqw_max,
 	},
 	{
 		.procname	= "rx_ccid",
