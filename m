From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [BK PATCH] 2.4 SCTP updates
Date: Tue, 23 Mar 2004 12:15:41 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0403231214110.1818@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,

Please do a
        bk pull http://linux-lksctp.bkbits.net/lksctp-2.4.work
to get the following update to SCTP on top of linux 2.4.26-pre5

# This patch includes the following deltas:
#	           ChangeSet	1.1309  -> 1.1311
#	net/sctp/sm_make_chunk.c	1.4     -> 1.5
#	 net/sctp/ulpevent.c	1.4     -> 1.5
#	  net/sctp/Config.in	1.5     -> 1.6
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/03/23	sri@us.ibm.com	1.1310
# [SCTP] Don't do any ppid byte-order conversions as it is opaque to SCTP.
# --------------------------------------------
# 04/03/23	sri@us.ibm.com	1.1311
# [SCTP] Avoid the use of hacking CONFIG_IPV6_SCTP__ option.
# --------------------------------------------
#
diff -Nru a/net/sctp/Config.in b/net/sctp/Config.in
--- a/net/sctp/Config.in	Tue Mar 23 11:54:53 2004
+++ b/net/sctp/Config.in	Tue Mar 23 11:54:53 2004
@@ -4,39 +4,38 @@
 mainmenu_option next_comment
 comment '   SCTP Configuration (EXPERIMENTAL)'

-if [ "$CONFIG_IPV6" != "n" ]; then
-   define_bool CONFIG_IPV6_SCTP__ $CONFIG_IPV6
+if [ "$CONFIG_IPV6" = "n" ]; then
+  tristate '  The SCTP Protocol (EXPERIMENTAL)' CONFIG_IP_SCTP
 else
-   define_bool CONFIG_IPV6_SCTP__ y
+  dep_tristate '  The SCTP Protocol (EXPERIMENTAL)' CONFIG_IP_SCTP $CONFIG_IPV6
 fi

-dep_tristate '  The SCTP Protocol (EXPERIMENTAL)' CONFIG_IP_SCTP $CONFIG_IPV6_SCTP__
 if [ "$CONFIG_IP_SCTP" != "n" ]; then
-   bool '    SCTP: Debug messages' CONFIG_SCTP_DBG_MSG
-   bool '    SCTP: Debug object counts' CONFIG_SCTP_DBG_OBJCNT
-fi
-if [ "$CONFIG_CRYPTO_HMAC" = "n" ]; then
-  choice '    SCTP: Cookie HMAC Algorithm' \
-        "HMAC-NONE		CONFIG_SCTP_HMAC_NONE" HMAC-NONE
-else
-  if [ "$CONFIG_CRYPTO_MD5" = "n" -a "$CONFIG_CRYPTO_SHA1" = "n" ]; then
+  bool '    SCTP: Debug messages' CONFIG_SCTP_DBG_MSG
+  bool '    SCTP: Debug object counts' CONFIG_SCTP_DBG_OBJCNT
+  if [ "$CONFIG_CRYPTO_HMAC" = "n" ]; then
     choice '    SCTP: Cookie HMAC Algorithm' \
-        "HMAC-NONE		CONFIG_SCTP_HMAC_NONE" HMAC-NONE
+      "HMAC-NONE		CONFIG_SCTP_HMAC_NONE" HMAC-NONE
   else
-    if [ "$CONFIG_CRYPTO_MD5" != "n" -a "$CONFIG_CRYPTO_SHA1" != "n" ]; then
+    if [ "$CONFIG_CRYPTO_MD5" = "n" -a "$CONFIG_CRYPTO_SHA1" = "n" ]; then
       choice '    SCTP: Cookie HMAC Algorithm' \
-        "HMAC-NONE		CONFIG_SCTP_HMAC_NONE \
-         HMAC-SHA1              CONFIG_SCTP_HMAC_SHA1 \
-         HMAC-MD5		CONFIG_SCTP_HMAC_MD5"	HMAC-SHA1
+        "HMAC-NONE		CONFIG_SCTP_HMAC_NONE" HMAC-NONE
     else
-      if [ "$CONFIG_CRYPTO_MD5" != "n" ]; then
-        choice 'SCTP: Cookie HMAC Algorithm' \
-        "HMAC-NONE		CONFIG_SCTP_HMAC_NONE \
-         HMAC-MD5		CONFIG_SCTP_HMAC_MD5"	HMAC-MD5
+      if [ "$CONFIG_CRYPTO_MD5" != "n" -a "$CONFIG_CRYPTO_SHA1" != "n" ]; then
+        choice '    SCTP: Cookie HMAC Algorithm' \
+          "HMAC-NONE		CONFIG_SCTP_HMAC_NONE \
+           HMAC-SHA1              CONFIG_SCTP_HMAC_SHA1 \
+           HMAC-MD5		CONFIG_SCTP_HMAC_MD5"	HMAC-MD5
       else
-        choice 'SCTP: Cookie HMAC Algorithm' \
-        "HMAC-NONE		CONFIG_SCTP_HMAC_NONE \
-         HMAC-SHA1		CONFIG_SCTP_HMAC_SHA1"	HMAC-SHA1
+        if [ "$CONFIG_CRYPTO_MD5" != "n" ]; then
+          choice 'SCTP: Cookie HMAC Algorithm' \
+          "HMAC-NONE		CONFIG_SCTP_HMAC_NONE \
+           HMAC-MD5		CONFIG_SCTP_HMAC_MD5"	HMAC-MD5
+        else
+          choice 'SCTP: Cookie HMAC Algorithm' \
+          "HMAC-NONE		CONFIG_SCTP_HMAC_NONE \
+           HMAC-SHA1		CONFIG_SCTP_HMAC_SHA1"	HMAC-SHA1
+        fi
       fi
     fi
   fi
diff -Nru a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
--- a/net/sctp/sm_make_chunk.c	Tue Mar 23 11:54:53 2004
+++ b/net/sctp/sm_make_chunk.c	Tue Mar 23 11:54:53 2004
@@ -516,7 +516,7 @@
 	 */
 	dp.tsn = 0;
 	dp.stream = htons(sinfo->sinfo_stream);
-	dp.ppid   = htonl(sinfo->sinfo_ppid);
+	dp.ppid   = sinfo->sinfo_ppid;

 	/* Set the flags for an unordered send.  */
 	if (sinfo->sinfo_flags & MSG_UNORDERED) {
diff -Nru a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
--- a/net/sctp/ulpevent.c	Tue Mar 23 11:54:53 2004
+++ b/net/sctp/ulpevent.c	Tue Mar 23 11:54:53 2004
@@ -663,7 +663,7 @@
 	 * for and this information is passed opaquely by the SCTP stack from
 	 * one end to the other.
 	 */
-	info->sinfo_ppid = ntohl(chunk->subh.data_hdr->ppid);
+	info->sinfo_ppid = chunk->subh.data_hdr->ppid;

 	/* Sockets API Extensions for SCTP
 	 * Section 5.2.2 SCTP Header Information Structure (SCTP_SNDRCV)
