From: David Newall <davidn@davidnewall.com>
Subject: Re: Small bug in ping
Date: Wed, 04 Jun 2014 19:20:39 +0930
Message-ID: <538EEBEF.4090500@davidnewall.com>
References: <538E36E5.4070204@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Jakob Unterwurzacher <jakobunt@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hawking.rebel.net.au ([203.20.69.83]:40849 "EHLO
	hawking.rebel.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751826AbaFDJuw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 05:50:52 -0400
In-Reply-To: <538E36E5.4070204@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/06/14 06:28, Jakob Unterwurzacher wrote:
> 4) Ping replies seem to come from your own IP

Yes, a bug.  To minimise use of DNS, ping only queries or formats an 
addresses once, and returns that result thereafter.  The bug was 
introduced at bug10979-less-dns.  I sent the following patch, which only 
returns the previous value if it's for the same IP address, to ping's 
maintainer, last month:

Index: iputils/ping.c
===================================================================
--- iputils.orig/ping.c	2013-12-12 21:50:00.237785711 -0800
+++ iputils/ping.c	2013-12-12 22:11:24.800155180 -0800
@@ -1243,7 +1243,12 @@
  pr_addr(__u32 addr)
  {
  	struct hostent *hp;
-	static char buf[4096];
+	static char buf[4096] = "";
+	static __u32 last_addr;
+
+	if (*buf && addr == last_addr)
+		return(buf);
+	last_addr = addr;
  
  	in_pr_addr = !setjmp(pr_addr_jmp);
  
Index: iputils/ping6.c
===================================================================
--- iputils.orig/ping6.c	2013-12-12 21:50:00.189785476 -0800
+++ iputils/ping6.c	2013-12-12 22:12:22.856444368 -0800
@@ -1794,7 +1794,7 @@
   */
  char * pr_addr(struct in6_addr *addr)
  {
-	struct hostent *hp = NULL;
+	static struct hostent *hp = NULL;
  	static char *s;
  
  #ifdef USE_IDN
@@ -1803,7 +1803,7 @@
  
  	in_pr_addr = !setjmp(pr_addr_jmp);
  
-	if (!(exiting || options&F_NUMERIC))
+	if (!hp && !(exiting || options&F_NUMERIC))
  		hp = gethostbyaddr((__u8*)addr, sizeof(struct in6_addr), AF_INET6);
  
  	in_pr_addr = 0;
