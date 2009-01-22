From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: [PATCH] iproute2 : invalid burst/cburst calculation with hrtimers
Date: Thu, 22 Jan 2009 11:45:57 +0200
Message-ID: <200901221145.57856.denys@visp.net.lb>
References: <20090122072540.GA11139@ff.dom.local>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_VBEeJJ+W9F8haww"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:48290 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753015AbZAVJqA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 04:46:00 -0500
In-Reply-To: <20090122072540.GA11139@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_VBEeJJ+W9F8haww
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Thursday 22 January 2009 09:25:41 Jarek Poplawski wrote:
> On 21-01-2009 15:33, Denys Fedoryschenko wrote:
> ...
>
> > It is some "tokens" that used to refill bucket each piece of time
> > (related with get_hz and rate?)
> > Is there any place i can read about this?
>
> http://en.wikipedia.org/wiki/Token_bucket
>
> Jarek P.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Thanks a lot. Seems also Martin Devera pointed me, what can be issue.
HZ=1000000000 is way too high.
Real tests shows, that HZ=1000 more than enough with hrtimers on.

By the way possible it is triggered deadlock bug in htb, it is not a fix of this bug,
but a fix of very wrong behaviour, because of this bug 
HTB will use very extensively resources.

If it's required, i can give more detailed explanation

------------->
iproute2 : invalid burst/cburst calculation with hrtimers

If hrtimers on, /proc/net/psched shows 4th variable 
as 1000000000
Because burst calculated by division rate to this variable, 
it will be almost always zero. As result, we will get higher system 
load on low rates, and on high rates shaper will not able to process 
data. It is checked and proved. Core 2 Quad was not able to 
shape 200Mbps, and gave only 180-190. It is more safe to set it 
to 1000HZ. If user wants, he can set custom "env" HZ variable.

Signed-off-by: Denys Fedoryschenko <denys@visp.net.lb>
---

--Boundary-00=_VBEeJJ+W9F8haww
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

--Boundary-00=_VBEeJJ+W9F8haww--
