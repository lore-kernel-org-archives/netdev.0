From: love_phil@emc.com
Subject: [PATCH] tcp: fix tcp header size miscalculation when window scale is unused (resend)
Date: Tue, 26 Aug 2008 12:56:27 -0400 (EDT)
Message-ID: <200808261656.m7QGuR5k029805@mailhub.lss.emc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:40251 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757376AbYHZQ4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 12:56:33 -0400
Received: from hop04-l1d11-si02.isus.emc.com (HOP04-L1D11-SI02.isus.emc.com [10.254.111.55])
	by mexforward.lss.emc.com (Switch-3.2.5/Switch-3.1.7) with ESMTP id m7QGuUnN029971
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 12:56:30 -0400 (EDT)
Received: from mailhub.lss.emc.com (nagas.lss.emc.com [10.254.144.11]) by hop04-l1d11-si02.isus.emc.com (Tablus Interceptor) for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 12:34:45 -0400
Received: from psm2 ([10.5.240.191])
	by mailhub.lss.emc.com (Switch-3.2.5/Switch-3.1.7) with ESMTP id m7QGuR5k029805
	for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 12:56:29 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp: fix tcp header size miscalculation when window scale is unused

The size of the TCP header is miscalculated when the window scale ends up being 0. Additionally, this can be induced by sending a SYN to a passive open port with a window scale option with value 0.

Signed-off-by: Philip Love <love_phil@emc.com>


--- a/net/ipv4/tcp_output.c	2008-08-24 07:44:18.000000000 -0700
+++ b/net/ipv4/tcp_output.c	2008-08-24 07:43:05.000000000 -0700
@@ -468,7 +468,8 @@ static unsigned tcp_syn_options(struct s
 	}
 	if (likely(sysctl_tcp_window_scaling)) {
 		opts->ws = tp->rx_opt.rcv_wscale;
-		size += TCPOLEN_WSCALE_ALIGNED;
+		if(likely(opts->ws))
+			size += TCPOLEN_WSCALE_ALIGNED;
 	}
 	if (likely(sysctl_tcp_sack)) {
 		opts->options |= OPTION_SACK_ADVERTISE;
@@ -509,7 +510,8 @@ static unsigned tcp_synack_options(struc
 
 	if (likely(ireq->wscale_ok)) {
 		opts->ws = ireq->rcv_wscale;
-		size += TCPOLEN_WSCALE_ALIGNED;
+		if(likely(opts->ws))
+			size += TCPOLEN_WSCALE_ALIGNED;
 	}
 	if (likely(doing_ts)) {
 		opts->options |= OPTION_TS;
