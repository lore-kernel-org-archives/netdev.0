From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [Intel-wired-lan] [PATCH] igb: use igb_adapter->io_addr instead
 of e1000_hw->hw_addr
Date: Tue, 8 Nov 2016 17:42:14 +0100
Message-ID: <20161108164214.GF31855@calimero.vinschen.de>
References: <1478588780-24480-1-git-send-email-caoj.fnst@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="5QAgd0e35j3NYeGe"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        izumi.taku@jp.fujitsu.com, intel-wired-lan@lists.osuosl.org
To: Cao jin <caoj.fnst@cn.fujitsu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1478588780-24480-1-git-send-email-caoj.fnst@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--5QAgd0e35j3NYeGe
Content-Type: multipart/mixed; boundary="hQiwHBbRI9kgIhsi"
Content-Disposition: inline


--hQiwHBbRI9kgIhsi
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Nov  8 15:06, Cao jin wrote:
> When running as guest, under certain condition, it will oops as following.
> writel() in igb_configure_tx_ring() results in oops, because hw->hw_addr
> is NULL. While other register access won't oops kernel because they use
> wr32/rd32 which have a defense against NULL pointer.
>=20
>     [  141.225449] pcieport 0000:00:1c.0: AER: Multiple Uncorrected (Fata=
l)
>     error received: id=3D0101
>     [  141.225523] igb 0000:01:00.1: PCIe Bus Error:
>     severity=3DUncorrected (Fatal), type=3DUnaccessible,
>     id=3D0101(Unregistered Agent ID)
>     [  141.299442] igb 0000:01:00.1: broadcast error_detected message
>     [  141.300539] igb 0000:01:00.0 enp1s0f0: PCIe link lost, device now
>     detached
>     [  141.351019] igb 0000:01:00.1 enp1s0f1: PCIe link lost, device now
>     detached
>     [  143.465904] pcieport 0000:00:1c.0: Root Port link has been reset
>     [  143.465994] igb 0000:01:00.1: broadcast slot_reset message
>     [  143.466039] igb 0000:01:00.0: enabling device (0000 -> 0002)
>     [  144.389078] igb 0000:01:00.1: enabling device (0000 -> 0002)
>     [  145.312078] igb 0000:01:00.1: broadcast resume message
>     [  145.322211] BUG: unable to handle kernel paging request at
>     0000000000003818
>     [  145.361275] IP: [<ffffffffa02fd38d>]
>     igb_configure_tx_ring+0x14d/0x280 [igb]
>     [  145.400048] PGD 0
>     [  145.438007] Oops: 0002 [#1] SMP
>=20
> A similiar issue & solution could be found at:
>     http://patchwork.ozlabs.org/patch/689592/
>=20
> Signed-off-by: Cao jin <caoj.fnst@cn.fujitsu.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethe=
rnet/intel/igb/igb_main.c
> index edc9a6a..3f240ac 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -3390,7 +3390,7 @@ void igb_configure_tx_ring(struct igb_adapter *adap=
ter,
>  	     tdba & 0x00000000ffffffffULL);
>  	wr32(E1000_TDBAH(reg_idx), tdba >> 32);
> =20
> -	ring->tail =3D hw->hw_addr + E1000_TDT(reg_idx);
> +	ring->tail =3D adapter->io_addr + E1000_TDT(reg_idx);
>  	wr32(E1000_TDH(reg_idx), 0);
>  	writel(0, ring->tail);
> =20
> @@ -3729,7 +3729,7 @@ void igb_configure_rx_ring(struct igb_adapter *adap=
ter,
>  	     ring->count * sizeof(union e1000_adv_rx_desc));
> =20
>  	/* initialize head and tail */
> -	ring->tail =3D hw->hw_addr + E1000_RDT(reg_idx);
> +	ring->tail =3D adapter->io_addr + E1000_RDT(reg_idx);
>  	wr32(E1000_RDH(reg_idx), 0);
>  	writel(0, ring->tail);
> =20
> --=20
> 2.1.0

Incidentally we're just looking for a solution to that problem too.
Do three patches to fix the same problem at rougly the same time already
qualify as freak accident?

FTR, I attached my current patch, which I was planning to submit after
some external testing.

However, all three patches have one thing in common:  They workaround
a somewhat dubious resetting of the hardware address to NULL in case
reading from a register failed.

That makes me wonder if setting the hardware address to NULL in
rd32/igb_rd32 is really such a good idea.  It's performed in a function
which return value is *never* tested for validity in the calling
functions and leads to subsequent crashes since no tests for hw_addr =3D=3D
NULL are performed.

Maybe commit 22a8b2915 should be reconsidered?  Isn't there some more
graceful way to handle the "surprise removal"?


Thanks,
Corinna

--hQiwHBbRI9kgIhsi
Content-Type: text/plain; charset=utf-8
Content-Disposition: attachment; filename="0001-igb_resume-Fix-up-hw_addr-on-resume.patch"
Content-Transfer-Encoding: quoted-printable

=46rom c6e80c04a7f20bdf3bde490ff842bcc1c800bf2a Mon Sep 17 00:00:00 2001
=46rom: Corinna Vinschen <vinschen@redhat.com>
Date: Mon, 24 Oct 2016 16:44:55 +0200
Subject: [RHEL7.4 PATCH] igb_resume: Fix up hw_addr on resume

A suspend hanging for too long can trigger spurious reads.
The device is already suspended so igb_rd32 fails to read
and sets hw->hw_addr to NULL.  If we don't fix that here,
subsequent code will fail to write to HW registers and igb
crashes eventually in a writel call.

Signed-off-by: Corinna Vinschen <vinschen@redhat.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethern=
et/intel/igb/igb_main.c
index 8e96c35..d1f9d34 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -7577,6 +7577,9 @@ static int igb_resume(struct device *dev)
 	pci_enable_wake(pdev, PCI_D3hot, 0);
 	pci_enable_wake(pdev, PCI_D3cold, 0);
=20
+	if (E1000_REMOVED(hw->hw_addr) && adapter->io_addr)
+		hw->hw_addr =3D adapter->io_addr;
+
 	if (igb_init_interrupt_scheme(adapter, true)) {
 		dev_err(&pdev->dev, "Unable to allocate memory for queues\n");
 		return -ENOMEM;
--=20
2.5.5


--hQiwHBbRI9kgIhsi--

--5QAgd0e35j3NYeGe
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJYIgBmAAoJEPU2Bp2uRE+grlcP/3PojhgyTsOiKy08PSCxYgSY
AYGYI1zza/zFtPOiqb5UhVy9mTWe8Fw1Om68MmeS4dOXx5k+uwQ/bXGtpeyCmG7u
A2gBG5P9Kh+CHf36iJVXHaBzn7V37NuyMcuM+hBfeoFW5/yk8H9BE8KtwSm799wx
mE1U4rJvlWA6pNliiCjp+zqSiYdf6Sn+NbtIdd4kIzD0IRSDwweqwznOSUWly2zJ
nQQ0Mt1p/Ppd8EP5JEdUZ/dSFQvTYq9fNCi6w2MszZw8sucoH1lf96M9vgsir4iQ
s+/X8maZUXjWYw8BS8077q6TGRlEoqeyJ0mbm6hUi9srvwz6jzY0KHDTws9taIk0
+1xUPlbaM08b/h7PM1AyPO9naLjSQ4tuNIPS8FnE4m7c6HrIgBMrkHlZs6W5DUEi
Pw4WWE64YSC3tKpV3HetgiAi9UKKbHikNwnKGhCu1salUpE/5TMPZ5Ntr3CVWDcq
6UCcFz3H+OK0znAv2qR8XRh0vgwMj36idp5Nr5uj2XP/VzgpMTo1o1Y4cMdVCE4/
8fNGVMlAFY9sBKsK1IAwj9p/X+wqyD7hI5PC7Bc+qRIqNRk9paJFbg+1vG+qNMOs
tTXujA+rD6RfgMZHaJob2DFrj/SW87BjR3EPfxxjUJU8vyL/B8gMZoRsBO7zrlVY
HOCu+NOLS2O9y0OH1Szb
=4+mi
-----END PGP SIGNATURE-----

--5QAgd0e35j3NYeGe--
