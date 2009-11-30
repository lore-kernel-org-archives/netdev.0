From: jamal <hadi@cyberus.ca>
Subject: Re: [tproxy,regression] tproxy broken in 2.6.32
Date: Mon, 30 Nov 2009 08:59:37 -0500
Message-ID: <1259589577.873.30.camel@bigi>
References: <db81a9a20911260919w1ffded25ref5ae24ee73f8eda@mail.gmail.com>
	 <1259310417.3809.5.camel@nienna.balabit> <1259337932.3299.3.camel@bigi>
	 <20091128151515.GA20476@sch.bme.hu> <4B1145F1.3090704@trash.net>
	 <1259424278.3864.16.camel@bigi> <4B1158CE.90803@trash.net>
	 <1259429774.3864.41.camel@bigi> <20091128190500.GB12264@sch.bme.hu>
	 <1259437442.3864.61.camel@bigi>  <20091129203508.GB18259@sch.bme.hu>
	 <1259583359.873.17.camel@bigi>  <1259585129.3992.13.camel@nienna.balabit>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-fcQdbD+C+KCJUt4MsNu6"
Cc: KOVACS Krisztian <hidden@sch.bme.hu>,
	Patrick McHardy <kaber@trash.net>,
	Andreas Schultz <aschultz@warp10.net>, tproxy@lists.balabit.hu,
	netdev@vger.kernel.org
To: KOVACS Krisztian <hidden@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f182.google.com ([209.85.211.182]:42845 "EHLO
	mail-yw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752929AbZK3N7e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 08:59:34 -0500
Received: by ywh12 with SMTP id 12so3894538ywh.21
        for <netdev@vger.kernel.org>; Mon, 30 Nov 2009 05:59:41 -0800 (PST)
In-Reply-To: <1259585129.3992.13.camel@nienna.balabit>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-fcQdbD+C+KCJUt4MsNu6
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Mon, 2009-11-30 at 13:45 +0100, KOVACS Krisztian wrote:
> Hi,
> 

> No, because by narrowing the rule to specific ingress interfaces the
> lookup done in fib_validate_source() won't match the rule(s) (because
> the flow used will have iif set to the loopback device), and thus it
> will look up the main table and select a unicast route.

ok, nice;->

> I don't think it would be unreasonable to add a sysctl but disable the
> feature by default. It's up to you, of course.

The problem is it is hard to decide where the proper exception is to be
made. I can make it only worry about the scenario you are faced with
something like attached (incomplete, uncompiled, untested) patch. Will
that do it or can you think of other scenarios where source validation
is done and this is needed (example forwarding path)? Patrick?
[I could move the check into fib_validate, but that would punish other
users with a few extra cycles]. 

cheers,
jamal

--=-fcQdbD+C+KCJUt4MsNu6
Content-Disposition: attachment; filename="fib-val-sysctl"
Content-Type: text/x-patch; name="fib-val-sysctl"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 5b1050a..f509f7b 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2139,9 +2139,12 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 
 	if (res.type == RTN_LOCAL) {
 		int result;
+		int mark = 0;
+		if (sysctl_mark_validate_source)
+			mark = skb->mark;
 		result = fib_validate_source(saddr, daddr, tos,
 					     net->loopback_dev->ifindex,
-					     dev, &spec_dst, &itag, skb->mark);
+					     dev, &spec_dst, &itag, mark);
 		if (result < 0)
 			goto martian_source;
 		if (result)

--=-fcQdbD+C+KCJUt4MsNu6--

