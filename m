From: Mel Gorman <mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [Bug #14016] mm/ipw2200 regression
Date: Wed, 26 Aug 2009 10:37:49 +0100
Message-ID: <20090826093747.GA10955@csn.ul.ie>
References: <riPp5fx5ECC.A.2IG.qsGlKB@chimera> <_yaHeGjHEzG.A.FIH.7sGlKB@chimera> <84144f020908252309u5cff8afdh2214577ca4db9b5d@mail.gmail.com> <20090826082741.GA25955@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Bartlomiej Zolnierkiewicz <bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Mel Gorman <mel-wJa12IhQEiizQB+pC5nmwQ@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org
To: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090826082741.GA25955-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 26, 2009 at 10:27:41AM +0200, Johannes Weiner wrote:
> [Cc netdev]
>=20
> On Wed, Aug 26, 2009 at 09:09:44AM +0300, Pekka Enberg wrote:
> > On Tue, Aug 25, 2009 at 11:34 PM, Rafael J. Wysocki<rjw-KKrjLPT3xs0@public.gmane.org> wr=
ote:
> > > This message has been generated automatically as a part of a repo=
rt
> > > of recent regressions.
> > >
> > > The following bug entry is on the current list of known regressio=
ns
> > > from 2.6.30. =A0Please verify if it still should be listed and le=
t me know
> > > (either way).
> > >
> > > Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?i=
d=3D14016
> > > Subject =A0 =A0 =A0 =A0 : mm/ipw2200 regression
> > > Submitter =A0 =A0 =A0 : Bartlomiej Zolnierkiewicz <bzolnier@gmail=
=2Ecom>
> > > Date =A0 =A0 =A0 =A0 =A0 =A0: 2009-08-15 16:56 (11 days old)
> > > References =A0 =A0 =A0: http://marc.info/?l=3Dlinux-kernel&m=3D12=
5036437221408&w=3D4
> >=20
> > If am reading the page allocator dump correctly, there's plenty of
> > pages left but we're unable to satisfy an order 6 allocation. There=
's
> > no slab allocator involved so the page allocator changes that went
> > into 2.6.31 seem likely. Mel, ideas?
>=20
> It's an atomic order-6 allocation, the chances for this to succeed
> after some uptime become infinitesimal.  The chunks > order-2 are
> pretty much exhausted on this dump.
>=20
> 64 pages, presumably 256k, for fw->boot_size while current ipw
> firmware images have ~188k.  I don't know jack squat about this
> driver, but given the field name and the struct:
>=20
> 	struct ipw_fw {
> 		__le32 ver;
> 		__le32 boot_size;
> 		__le32 ucode_size;
> 		__le32 fw_size;
> 		u8 data[0];
> 	};
>=20
> fw->boot_size alone being that big sounds a bit fishy to me.
>=20

Agreed. While there are a low number of order-6 pages free in the page
allocation failure dump, there are not enough for watermarks to be
satisified. As it's atomic, there is little that can be done from a VM
perspective and it's the responsibility of the driver. I'm no driver ex=
pert
but I'll have a go at fixing it anyway.

My reading of this is that the firmware is being loaded from a workqueu=
e and
I am failing to see any restriction on sleeping in the path. It would a=
ppear
that the driver just used the most convenient *_alloc_coherent function
available forgetting that it assumes GFP_ATOMIC. Can someone who does k=
now
which way is up with a driver tell me why the patch below might not
work?

Bartlomiej, any chance you could give this a spin? Preferably, you'd
have preempt enabled and CONFIG_DEBUG_SPINLOCK_SLEEP on as well because
that combination will complain loudly if we really can't sleep in this
path.

=3D=3D=3D=3D=3D
ipw2200: Avoid large GFP_ATOMIC allocation during firmware loading

ipw2200 uses pci_alloc_consistent() to allocate a large coherent buffer=
 for
the loading of firmware which is an order-6 allocation of GFP_ATOMIC. A=
t
system start-up time, this is not a problem. However, the firmware on t=
he
card can get confused and the corrective action taken is to reload the
firmware and reinit the card. High-order GFP_ATOMIC allocations of this
type can and will fail when the system is already up and running.

As the firmware is loaded from a workqueue, it should be possible for
the driver to go to sleep. This patch converts the call of
pci_alloc_consistent() which assumes GFP_ATOMIC to dma_alloc_coherent()
which can specify its own flags.

The big downside with this patch is that it uses GFP_REPEAT to avoid th=
e
driver unloading. There is potential that this will cause a reclaim
storm as the machine tries to find a free order-6 buffer. A suggested
alternative for the driver owner is in the comments.

Signed-off-by: Mel Gorman <mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org>
---=20
 drivers/net/wireless/ipw2x00/ipw2200.c |   14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wirel=
ess/ipw2x00/ipw2200.c
index 44c29b3..f2e251e 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -3167,7 +3167,19 @@ static int ipw_load_firmware(struct ipw_priv *pr=
iv, u8 * data, size_t len)
 	u8 *shared_virt;
=20
 	IPW_DEBUG_TRACE("<< : \n");
-	shared_virt =3D pci_alloc_consistent(priv->pci_dev, len, &shared_phys=
);
+
+	/*
+	 * This is a whopping large allocation, in or around order-6 so
+	 * dma_alloc_coherent is used to specify the GFP_KERNEL|__GFP_REPEAT
+	 * flags. Note that this action means the system could go into a
+	 * reclaim loop until it cannot reclaim any more trying to satisfy
+	 * the allocation. It would be preferable if one buffer is allocated
+	 * at driver initialisation and reused when the firmware needs to
+	 * be reloaded, overwriting the existing firmware each time
+	 */
+	shared_virt =3D dma_alloc_coherent(
+			priv->pci_dev =3D=3D NULL ? NULL : &priv->pci_dev->dev,=20
+			len, &shared_phys, GFP_KERNEL|__GFP_REPEAT);
=20
 	if (!shared_virt)
 		return -ENOMEM;
