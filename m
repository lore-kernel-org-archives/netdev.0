From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: avoid reloads in SNMP_UPD_PO_STATS
Date: Sun, 05 Aug 2012 08:26:13 +0200
Message-ID: <1344147973.9299.1563.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:44906 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751244Ab2HEG0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Aug 2012 02:26:18 -0400
Received: by weyx8 with SMTP id x8so1254442wey.19
        for <netdev@vger.kernel.org>; Sat, 04 Aug 2012 23:26:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Avoid two instructions to reload dev->nd_net->mib.ip_statistics pointer,
unsing a temp variable, in ip_rcv(), ip_output() paths for example.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/snmp.h |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/include/net/snmp.h b/include/net/snmp.h
index 0147b90..7159626 100644
--- a/include/net/snmp.h
+++ b/include/net/snmp.h
@@ -154,13 +154,15 @@ struct linux_xfrm_mib {
  */
 #define SNMP_UPD_PO_STATS(mib, basefield, addend)	\
 	do { \
-		this_cpu_inc(mib[0]->mibs[basefield##PKTS]);		\
-		this_cpu_add(mib[0]->mibs[basefield##OCTETS], addend);	\
+		__typeof__(*mib[0]->mibs) *ptr = mib[0]->mibs;	\
+		this_cpu_inc(ptr[basefield##PKTS]);		\
+		this_cpu_add(ptr[basefield##OCTETS], addend);	\
 	} while (0)
 #define SNMP_UPD_PO_STATS_BH(mib, basefield, addend)	\
 	do { \
-		__this_cpu_inc(mib[0]->mibs[basefield##PKTS]);		\
-		__this_cpu_add(mib[0]->mibs[basefield##OCTETS], addend);	\
+		__typeof__(*mib[0]->mibs) *ptr = mib[0]->mibs;	\
+		__this_cpu_inc(ptr[basefield##PKTS]);		\
+		__this_cpu_add(ptr[basefield##OCTETS], addend);	\
 	} while (0)
 
 
