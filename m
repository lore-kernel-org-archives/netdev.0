From: Somnath Kotur <somnath.kotur@broadcom.com>
Subject: Re: [PATCH net-next v3 10/27] benet: use __vlan_hwaccel helpers
Date: Wed, 11 Jan 2017 10:59:54 +0530
Message-ID: <CAOBf=muK-w-=5Vdz-3tMXUGw=YsFXB8sow+8iSd-Zo1kS9DNdw@mail.gmail.com>
References: <cover.1483484748.git.mirq-linux@rere.qmqm.pl> <49348df8468691f6065a7a3c8c10dd076612d587.1483475202.git.mirq-linux@rere.qmqm.pl>
 <CACZ4nhsUxWYvM5HoASHb7-m2uZtnk3DN6cQigp+cObyLqPJXdA@mail.gmail.com> <8a9f0d12b69ee4e25fefc4872575d5cf31441bb8.1483484748.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, Ajit Khaparde <ajit.khaparde@broadcom.com>
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f50.google.com ([209.85.214.50]:38008 "EHLO
        mail-it0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761703AbdAKFaQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 00:30:16 -0500
Received: by mail-it0-f50.google.com with SMTP id x2so105629418itf.1
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 21:30:15 -0800 (PST)
In-Reply-To: <8a9f0d12b69ee4e25fefc4872575d5cf31441bb8.1483484748.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 4, 2017 at 4:41 AM, Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.=
qmqm.pl> wrote:
>
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> ---
> v3: fix adapter->pvid handling
>
>  drivers/net/ethernet/emulex/benet/be_main.c | 13 +++++++++----
>  1 file changed, 9 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/et=
hernet/emulex/benet/be_main.c
> index 7e1633bf5a22..cd12c9a7664b 100644
> --- a/drivers/net/ethernet/emulex/benet/be_main.c
> +++ b/drivers/net/ethernet/emulex/benet/be_main.c
> @@ -1035,30 +1035,35 @@ static struct sk_buff *be_insert_vlan_in_pkt(stru=
ct be_adapter *adapter,
>                                              struct be_wrb_params
>                                              *wrb_params)
>  {
> +       bool insert_vlan =3D false;
>         u16 vlan_tag =3D 0;
>
>         skb =3D skb_share_check(skb, GFP_ATOMIC);
>         if (unlikely(!skb))
>                 return skb;
>
> -       if (skb_vlan_tag_present(skb))
> +       if (skb_vlan_tag_present(skb)) {
>                 vlan_tag =3D be_get_tx_vlan_tag(adapter, skb);
> +               insert_vlan =3D true;
> +       }
>
>         if (qnq_async_evt_rcvd(adapter) && adapter->pvid) {
> -               if (!vlan_tag)
> +               if (!insert_vlan) {
>                         vlan_tag =3D adapter->pvid;
> +                       insert_vlan =3D true;
> +               }
>                 /* f/w workaround to set skip_hw_vlan =3D 1, informs the =
F/W to
>                  * skip VLAN insertion
>                  */
>                 BE_WRB_F_SET(wrb_params->features, VLAN_SKIP_HW, 1);
>         }
>
> -       if (vlan_tag) {
> +       if (insert_vlan) {
>                 skb =3D vlan_insert_tag_set_proto(skb, htons(ETH_P_8021Q)=
,
>                                                 vlan_tag);
>                 if (unlikely(!skb))
>                         return skb;
> -               skb->vlan_tci =3D 0;
> +               __vlan_hwaccel_clear_tag(skb);
>         }
>
>         /* Insert the outer VLAN, if any */
> --
> 2.11.0
>

Thanks

Acked-by: Somnath Kotur <somnath.kotur@broadcom.com>
