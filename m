From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [RFC] iproute2: reject zero length strings for matches
Date: Wed, 11 Oct 2017 18:21:44 -0700
Message-ID: <20171011182144.08ffc990@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:50916 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752470AbdJLBVz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 21:21:55 -0400
Received: by mail-pf0-f172.google.com with SMTP id m63so2723576pfk.7
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 18:21:55 -0700 (PDT)
Received: from xeon-e3 (76-14-207-240.or.wavecable.com. [76.14.207.240])
        by smtp.gmail.com with ESMTPSA id f7sm495200pgq.5.2017.10.11.18.21.53
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 11 Oct 2017 18:21:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ip commands use the function matches() to allow for abbreviations like:
  $ ip l
  $ ip r

But the function does not check for zero length strings which is potentially error
prone (but might also break some power users assumptions). For example:

$ ip ""
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever

This patch checks for zero length strings and never matches the option.

$ ip ""
Object "" is unknown, try "ip help".

diff --git a/lib/utils.c b/lib/utils.c
index ac155bf5a044..b68a2e0f4a07 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -733,7 +733,7 @@ int matches(const char *cmd, const char *pattern)
 {
 	int len = strlen(cmd);
 
-	if (len > strlen(pattern))
+	if (len == 0 || len > strlen(pattern))
 		return -1;
 	return memcmp(pattern, cmd, len);
 }
