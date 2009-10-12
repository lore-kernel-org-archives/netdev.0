From: jamal <hadi@cyberus.ca>
Subject: [PATCH] iputils: ping by mark
Date: Mon, 12 Oct 2009 17:05:58 -0400
Message-ID: <1255381558.5406.33.camel@dogo.mojatatu.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Fp94z2bBC7o5LzVc2+Di"
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f186.google.com ([209.85.221.186]:46622 "EHLO
	mail-qy0-f186.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757991AbZJLVJg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 17:09:36 -0400
Received: by qyk16 with SMTP id 16so2676713qyk.15
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2009 14:08:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Fp94z2bBC7o5LzVc2+Di
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


ping by mark, example to use firewall mark decimal 10 
(which hopefully maps to something meaningful with policy routing):

ping -m 10 10.0.0.1 

cheers,
jamal

--=-Fp94z2bBC7o5LzVc2+Di
Content-Disposition: attachment; filename=ping-mark
Content-Type: text/plain; name=ping-mark; charset=UTF-8
Content-Transfer-Encoding: 7bit

commit 7afb1e52ecc8bda3677f8b7db8433486936d473f
Author: Jamal Hadi Salim <hadi@cyberus.ca>
Date:   Mon Oct 12 16:59:27 2009 -0400

    [PATCH] iputils: ping by mark
    
    This extends ping to send a packet out based on a given
    mark using -m option. Useful with policy routing to take different paths
    to same destination ..
    
    Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

diff --git a/ping.c b/ping.c
index b67cff4..5c913e0 100644
--- a/ping.c
+++ b/ping.c
@@ -1216,7 +1216,7 @@ void usage(void)
 	fprintf(stderr,
 "Usage: ping [-LRUbdfnqrvVaA] [-c count] [-i interval] [-w deadline]\n"
 "            [-p pattern] [-s packetsize] [-t ttl] [-I interface or address]\n"
-"            [-M mtu discovery hint] [-S sndbuf]\n"
+"            [-M mtu discovery hint] [-m mark] [-S sndbuf]\n"
 "            [ -T timestamp option ] [ -Q tos ] [hop1 ...] destination\n");
 	exit(2);
 }
diff --git a/ping_common.c b/ping_common.c
index be36cbd..b1cc9fc 100644
--- a/ping_common.c
+++ b/ping_common.c
@@ -4,6 +4,7 @@
 
 int options;
 
+int mark;
 int sndbuf;
 int ttl;
 int rtt;
@@ -141,6 +142,17 @@ void common_options(int ch)
 		options |= F_INTERVAL;
 		break;
 	}
+	case 'm':
+	{
+		char *endp;
+		mark = (int)strtoul(optarg, &endp, 10);
+		if (mark < 0 || *endp != '\0') {
+			fprintf(stderr, "mark cannot be negative");
+			exit(2);
+		}
+		options |= F_MARK;
+		break;
+	}
 	case 'w':
 		deadline = atoi(optarg);
 		if (deadline < 0) {
@@ -442,6 +454,15 @@ void setup(int icmp_sock)
 			fprintf(stderr, "Warning: no SO_TIMESTAMP support, falling back to SIOCGSTAMP\n");
 	}
 #endif
+	if (options & F_MARK) {
+		if (setsockopt(icmp_sock, SOL_SOCKET, SO_MARK,
+				&mark, sizeof(mark)) == -1) {
+			/* we probably dont wanna exit since old kernels
+			 * dont support mark ..
+			*/
+			fprintf(stderr, "Warning: Failed to set mark %d\n", mark);
+		}
+	}
 
 	/* Set some SNDTIMEO to prevent blocking forever
 	 * on sends, when device is too slow or stalls. Just put limit
diff --git a/ping_common.h b/ping_common.h
index 5b80118..466792e 100644
--- a/ping_common.h
+++ b/ping_common.h
@@ -60,6 +60,7 @@ extern int options;
 #define	F_STRICTSOURCE	0x8000
 #define F_NOLOOP	0x10000
 #define F_TTL		0x20000
+#define F_MARK		0x40000
 
 /*
  * MAX_DUP_CHK is the number of bits in received table, i.e. the maximum
@@ -118,9 +119,9 @@ case 'a': case 'U': case 'c': case 'd': \
 case 'f': case 'i': case 'w': case 'l': \
 case 'S': case 'n': case 'p': case 'q': \
 case 'r': case 's': case 'v': case 'L': \
-case 't': case 'A': case 'W': case 'B':
+case 't': case 'A': case 'W': case 'B': case 'm':
 
-#define COMMON_OPTSTR "h?VQ:I:M:aUc:dfi:w:l:S:np:qrs:vLt:AW:B"
+#define COMMON_OPTSTR "h?VQ:I:M:aUc:dfi:w:l:S:np:qrs:vLt:AW:Bm:"
 
 
 /*

--=-Fp94z2bBC7o5LzVc2+Di--

