From: Ralf Baechle DL5RB <ralf@linux-mips.org>
Subject: [AX.25] Make asc2ax thread-proof
Date: Wed, 7 Sep 2005 15:34:01 +0100
Message-ID: <20050907143401.GC3493@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Asc2ax was still using a static buffer for all invocations which isn't
exactly SMP-safe.  Change asc2ax to take an additional result buffer as
the argument.  Change all callers to provide such a buffer.

This one only really is a fix for ROSE and as per recent discussions
there's still much more to fix in ROSE ...

Signed-off-by: Ralf Baechle DL5RB <ralf@linux-mips.org>

 include/net/ax25.h   |    2 +-
 net/ax25/ax25_addr.c |   27 ++++++++++++---------------
 net/rose/rose_subr.c |    4 ++--
 3 files changed, 15 insertions(+), 18 deletions(-)

Index: linux-cvs/include/net/ax25.h
===================================================================
--- linux-cvs.orig/include/net/ax25.h
+++ linux-cvs/include/net/ax25.h
@@ -279,7 +279,7 @@ extern struct sock *ax25_make_new(struct
 /* ax25_addr.c */
 extern ax25_address null_ax25_address;
 extern char *ax2asc(char *buf, ax25_address *);
-extern ax25_address *asc2ax(char *);
+extern void asc2ax(ax25_address *addr, char *callsign);
 extern int  ax25cmp(ax25_address *, ax25_address *);
 extern int  ax25digicmp(ax25_digi *, ax25_digi *);
 extern unsigned char *ax25_addr_parse(unsigned char *, int, ax25_address *, ax25_address *, ax25_digi *, int *, int *);
Index: linux-cvs/net/ax25/ax25_addr.c
===================================================================
--- linux-cvs.orig/net/ax25/ax25_addr.c
+++ linux-cvs/net/ax25/ax25_addr.c
@@ -67,37 +67,34 @@ char *ax2asc(char *buf, ax25_address *a)
 /*
  *	ascii -> ax25 conversion
  */
-ax25_address *asc2ax(char *callsign)
+void asc2ax(ax25_address *addr, char *callsign)
 {
-	static ax25_address addr;
 	char *s;
 	int n;
 
 	for (s = callsign, n = 0; n < 6; n++) {
 		if (*s != '\0' && *s != '-')
-			addr.ax25_call[n] = *s++;
+			addr->ax25_call[n] = *s++;
 		else
-			addr.ax25_call[n] = ' ';
-		addr.ax25_call[n] <<= 1;
-		addr.ax25_call[n] &= 0xFE;
+			addr->ax25_call[n] = ' ';
+		addr->ax25_call[n] <<= 1;
+		addr->ax25_call[n] &= 0xFE;
 	}
 
 	if (*s++ == '\0') {
-		addr.ax25_call[6] = 0x00;
-		return &addr;
+		addr->ax25_call[6] = 0x00;
+		return;
 	}
 
-	addr.ax25_call[6] = *s++ - '0';
+	addr->ax25_call[6] = *s++ - '0';
 
 	if (*s != '\0') {
-		addr.ax25_call[6] *= 10;
-		addr.ax25_call[6] += *s++ - '0';
+		addr->ax25_call[6] *= 10;
+		addr->ax25_call[6] += *s++ - '0';
 	}
 
-	addr.ax25_call[6] <<= 1;
-	addr.ax25_call[6] &= 0x1E;
-
-	return &addr;
+	addr->ax25_call[6] <<= 1;
+	addr->ax25_call[6] &= 0x1E;
 }
 
 /*
Index: linux-cvs/net/rose/rose_subr.c
===================================================================
--- linux-cvs.orig/net/rose/rose_subr.c
+++ linux-cvs/net/rose/rose_subr.c
@@ -337,13 +337,13 @@ static int rose_parse_ccitt(unsigned cha
 				memcpy(&facilities->source_addr, p + 7, ROSE_ADDR_LEN);
 				memcpy(callsign, p + 12,   l - 10);
 				callsign[l - 10] = '\0';
-				facilities->source_call = *asc2ax(callsign);
+				asc2ax(&facilities->source_call, callsign);
 			}
 			if (*p == FAC_CCITT_SRC_NSAP) {
 				memcpy(&facilities->dest_addr, p + 7, ROSE_ADDR_LEN);
 				memcpy(callsign, p + 12, l - 10);
 				callsign[l - 10] = '\0';
-				facilities->dest_call = *asc2ax(callsign);
+				asc2ax(&facilities->dest_call, callsign);
 			}
 			p   += l + 2;
 			n   += l + 2;
