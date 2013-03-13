From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: atl1c issues on 3.8.2
Date: Wed, 13 Mar 2013 06:57:38 +0100
Message-ID: <1363154258.13690.40.camel@edumazet-glaptop>
References: <20130312161753.281681f2@milhouse>
	 <1363103144.13690.12.camel@edumazet-glaptop>
	 <20130312180942.4198e88e@milhouse>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <edumazet@google.com>,
	linux-netdev <netdev@vger.kernel.org>,
	"David S.Miller" <davem@davemloft.net>
To: Michael =?ISO-8859-1?Q?B=FCsch?= <m@bues.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:60060 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754073Ab3CMF5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 01:57:42 -0400
Received: by mail-ee0-f43.google.com with SMTP id c50so245013eek.30
        for <netdev@vger.kernel.org>; Tue, 12 Mar 2013 22:57:41 -0700 (PDT)
In-Reply-To: <20130312180942.4198e88e@milhouse>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-03-12 at 18:09 +0100, Michael B=C3=BCsch wrote:
> On Tue, 12 Mar 2013 16:45:44 +0100
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> > On Tue, 2013-03-12 at 16:17 +0100, Michael B=C3=BCsch wrote:
> > > Hi,
> > >=20
> > > Starting with 3.8.x scp stalls the atl1c based interface on my As=
us Eeepc 1011px.
> > > iperf (for example) does not do that. But after scp stalled the i=
nterface,
> > > iperf transfers fail, too.
> >=20
> > I am pretty sure David stable list contains the needed fix=20
> >=20
> > http://patchwork.ozlabs.org/bundle/davem/stable/?state=3D*
>=20
> No this didn't fix it.
>=20
> However, I tried to revert 69b08f62e17439ee3d436faf0b9a7ca6fffb78db a=
gain,
> which already caused trouble for me in 3.7
> and this fixed the issue.
>=20
> So it seems that this still is the same or a related issue that I rep=
orted
> for 3.7. I just wrongly stated that the problem was fixed in 3.8, bec=
ause my
> simple ping test doesn't catch it on 3.8.
>=20



kmalloc(2000) never had the guarantee that the result would not span tw=
o
4K pages.

Apparently the NIC doesn't allow a rx descriptor spanning two 4K pages
or has a particular hardware bug that I can not possibly find myself.
(I don't have atl1c nor any documentation)

atl1c driver authors will need to find the bug and fix the driver.

Drivers that deal with this kind of hardware limitation allocates page
themselves and provide skbs with a fragment to upper stack, or use
build_skb() once the frame is received.

drivers/net/ethernet/intel/igb/igb_main.c is a an example.

Could you try (on net-next tree) different values for the
NETDEV_FRAG_PAGE_MAX_ORDER constant, as it might give to Atheros some
hints ?

(8192 & 16384)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 821c7f4..769fdac 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1844,7 +1844,7 @@ static inline void __skb_queue_purge(struct sk_bu=
ff_head *list)
 		kfree_skb(skb);
 }
=20
-#define NETDEV_FRAG_PAGE_MAX_ORDER get_order(32768)
+#define NETDEV_FRAG_PAGE_MAX_ORDER get_order(8192)
 #define NETDEV_FRAG_PAGE_MAX_SIZE  (PAGE_SIZE << NETDEV_FRAG_PAGE_MAX_=
ORDER)
 #define NETDEV_PAGECNT_MAX_BIAS	   NETDEV_FRAG_PAGE_MAX_SIZE
=20
