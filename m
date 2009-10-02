From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH] make TLLAO option for NA packets configurable
Date: Sat, 3 Oct 2009 00:39:15 +0300
Message-ID: <200910030039.15952.opurdila@ixiacom.com>
References: <20091001111450.221969cc@s6510> <200910020119.47320.opurdila@ixiacom.com> <20091002105351.0fbde9c2@nehalam>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_DMnxK5FdPHloyQx"
Cc: David Miller <davem@davemloft.net>, cratiu@ixiacom.com,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:24309 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754182AbZJBVoM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 17:44:12 -0400
In-Reply-To: <20091002105351.0fbde9c2@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_DMnxK5FdPHloyQx
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Friday 02 October 2009 20:53:51 you wrote:

> This is good although I would have shortened the name.

Ah, I knew I forgot something :) Here is v4. 

tavi

--Boundary-00=_DMnxK5FdPHloyQx
Content-Type: text/x-patch;
  charset="us-ascii";
  name="0001-ipv6-new-sysctl-for-sending-TLLAO-with-unicast-NAs.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline;
	filename="0001-ipv6-new-sysctl-for-sending-TLLAO-with-unicast-NAs.patch"

=46rom 24d96d825b9fa832b22878cc6c990d5711968734 Mon Sep 17 00:00:00 2001
=46rom: Octavian Purdila <opurdila@ixiacom.com>
Date: Fri, 2 Oct 2009 00:51:15 +0300
Subject: [PATCH] ipv6: new sysctl for sending TLLAO with unicast NAs

Neighbor advertisements responding to unicast neighbor solicitations
did not include the target link-layer address option. This patch adds
a new sysctl option (disabled by default) which controls whether this
option should be sent even with unicast NAs.

The need for this arose because certain routers expect the TLLAO in
some situations even as a response to unicast NS packets.

Moreover, RFC 2461 recommends sending this to avoid a race condition
(section 4.4, Target link-layer address)

Signed-off-by: Cosmin Ratiu <cratiu@ixiacom.com>
Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
=2D--
 Documentation/networking/ip-sysctl.txt |   18 ++++++++++++++++++
 include/linux/ipv6.h                   |    1 +
 net/ipv6/addrconf.c                    |    8 ++++++++
 net/ipv6/ndisc.c                       |    1 +
 4 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/network=
ing/ip-sysctl.txt
index fbe427a..a0e134d 100644
=2D-- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1086,6 +1086,24 @@ accept_dad - INTEGER
 	2: Enable DAD, and disable IPv6 operation if MAC-based duplicate
 	   link-local address has been found.
=20
+force_tllao - BOOLEAN
+	Enable sending the target link-layer address option even when
+	responding to a unicast neighbor solicitation.
+	Default: FALSE
+
+	Quoting from RFC 2461, section 4.4, Target link-layer address:
+
+	"The option MUST be included for multicast solicitations in order to
+	avoid infinite Neighbor Solicitation "recursion" when the peer node
+	does not have a cache entry to return a Neighbor Advertisements
+	message.  When responding to unicast solicitations, the option can be
+	omitted since the sender of the solicitation has the correct link-
+	layer address; otherwise it would not have be able to send the unicast
+	solicitation in the first place. However, including the link-layer
+	address in this case adds little overhead and eliminates a potential
+	race condition where the sender deletes the cached link-layer address
+	prior to receiving a response to a previous solicitation."
+
 icmp/*:
 ratelimit - INTEGER
 	Limit the maximal rates for sending ICMPv6 packets.
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index c662efa..ae74ede 100644
=2D-- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -167,6 +167,7 @@ struct ipv6_devconf {
 #endif
 	__s32		disable_ipv6;
 	__s32		accept_dad;
+	__s32		force_tllao;
 	void		*sysctl;
 };
=20
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 1fd0a3d..bdcee69 100644
=2D-- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4353,6 +4353,14 @@ static struct addrconf_sysctl_table
 			.proc_handler	=3D	proc_dointvec,
 		},
 		{
+			.ctl_name       =3D CTL_UNNUMBERED,
+			.procname       =3D "force_tllao",
+			.data           =3D &ipv6_devconf.force_tllao,
+			.maxlen         =3D sizeof(int),
+			.mode           =3D 0644,
+			.proc_handler   =3D proc_dointvec
+		},
+		{
 			.ctl_name	=3D	0,	/* sentinel */
 		}
 	},
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index f74e4e2..3507cfe 100644
=2D-- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -598,6 +598,7 @@ static void ndisc_send_na(struct net_device *dev, struc=
t neighbour *neigh,
 	icmp6h.icmp6_solicited =3D solicited;
 	icmp6h.icmp6_override =3D override;
=20
+	inc_opt |=3D ifp->idev->cnf.force_tllao;
 	__ndisc_send(dev, neigh, daddr, src_addr,
 		     &icmp6h, solicited_addr,
 		     inc_opt ? ND_OPT_TARGET_LL_ADDR : 0);
=2D-=20
1.5.6.5


--Boundary-00=_DMnxK5FdPHloyQx--
