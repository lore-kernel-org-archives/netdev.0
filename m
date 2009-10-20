From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: pktgen and spin_lock_bh in xmit path
Date: Tue, 20 Oct 2009 19:44:05 +0200
Message-ID: <4ADDF6E5.4070509@gmail.com>
References: <4ADD309B.1040505@candelatech.com> <4ADD32FA.6030409@gmail.com> <4ADD41F5.5080707@candelatech.com> <4ADDF560.1020509@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>, robert@herjulf.net
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:42055 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751096AbZJTRoH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 13:44:07 -0400
In-Reply-To: <4ADDF560.1020509@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear a =E9crit :
> On 10/19/2009 09:52 PM, Ben Greear wrote:
>> Eric Dumazet wrote:
>>> Ben Greear a =E9crit :
>>>> I'm having strange issues when running pktgen on 10G interfaces wh=
ile
>>>> also running
>>>> pktgen on mac-vlans on that interface, when the mac-vlan pktgen th=
reads
>>>> are on a different
>>>> CPU.
>=20
>=20
> I think I found the problem.  First, lockdep was not the issue, and
> mac-vlans
> were properly setting up the lockdep keys.  I would have expected
> lockdep to
> figure out I was trying to lock a non-valid lock, but maybe something=
 else
> kept that from happening.
>=20
> Second:  I think the problem can only happen on my code tree because =
I
> added code to allow mac-vlans to return NETDEV_TX_BUSY
> when a hacked varient of dev_queue_xmit decided it could not immediat=
ely
> transmit a packet.  Without my change, a packet would have to be crea=
ted
> fresh
> in this scenario, so it would not hit the bug.
>=20
> However, I think pktgen might still need a similar fix because other
> drivers or
> logic might also change the skb tx-queue map.
>=20
> Here is the problem, or at least one of them:
>=20
> pktgen tries to xmit, but gets NETDEV_TX_BUSY.  During the xmit attem=
pt,
> the
> skb queue map was changed to that of the underlying device, which was
> 4.  Note
> that mac-vlans have only a single tx queue.

Thats not true since commit 2c11455321f37da6fe6cc36353149f9ac9183334
Date:   Thu Sep 3 00:11:45 2009 +0000
(macvlan: add multiqueue capability )

    macvlan devices are currently not multi-queue capable.

    We can do that defining rtnl_link_ops method,
    get_tx_queues(), called from rtnl_create_link()

    This new method gets num_tx_queues/real_num_tx_queues
    from lower device.

    macvlan_get_tx_queues() is a copy of vlan_get_tx_queues().

    Because macvlan_start_xmit() has to update netdev_queue
    stats only (and not dev->stats), I chose to change
    tx_errors/tx_aborted_errors accounting to tx_dropped,
    since netdev_queue structure doesnt define tx_errors /
    tx_aborted_errors.


> pktgen will retry this skb, but it never resets the skb queue back to=
 0.
> This means that it will soon be accessing txq[4], which is corrupting
> memory.  Things rapidly decline from here!

Something is really wrong on your kernel :)

>=20
> Here is a patch for comment, in case the pktgen folks would like to
> apply something similar:
>=20
> @@ -3991,11 +4001,26 @@ static void pktgen_xmit(struct pktgen_dev
> *pkt_dev, u64 now)
>                 }
>         }
>=20
> -       if (!pkt_dev->skb) {
> +       if ((!pkt_dev->skb) || (pkt_dev->clone_count <=3D 1)) {
> +               /** If clone count is low, that might be because devi=
ce
> is a layered
> +                * virtual device, like mac-vlan.  In that case, the
> queue-map may be
> +                * changed while transmitting out the lower levels, s=
o
> we need to
> +                * reset this here so we don't accidentally use a bog=
us
> queue.
> +                */
> +       reset_queue_map:
>                 set_cur_queue_map(pkt_dev);
>                 queue_map =3D pkt_dev->cur_queue_map;
>         } else {
>                 queue_map =3D skb_get_queue_mapping(pkt_dev->skb);
> +               if (unlikely(queue_map >=3D odev->num_tx_queues)) {
> +                       static int do_once =3D 1;
> +                       if (do_once) {
> +                               printk("pktgen ERROR:  queue_map rang=
e
> error, queue_map: %i  num_tx_queues: %i  iface: %s\n",
> +                                      queue_map, odev->num_tx_queues=
,
> odev->name);
> +                               WARN_ON(1);
> +                       }
> +                       goto reset_queue_map;
> +               }
>         }
>=20
>         txq =3D netdev_get_tx_queue(odev, queue_map);

Please try last kernel before posting patches :)
