From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH] dccp_diag: LISTEN sockets don't have CCIDs
Date: Wed, 17 Dec 2008 18:03:32 -0200
Message-ID: <20081217200332.GY14518@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	DCCP Mailing List <dccp@vger.kernel.org>,
	Linux Networking Development Mailing List
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:46153 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751101AbYLQUDp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Dec 2008 15:03:45 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And thus when we try to use 'ss -danemi' on these sockets that have no
ccid blocks (data collected using systemtap after I fixed the problem):

dccp_diag_get_info sk=0xffff8801220a3100, dp->dccps_hc_rx_ccid=0x0000000000000000, dp->dccps_hc_tx_ccid=0x0000000000000000

We get an OOPS:

mica.ghostprotocols.net login: BUG: unable to handle kernel NULL pointer
dereferenc0
IP: [<ffffffffa0136082>] dccp_diag_get_info+0x82/0xc0 [dccp_diag]
PGD 12106f067 PUD 122488067 PMD 0
Oops: 0000 [#1] PREEMPT

Fix is trivial, and 'ss -d' is working again:

[root@mica ~]# ss -danemi
State   Recv-Q Send-Q   Local Address:Port   Peer Address:Port 
LISTEN  0      0                    *:5001              *:*
ino:7288 sk:220a3100ffff8801
	 mem:(r0,w0,f0,t0) cwnd:0 ssthresh:0
[root@mica ~]# 

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

diff --git a/net/dccp/diag.c b/net/dccp/diag.c
index 652a1b6..b21f261 100644
--- a/net/dccp/diag.c
+++ b/net/dccp/diag.c
@@ -32,8 +32,11 @@ static void dccp_get_info(struct sock *sk, struct tcp_info *info)
 	if (dp->dccps_hc_rx_ackvec != NULL)
 		info->tcpi_options |= TCPI_OPT_SACK;
 
-	ccid_hc_rx_get_info(dp->dccps_hc_rx_ccid, sk, info);
-	ccid_hc_tx_get_info(dp->dccps_hc_tx_ccid, sk, info);
+	if (dp->dccps_hc_rx_ccid != NULL)
+		ccid_hc_rx_get_info(dp->dccps_hc_rx_ccid, sk, info);
+
+	if (dp->dccps_hc_tx_ccid != NULL)
+		ccid_hc_tx_get_info(dp->dccps_hc_tx_ccid, sk, info);
 }
 
 static void dccp_diag_get_info(struct sock *sk, struct inet_diag_msg *r,
