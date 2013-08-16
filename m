From: Jiri Bohac <jbohac@suse.cz>
Subject: [PATCH 3/3] [RFC] TCP syncookies: only allow 3 MSS values by default
 to mitigate spoofing attacks
Date: Fri, 16 Aug 2013 02:05:23 +0200
Message-ID: <20130816000523.GC11950@midget.suse.cz>
References: <520A3B4A.1050704@jakoblell.com>
 <20130815235743.GA25665@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jakob Lell <jakob@jakoblell.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:46367 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752047Ab3HPAF1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Aug 2013 20:05:27 -0400
Content-Disposition: inline
In-Reply-To: <20130815235743.GA25665@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jakob Lell discovered that the sequence number that needs to be guessed to
successfully spoof a TCP connection with syncookies only has 27 bits of
entropy. Of the 32 bits, 3 are wasted by the 8 differrent RSS values. [1]

This patch decreases the number of possible MSS values from 8 to 3,
making the spoofing attack 8/3 times more difficult.

Rationale for the new values
- most packets are (1500 - headers); (1450 - headers) is not a huge waste and
  prevents fallback to much lower values
- clients will rarely send MSS below 536, so that's a safe fallback
- we need to keep the minimum (64)

[1]: http://www.jakoblell.com/blog/2013/08/13/quick-blind-tcp-connection-spoofing-with-syn-cookies/

Signed-off-by: Jiri Bohac <jbohac@suse.cz>
---
 net/ipv4/syncookies.c | 9 ++-------
 net/ipv6/syncookies.c | 9 ++-------
 2 files changed, 4 insertions(+), 14 deletions(-)

diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index af0692f..0504bbe 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -148,15 +148,10 @@ static __u32 check_tcp_syn_cookie(__u32 cookie, __be32 saddr, __be32 daddr,
 int sysctl_tcp4_syncookies_mss[TCP_SYNCOOKIES_MSS_COUNT_MAX] = {
 	64,
 	512,
-	536,
-	1024,
-	1440,
-	1460,
-	4312,
-	8960,
+	1450 - 40,
 	/* update sysctl_tcp4_syncookies_mss_count accordingly */
 };
-int sysctl_tcp4_syncookies_mss_count = 8;
+int sysctl_tcp4_syncookies_mss_count = 3;
 
 /*
  * This value is the age (in seconds) of syncookies which will always be
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 4268448..ccdb880 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -28,15 +28,10 @@
 int sysctl_tcp6_syncookies_mss[TCP_SYNCOOKIES_MSS_COUNT_MAX] = {
 	64,
 	512,
-	536,
-	1280 - 60,
-	1480 - 60,
-	1500 - 60,
-	4460 - 60,
-	9000 - 60,
+	1450 - 60,
 	/* update sysctl_tcp6_syncookies_mss_count accordingly */
 };
-int sysctl_tcp6_syncookies_mss_count = 8;
+int sysctl_tcp6_syncookies_mss_count = 3;
 
 /*
  * This value is the age (in seconds) of syncookies which will always be

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
