From: Matt Domsch <Matt_Domsch-8PEkshWhKlo@public.gmane.org>
Subject: [PATCH ppp-2.4.3] add SC_MUST_COMPRESS flag
Date: Sun, 14 Aug 2005 09:18:11 -0500
Message-ID: <20050814141810.GC20944@lists.us.dell.com>
References: <42B747C9.7060901@pobox.com> <17102.26269.264419.345257@cargo.ozlabs.ibm.com> <17102.30763.326707.473425@cargo.ozlabs.ibm.com> <20050814141046.GB20944@lists.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, akpm-3NddpPZAyC0@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Brice.Goglin-vYW+cPY1g1pg9hUCZPvPmw@public.gmane.org, james.cameron-VXdhtT5mjnY@public.gmane.org,
	pptpclient-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <pptpclient-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20050814141046.GB20944-XtjxT7Vmt5ZskZv2Y/7f+AC/G2K4zDHf@public.gmane.org>
Sender: pptpclient-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: pptpclient-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/pptpclient-devel>,
	<mailto:pptpclient-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:pptpclient-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:pptpclient-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/pptpclient-devel>,
	<mailto:pptpclient-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=pptpclient-devel>
List-Id: netdev.vger.kernel.org

PPP 2.4.3 patch creates the new flag SC_MUST_COMPRESS.  This is set on
CCP UP with MPPE enabled, and never cleared.  The kernel uses this
flag to drop packets which aren't compressed/decompressed properly
when MPPE is enabled.

In the existing code, on SIGUSR2, CCP is renegotiated, and with MPPE
enabled, LCP (and thus the link) is taken down, so the user can't
disable MPPE after it's enabled on a link.


1) sync to kernel's include/linux/if_ppp.h copy, adding
   SC_MUST_COMPRESS
2) add SC_MUST_COMPRESS to include/net/if_ppp.h also
3) set SC_MUST_COMPRESS on CCP UP

 include/linux/if_ppp.h |   62 +++++++++++++++++--------------------------------
 include/net/if_ppp.h   |    1
 pppd/ccp.c             |   15 +++++++----
 pppd/pppd.h            |    2 -
 pppd/sys-linux.c       |    6 +++-
 pppd/sys-solaris.c     |    4 +--
 6 files changed, 40 insertions(+), 50 deletions(-)


Lightly tested, review much appeciated.

Signed-off-by: Matt Domsch <Matt_Domsch-8PEkshWhKlo@public.gmane.org>

-- 
Matt Domsch
Software Architect
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com

diff -urNp --exclude-from=/mdomsch2/excludes --minimal ppp-2.4.3.orig/include/linux/if_ppp.h ppp-2.4.3.ppp_mppe/include/linux/if_ppp.h
--- ppp-2.4.3.orig/include/linux/if_ppp.h	2002-12-06 01:49:15.000000000 -0800
+++ ppp-2.4.3.ppp_mppe/include/linux/if_ppp.h	2005-08-12 11:07:01.000000000 -0700
@@ -1,50 +1,27 @@
-/*	$Id: if_ppp.h,v 1.23 2002/12/06 09:49:15 paulus Exp $	*/
+/*	$Id: if_ppp.h,v 1.21 2000/03/27 06:03:36 paulus Exp $	*/
 
 /*
  * if_ppp.h - Point-to-Point Protocol definitions.
  *
- * Copyright (c) 1984-2000 Carnegie Mellon University. All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions
- * are met:
- *
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- *
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in
- *    the documentation and/or other materials provided with the
- *    distribution.
- *
- * 3. The name "Carnegie Mellon University" must not be used to
- *    endorse or promote products derived from this software without
- *    prior written permission. For permission or any legal
- *    details, please contact
- *      Office of Technology Transfer
- *      Carnegie Mellon University
- *      5000 Forbes Avenue
- *      Pittsburgh, PA  15213-3890
- *      (412) 268-4387, fax: (412) 268-7395
- *      tech-transfer-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org
- *
- * 4. Redistributions of any form whatsoever must retain the following
- *    acknowledgment:
- *    "This product includes software developed by Computing Services
- *     at Carnegie Mellon University (http://www.cmu.edu/computing/)."
+ * Copyright (c) 1989 Carnegie Mellon University.
+ * All rights reserved.
  *
- * CARNEGIE MELLON UNIVERSITY DISCLAIMS ALL WARRANTIES WITH REGARD TO
- * THIS SOFTWARE, INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
- * AND FITNESS, IN NO EVENT SHALL CARNEGIE MELLON UNIVERSITY BE LIABLE
- * FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
- * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN
- * AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
- * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ * Redistribution and use in source and binary forms are permitted
+ * provided that the above copyright notice and this paragraph are
+ * duplicated in all such forms and that any documentation,
+ * advertising materials, and other materials related to such
+ * distribution and use acknowledge that the software was developed
+ * by Carnegie Mellon University.  The name of the
+ * University may not be used to endorse or promote products derived
+ * from this software without specific prior written permission.
+ * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
+ * IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
+ * WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
  *
  */
 
 /*
- *  ==FILEVERSION 20000724==
+ *  ==FILEVERSION 20050812==
  *
  *  NOTE TO MAINTAINERS:
  *     If you modify this file at all, please set the above date.
@@ -93,7 +70,8 @@
 #define SC_LOG_RAWIN	0x00080000	/* log all chars received */
 #define SC_LOG_FLUSH	0x00100000	/* log all chars flushed */
 #define	SC_SYNC		0x00200000	/* synchronous serial mode */
-#define	SC_MASK		0x0f200fff	/* bits that user can change */
+#define	SC_MUST_COMP    0x00400000	/* no uncompressed packets may be sent or received */
+#define	SC_MASK		0x0f600fff	/* bits that user can change */
 
 /* state bits */
 #define SC_XMIT_BUSY	0x10000000	/* (used by isdn_ppp?) */
@@ -113,9 +91,13 @@ struct npioctl {
 	enum NPmode	mode;
 };
 
+#ifndef __user
+#define __user
+#endif
+
 /* Structure describing a CCP configuration option, for PPPIOCSCOMPRESS */
 struct ppp_option_data {
-	__u8	*ptr;
+	__u8	__user *ptr;
 	__u32	length;
 	int	transmit;
 };
diff -urNp --exclude-from=/mdomsch2/excludes --minimal ppp-2.4.3.orig/include/net/if_ppp.h ppp-2.4.3.ppp_mppe/include/net/if_ppp.h
--- ppp-2.4.3.orig/include/net/if_ppp.h	2002-12-06 01:49:15.000000000 -0800
+++ ppp-2.4.3.ppp_mppe/include/net/if_ppp.h	2005-08-13 20:08:55.000000000 -0700
@@ -66,6 +66,7 @@
 #define SC_RCV_EVNP	0x04000000	/* have rcvd char with even parity */
 #define SC_RCV_ODDP	0x08000000	/* have rcvd char with odd parity */
 #define SC_SYNC		0x00200000	/* use synchronous HDLC framing */
+#define	SC_MUST_COMP    0x00400000	/* no uncompressed packets may be sent or received */
 #define	SC_MASK		0x0fff00ff	/* bits that user can change */
 
 /*
diff -urNp --exclude-from=/mdomsch2/excludes --minimal ppp-2.4.3.orig/pppd/ccp.c ppp-2.4.3.ppp_mppe/pppd/ccp.c
--- ppp-2.4.3.orig/pppd/ccp.c	2004-11-12 18:28:15.000000000 -0800
+++ ppp-2.4.3.ppp_mppe/pppd/ccp.c	2005-08-12 11:53:31.000000000 -0700
@@ -390,7 +390,7 @@ ccp_open(unit)
     fsm *f = &ccp_fsm[unit];
 
     if (f->state != OPENED)
-	ccp_flags_set(unit, 1, 0);
+	ccp_flags_set(unit, 1, 0, 0);
 
     /*
      * Find out which compressors the kernel supports before
@@ -411,7 +411,7 @@ ccp_close(unit, reason)
     int unit;
     char *reason;
 {
-    ccp_flags_set(unit, 0, 0);
+    ccp_flags_set(unit, 0, 0, 0);
     fsm_close(&ccp_fsm[unit], reason);
 }
 
@@ -511,7 +511,7 @@ static void
 ccp_protrej(unit)
     int unit;
 {
-    ccp_flags_set(unit, 0, 0);
+    ccp_flags_set(unit, 0, 0, 0);
     fsm_lowerdown(&ccp_fsm[unit]);
 
 #ifdef MPPE
@@ -1424,8 +1424,13 @@ ccp_up(f)
     ccp_options *go = &ccp_gotoptions[f->unit];
     ccp_options *ho = &ccp_hisoptions[f->unit];
     char method1[64];
+    int must_comp = 0;
 
-    ccp_flags_set(f->unit, 1, 1);
+#ifdef MPPE
+    if (go->mppe)
+	    must_comp = 1;
+#endif
+    ccp_flags_set(f->unit, 1, 1, must_comp);
     if (ANY_COMPRESS(*go)) {
 	if (ANY_COMPRESS(*ho)) {
 	    if (go->method == ho->method) {
@@ -1458,7 +1463,7 @@ ccp_down(f)
     if (ccp_localstate[f->unit] & RACK_PENDING)
 	UNTIMEOUT(ccp_rack_timeout, f);
     ccp_localstate[f->unit] = 0;
-    ccp_flags_set(f->unit, 1, 0);
+    ccp_flags_set(f->unit, 1, 0, 0);
 #ifdef MPPE
     if (ccp_gotoptions[f->unit].mppe) {
 	ccp_gotoptions[f->unit].mppe = 0;
diff -urNp --exclude-from=/mdomsch2/excludes --minimal ppp-2.4.3.orig/pppd/pppd.h ppp-2.4.3.ppp_mppe/pppd/pppd.h
--- ppp-2.4.3.orig/pppd/pppd.h	2004-11-13 04:02:22.000000000 -0800
+++ ppp-2.4.3.ppp_mppe/pppd/pppd.h	2005-08-12 11:40:40.000000000 -0700
@@ -615,7 +615,7 @@ void tty_recv_config __P((int, u_int32_t
 				/* Configure i/f receive parameters */
 int  ccp_test __P((int, u_char *, int, int));
 				/* Test support for compression scheme */
-void ccp_flags_set __P((int, int, int));
+void ccp_flags_set __P((int, int, int, int));
 				/* Set kernel CCP state */
 int  ccp_fatal_error __P((int)); /* Test for fatal decomp error in kernel */
 int  get_idle_time __P((int, struct ppp_idle *));
diff -urNp --exclude-from=/mdomsch2/excludes --minimal ppp-2.4.3.orig/pppd/sys-linux.c ppp-2.4.3.ppp_mppe/pppd/sys-linux.c
--- ppp-2.4.3.orig/pppd/sys-linux.c	2005-07-23 08:35:09.000000000 -0700
+++ ppp-2.4.3.ppp_mppe/pppd/sys-linux.c	2005-08-12 11:37:39.000000000 -0700
@@ -1278,13 +1278,15 @@ ccp_test(int unit, u_char *opt_ptr, int 
 /********************************************************************
  *
  * ccp_flags_set - inform kernel about the current state of CCP.
+ *   Once SC_MUST_COMP is set, never clear it.
  */
 
-void ccp_flags_set (int unit, int isopen, int isup)
+void ccp_flags_set (int unit, int isopen, int isup, int must_comp)
 {
 	int x;
 
-	x = (isopen? SC_CCP_OPEN: 0) | (isup? SC_CCP_UP: 0);
+	x = (isopen? SC_CCP_OPEN: 0) | (isup? SC_CCP_UP: 0)
+		| (must_comp? SC_MUST_COMP: 0);
 	if (still_ppp() && ppp_dev_fd >= 0)
 		modify_flags(ppp_dev_fd, SC_CCP_OPEN|SC_CCP_UP, x);
 }
diff -urNp --exclude-from=/mdomsch2/excludes --minimal ppp-2.4.3.orig/pppd/sys-solaris.c ppp-2.4.3.ppp_mppe/pppd/sys-solaris.c
--- ppp-2.4.3.orig/pppd/sys-solaris.c	2004-11-04 02:02:26.000000000 -0800
+++ ppp-2.4.3.ppp_mppe/pppd/sys-solaris.c	2005-08-12 11:41:59.000000000 -0700
@@ -1633,8 +1633,8 @@ ccp_test(unit, opt_ptr, opt_len, for_tra
  * ccp_flags_set - inform kernel about the current state of CCP.
  */
 void
-ccp_flags_set(unit, isopen, isup)
-    int unit, isopen, isup;
+ccp_flags_set(unit, isopen, isup, unused_must_comp)
+    int unit, isopen, isup, unused_must_comp;
 {
     int cf[2];
 


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
