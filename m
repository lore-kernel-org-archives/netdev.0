From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH v2] sctp: Change defaults on cookie hmac selection
Date: Fri, 14 Dec 2012 20:22:01 -0500
Message-ID: <1355534521-32719-1-git-send-email-nhorman@tuxdriver.com>
References: <1355511060-27320-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46222 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932151Ab2LOBXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2012 20:23:05 -0500
In-Reply-To: <1355511060-27320-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recently I posted commit 3c68198e75 which made selection of the cookie hmac
algorithm selectable.  This is all well and good, but Linus noted that it
changes the default config:
http://marc.info/?l=linux-netdev&m=135536629004808&w=2

I've modified the sctp Kconfig file to reflect the recommended way of making
this choice, using the thermal driver example specified, and brought the
defaults back into line with the way they were prior to my origional patch

Also, on Linus' suggestion, re-adding ability to select default 'none' hmac
algorithm, so we don't needlessly bloat the kernel by forcing a non-none
default.  This also led me to note that we won't honor the default none
condition properly because of how sctp_net_init is encoded.  Fix that up as
well.

Tested by myself (allbeit fairly quickly).  All configuration combinations seems
to work soundly.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: David Miller <davem@davemloft.net>
CC: Linus Torvalds <torvalds@linux-foundation.org>
CC: Vlad Yasevich <vyasevich@gmail.com>
CC: linux-sctp@vger.kernel.org
---
 net/sctp/Kconfig    | 27 +++++++++++++++++++++++++--
 net/sctp/protocol.c |  4 ++--
 2 files changed, 27 insertions(+), 4 deletions(-)

diff --git a/net/sctp/Kconfig b/net/sctp/Kconfig
index a9edd2e..c262106 100644
--- a/net/sctp/Kconfig
+++ b/net/sctp/Kconfig
@@ -66,12 +66,36 @@ config SCTP_DBG_OBJCNT
 	  'cat /proc/net/sctp/sctp_dbg_objcnt'
 
 	  If unsure, say N
+choice
+	prompt "Default SCTP cookie HMAC encoding"
+	default SCTP_COOKIE_HMAC_MD5
+	help
+	  This option sets the default sctp cookie hmac algorithm
+	  when in doubt select 'md5'
+
+config SCTP_DEFAULT_COOKIE_HMAC_MD5
+	bool "Enable optional MD5 hmac cookie generation"
+	help
+	  Enable optional MD5 hmac based SCTP cookie generation
+	select SCTP_COOKIE_HMAC_MD5
+
+config SCTP_DEFAULT_COOKIE_HMAC_SHA1
+	bool "Enable optional SHA1 hmac cookie generation"
+	help
+	  Enable optional SHA1 hmac based SCTP cookie generation
+	select SCTP_COOKIE_HMAC_SHA1
+
+config SCTP_DEFAULT_COOKIE_HMAC_NONE
+	bool "Use no hmac alg in SCTP cookie generation"
+	help
+	  Use no hmac algorithm in SCTP cookie generation
+
+endchoice
 
 config SCTP_COOKIE_HMAC_MD5
 	bool "Enable optional MD5 hmac cookie generation"
 	help
 	  Enable optional MD5 hmac based SCTP cookie generation
-	default y
 	select CRYPTO_HMAC if SCTP_COOKIE_HMAC_MD5
 	select CRYPTO_MD5 if SCTP_COOKIE_HMAC_MD5
 
@@ -79,7 +103,6 @@ config SCTP_COOKIE_HMAC_SHA1
 	bool "Enable optional SHA1 hmac cookie generation"
 	help
 	  Enable optional SHA1 hmac based SCTP cookie generation
-	default y
 	select CRYPTO_HMAC if SCTP_COOKIE_HMAC_SHA1
 	select CRYPTO_SHA1 if SCTP_COOKIE_HMAC_SHA1
 
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 2c7785b..f898b1c 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1191,9 +1191,9 @@ static int __net_init sctp_net_init(struct net *net)
 	net->sctp.cookie_preserve_enable 	= 1;
 
 	/* Default sctp sockets to use md5 as their hmac alg */
-#if defined (CONFIG_CRYPTO_MD5)
+#if defined (CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5)
 	net->sctp.sctp_hmac_alg			= "md5";
-#elif defined (CONFIG_CRYPTO_SHA1)
+#elif defined (CONFIG_SCTP_DEFAULT_COOKIE_HMAC_SHA1)
 	net->sctp.sctp_hmac_alg			= "sha1";
 #else
 	net->sctp.sctp_hmac_alg			= NULL;
-- 
1.7.11.7
