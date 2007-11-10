From: osprey67 <osprey67@yahoo.com>
Subject: [PATCH 01/01] iproute2-2.6.23: RFC4214 Support (3)
Date: Fri, 09 Nov 2007 16:42:53 -0800
Message-ID: <4734FE8D.5070107@yahoo.com>
References: <473371B3.5030908@yahoo.com> <4734FCEF.3080301@yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080702010100040905060108"
Cc: osprey67 <osprey67@yahoo.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp120.plus.mail.sp1.yahoo.com ([69.147.95.83]:36498 "HELO
	smtp120.plus.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754793AbXKJAnX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2007 19:43:23 -0500
In-Reply-To: <4734FCEF.3080301@yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080702010100040905060108
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

From: Fred L. Templin <fred.l.templin@boeing.com>

This is experimental support for the Intra-Site Automatic
Tunnel Addressing Protocol (ISATAP) per RFC4214. It uses
the SIT module, and is configured using the unmodified
"ip" utility with device names beginning with: "isatap".

The following diffs are specific to the iproute2-2.6.23
software distribution. The diff text file itself is also
attached and should be suitable for use with the patch
utility.

Signed-off-by: Fred L. Templin <fred.l.templin@boeing.com>

---

--- iproute2-2.6.23/ip/iptunnel.c.orig  2007-11-08 16:27:24.000000000 -0800
+++ iproute2-2.6.23/ip/iptunnel.c       2007-11-09 15:47:06.000000000 -0800
@@ -1,3 +1,5 @@
+#define ISATAP
+
  /*
   * iptunnel.c         "ip tunnel"
   *
@@ -39,7 +41,12 @@ static void usage(void) __attribute__((n
  static void usage(void)
  {
         fprintf(stderr, "Usage: ip tunnel { add | change | del | show } [ NAME ]\n");
+#if defined(ISATAP)
+       fprintf(stderr, "          [ mode { ipip | gre | sit | isatap } ]\n");
+       fprintf(stderr, "          [ remote ADDR ] [ local ADDR ] [ router ADDR ] [ lifetime NUMBER ]\n");
+#else
         fprintf(stderr, "          [ mode { ipip | gre | sit } ] [ remote ADDR ] [ local ADDR ]\n");
+#endif
         fprintf(stderr, "          [ [i|o]seq ] [ [i|o]key KEY ] [ [i|o]csum ]\n");
         fprintf(stderr, "          [ ttl TTL ] [ tos TOS ] [ [no]pmtudisc ] [ dev PHYS_DEV ]\n");
         fprintf(stderr, "\n");
@@ -55,6 +62,9 @@ static int parse_args(int argc, char **a
  {
         int count = 0;
         char medium[IFNAMSIZ];
+#if defined(ISATAP)
+       int isatap = 0;
+#endif

         memset(p, 0, sizeof(*p));
         memset(&medium, 0, sizeof(medium));
@@ -90,6 +100,15 @@ static int parse_args(int argc, char **a
                                         exit(-1);
                                 }
                                 p->iph.protocol = IPPROTO_IPV6;
+#if defined(ISATAP)
+                       } else if (strcmp(*argv, "isatap") == 0) {
+                               if (p->iph.protocol && p->iph.protocol != IPPROTO_IPV6) {
+                                       fprintf(stderr,"You managed to ask for more than one tunnel mode.\n");
+                                       exit(-1);
+                               }
+                               p->iph.protocol = IPPROTO_IPV6;
+                               isatap++;
+#endif
                         } else {
                                 fprintf(stderr,"Cannot guess tunnel mode.\n");
                                 exit(-1);
@@ -160,6 +179,20 @@ static int parse_args(int argc, char **a
                         NEXT_ARG();
                         if (strcmp(*argv, "any"))
                                 p->iph.saddr = get_addr32(*argv);
+#if defined(ISATAP)
+               } else if (strcmp(*argv, "router") == 0) {
+                       NEXT_ARG();
+                       if (strcmp(*argv, "any"))
+                               p->router = get_addr32(*argv);
+               } else if (strcmp(*argv, "lifetime") == 0) {
+                       unsigned uval;
+                       NEXT_ARG();
+                       if (get_unsigned(&uval, *argv, 0)) {
+                               invarg("invalid lifetime\n", *argv);
+                               exit(-1);
+                       }
+                       p->lifetime = uval;
+#endif
                 } else if (strcmp(*argv, "dev") == 0) {
                         NEXT_ARG();
                         strncpy(medium, *argv, IFNAMSIZ-1);
@@ -212,6 +245,12 @@ static int parse_args(int argc, char **a
                         p->iph.protocol = IPPROTO_IPIP;
                 else if (memcmp(p->name, "sit", 3) == 0)
                         p->iph.protocol = IPPROTO_IPV6;
+#if defined(ISATAP)
+               else if (memcmp(p->name, "isatap", 6) == 0) {
+                       p->iph.protocol = IPPROTO_IPV6;
+                       isatap++;
+               }
+#endif
         }

         if (p->iph.protocol == IPPROTO_IPIP || p->iph.protocol == IPPROTO_IPV6) {
@@ -239,6 +278,22 @@ static int parse_args(int argc, char **a
                 fprintf(stderr, "Broadcast tunnel requires a source address.\n");
                 return -1;
         }
+#if defined(ISATAP)
+       if (isatap) {
+               if (p->iph.daddr) {
+                       fprintf(stderr, "no remote with isatap.\n");
+                       return -1;
+               }
+               if (!p->router) p->router = INADDR_NONE;
+               if (!p->lifetime) p->lifetime = 120;
+       } else {
+               if (p->router || p->lifetime) {
+                       fprintf(stderr, "router/lifetime only for isatap.\n");
+                       return -1;
+               }
+       }
+#endif
+
         return 0;
  }


--------------080702010100040905060108
Content-Type: text/plain;
 name="isatap_iproute2.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="isatap_iproute2.txt"

--- iproute2-2.6.23/ip/iptunnel.c.orig	2007-11-08 16:27:24.000000000 -0800
+++ iproute2-2.6.23/ip/iptunnel.c	2007-11-09 15:47:06.000000000 -0800
@@ -1,3 +1,5 @@
+#define ISATAP
+
 /*
  * iptunnel.c	       "ip tunnel"
  *
@@ -39,7 +41,12 @@ static void usage(void) __attribute__((n
 static void usage(void)
 {
 	fprintf(stderr, "Usage: ip tunnel { add | change | del | show } [ NAME ]\n");
+#if defined(ISATAP)
+	fprintf(stderr, "          [ mode { ipip | gre | sit | isatap } ]\n");
+	fprintf(stderr, "          [ remote ADDR ] [ local ADDR ] [ router ADDR ] [ lifetime NUMBER ]\n");
+#else
 	fprintf(stderr, "          [ mode { ipip | gre | sit } ] [ remote ADDR ] [ local ADDR ]\n");
+#endif
 	fprintf(stderr, "          [ [i|o]seq ] [ [i|o]key KEY ] [ [i|o]csum ]\n");
 	fprintf(stderr, "          [ ttl TTL ] [ tos TOS ] [ [no]pmtudisc ] [ dev PHYS_DEV ]\n");
 	fprintf(stderr, "\n");
@@ -55,6 +62,9 @@ static int parse_args(int argc, char **a
 {
 	int count = 0;
 	char medium[IFNAMSIZ];
+#if defined(ISATAP)
+	int isatap = 0;
+#endif
 
 	memset(p, 0, sizeof(*p));
 	memset(&medium, 0, sizeof(medium));
@@ -90,6 +100,15 @@ static int parse_args(int argc, char **a
 					exit(-1);
 				}
 				p->iph.protocol = IPPROTO_IPV6;
+#if defined(ISATAP)
+			} else if (strcmp(*argv, "isatap") == 0) {
+				if (p->iph.protocol && p->iph.protocol != IPPROTO_IPV6) {
+					fprintf(stderr,"You managed to ask for more than one tunnel mode.\n");
+					exit(-1);
+				}
+				p->iph.protocol = IPPROTO_IPV6;
+				isatap++;
+#endif
 			} else {
 				fprintf(stderr,"Cannot guess tunnel mode.\n");
 				exit(-1);
@@ -160,6 +179,20 @@ static int parse_args(int argc, char **a
 			NEXT_ARG();
 			if (strcmp(*argv, "any"))
 				p->iph.saddr = get_addr32(*argv);
+#if defined(ISATAP)
+		} else if (strcmp(*argv, "router") == 0) {
+			NEXT_ARG();
+			if (strcmp(*argv, "any"))
+				p->router = get_addr32(*argv);
+		} else if (strcmp(*argv, "lifetime") == 0) {
+			unsigned uval;
+			NEXT_ARG();
+			if (get_unsigned(&uval, *argv, 0)) {
+				invarg("invalid lifetime\n", *argv);
+				exit(-1);
+			}
+			p->lifetime = uval;
+#endif
 		} else if (strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
 			strncpy(medium, *argv, IFNAMSIZ-1);
@@ -212,6 +245,12 @@ static int parse_args(int argc, char **a
 			p->iph.protocol = IPPROTO_IPIP;
 		else if (memcmp(p->name, "sit", 3) == 0)
 			p->iph.protocol = IPPROTO_IPV6;
+#if defined(ISATAP)
+		else if (memcmp(p->name, "isatap", 6) == 0) {
+			p->iph.protocol = IPPROTO_IPV6;
+			isatap++;
+		}
+#endif
 	}
 
 	if (p->iph.protocol == IPPROTO_IPIP || p->iph.protocol == IPPROTO_IPV6) {
@@ -239,6 +278,22 @@ static int parse_args(int argc, char **a
 		fprintf(stderr, "Broadcast tunnel requires a source address.\n");
 		return -1;
 	}
+#if defined(ISATAP)
+	if (isatap) {
+		if (p->iph.daddr) {
+			fprintf(stderr, "no remote with isatap.\n");
+			return -1;
+		}
+		if (!p->router) p->router = INADDR_NONE;
+		if (!p->lifetime) p->lifetime = 120;
+	} else {
+		if (p->router || p->lifetime) {
+			fprintf(stderr, "router/lifetime only for isatap.\n");
+			return -1;
+		}
+	}
+#endif
+
 	return 0;
 }
 

--------------080702010100040905060108--
