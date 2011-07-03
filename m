From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison
 overwritten
Date: Sun, 03 Jul 2011 17:46:11 +0200
Message-ID: <1309707971.2523.20.camel@edumazet-laptop>
References: <bug-38102-10286@https.bugzilla.kernel.org/>
	 <20110629145135.5179fb0c.akpm@linux-foundation.org>
	 <BANLkTi=PxH8V58k-VycsM=1ZiE9hPqCN4Q@mail.gmail.com>
	 <CAB9v_DHXB6n07sEY_=HZ8S4zMO01Vs8B78dGyEWrm-hyRP82XA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	Gary Zambrano <zambrano@broadcom.com>,
	bugme-daemon@bugzilla.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Pekka Pietikainen <pp@ee.oulu.fi>,
	Florian Schirmer <jolt@tuxbox.org>,
	Felix Fietkau <nbd@openwrt.org>, Michael Buesch <mb@bu3sch.de>
To: Alexey Zaytsev <alexey.zaytsev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45932 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753944Ab1GCPqS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jul 2011 11:46:18 -0400
Received: by wyg8 with SMTP id 8so2991546wyg.19
        for <netdev@vger.kernel.org>; Sun, 03 Jul 2011 08:46:17 -0700 (PDT)
In-Reply-To: <CAB9v_DHXB6n07sEY_=HZ8S4zMO01Vs8B78dGyEWrm-hyRP82XA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 03 juillet 2011 =C3=A0 01:25 +0400, Alexey Zaytsev a =C3=A9=
crit :
> On Fri, Jul 1, 2011 at 10:01, Alexey Zaytsev <alexey.zaytsev@gmail.co=
m> wrote:
> > On Thu, Jun 30, 2011 at 01:51, Andrew Morton <akpm@linux-foundation=
=2Eorg> wrote:
> >>
> >> (switched to email.  Please respond via emailed reply-to-all, not =
via the
> >> bugzilla web interface).
> >>
> >> On Thu, 23 Jun 2011 17:33:54 GMT
> >> bugzilla-daemon@bugzilla.kernel.org wrote:
> >>
> >>> https://bugzilla.kernel.org/show_bug.cgi?id=3D38102
> >>>
> >>>            Summary: BUG kmalloc-2048: Poison overwritten
> >>>            Product: Drivers
> >>>            Version: 2.5
> >>>     Kernel Version: 3.0.0-rc4
> >>
> >> Looks like a 2.6.38->2.6.39 regression, perhaps a memory scribble =
in b44.
> >
> > Actually, not sure about the version. 39 was the first one I've bee=
n
> > using in the scenario. Checking older versions now.
> > And git-log does not show a lot of changes to the b44 driver, so it
> > might be something unrelated.
> >
>=20
> I've checked back as far as 2.6.27, and the problem is still there.
> I've also looked through the allocation-related code, and it seemed
> sane. I'm not sure I understand the 1GB dma workaround, but this path
> is never hit in my case. So adding the driver authors to CC. This
> could be something different, but I've been unable to reproduce using
> an other machine with an rtl8139 nic.

Hmm, looking at b44 code, I believe there is a race there.

Could you try following patch ?

Thanks

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index a69331e..80f2fdc 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -689,9 +689,9 @@ static int b44_alloc_rx_skb(struct b44 *bp, int src=
_idx, u32 dest_idx_unmasked)
 		ctrl |=3D DESC_CTRL_EOT;
=20
 	dp =3D &bp->rx_ring[dest_idx];
-	dp->ctrl =3D cpu_to_le32(ctrl);
 	dp->addr =3D cpu_to_le32((u32) mapping + bp->dma_offset);
-
+	wmb();
+	dp->ctrl =3D cpu_to_le32(ctrl);
 	if (bp->flags & B44_FLAG_RX_RING_HACK)
 		b44_sync_dma_desc_for_device(bp->sdev, bp->rx_ring_dma,
 			                    dest_idx * sizeof(*dp),


