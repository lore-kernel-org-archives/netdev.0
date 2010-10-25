From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH v2 10/14] ixgbe: Update ixgbe to use new vlan accleration.
Date: Mon, 25 Oct 2010 15:02:41 -0700
Message-ID: <4CC5FE81.4020606@intel.com>
References: <1287618974-4714-1-git-send-email-jesse@nicira.com>	<1287618974-4714-11-git-send-email-jesse@nicira.com>	<AANLkTindxJD1a5UPV+6vWbDEeMUTy1QgPs1X8pT-b69D@mail.gmail.com>	<1288029009.1808.1.camel@pjaxe> <AANLkTi=R9f3oAdVAG1MyyTwEqBGRaBj8mtLPg15R2BjW@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Jesse Gross <jesse@nicira.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:63568 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756153Ab0JYWCm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Oct 2010 18:02:42 -0400
In-Reply-To: <AANLkTi=R9f3oAdVAG1MyyTwEqBGRaBj8mtLPg15R2BjW@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/25/2010 2:40 PM, Micha=B3 Miros=B3aw wrote:
> W dniu 25 pa=BCdziernika 2010 19:50 u=BFytkownik Peter P Waskiewicz J=
r
> <peter.p.waskiewicz.jr@intel.com> napisa=B3:
>> On Fri, 2010-10-22 at 06:24 -0700, Micha=B3 Miros=B3aw wrote:
>>> 2010/10/21 Jesse Gross <jesse@nicira.com>:
>>>> Make the ixgbe driver use the new vlan accleration model.
>>> [...]
>>>> --- a/drivers/net/ixgbe/ixgbe_main.c
>>>> +++ b/drivers/net/ixgbe/ixgbe_main.c
>>>> @@ -954,17 +954,13 @@ static void ixgbe_receive_skb(struct ixgbe_q=
_vector *q_vector,
>>>>        bool is_vlan =3D (status & IXGBE_RXD_STAT_VP);
>>>>        u16 tag =3D le16_to_cpu(rx_desc->wb.upper.vlan);
>>>>
>>>> -       if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL)) {
>>>> -               if (adapter->vlgrp && is_vlan && (tag & VLAN_VID_M=
ASK))
>>>> -                       vlan_gro_receive(napi, adapter->vlgrp, tag=
, skb);
>>>> -               else
>>>> -                       napi_gro_receive(napi, skb);
>>>> -       } else {
>>>> -               if (adapter->vlgrp && is_vlan && (tag & VLAN_VID_M=
ASK))
>>>> -                       vlan_hwaccel_rx(skb, adapter->vlgrp, tag);
>>>> -               else
>>>> -                       netif_rx(skb);
>>>> -       }
>>>> +       if (is_vlan && (tag & VLAN_VID_MASK))
>>>> +               __vlan_hwaccel_put_tag(skb, tag);
>>>
>>> I know that this is carried over from the driver, but why tag =3D=3D=
 0 is
>>> treated differently here? VID0 is somewhat special, as normally it
>>> means 802.1p packet, but i.e. in embedded world people are using it=
 as
>>> normal VID. It would be nice to have this handled consistently in t=
he
>>> VLAN core - deliver to base dev (tag stripped) if vlan 0 is not
>>> configured and to vlan dev if it is.
>>
>> ixgbe handles VLAN 0 differently because that's the tag that's used =
when
>> DCB is enabled, and no VLAN is configured.  We have to insert the 80=
2.1p
>> tag for DCB to work, but the OS won't know about the 802.1q tag, and
>> ends up dropping the frame.  So we enable VLAN ID 0 in the HW and te=
ll
>> it to strip the tag, so we can still pass the frame up the stack.
>=20
> So that's actually (part of) what I'm proposing but done at driver le=
vel.
>=20

Michal,

I agree this should be handled outside the driver. Something like this =
should
do,

--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -12,10 +12,12 @@ Hunk #1, a/net/8021q/vlan_core.c bool vlan_hwaccel_=
do_receive(struct sk_buff **skbp)
        struct vlan_rx_stats *rx_stats;

        vlan_dev =3D vlan_find_dev(skb->dev, vlan_id);
-       if (!vlan_dev) {
-               if (vlan_id)
-                       skb->pkt_type =3D PACKET_OTHERHOST;
+       if (!vlan_dev && vlan_id) {
+               skb->pkt_type =3D PACKET_OTHERHOST;
                return false;
+       } else if (!vlan_dev) {
+               skb->vlan_tci =3D 0;
+               return true;
        }

        skb =3D *skbp =3D skb_share_check(skb, GFP_ATOMIC);
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -134,14 +134,14 @@ Hunk #1, a/net/8021q/vlan_dev.c int vlan_skb_recv=
(struct sk_buff *skb, struct net_device *dev,
         * wrapped proto: we do nothing here.
         */

-       if (!vlan_dev) {
+       if (!vlan_dev && vlan_id) {
                if (vlan_id) {
                        pr_debug("%s: ERROR: No net_device for VID: %u =
on dev: %s\n",
                                 __func__, vlan_id, dev->name);
                        goto err_unlock;
                }
                rx_stats =3D NULL;
-       } else {
+       } else if (vlan_id) {
                skb->dev =3D vlan_dev;

                rx_stats =3D this_cpu_ptr(vlan_dev_info(skb->dev)->vlan=
_rx_stats);



> BTW, What happens If you both configure VLAN 0 and enable DCB?
>=20

Currently, on ixgbe VLAN0 will not work with DCB. We should just remove=
 it
on net-next. I'll put together a formal patch for the first part.

Thanks,
John

> Best Regards,
> Micha=B3 Miros=B3aw
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

