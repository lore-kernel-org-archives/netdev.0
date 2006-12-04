From: Patrick McHardy <kaber@trash.net>
Subject: Re: RFC: consistent disable_xfrm behaviour
Date: Mon, 04 Dec 2006 18:03:11 +0100
Message-ID: <457454CF.7040308@trash.net>
References: <457437EA.7000406@trash.net> <XMMS.LNX.4.64.0612041005260.4314@d.namei> <45743CC1.1080904@trash.net> <20061204165253.GA11905@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010207090906070200060608"
Cc: James Morris <jmorris@namei.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49147 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937203AbWLDRAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 12:00:09 -0500
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20061204165253.GA11905@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010207090906070200060608
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Alexey Kuznetsov wrote:
> Hello!
> 
> 
>>Alexey, do you remember what the original intent of this was?
> 
> 
> disable_policy was supposed to skip policy checks on input.
> It makes sense only on input device.
> 
> disable_xfrm was supposed to skip transformations on output.
> It makes sense only on output device.
> 
> If it does not work, it was done wrong. :-)
> 
> As I see it, root of the problem is that DST_NOXFRM flag
> is calculated using wrong device. out_dev should be used
> in __mkroute_input(). It looks as a cut-n-paste error, the code
> was taken from output path, where it is correct.

Thanks, thats exactly what I suspected :)

Here's the patch again properly signed off.




--------------010207090906070200060608
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[XFRM]: Use output device disable_xfrm for forwarded packets

Currently the behaviour of disable_xfrm is inconsistent between
locally generated and forwarded packets. For locally generated
packets disable_xfrm disables the policy lookup if it is set on
the output device, for forwarded traffic however it looks at the
input device. This makes it impossible to disable xfrm on all
devices but a dummy device and use normal routing to direct
traffic to that device.

Always use the output device when checking disable_xfrm.

Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 9f3924c..164a7ee 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1780,7 +1780,7 @@ #ifdef CONFIG_IP_ROUTE_MULTIPATH_CACHED
 #endif
 	if (in_dev->cnf.no_policy)
 		rth->u.dst.flags |= DST_NOPOLICY;
-	if (in_dev->cnf.no_xfrm)
+	if (out_dev->cnf.no_xfrm)
 		rth->u.dst.flags |= DST_NOXFRM;
 	rth->fl.fl4_dst	= daddr;
 	rth->rt_dst	= daddr;

--------------010207090906070200060608--
