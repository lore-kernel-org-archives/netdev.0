From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] bridge: avoid OOPS if root port not found
Date: Tue, 30 Apr 2013 08:29:27 -0700
Message-ID: <20130430082927.56aa0785@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:33883 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932930Ab3D3P3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 11:29:40 -0400
Received: by mail-pd0-f175.google.com with SMTP id g10so367566pdj.20
        for <netdev@vger.kernel.org>; Tue, 30 Apr 2013 08:29:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bridge can crash while trying to send topology change packet.
This happens if root port can't be found. This was reported by user
but currently unable to reproduce it easily. The STP conditions that cause
this are not known yet, but the problem doesn't have to be fatal.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/net/bridge/br_stp.c	2013-03-07 18:12:53.885287247 -0800
+++ b/net/bridge/br_stp.c	2013-04-30 08:24:05.935771645 -0700
@@ -225,7 +225,14 @@ static void br_record_config_timeout_val
 /* called under bridge lock */
 void br_transmit_tcn(struct net_bridge *br)
 {
-	br_send_tcn_bpdu(br_get_port(br, br->root_port));
+	struct net_bridge_port *p;
+
+	p = br_get_port(br, br->root_port);
+	if (p)
+		br_send_tcn_bpdu(p);
+	else
+		br_notice(br, "root port %u not found for topology notice\n",
+			  br->root_port);
 }
 
 /* called under bridge lock */
