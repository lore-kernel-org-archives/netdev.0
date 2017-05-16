From: Michael Ulmer <mulmer@cradlepoint.com>
Subject: [Patch][IPv6] Fix wrong routing mechanism for Link Local IPv6 packets
Date: Tue, 16 May 2017 15:37:39 +0000
Message-ID: <MWHPR1201MB01730F7F4A6BE57ADFB92EAFCAE60@MWHPR1201MB0173.namprd12.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0126.outbound.protection.outlook.com ([104.47.38.126]:27552
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752249AbdEPPhr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 16 May 2017 11:37:47 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Blast from the past. 10 years back Wei Dong submitted the patch found (amon=
gst several places) here:
http://lists.openwall.net/netdev/2007/01/30/20

Problem:
I have a firewall rule that DNATs ipv6 traffic from a destination address t=
o ::1. The route lookup gives me the Main table & forwards that DNAT'd traf=
fic instead of sending it to local process.

Example:
Looking at this from a netfilter point of view, a client (IP of fd00::5) re=
quests a web page at [2000::25:0:0:1]:8080. The firewall rule DNATs it to :=
:1 (note that I threw a -j TRACE in raw's REROUTING).
TRACE: nat:PREROUTING:rule:2 SRC=3Dfd00::5 DST=3D2000::25:0:0:1
TRACE: mangle:FORWARD:rule:1 SRC=3Dfd00::5 DST=3D::1

The patch is verbatim (as is the subject line for this email). Traffic DNAT=
'd to ::1 now goes to mangle's INPUT chain after routing decision. I'm not =
sure why it was removed--I'm assuming it was an accident--as I can't find a=
 record in the mailing list archive.

diff --git a/gpl/kernel/linux/net/ipv6/route.c b/gpl/kernel/linux/net/ipv6/=
route.c
index 3809ca2..2a2563f 100644
--- a/gpl/kernel/linux/net/ipv6/route.c
+++ b/gpl/kernel/linux/net/ipv6/route.c
@@ -611,7 +611,7 @@ static int rt6_score_route(struct rt6_info *rt, int oif=
,
        int m;
=20
        m =3D rt6_check_dev(rt, oif);
-       if (!m && (strict & RT6_LOOKUP_F_IFACE))
+       if (!m && (rt->rt6i_flags & RTF_CACHE) && (strict & RT6_LOOKUP_F_IF=
ACE))
                return RT6_NUD_FAIL_HARD;
 #ifdef CONFIG_IPV6_ROUTER_PREF
        m |=3D IPV6_DECODE_PREF(IPV6_EXTRACT_PREF(rt->rt6i_flags)) << 2;



__
Mike Ulmer=
