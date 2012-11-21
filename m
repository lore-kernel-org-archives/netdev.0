From: Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>
Subject: Re: net, bluetooth: object debug warning in bt_host_release()
Date: Wed, 21 Nov 2012 15:27:09 -0200
Message-ID: <20121121172709.GB15370@joana>
References: <50A272E7.9080103@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="wq9mPyueHGvFACwf"
Cc: marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Sasha Levin <sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <50A272E7.9080103-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--wq9mPyueHGvFACwf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

* Sasha Levin <sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org> [2012-11-13 11:18:47 -0500]:

> Hi all,
>=20
> While fuzzing with trinity on a KVM tools (lkvm) guest running latest -ne=
xt kernel I've
> stumbled on the following:
>=20
> [ 1434.201149] ------------[ cut here ]------------
> [ 1434.204998] WARNING: at lib/debugobjects.c:261 debug_print_object+0x8e=
/0xb0()
> [ 1434.208324] ODEBUG: free active (active state 0) object type: work_str=
uct hint: hci_power_on+0x0/0x90
> [ 1434.210386] Pid: 8564, comm: trinity-child25 Tainted: G        W    3.=
7.0-rc5-next-20121112-sasha-00018-g2f4ce0e #127
> [ 1434.210760] Call Trace:
> [ 1434.210760]  [<ffffffff819f3d6e>] ? debug_print_object+0x8e/0xb0
> [ 1434.210760]  [<ffffffff8110b887>] warn_slowpath_common+0x87/0xb0
> [ 1434.210760]  [<ffffffff8110b911>] warn_slowpath_fmt+0x41/0x50
> [ 1434.210760]  [<ffffffff819f3d6e>] debug_print_object+0x8e/0xb0
> [ 1434.210760]  [<ffffffff8376b750>] ? hci_dev_open+0x310/0x310
> [ 1434.210760]  [<ffffffff83bf94e5>] ? _raw_spin_unlock_irqrestore+0x55/0=
xa0
> [ 1434.210760]  [<ffffffff819f3ee5>] __debug_check_no_obj_freed+0xa5/0x230
> [ 1434.210760]  [<ffffffff83785db0>] ? bt_host_release+0x10/0x20
> [ 1434.210760]  [<ffffffff819f4d15>] debug_check_no_obj_freed+0x15/0x20
> [ 1434.210760]  [<ffffffff8125eee7>] kfree+0x227/0x330
> [ 1434.210760]  [<ffffffff83785db0>] bt_host_release+0x10/0x20
> [ 1434.210760]  [<ffffffff81e539e5>] device_release+0x65/0xc0
> [ 1434.210760]  [<ffffffff819d3975>] kobject_cleanup+0x145/0x190
> [ 1434.210760]  [<ffffffff819d39cd>] kobject_release+0xd/0x10
> [ 1434.210760]  [<ffffffff819d33cc>] kobject_put+0x4c/0x60
> [ 1434.210760]  [<ffffffff81e548b2>] put_device+0x12/0x20
> [ 1434.210760]  [<ffffffff8376a334>] hci_free_dev+0x24/0x30
> [ 1434.210760]  [<ffffffff82fd8fe1>] vhci_release+0x31/0x60
> [ 1434.210760]  [<ffffffff8127be12>] __fput+0x122/0x250
> [ 1434.210760]  [<ffffffff811cab0d>] ? rcu_user_exit+0x9d/0xd0
> [ 1434.210760]  [<ffffffff8127bf49>] ____fput+0x9/0x10
> [ 1434.210760]  [<ffffffff81133402>] task_work_run+0xb2/0xf0
> [ 1434.210760]  [<ffffffff8106cfa7>] do_notify_resume+0x77/0xa0
> [ 1434.210760]  [<ffffffff83bfb0ea>] int_signal+0x12/0x17
> [ 1434.210760] ---[ end trace a6d57fefbc8a8cc7 ]---
>=20
> Not that the guest doesn't emulate anything that looks like a bluetooth d=
evice or
> has bluetooth capabilities.

You have a virtual bluetooth device (vhci). That is why you get a bluetooth
crash. I think the following patch will fix this issue.

	Gustavo

---
Author: Gustavo Padovan <gustavo.padovan-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org>
Date:   Wed Nov 21 00:50:21 2012 -0200

    Bluetooth: cancel power_on work when unregistering the device
   =20
    We need to cancel the hci_power_on work in order to avoid it run when we
    try to free the hdev.
   =20
    [ 1434.201149] ------------[ cut here ]------------
    [ 1434.204998] WARNING: at lib/debugobjects.c:261 debug_print_object+0x=
8e/0xb0()
    [ 1434.208324] ODEBUG: free active (active state 0) object type: work_s=
truct hint:
    _power_on+0x0/0x90
    [ 1434.210386] Pid: 8564, comm: trinity-child25 Tainted: G        W    =
3.7.0-rc5-n
    20121112-sasha-00018-g2f4ce0e #127
    [ 1434.210760] Call Trace:
    [ 1434.210760]  [<ffffffff819f3d6e>] ? debug_print_object+0x8e/0xb0
    [ 1434.210760]  [<ffffffff8110b887>] warn_slowpath_common+0x87/0xb0
    [ 1434.210760]  [<ffffffff8110b911>] warn_slowpath_fmt+0x41/0x50
    [ 1434.210760]  [<ffffffff819f3d6e>] debug_print_object+0x8e/0xb0
    [ 1434.210760]  [<ffffffff8376b750>] ? hci_dev_open+0x310/0x310
    [ 1434.210760]  [<ffffffff83bf94e5>] ? _raw_spin_unlock_irqrestore+0x55=
/0xa0
    [ 1434.210760]  [<ffffffff819f3ee5>] __debug_check_no_obj_freed+0xa5/0x=
230
    [ 1434.210760]  [<ffffffff83785db0>] ? bt_host_release+0x10/0x20
    [ 1434.210760]  [<ffffffff819f4d15>] debug_check_no_obj_freed+0x15/0x20
    [ 1434.210760]  [<ffffffff8125eee7>] kfree+0x227/0x330
    [ 1434.210760]  [<ffffffff83785db0>] bt_host_release+0x10/0x20
    [ 1434.210760]  [<ffffffff81e539e5>] device_release+0x65/0xc0
    [ 1434.210760]  [<ffffffff819d3975>] kobject_cleanup+0x145/0x190
    [ 1434.210760]  [<ffffffff819d39cd>] kobject_release+0xd/0x10
    [ 1434.210760]  [<ffffffff819d33cc>] kobject_put+0x4c/0x60
    [ 1434.210760]  [<ffffffff81e548b2>] put_device+0x12/0x20
    [ 1434.210760]  [<ffffffff8376a334>] hci_free_dev+0x24/0x30
    [ 1434.210760]  [<ffffffff82fd8fe1>] vhci_release+0x31/0x60
    [ 1434.210760]  [<ffffffff8127be12>] __fput+0x122/0x250
    [ 1434.210760]  [<ffffffff811cab0d>] ? rcu_user_exit+0x9d/0xd0
    [ 1434.210760]  [<ffffffff8127bf49>] ____fput+0x9/0x10
    [ 1434.210760]  [<ffffffff81133402>] task_work_run+0xb2/0xf0
    [ 1434.210760]  [<ffffffff8106cfa7>] do_notify_resume+0x77/0xa0
    [ 1434.210760]  [<ffffffff83bfb0ea>] int_signal+0x12/0x17
    [ 1434.210760] ---[ end trace a6d57fefbc8a8cc7 ]---
   =20
    Reported-by: Sasha Levin <sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Gustavo Padovan <gustavo.padovan-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org>

diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index 81f4bac..69eb644 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -1854,6 +1854,8 @@ void hci_unregister_dev(struct hci_dev *hdev)
        for (i =3D 0; i < NUM_REASSEMBLY; i++)
                kfree_skb(hdev->reassembly[i]);
=20
+       cancel_work_sync(&hdev->power_on);
+
        if (!test_bit(HCI_INIT, &hdev->flags) &&
            !test_bit(HCI_SETUP, &hdev->dev_flags)) {
                hci_dev_lock(hdev);


--wq9mPyueHGvFACwf
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQrQ7sAAoJEPs3PUX4s20olbsP/0eu6HagUf9SEOek9DSNogCF
6sT//DU7IJPiY9kw21yHwmYbxWpv+EiGqmO2ryfk5l7IQI1fGuvWWA+MT+YWkfIj
wNlqpzmSGjE0v3WBh6sswTCbx2kTAHLYyGu8ebvNazIrr+zMrRRYTm3jMk6YW4Q0
3fxUhl6yYnTgs3uD9Tt8EIzkk5zsDbsrxeyf6F2lrLBoKHCSXmHRd7RsVT3HAplH
HILixhkj8l/+nSfJMi0Xf025d65PdzbTfMhPyoSkNpJeSGg4MJNbgkVyhU3StNiV
ivFBUGaRUJXPuHdNA0Wvlnzqf+l6Z9OKfh4Om6vWDtW5pYTZozhISGov1pnq4K7H
FUe6npeTN0KwDJ15VHjSzfWIQZj/E32YmidhW7g1iK/P9BVDtfxOTtLPPWBnTssQ
n71Inuisu74L7iRwY6HQlaOqKZ97tsZoCnADZOQ/rVoF1hGkArUze/svvzTJpkIm
c++LawVqXM+SgCxq1OX9LzlsNGw3kQthrE5g7gc+EbLFY0gNOBrkWETvaLt1X3en
svOpsJNZGS6KLUKuybSVX7NxjOYeurXmb5iAQo8sjIgK/bHj6Ol1Vz/yLeyrwRN2
A89m0fr2VY851bh9A4iySl0GiUhDGPftPI6aqBOYKL17G7EwWJ2fz1YS4qhAH0Zg
zJQA20U29MMbGyC5aHGo
=u5vq
-----END PGP SIGNATURE-----

--wq9mPyueHGvFACwf--
