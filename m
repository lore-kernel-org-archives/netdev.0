From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Iproute2: update
Date: Mon, 21 Mar 2005 21:11:28 +0100
Message-ID: <20050321201128.GA10625@xi.wantstofly.org>
References: <20050112125903.64d42737@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050112125903.64d42737@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jan 12, 2005 at 12:59:03PM -0800, Stephen Hemminger wrote:

> There is an new version of iproute2 for testing.
> http://developer.osdl.org/dev/iproute2/download/iproute2-2.6.10-ss050112.tar.gz	

Doesn't build on my box (ARM platform):

	gcc -D_GNU_SOURCE -O2 -Wstrict-prototypes -Wall -g -I../include -DRESOLVE_HOSTNAMES -DCONFIG_GACT -DCONFIG_GACT_PROB -o normal normal.c -lm
	./normal >normal.dist
	*** glibc detected *** double free or corruption: 0x00011050 ***
	/bin/sh: line 1: 30106 Aborted                 ./normal >normal.dist
	make[1]: *** [normal.dist] Error 134

The same thing for paretonormal.

TABLESIZE is 16384, and some debug code shows that it's trying to
write one element past the end of the table:

	setting table[16384] to 4.008800
	setting table[16384] to 4.008850
	[...]
	setting table[16384] to 10.049950
	setting table[16384] to 10.050000

I thought it was a floating point emulation bug at first, but it
also appears to do this on my x86.

We don't use table[16384] anyway, so this works:


--L


--- iproute2-2.6.9/tc/paretonormal.c.orig	2005-03-21 21:04:21.863592000 +0100
+++ iproute2-2.6.9/tc/paretonormal.c	2005-03-21 21:07:34.590781000 +0100
@@ -62,7 +62,8 @@
 
 	for (x = -10.0; x < 10.05; x += .00005) {
 		i = (int)rint(TABLESIZE*normal(x, 0.0, 1.0));
-		table[i] = x;
+		if (i >= 0 && i < TABLESIZE)
+			table[i] = x;
 	}
 	printf(
 "# This is the distribution table for the paretonormal distribution.\n"
--- iproute2-2.6.9/tc/normal.c.orig	2005-03-21 21:00:40.420057000 +0100
+++ iproute2-2.6.9/tc/normal.c	2005-03-21 21:01:08.040316000 +0100
@@ -35,7 +35,8 @@
 
 	for (x = -10.0; x < 10.05; x += .00005) {
 		i = (int)rint(TABLESIZE*normal(x, 0.0, 1.0));
-		table[i] = x;
+		if (i >= 0 && i < TABLESIZE)
+			table[i] = x;
 	}
 
 	
