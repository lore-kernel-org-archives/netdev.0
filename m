From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: RE: [PATCH] qlcnic: Fix MSI-X initialization code
Date: Tue, 15 Apr 2014 12:06:58 +0000
Message-ID: <262CB373A6D1F14F9B81E82F74F77D5A46F910CF@avmb2.qlogic.org>
References: <1397554634-26795-1-git-send-email-agordeev@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="_000_262CB373A6D1F14F9B81E82F74F77D5A46F910CFavmb2qlogicorg_"
Cc: Dept-HSG Linux NIC Dev <Dept-HSGLinuxNICDev@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	linux-pci <linux-pci@vger.kernel.org>
To: Alexander Gordeev <agordeev@redhat.com>,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1397554634-26795-1-git-send-email-agordeev@redhat.com>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--_000_262CB373A6D1F14F9B81E82F74F77D5A46F910CFavmb2qlogicorg_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

> -----Original Message-----
> From: Alexander Gordeev [mailto:agordeev@redhat.com]
> Sent: Tuesday, April 15, 2014 3:07 PM
> To: linux-kernel
> Cc: Alexander Gordeev; Shahed Shaikh; Dept-HSG Linux NIC Dev; netdev;
> linux-pci
> Subject: [PATCH] qlcnic: Fix MSI-X initialization code
>=20
> Function qlcnic_setup_tss_rss_intr() might enter endless loop in case
> pci_enable_msix() contiguously returns a positive number of MSI-Xs that
> could have been allocated.
> Besides, the function contains 'err =3D -EIO;' assignment that never coul=
d be
> reached. This update fixes the aforementioned issues.
>=20
> Cc: Shahed Shaikh <shahed.shaikh@qlogic.com>
> Cc: Dept-HSGLinuxNICDev@qlogic.com
> Cc: netdev@vger.kernel.org
> Cc: linux-pci@vger.kernel.org
>=20
> Signed-off-by: Alexander Gordeev <agordeev@redhat.com>

Acked-by: Shahed Shaikh <shahed.shaikh@qlogic.com>

Thanks,
Shahed
> ---
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   28 ++++++++++++----=
---
> --
>  1 files changed, 16 insertions(+), 12 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> index 309d056..2e615d5 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> @@ -670,7 +670,7 @@ int qlcnic_setup_tss_rss_intr(struct qlcnic_adapter
> *adapter)
>  	else
>  		num_msix +=3D adapter->drv_tx_rings;
>=20
> -	if (adapter->drv_rss_rings  > 0)
> +	if (adapter->drv_rss_rings > 0)
>  		num_msix +=3D adapter->drv_rss_rings;
>  	else
>  		num_msix +=3D adapter->drv_sds_rings;
> @@ -686,19 +686,15 @@ int qlcnic_setup_tss_rss_intr(struct qlcnic_adapter
> *adapter)
>  			return -ENOMEM;
>  	}
>=20
> -restore:
>  	for (vector =3D 0; vector < num_msix; vector++)
>  		adapter->msix_entries[vector].entry =3D vector;
>=20
> +restore:
>  	err =3D pci_enable_msix(pdev, adapter->msix_entries, num_msix);
> -	if (err =3D=3D 0) {
> -		adapter->ahw->num_msix =3D num_msix;
> -		if (adapter->drv_tss_rings > 0)
> -			adapter->drv_tx_rings =3D adapter->drv_tss_rings;
> +	if (err > 0) {
> +		if (!adapter->drv_tss_rings && !adapter->drv_rss_rings)
> +			return -ENOSPC;
>=20
> -		if (adapter->drv_rss_rings > 0)
> -			adapter->drv_sds_rings =3D adapter->drv_rss_rings;
> -	} else {
>  		netdev_info(adapter->netdev,
>  			    "Unable to allocate %d MSI-X vectors, Available
> vectors %d\n",
>  			    num_msix, err);
> @@ -716,12 +712,20 @@ restore:
>  			    "Restoring %d Tx, %d SDS rings for total %d
> vectors.\n",
>  			    adapter->drv_tx_rings, adapter->drv_sds_rings,
>  			    num_msix);
> -		goto restore;
>=20
> -		err =3D -EIO;
> +		goto restore;
> +	} else if (err < 0) {
> +		return err;
>  	}
>=20
> -	return err;
> +	adapter->ahw->num_msix =3D num_msix;
> +	if (adapter->drv_tss_rings > 0)
> +		adapter->drv_tx_rings =3D adapter->drv_tss_rings;
> +
> +	if (adapter->drv_rss_rings > 0)
> +		adapter->drv_sds_rings =3D adapter->drv_rss_rings;
> +
> +	return 0;
>  }
>=20
>  int qlcnic_enable_msix(struct qlcnic_adapter *adapter, u32 num_msix)
> --
> 1.7.7.6


--_000_262CB373A6D1F14F9B81E82F74F77D5A46F910CFavmb2qlogicorg_
Content-Disposition: attachment; filename="winmail.dat"
Content-Transfer-Encoding: base64
Content-Type: application/ms-tnef; name="winmail.dat"

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
kiwiVTvjHMBvQYcgJc8cYDQEpARDIUF2JZE78ocjZ9a11hFcXG4i0y+/1DmVNiiQRMGw2X8CN2mA
y5hgarAr3MAyLCFxfwF3q7/Z79TQUt3ziMHWElTz23HWIVNEBfCL5KOyGJD/AZADINjh1+1CINkf
1Ay6z/+Iwq7JlovkH9pfsL+U1FnA/9Vh3eXGj7NaRMnEP+wfvdv/z6ax5qUwv0/FPETBn/+hD/+K
FvUPjPe0H7Uvvb+3j8mP/7/s5d/M37zv/EX8H8iP/j///0/njwFfzh8Df58GpJCS2f/2v2JBmVk7
2ps/nEKdByiQPHUzarDqZ2cvI8ExLmo3FFE2Wvx9F8EV0AAAHwBCAAEAAAAcAAAAUwBoAGEAaABl
AGQAIABTAGgAYQBpAGsAaAAAAB8AZQABAAAAMgAAAHMAaABhAGgAZQBkAC4AcwBoAGEAaQBrAGgA
QABxAGwAbwBnAGkAYwAuAGMAbwBtAAAAAAAfAGQAAQAAAAoAAABTAE0AVABQAAAAAAACAUEAAQAA
AHAAAAAAAAAAgSsfpL6jEBmdbgDdAQ9UAgAAAIBTAGgAYQBoAGUAZAAgAFMAaABhAGkAawBoAAAA
UwBNAFQAUAAAAHMAaABhAGgAZQBkAC4AcwBoAGEAaQBrAGgAQABxAGwAbwBnAGkAYwAuAGMAbwBt
AAAAHwACXQEAAAAyAAAAcwBoAGEAaABlAGQALgBzAGgAYQBpAGsAaABAAHEAbABvAGcAaQBjAC4A
YwBvAG0AAAAAAB8A5V8BAAAAOgAAAHMAaQBwADoAcwBoAGEAaABlAGQALgBzAGgAYQBpAGsAaABA
AHEAbABvAGcAaQBjAC4AYwBvAG0AAAAAAB8AGgwBAAAAHAAAAFMAaABhAGgAZQBkACAAUwBoAGEA
aQBrAGgAAAAfAB8MAQAAADIAAABzAGgAYQBoAGUAZAAuAHMAaABhAGkAawBoAEAAcQBsAG8AZwBp
AGMALgBjAG8AbQAAAAAAHwAeDAEAAAAKAAAAUwBNAFQAUAAAAAAAAgEZDAEAAABwAAAAAAAAAIEr
H6S+oxAZnW4A3QEPVAIAAACAUwBoAGEAaABlAGQAIABTAGgAYQBpAGsAaAAAAFMATQBUAFAAAABz
AGgAYQBoAGUAZAAuAHMAaABhAGkAawBoAEAAcQBsAG8AZwBpAGMALgBjAG8AbQAAAB8AAV0BAAAA
MgAAAHMAaABhAGgAZQBkAC4AcwBoAGEAaQBrAGgAQABxAGwAbwBnAGkAYwAuAGMAbwBtAAAAAAAf
APg/AQAAABwAAABTAGgAYQBoAGUAZAAgAFMAaABhAGkAawBoAAAAHwAjQAEAAAAyAAAAcwBoAGEA
aABlAGQALgBzAGgAYQBpAGsAaABAAHEAbABvAGcAaQBjAC4AYwBvAG0AAAAAAB8AIkABAAAACgAA
AFMATQBUAFAAAAAAAAIB+T8BAAAAcAAAAAAAAACBKx+kvqMQGZ1uAN0BD1QCAAAAgFMAaABhAGgA
ZQBkACAAUwBoAGEAaQBrAGgAAABTAE0AVABQAAAAcwBoAGEAaABlAGQALgBzAGgAYQBpAGsAaABA
AHEAbABvAGcAaQBjAC4AYwBvAG0AAAAfAAldAQAAADIAAABzAGgAYQBoAGUAZAAuAHMAaABhAGkA
awBoAEAAcQBsAG8AZwBpAGMALgBjAG8AbQAAAAAAHwAxQAEAAAACAAAAAAAAAAsAQDoBAAAAHwAw
QAEAAAACAAAAAAAAAB8AGgABAAAAEgAAAEkAUABNAC4ATgBvAHQAZQAAAAAAAwDxPwkEAAALAEA6
AQAAAAMA/T/kBAAAAgELMAEAAAAQAAAA0McSTGrqAU+tAzwE1GP1vgMAFwABAAAAQAA5AABdQzOj
WM8BQAAIMAhJcDOjWM8BCwApAAAAAAALACMAAAAAAB8AAICGAwIAAAAAAMAAAAAAAABGAQAAAB4A
AABhAGMAYwBlAHAAdABsAGEAbgBnAHUAYQBnAGUAAAAAAAEAAAAMAAAAZQBuAC0AVQBTAAAACwAA
gAggBgAAAAAAwAAAAAAAAEYAAAAABoUAAAAAAAAfADcAAQAAAGQAAABSAEUAOgAgAFsAUABBAFQA
QwBIAF0AIABxAGwAYwBuAGkAYwA6ACAARgBpAHgAIABNAFMASQAtAFgAIABpAG4AaQB0AGkAYQBs
AGkAegBhAHQAaQBvAG4AIABjAG8AZABlAAAAHwA9AAEAAAAKAAAAUgBFADoAIAAAAAAAAwA2AAAA
AAADAC4AAAAAAB8AQhABAAAAcAAAADwAMQAzADkANwA1ADUANAA2ADMANAAtADIANgA3ADkANQAt
ADEALQBnAGkAdAAtAHMAZQBuAGQALQBlAG0AYQBpAGwALQBhAGcAbwByAGQAZQBlAHYAQAByAGUA
ZABoAGEAdAAuAGMAbwBtAD4AAAACAXEAAQAAABsAAAABAc9Yjg4+aPMU3w7DRpNM2Cebz8lpmxKT
0sAAHwBwAAEAAABcAAAAWwBQAEEAVABDAEgAXQAgAHEAbABjAG4AaQBjADoAIABGAGkAeAAgAE0A
UwBJAC0AWAAgAGkAbgBpAHQAaQBhAGwAaQB6AGEAdABpAG8AbgAgAGMAbwBkAGUAAAAfADUQAQAA
AHgAAAA8ADIANgAyAEMAQgAzADcAMwBBADYARAAxAEYAMQA0AEYAOQBCADgAMQBFADgAMgBGADcA
NABGADcANwBEADUAQQA0ADYARgA5ADEAMABDAEYAQABhAHYAbQBiADIALgBxAGwAbwBnAGkAYwAu
AG8AcgBnAD4AAAAfADkQAQAAAHAAAAA8ADEAMwA5ADcANQA1ADQANgAzADQALQAyADYANwA5ADUA
LQAxAC0AZwBpAHQALQBzAGUAbgBkAC0AZQBtAGEAaQBsAC0AYQBnAG8AcgBkAGUAZQB2AEAAcgBl
AGQAaABhAHQALgBjAG8AbQA+AAAAAwDeP59OAAALAACACCAGAAAAAADAAAAAAAAARgAAAAADhQAA
AAAAAAMAAIAIIAYAAAAAAMAAAAAAAABGAAAAAAGFAAAAAAAAAwCAEP////9AAAcw6F4SMqNYzwEL
AAIAAQAAAAMAJgAAAAAACwArAAAAAAACAUcAAQAAAC8AAABjPVVTO2E9IDtwPVFMb2dpYztsPUFW
TUIyLTE0MDQxNTEyMDY1OFotMTU1NDY2AAACARAwAQAAAEYAAAAAAAAArzyCpH4RikG4uh7fmKWN
YAcAWoRvvvW+/0639oZ+uI4ZfAAaa2g25QAArrMo5QJN4EiIC4rd8TVo8wBLdv2FfwAAAAAfAPo/
AQAAABwAAABTAGgAYQBoAGUAZAAgAFMAaABhAGkAawBoAAAAAwAJWQEAAAADAACACCAGAAAAAADA
AAAAAAAARgAAAAAQhQAAAAAAAAsAAIAIIAYAAAAAAMAAAAAAAABGAAAAAA6FAAAAAAAAAwAAgAgg
BgAAAAAAwAAAAAAAAEYAAAAAGIUAAAAAAAALAACACCAGAAAAAADAAAAAAAAARgAAAACChQAAAAAA
AB8AAIAIIAYAAAAAAMAAAAAAAABGAAAAANiFAAABAAAAEgAAAEkAUABNAC4ATgBvAHQAZQAAAAAA
AwANNP0/AAAfAACAhgMCAAAAAADAAAAAAAAARgEAAAAgAAAAeAAtAG0AcwAtAGgAYQBzAC0AYQB0
AHQAYQBjAGgAAAABAAAAAgAAAAAAAAAfAACAhgMCAAAAAADAAAAAAAAARgEAAAAiAAAAeAAtAG8A
cgBpAGcAaQBuAGEAdABpAG4AZwAtAGkAcAAAAAAAAQAAABgAAABbADEAMAAuADEALgA0AC4AMQAw
AF0AAAC3Mg==

--_000_262CB373A6D1F14F9B81E82F74F77D5A46F910CFavmb2qlogicorg_--
