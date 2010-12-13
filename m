From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Fw: [Bug 24842] New: Compatibility issue with uggly Windows RFC1323
 implementation.
Date: Mon, 13 Dec 2010 08:59:13 -0800
Message-ID: <20101213085913.374c1072@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33392 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758311Ab0LMQ7R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Dec 2010 11:59:17 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id BCE5518288EA
	for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 08:59:16 -0800 (PST)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id wcDSSAGW7+Kw for <netdev@vger.kernel.org>;
	Mon, 13 Dec 2010 08:59:15 -0800 (PST)
Received: from nehalam (pool-74-107-135-205.ptldor.fios.verizon.net [74.107.135.205])
	by mail.vyatta.com (Postfix) with ESMTPSA id 3B65918288C3
	for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 08:59:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon, 13 Dec 2010 14:29:58 GMT
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 24842] New: Compatibility issue with uggly Windows RFC1323 implementation.


https://bugzilla.kernel.org/show_bug.cgi?id=24842

           Summary: Compatibility issue with uggly Windows RFC1323
                    implementation.
           Product: Networking
           Version: 2.5
    Kernel Version: All
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: dmitriy.balakin@nicneiron.ru
        Regression: No


Created an attachment (id=40012)
 --> (https://bugzilla.kernel.org/attachment.cgi?id=40012)
Patch

First, sorry for my bad english. 

The issue is that Linux-based OS sometimes can't make an tcp connection to some
Windows servers with switched on buggy implementation of rfc1323, that
described on this forum:
http://www.network-builders.com/windows-tcp-timestamp-not-compliant-rfc-1323-a-t80898.html.

Because some Windows hosts implementation of rfc1323 bases on randomly
generated TSval and sent first value of TSval as 0, the difference of recent
and new TSval sometimes has been affected by a sign magic issue and the PAWS
mechanism has been triggered. Anyway, the rfc1323 has discribes the condition
of PAWS as "0 < (t - s) < 2**31", that has been right implementation in current
linux kernel, but incompatible with Windows bug.

For example, the one of affected to this issue Windows host is behind
relay.n-l-e.ru:80

I think that my small patch makes the kernel more compatible with this windows
bug.

-- 
--- include/net/tcp.h.orig	2010-12-02 04:41:22.000000000 +0300
+++ include/net/tcp.h	2010-12-13 13:58:05.000000000 +0300
@@ -1077,9 +1077,10 @@
 }
 
 static inline int tcp_paws_check(const struct tcp_options_received *rx_opt,
-				 int paws_win)
+				unsigned int paws_win)
 {
-	if ((s32)(rx_opt->ts_recent - rx_opt->rcv_tsval) <= paws_win)
+	if (rx_opt->ts_recent < rx_opt->rcv_tsval ||
+			rx_opt->ts_recent - rx_opt->rcv_tsval <= paws_win)
 		return 1;
 	if (unlikely(get_seconds() >= rx_opt->ts_recent_stamp + TCP_PAWS_24DAYS))
 		return 1;


-- 
