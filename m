From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: weird problem
Date: Fri, 10 Jul 2009 16:47:54 +0200
Message-ID: <20090710144754.GA25385@ami.dom.local>
References: <20090708223459.GB3666@ami.dom.local> <4A5679CC.800@itcare.pl> <4A568444.7010307@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Network Development list <netdev@vger.kernel.org>
To: =?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:34305 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753546AbZGJOsI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2009 10:48:08 -0400
Received: by fxm18 with SMTP id 18so938436fxm.37
        for <netdev@vger.kernel.org>; Fri, 10 Jul 2009 07:48:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A568444.7010307@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 10, 2009 at 01:59:00AM +0200, Pawe=B3 Staszewski wrote:
> Today i make other tests with change of =20
> /proc/sys/net/ipv4/rt_cache_rebuild_count and kernel 2.6.30.1
>
> And when rt_cache_rebuild_count is set to "-1" i have always load on =
=20
> x86_64 machine approx 40-50% of each cpu where network card is binded=
 by =20
> irq_aff
>
> when rt_cache_rebuild_count is set to more than "-1" i have 15 to 20 =
sec =20
> of 1 to 3% cpu and after 40-50% cpu
=2E..

Here is one more patch for testing (with caution!). It adds possibility
to turn off cache disabling (so it should even more resemble 2.6.28)
after setting: rt_cache_rebuild_count =3D 0

I'd like you to try this patch:
1) together with the previous patch and "rt_cache_rebuild_count =3D 0"
   to check if there is still the difference wrt. 2.6.28; Btw., let
   me know which /proc/sys/net/ipv4/route/* settings do you need to
   change and why

2) alone (without the previous patch) and "rt_cache_rebuild_count =3D 0=
"

3) if it's possible to try 2.6.30.1 without these patches, but with
   default /proc/sys/net/ipv4/route/* settings, and higher
   rt_cache_rebuild_count, e.g. 100; I'm interested if/how long it
   takes to trigger higher cpu load and the warning "... rebuilds is
   over limit, route caching disabled"; (Btw., I wonder why you didn't
   mention about these or maybe also other route caching warnings?)

Regards,
Jarek P.
--- (debugging patch #2; apply to 2.6.30.1 or 2.6.29.6)

 net/ipv4/route.c |   16 +++++++++++-----
 1 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 278f46f..3d183cb 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1181,12 +1181,18 @@ restart:
 	} else {
 		if (chain_length > rt_chain_length_max) {
 			struct net *net =3D dev_net(rt->u.dst.dev);
-			int num =3D ++net->ipv4.current_rt_cache_rebuild_count;
-			if (!rt_caching(dev_net(rt->u.dst.dev))) {
-				printk(KERN_WARNING "%s: %d rebuilds is over limit, route caching =
disabled\n",
-					rt->u.dst.dev->name, num);
+
+			if (net->ipv4.sysctl_rt_cache_rebuild_count > 0) {
+				int num =3D ++net->ipv4.current_rt_cache_rebuild_count;
+
+				if (!rt_caching(net))
+					printk(KERN_WARNING
+					       "%s: %d rebuilds is over limit, "
+					       "route caching disabled\n",
+					       rt->u.dst.dev->name, num);
+
+				rt_emergency_hash_rebuild(net);
 			}
-			rt_emergency_hash_rebuild(dev_net(rt->u.dst.dev));
 		}
 	}
=20
