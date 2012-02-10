From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH v2 02/10] e100: Support RXFCS feature flag.
Date: Fri, 10 Feb 2012 23:56:31 +0100
Message-ID: <CAHXqBFJoxkM+U5y5NiepO3BxsjuK=gpYQQTvWXjbRZOnKjCiaQ@mail.gmail.com>
References: <1328730885-10941-1-git-send-email-greearb@candelatech.com> <1328730885-10941-3-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:41854 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760692Ab2BJW4v convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 17:56:51 -0500
Received: by yhoo21 with SMTP id o21so1766364yho.19
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2012 14:56:51 -0800 (PST)
In-Reply-To: <1328730885-10941-3-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/2/8  <greearb@candelatech.com>:
> From: Ben Greear <greearb@candelatech.com>
>
> This allows e100 to be configured to append the
> Ethernet FCS to the skb.
[...]
> @@ -1919,6 +1923,7 @@ static int e100_rx_indicate(struct nic *nic, st=
ruct rx *rx,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct sk_buff *skb =3D rx->skb;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct rfd *rfd =3D (struct rfd *)skb->dat=
a;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u16 rfd_status, actual_size;
> + =C2=A0 =C2=A0 =C2=A0 u16 fcs_pad =3D 0;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (unlikely(work_done && *work_done >=3D =
work_to_do))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -EAGAIN=
;

Remove this part.

> @@ -1951,9 +1956,11 @@ static int e100_rx_indicate(struct nic *nic, s=
truct rx *rx,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Get actual data size */
> + =C2=A0 =C2=A0 =C2=A0 if (unlikely(dev->features & NETIF_F_RXFCS))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 fcs_pad =3D 4;

Remove part above.

> =C2=A0 =C2=A0 =C2=A0 =C2=A0actual_size =3D le16_to_cpu(rfd->actual_si=
ze) & 0x3FFF;

u16 data_size =3D actual_size;
if (unlikely(dev->features & NETIF_F_RXFCS))
    actual_size -=3D 4;

> - =C2=A0 =C2=A0 =C2=A0 if (unlikely(actual_size > RFD_BUF_LEN - sizeo=
f(struct rfd)))
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 actual_size =3D RF=
D_BUF_LEN - sizeof(struct rfd);
> + =C2=A0 =C2=A0 =C2=A0 if (unlikely(actual_size > RFD_BUF_LEN + fcs_p=
ad - sizeof(struct rfd)))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 actual_size =3D RF=
D_BUF_LEN + fcs_pad - sizeof(struct rfd);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Get data */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_unmap_single(nic->pdev, rx->dma_addr,

Remove this part.

=2E..
skb_put(skb, data_size);
=2E..

> @@ -1980,7 +1987,7 @@ static int e100_rx_indicate(struct nic *nic, st=
ruct rx *rx,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (unlikely(!(rfd_status & cb_ok))) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Don't indic=
ate if hardware indicates errors */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dev_kfree_skb_=
any(skb);
> - =C2=A0 =C2=A0 =C2=A0 } else if (actual_size > ETH_DATA_LEN + VLAN_E=
TH_HLEN) {
> + =C2=A0 =C2=A0 =C2=A0 } else if (actual_size > ETH_DATA_LEN + VLAN_E=
TH_HLEN + fcs_pad) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Don't indic=
ate oversized frames */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0nic->rx_over_l=
ength_errors++;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dev_kfree_skb_=
any(skb);

Remove this part.

Those changes will keep RX bytes counter behaviour consistent
regardles if RXFCS is on or not. It's less code, BTW. ;-)

Best Regards,
Micha=C5=82 Miros=C5=82aw
