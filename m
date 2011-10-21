From: "Yan, Zheng" <zheng.z.yan@linux.intel.com>
Subject: Re: IPsec performance bug
Date: Fri, 21 Oct 2011 16:28:30 +0800
Message-ID: <CAAM7YAkxP06_=y1wg4P1JhPDWhZgRM6+wbFQRG5PFkAq8vgsTw@mail.gmail.com>
References: <20111019212229.72078d51.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	hirofumi@mail.parknet.co.jp
To: Kim Phillips <kim.phillips@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:58226 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751268Ab1JUI2b convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2011 04:28:31 -0400
Received: by vcge1 with SMTP id e1so3104034vcg.19
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2011 01:28:30 -0700 (PDT)
In-Reply-To: <20111019212229.72078d51.kim.phillips@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 20, 2011 at 10:22 AM, Kim Phillips
<kim.phillips@freescale.com> wrote:
> Hi,
>
> I'm trying to debug an IPSec forwarding performance slowdown on a
> p2020 dual-core powerpc linux box using s/w crypto (no crypto h/w
> offload enabled) between vanilla kernel versions 2.6.35 and 3.0.
> Using a h/w packet generator set to 64-byte packets, I get the
> following results:
>
> v2.6.35: 48.5kpps
> v3.0.0: =A0 0.2kpps
> v3.0.7: =A0 0.2kpps
> v3.1.0-rc9-01707-gf7ba35d (a recent net-next): 13.6kpps
>
> I was able to bisect the problem down to the following commit:
>
> 7e1dc7b6f709dfc1a9ab4b320dbe723f45992693 is the first bad commit
> commit 7e1dc7b6f709dfc1a9ab4b320dbe723f45992693
> Author: David S. Miller <davem@davemloft.net>
> Date: =A0 Sat Mar 12 02:42:11 2011 -0500
>
> =A0 =A0net: Use flowi4 and flowi6 in xfrm layer.
>
> =A0 =A0Signed-off-by: David S. Miller <davem@davemloft.net>
>
> And, indeed, going back one commit (i.e., v2.6.38-rc8-1468-g2032656
> and manually applying commit 7313714: =A0"xfrm: fix
> __xfrm_route_forward ()"), brings performance back to ~50kpps from
> 0.2kpps.
>
> Tracing shows that the commit breaks the route cache [1], and I
> understand there is major surgery going on in the area [2], so I
> suppose my question is twofold:
>
> (a) was such a large performance drop to be expected for v3.0?
>
> (b) any ideas how to fix? =A0I don't know much about routing
> internals, but in ip_route_input_common(), if I remove the input
> interface comparison (rth->rt_route_iif ^ iif), I get some
> performance back, but the system becomes unstable (it's booted over
> nfs).
>
> Thanks,
>
> Kim
>

Looks like xfrm4_fill_dst() reset rt->rt_route_iif to 0, it makes the
comparison (rth->rt_route_iif ^ iif) in
ip_route_input_common() return false.

Please try patch below. It improves the performance of 3.1-rc10
kernel. (I'm not sure the patch is harmless)

---
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index fc5368a..88a0972 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -82,7 +82,6 @@ static int xfrm4_fill_dst(struct xfrm_dst *xdst,
struct net_device *dev,
 	rt->rt_key_dst =3D fl4->daddr;
 	rt->rt_key_src =3D fl4->saddr;
 	rt->rt_key_tos =3D fl4->flowi4_tos;
-	rt->rt_route_iif =3D fl4->flowi4_iif;
 	rt->rt_iif =3D fl4->flowi4_iif;
 	rt->rt_oif =3D fl4->flowi4_oif;
 	rt->rt_mark =3D fl4->flowi4_mark;
