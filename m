From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Mcast packet loss 2.6.8.1 kernel
Date: Fri, 16 Nov 2007 12:38:22 +0100
Message-ID: <20071116123822.39babae8.dada1@cosmosbay.com>
References: <1195112740.4853.14.camel@linux-ak10.SGC>
	<E1IswSr-0006Nd-00@calista.eckenfels.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akadwa@grintek.com, linux-net@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Bernd Eckenfels <ecki@lina.inka.de>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <E1IswSr-0006Nd-00@calista.eckenfels.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 16 Nov 2007 09:22:13 +0100
Bernd Eckenfels <ecki@lina.inka.de> wrote:

> In article <1195112740.4853.14.camel@linux-ak10.SGC> you wrote:
> > output of netstat after startup and before tx of packets
> > /flash/sbin/netstat -s
> ...
> > error parsing /proc/net/snmp: Success
> 
> Could you sent me (net-tools maintainer) the output of netstat -V as well as
> the content of "cat /proc/net/snmp > dump" so i can see if this is a fixable
> problem?

Hello Bernd

I did some investigations on the "netstat -s" problem and one
 fix is to change the size of char buf1[1024], buf2[1024];

(function process_fd(), file statistics.c)

from 1024 to say 2048, because one line of /proc/net/netstat exceeds 1024 chars in current kernels.

Thank you

BTW, a real usefull thing would be to force reads of various 
/proc files to use PAGE_SIZE buffers instead of standard 1024 ones.

This can speedup netstat by a four factor at least. (reading of /proc/net/tcp file is O(N^2))

--- netstat.c.orig	2007-11-16 12:28:15.000000000 +0100
+++ netstat.c	2007-11-16 12:33:12.000000000 +0100
@@ -152,8 +152,24 @@
 
 FILE *procinfo;
 
+FILE *myfopen_r(const char *name)
+{
+	static char *buffer;
+	static size_t pagesz;
+	FILE *res = fopen(name, "r");
+
+	if (res != NULL) {
+		if (!buffer) {
+			pagesz = getpagesize();
+			buffer = malloc(pagesz);
+		}
+		setvbuf(res, buffer, _IOFBF, pagesz); 
+	}
+	return res;
+}
+
 #define INFO_GUTS1(file,name,proc)			\
-  procinfo = fopen((file), "r");			\
+  procinfo = myfopen_r((file));			\
   if (procinfo == NULL) {				\
     if (errno != ENOENT) {				\
       perror((file));					\
@@ -174,7 +190,7 @@
 #if HAVE_AFINET6
 #define INFO_GUTS2(file,proc)				\
   lnr = 0;						\
-  procinfo = fopen((file), "r");		       	\
+  procinfo = myfopen_r((file));		       	\
   if (procinfo != NULL) {				\
     do {						\
       if (fgets(buffer, sizeof(buffer), procinfo))	\

