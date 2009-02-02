From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: [PATCH] [RESEND] iproute2 : invalid burst/cburst calculation with hrtimers
Date: Mon, 2 Feb 2009 19:26:17 +0200
Message-ID: <200902021926.17768.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_5yyhJmimxGvK0BS"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:59902 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752552AbZBBR0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2009 12:26:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_5yyhJmimxGvK0BS
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------->
iproute2 : invalid burst/cburst calculation with hrtimers

If hrtimers on, /proc/net/psched shows 4th variable 
as 1000000000
Because burst calculated by division rate to this variable, 
it will be almost always zero. As result, we will get higher system 
load on low rates, and on high rates shaper will not able to process 
data. So it is kind of critical bugfix for systems with hrtimers.
It is checked and proved. Core 2 Quad was not able to 
shape 200Mbps, and gave only 180-190. It is more safe to set it 
to 1000HZ. If user wants, he can set custom "env" HZ variable.

Signed-off-by: Denys Fedoryschenko <denys@visp.net.lb>
---

-------------------------------------------------------

--Boundary-00=_5yyhJmimxGvK0BS
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="iproute2-htb-gethz-invalid.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="iproute2-htb-gethz-invalid.patch"

diff -Naur iproute2/tc/q_htb.c iproute2-new/tc/q_htb.c
--- iproute2/tc/q_htb.c	2009-01-22 11:10:36.000000000 +0200
+++ iproute2-new/tc/q_htb.c	2009-01-22 11:31:40.000000000 +0200
@@ -110,6 +110,7 @@
 	unsigned mtu;
 	unsigned short mpu = 0;
 	unsigned short overhead = 0;
+	unsigned int bursthz;
 	unsigned int linklayer  = LINKLAYER_ETHERNET; /* Assume ethernet */
 	struct rtattr *tail;
 
@@ -209,9 +210,16 @@
 	if (!opt.ceil.rate) opt.ceil = opt.rate;
 
 	/* compute minimal allowed burst from rate; mtu is added here to make
-	   sute that buffer is larger than mtu and to have some safeguard space */
-	if (!buffer) buffer = opt.rate.rate / get_hz() + mtu;
-	if (!cbuffer) cbuffer = opt.ceil.rate / get_hz() + mtu;
+	   sure that buffer is larger than mtu and to have some safeguard space 
+	   With hrtimers enabled, hz variable gets too high resolution. If we
+	   use it for computing burst, burst will be too low. In worst case 
+	   we will not reach specified rate/ceil, in best - load will be too 
+	   high.
+	*/
+	bursthz = get_hz() == 1000000000 ? 1000 : get_hz();	
+
+	if (!buffer) buffer = opt.rate.rate / bursthz + mtu;
+	if (!cbuffer) cbuffer = opt.ceil.rate / bursthz + mtu;
 
 	opt.ceil.overhead = overhead;
 	opt.rate.overhead = overhead;

--Boundary-00=_5yyhJmimxGvK0BS--
