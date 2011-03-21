From: <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH net-next-2.6 2/6] be2net: fix to not drop unfiltered
 vlan pkts
Date: Sun, 20 Mar 2011 22:41:30 -0700
Message-ID: <3367B80B08154D42A3B2BC708B5D41F63CC492C950@EXMAIL.ad.emulex.com>
References: <1300454462-1234-1-git-send-email-sathya.perla@emulex.com>
 <1300454462-1234-2-git-send-email-sathya.perla@emulex.com>
 <e340379d-68e1-42af-b7b7-94e07e729884@exht1.ad.emulex.com>
 <AANLkTimNHmvFznX-XHmhdVmkRBBjrkEa1OyAB=gSCciu@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:42719 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751039Ab1CUFrI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 01:47:08 -0400
In-Reply-To: <AANLkTimNHmvFznX-XHmhdVmkRBBjrkEa1OyAB=gSCciu@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, can you pls clarify what you mean by the "new vlan model" below...

thanks,
-Sathya

-----Original Message-----
=46rom: Jesse Gross [mailto:jesse@nicira.com]=20
Sent: Saturday, March 19, 2011 2:05 AM
To: Perla, Sathya
Cc: netdev@vger.kernel.org
Subject: Re: [PATCH net-next-2.6 2/6] be2net: fix to not drop unfiltere=
d vlan pkts

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
