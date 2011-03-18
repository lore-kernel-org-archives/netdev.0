From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next-2.6 2/6] be2net: fix to not drop unfiltered vlan pkts
Date: Fri, 18 Mar 2011 13:35:19 -0700
Message-ID: <AANLkTimNHmvFznX-XHmhdVmkRBBjrkEa1OyAB=gSCciu@mail.gmail.com>
References: <1300454462-1234-1-git-send-email-sathya.perla@emulex.com>
 <1300454462-1234-2-git-send-email-sathya.perla@emulex.com> <e340379d-68e1-42af-b7b7-94e07e729884@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Sathya Perla <sathya.perla@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:40629 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756953Ab1CRUfk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 16:35:40 -0400
Received: by vws1 with SMTP id 1so4002573vws.19
        for <netdev@vger.kernel.org>; Fri, 18 Mar 2011 13:35:39 -0700 (PDT)
In-Reply-To: <e340379d-68e1-42af-b7b7-94e07e729884@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 18, 2011 at 6:20 AM, Sathya Perla <sathya.perla@emulex.com>=
 wrote:
> When the device is in promiscuous mode, the driver can receive vlan p=
ackets
> (tag is always stripped by card) even when there is no vlan configura=
tion.
> Such packets must be sent to the stack and not dropped.
>
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
> ---
> =A0drivers/net/benet/be_main.c | =A0 =A09 ++-------
> =A01 files changed, 2 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.=
c
> index 97c5167..18c6da4 100644
> --- a/drivers/net/benet/be_main.c
> +++ b/drivers/net/benet/be_main.c
> @@ -1013,15 +1013,10 @@ static void be_rx_compl_process(struct be_ada=
pter *adapter,
> =A0 =A0 =A0 =A0skb->truesize =3D skb->len + sizeof(struct sk_buff);
> =A0 =A0 =A0 =A0skb->protocol =3D eth_type_trans(skb, adapter->netdev)=
;
>
> - =A0 =A0 =A0 if (unlikely(rxcp->vlanf)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!adapter->vlan_grp || adapter->vlan=
s_added =3D=3D 0) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree_skb(skb);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 if (unlikely(rxcp->vlanf))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0vlan_hwaccel_receive_skb(skb, adapter-=
>vlan_grp, rxcp->vid);

It would be better to use __vlan_hwaccel_put_tag() here - it's
equivalent but at least moves in the right direction.  Under the old
vlan model (which vlan_hwaccel_receive_skb() is left over from)
passing in a NULL vlan group is illegal, so it's inconsistent anyways.

Of course even better would be to fully convert over to the new vlan
model.  A quick skim through the code shows that there might be
similar issue with vlan_gro_frags() as above, so it could help catch
some of that.
