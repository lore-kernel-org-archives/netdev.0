From: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>
Subject: [PATCH v3 2/4] checkpatch: suggest using eth_zero_addr() and eth_broadcast_addr()
Date: Sun, 26 Apr 2015 18:43:18 +0200
Message-ID: <1430066600-12210-3-git-send-email-mateusz.kulikowski@gmail.com>
References: <1430066600-12210-1-git-send-email-mateusz.kulikowski@gmail.com>
Cc: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com, apw@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:32914 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752165AbbDZQnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Apr 2015 12:43:33 -0400
In-Reply-To: <1430066600-12210-1-git-send-email-mateusz.kulikowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Suggest using eth_zero_addr() or eth_broadcast_addr() instead of memset().

Signed-off-by: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>
---
 scripts/checkpatch.pl | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 0a511b7..263e831 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -5043,6 +5043,29 @@ sub process {
 			     "Prefer ether_addr_equal() or ether_addr_equal_unaligned() over memcmp()\n" . "$here\n$stat\n")
 		}
 
+# check for memset(foo, 0x0, ETH_ALEN) that could be eth_zero_addr
+# check for memset(foo, 0xFF, ETH_ALEN) that could be eth_broadcast_addr
+		if ($^V && $^V ge 5.10.0 &&
+		    defined $stat &&
+		    $stat =~ /^\+(?:.*?)\bmemset\s*\(\s*$FuncArg\s*,\s*$FuncArg\s*\,\s*ETH_ALEN\s*\)/) {
+
+			my $ms_val = $7;
+
+			if ($ms_val =~ /^(?:0x|)0+$/i) {
+				if (WARN("PREFER_ETH_ZERO_ADDR",
+					 "Prefer eth_zero_addr over memset()\n" . "$here\n$stat\n") &&
+				    $fix) {
+					$fixed[$fixlinenr] =~ s/\bmemset\s*\(\s*$FuncArg\s*,\s*$FuncArg\s*,\s*ETH_ALEN\s*\)/eth_zero_addr($2)/;
+				}
+			} elsif ($ms_val =~ /^(?:0xff|255)$/i) {
+				if (WARN("PREFER_ETH_BROADCAST_ADDR",
+					 "Prefer eth_broadcast_addr() over memset()\n" . "$here\n$stat\n") &&
+				    $fix) {
+					$fixed[$fixlinenr] =~ s/\bmemset\s*\(\s*$FuncArg\s*,\s*$FuncArg\s*,\s*ETH_ALEN\s*\)/eth_broadcast_addr($2)/;
+				}
+			}
+		}
+
 # typecasts on min/max could be min_t/max_t
 		if ($^V && $^V ge 5.10.0 &&
 		    defined $stat &&
-- 
1.8.4.1
