From: Andi Kleen <ak@suse.de>
Subject: [PATCH] Add 32bit emulation for cmsg SO_TIMESTAMP
Date: Wed, 7 Jan 2004 10:07:43 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040107100743.1c0b18c2.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Some traceroute versions use the SO_TIMESTAMP cmsg for time measurement.
This fixes them when running as 32bit on a 64bit x86-64 kernel.

-Andi

--- linux-2.6.1rc2-amd64/net/compat.c-o	2003-11-23 19:46:36.000000000 -0800
+++ linux-2.6.1rc2-amd64/net/compat.c	2004-01-07 00:21:43.741256711 -0800
@@ -215,15 +215,25 @@
 
 int put_cmsg_compat(struct msghdr *kmsg, int level, int type, int len, void *data)
 {
+	struct compat_timeval ctv;
 	struct compat_cmsghdr *cm = (struct compat_cmsghdr *) kmsg->msg_control;
 	struct compat_cmsghdr cmhdr;
-	int cmlen = CMSG_COMPAT_LEN(len);
+	int cmlen;
 
 	if(cm == NULL || kmsg->msg_controllen < sizeof(*cm)) {
 		kmsg->msg_flags |= MSG_CTRUNC;
 		return 0; /* XXX: return error? check spec. */
 	}
 
+	if (level == SOL_SOCKET && type == SO_TIMESTAMP) { 
+		struct timeval *tv = (struct timeval *)data;
+		ctv.tv_sec = tv->tv_sec;
+		ctv.tv_usec = tv->tv_usec;
+		data = &ctv;
+		len = sizeof(struct compat_timeval);
+	} 
+	
+	cmlen = CMSG_COMPAT_LEN(len);
 	if(kmsg->msg_controllen < cmlen) {
 		kmsg->msg_flags |= MSG_CTRUNC;
 		cmlen = kmsg->msg_controllen;
