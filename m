From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [Bug 3610] New: kernel-2.6.9 breaks Amanda
Date: Tue, 26 Oct 2004 10:54:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041026105422.56793912@zqx3.pdx.osdl.net>
References: <200410211647.i9LGlnp1030223@fire-1.osdl.org>
	<20041021121205.30556eac@zqx3.pdx.osdl.net>
	<41793958.3050306@nswc.navy.mil>
	<20041025161632.55fa938b@zqx3.pdx.osdl.net>
	<417E3754.3050009@nswc.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bill Ralph <wralph@nswc.navy.mil>
In-Reply-To: <417E3754.3050009@nswc.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Try the following patch to amanda that resolves potential
issues with UDP and blocking receive.

--- amanda-2.4.4p3/common-src/dgram.c.orig	2004-10-26 09:51:27.000000000 -0700
+++ amanda-2.4.4p3/common-src/dgram.c	2004-10-26 10:01:56.622775784 -0700
@@ -248,9 +248,31 @@
     socklen_t addrlen;
     int nfound;
     int save_errno;
+    int flags;
 
     sock = dgram->socket;
 
+    /* Need to be in non-blocking mode before doing receive,
+     * because select on Linux will return true when there is
+     * a UDP message with checksum error, but receive will
+     * then hang.
+     */
+    flags = fcntl(sock, F_GETFL);
+    if (flags < 0) {
+	    save_errno = errno;
+	    dbprintf(("%s: dgram_recv: fcntl get flags failed %s\n",
+		      debug_prefix(NULL), strerror(save_errno)));
+	    return -1;
+    }		     
+
+    if(fcntl(sock, F_SETFL, flags|O_NONBLOCK) < 0) {
+	    save_errno = errno;
+	    dbprintf(("%s: dgram_recv: fcntl set flags failed %s\n",
+		      debug_prefix(NULL), strerror(save_errno)));
+	    return -1;
+    }		     
+
+ retry:
     FD_ZERO(&ready);
     FD_SET(sock, &ready);
     to.tv_sec = timeout;
@@ -284,6 +306,7 @@
 	    nfound = -1;
 	}
 	errno = save_errno;
+	fcntl(sock, F_SETFL, flags);
 	return nfound;
     }
 
@@ -291,13 +314,19 @@
     size = recvfrom(sock, dgram->data, MAX_DGRAM, 0,
 		    (struct sockaddr *)fromaddr, &addrlen);
     if(size == -1) {
+	if (errno == EINTR || errno == EAGAIN)
+		goto retry;
 	save_errno = errno;
 	dbprintf(("%s: dgram_recv: recvfrom() failed: %s\n",
 		  debug_prefix(NULL),
 		  strerror(save_errno)));
 	errno = save_errno;
+	fcntl(sock, F_SETFL, flags);
 	return -1;
     }
+
+    fcntl(sock, F_SETFL, flags);
+
     dgram->len = size;
     dgram->data[size] = '\0';
     dgram->cur = dgram->data;
