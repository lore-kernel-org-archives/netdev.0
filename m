From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] nf_nat_snmp: fix checksum calculation (v3)
Date: Mon, 20 Sep 2010 19:35:08 +0200
Message-ID: <4C979B4C.4020605@trash.net>
References: <4C938AFB.3050303@trash.net>	<20100914163208.2ba165ca.akpm@linux-foundation.org>	<bug-17622-10286@https.bugzilla.kernel.org/>	<6029e4.25bb.12b1d97358d.Coremail.wtweeker@163.com>	<20100916223909.68e5c557@nehalam>	<4C935A58.8040208@trash.net>	<20100917083125.0d565a2d@nehalam>	<2a014b7c.92ce.12b293c61ba.Coremail.wtweeker@163.com> <20100920094448.67210244@nehalam>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010102030503000802030502"
Cc: =?ISO-8859-15?Q?=CD=F5=E8=BA=A3=A8=BC=C6=CB=E3=BB=FA=BF=C6=D1=A7=D1=A7?=
	 =?ISO-8859-15?Q?=D4=BA=A3=A9?= <wtweeker@163.com>,
	akpm@linux-foundation.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49933 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751440Ab0ITRfK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 13:35:10 -0400
In-Reply-To: <20100920094448.67210244@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010102030503000802030502
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

On 20.09.2010 18:44, Stephen Hemminger wrote:
> Revised version of the original patch in the bug
>   https://bugzilla.kernel.org/show_bug.cgi?id=17622
> from clark wang <wtweeker@163.com>
> 
> I took the opportunity to do some cleanup here.
>  * reorder the assignment to make the byte order clear
>  * get rid of unnecessary ref/deref and just pass the bytes
>  * use sizeof() instead of hard coding size
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Thanks Stephen, but this patch didn't compile:

net/ipv4/netfilter/nf_nat_snmp_basic.c: In function 'fast_csum':
net/ipv4/netfilter/nf_nat_snmp_basic.c:893: error: 's' undeclared (first
use in this function)
net/ipv4/netfilter/nf_nat_snmp_basic.c:893: error: (Each undeclared
identifier is reported only once
net/ipv4/netfilter/nf_nat_snmp_basic.c:893: error: for each function it
appears in.)
net/ipv4/netfilter/nf_nat_snmp_basic.c:890: warning: unused variable 'diff'

Since I prefer to keep this fix to the minimal size at this point,
I've committed this patch based on Clark's and your patches:


--------------010102030503000802030502
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="x"

commit 8d70d82cdcc6da0a77440c6d860957a1f50b8089
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Sep 20 19:29:40 2010 +0200

    netfilter: nf_nat_snmp: fix checksum calculation (v4)
    
    Fix checksum calculation in nf_nat_snmp_basic.
    
    Based on patches by Clark Wang <wtweeker@163.com> and
    Stephen Hemminger <shemminger@vyatta.com>.
    
    https://bugzilla.kernel.org/show_bug.cgi?id=17622
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter/nf_nat_snmp_basic.c b/net/ipv4/netfilter/nf_nat_snmp_basic.c
index 1679e2c..ee5f419 100644
--- a/net/ipv4/netfilter/nf_nat_snmp_basic.c
+++ b/net/ipv4/netfilter/nf_nat_snmp_basic.c
@@ -893,13 +893,15 @@ static void fast_csum(__sum16 *csum,
 	unsigned char s[4];
 
 	if (offset & 1) {
-		s[0] = s[2] = 0;
+		s[0] = ~0;
 		s[1] = ~*optr;
+		s[2] = 0;
 		s[3] = *nptr;
 	} else {
-		s[1] = s[3] = 0;
 		s[0] = ~*optr;
+		s[1] = ~0;
 		s[2] = *nptr;
+		s[3] = 0;
 	}
 
 	*csum = csum_fold(csum_partial(s, 4, ~csum_unfold(*csum)));

--------------010102030503000802030502--
