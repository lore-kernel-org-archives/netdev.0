From: raj@tardy.usa.hp.com (Rick Jones)
Subject: [PATCH net-next] net: track success and failure of TCP PMTU probing
Date: Tue, 21 Jul 2015 16:14:13 -0700 (PDT)
Message-ID: <20150721231413.9BCA62900711@tardy>
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t1383g.austin.hp.com ([15.217.136.92]:48846 "EHLO
	g2t1383g.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932830AbbGUXOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 19:14:23 -0400
Received: from g1t5424.austin.hp.com (g1t5424.austin.hp.com [15.216.225.54])
	(using TLSv1.2 with cipher DHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by g2t1383g.austin.hp.com (Postfix) with ESMTPS id F2E835729
	for <netdev@vger.kernel.org>; Tue, 21 Jul 2015 23:14:15 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>

Track success and failure of TCP PMTU probing.

Signed-off-by: Rick Jones <rick.jones2@hp.com>

---

Tested by loading-up into an OpenStack instance and kicking the MTU
out from under it in the corresponding router namespace.

diff --git a/include/uapi/linux/snmp.h b/include/uapi/linux/snmp.h
index eee8968..25a9ad8 100644
--- a/include/uapi/linux/snmp.h
+++ b/include/uapi/linux/snmp.h
@@ -278,6 +278,8 @@ enum
 	LINUX_MIB_TCPACKSKIPPEDCHALLENGE,	/* TCPACKSkippedChallenge */
 	LINUX_MIB_TCPWINPROBE,			/* TCPWinProbe */
 	LINUX_MIB_TCPKEEPALIVE,			/* TCPKeepAlive */
+	LINUX_MIB_TCPMTUPFAIL,			/* TCPMTUPFail */
+	LINUX_MIB_TCPMTUPSUCCESS,		/* TCPMTUPSuccess */
 	__LINUX_MIB_MAX
 };
 
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index da5d483..3abd9d7 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -300,6 +300,8 @@ static const struct snmp_mib snmp4_net_list[] = {
 	SNMP_MIB_ITEM("TCPACKSkippedChallenge", LINUX_MIB_TCPACKSKIPPEDCHALLENGE),
 	SNMP_MIB_ITEM("TCPWinProbe", LINUX_MIB_TCPWINPROBE),
 	SNMP_MIB_ITEM("TCPKeepAlive", LINUX_MIB_TCPKEEPALIVE),
+	SNMP_MIB_ITEM("TCPMTUPFail", LINUX_MIB_TCPMTUPFAIL),
+	SNMP_MIB_ITEM("TCPMTUPSuccess", LINUX_MIB_TCPMTUPSUCCESS),
 	SNMP_MIB_SENTINEL
 };
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 1578fc2..cda3ffe 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2593,6 +2593,7 @@ static void tcp_mtup_probe_failed(struct sock *sk)
 
 	icsk->icsk_mtup.search_high = icsk->icsk_mtup.probe_size - 1;
 	icsk->icsk_mtup.probe_size = 0;
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPMTUPFAIL);
 }
 
 static void tcp_mtup_probe_success(struct sock *sk)
@@ -2612,6 +2613,7 @@ static void tcp_mtup_probe_success(struct sock *sk)
 	icsk->icsk_mtup.search_low = icsk->icsk_mtup.probe_size;
 	icsk->icsk_mtup.probe_size = 0;
 	tcp_sync_mss(sk, icsk->icsk_pmtu_cookie);
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPMTUPSUCCESS);
 }
 
 /* Do a simple retransmit without using the backoff mechanisms in
