From: Cosmin Ratiu <cratiu@ixiacom.com>
Subject: Re: [PATCH] make TLLAO option for NA packets configurable
Date: Thu, 1 Oct 2009 21:08:40 +0300
Message-ID: <200910012108.41071.cratiu@ixiacom.com>
References: <200910011916.40908.cratiu@ixiacom.com> <20091001092100.14ea024b@s6510> <20091001.094356.95174955.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_pAPxK3lBHsEzVCg"
Cc: shemminger@vyatta.com, netdev@vger.kernel.org, opurdila@ixiacom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:30980 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755751AbZJASIi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 14:08:38 -0400
In-Reply-To: <20091001.094356.95174955.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_pAPxK3lBHsEzVCg
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Thursday 01 October 2009 19:43:56 David Miller wrote:
> Using CLT_UNNUMBERED is a must these days.
>
> Also, please fix the prefixing of the paths in your patch.
> See Documentation/SubmittingPatches in the kernel tree.

Here is the new variant. Please let me know what you think.

And I apologize for using [PATCH] instead of [RFC] in the subject, I don't 
know much about netdev protocol (yet).

Cosmin.

--Boundary-00=_pAPxK3lBHsEzVCg
Content-Type: text/x-patch;
  charset="utf-8";
  name="0001-ipv6-new-sysctl-for-sending-TLLAO-with-NAs.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline;
	filename="0001-ipv6-new-sysctl-for-sending-TLLAO-with-NAs.patch"

=46rom 1911a98df800cedf4c3a63b897163e2935c5f602 Mon Sep 17 00:00:00 2001
=46rom: Cosmin Ratiu <cratiu@ixiacom.com>
Date: Thu, 1 Oct 2009 20:27:39 +0300
Subject: [PATCH] ipv6: new sysctl for sending TLLAO with NAs

Neighbor advertisements responding to unicast Neighbor Solicitations did
not include the TLLAO option. This patch makes this configurable via
/proc/sys/net/ipv6/ndisc_force_tllao, which by default is off.

The need for this arose because certain routers expect the TLLAO in some
situations even as a response to unicast NS packets.

Moreover, RFC 2461 recommends on page 24 sending this to avoid a race.

Signed-off-by: Cosmin Ratiu <cratiu@ixiacom.com>
=2D--
 include/net/netns/ipv6.h   |    1 +
 net/ipv6/ndisc.c           |    1 +
 net/ipv6/sysctl_net_ipv6.c |    8 ++++++++
 3 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index dfeb2d7..dd0a95b 100644
=2D-- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -16,6 +16,7 @@ struct netns_sysctl_ipv6 {
 	struct ctl_table_header *frags_hdr;
 #endif
 	int bindv6only;
+	int ndisc_force_tllao;
 	int flush_delay;
 	int ip6_rt_max_size;
 	int ip6_rt_gc_min_interval;
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index f74e4e2..f08cf65 100644
=2D-- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -598,6 +598,7 @@ static void ndisc_send_na(struct net_device *dev, struc=
t neighbour *neigh,
 	icmp6h.icmp6_solicited =3D solicited;
 	icmp6h.icmp6_override =3D override;
=20
+	inc_opt |=3D dev_net(dev)->ipv6.sysctl.ndisc_force_tllao;
 	__ndisc_send(dev, neigh, daddr, src_addr,
 		     &icmp6h, solicited_addr,
 		     inc_opt ? ND_OPT_TARGET_LL_ADDR : 0);
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 0dc6a4e..fb423ce 100644
=2D-- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -37,6 +37,14 @@ static ctl_table ipv6_table_template[] =3D {
 		.mode		=3D 0644,
 		.proc_handler	=3D proc_dointvec
 	},
+	{
+		.ctl_name	=3D CTL_UNNUMBERED,
+		.procname	=3D "ndisc_force_tllao",
+		.data		=3D &init_net.ipv6.sysctl.ndisc_force_tllao,
+		.maxlen		=3D sizeof(int),
+		.mode		=3D 0644,
+		.proc_handler	=3D proc_dointvec
+	},
 	{ .ctl_name =3D 0 }
 };
=20
=2D-=20
1.6.3.3


--Boundary-00=_pAPxK3lBHsEzVCg--
