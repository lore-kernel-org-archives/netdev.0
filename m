From: Laurent Chavey <chavey@google.com>
Subject: Re: [PATCH v2.6.33 2/2] jme: Adding lock to protect vlgrp structure.
Date: Mon, 15 Mar 2010 11:22:48 -0700
Message-ID: <97949e3e1003151122q68ce19f4ja7f53ad380d3033f@mail.gmail.com>
References: <1268630132-10410-1-git-send-email-cooldavid@cooldavid.org>
	<1268630132-10410-2-git-send-email-cooldavid@cooldavid.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>,
	Ethan Hsiao <ethanhsiao@jmicron.com>
To: cooldavid@cooldavid.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:29377 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965596Ab0COSXM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 14:23:12 -0400
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o2FIN9F8024928
	for <netdev@vger.kernel.org>; Mon, 15 Mar 2010 18:23:10 GMT
Received: from gyd12 (gyd12.prod.google.com [10.243.49.204])
	by wpaz29.hot.corp.google.com with ESMTP id o2FIN8fc007452
	for <netdev@vger.kernel.org>; Mon, 15 Mar 2010 11:23:08 -0700
Received: by gyd12 with SMTP id 12so132069gyd.16
        for <netdev@vger.kernel.org>; Mon, 15 Mar 2010 11:23:08 -0700 (PDT)
In-Reply-To: <1268630132-10410-2-git-send-email-cooldavid@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

what does the spinlock protect ?


On Sun, Mar 14, 2010 at 10:15 PM,  <cooldavid@cooldavid.org> wrote:
> From: Guo-Fu Tseng <cooldavid@cooldavid.org>
>
> Adding a lock to prevent modifying the vlgrp structure while receivin=
g
> VLAN packet.
>
> Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
> ---
> =A0drivers/net/jme.c | =A0 =A06 ++++++
> =A0drivers/net/jme.h | =A0 =A01 +
> =A02 files changed, 7 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/jme.c b/drivers/net/jme.c
> index 3da390a..f10d9db 100644
> --- a/drivers/net/jme.c
> +++ b/drivers/net/jme.c
> @@ -942,11 +942,14 @@ jme_alloc_and_feed_skb(struct jme_adapter *jme,=
 int idx)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb->ip_summed =3D CHE=
CKSUM_NONE;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (rxdesc->descwb.flags & cpu_to_le16=
(RXWBFLAG_TAGON)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&jme->vlgrp_l=
ock);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (jme->vlgrp) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0jme->j=
me_vlan_rx(skb, jme->vlgrp,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0le16_to_cpu(rxdesc->descwb.vlan));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_un=
lock(&jme->vlgrp_lock);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0NET_ST=
AT(jme).rx_bytes +=3D 4;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_un=
lock(&jme->vlgrp_lock);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_kf=
ree_skb(skb);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else {
> @@ -2092,7 +2095,9 @@ jme_vlan_rx_register(struct net_device *netdev,=
 struct vlan_group *grp)
> =A0{
> =A0 =A0 =A0 =A0struct jme_adapter *jme =3D netdev_priv(netdev);
>
> + =A0 =A0 =A0 spin_lock_bh(&jme->vlgrp_lock);
> =A0 =A0 =A0 =A0jme->vlgrp =3D grp;
> + =A0 =A0 =A0 spin_unlock_bh(&jme->vlgrp_lock);
> =A0}
>
> =A0static void
> @@ -2759,6 +2764,7 @@ jme_init_one(struct pci_dev *pdev,
> =A0 =A0 =A0 =A0spin_lock_init(&jme->phy_lock);
> =A0 =A0 =A0 =A0spin_lock_init(&jme->macaddr_lock);
> =A0 =A0 =A0 =A0spin_lock_init(&jme->rxmcs_lock);
> + =A0 =A0 =A0 spin_lock_init(&jme->vlgrp_lock);
>
> =A0 =A0 =A0 =A0atomic_set(&jme->link_changing, 1);
> =A0 =A0 =A0 =A0atomic_set(&jme->rx_cleaning, 1);
> diff --git a/drivers/net/jme.h b/drivers/net/jme.h
> index 251abed..fbde5c5 100644
> --- a/drivers/net/jme.h
> +++ b/drivers/net/jme.h
> @@ -420,6 +420,7 @@ struct jme_adapter {
> =A0 =A0 =A0 =A0spinlock_t =A0 =A0 =A0 =A0 =A0 =A0 =A0phy_lock;
> =A0 =A0 =A0 =A0spinlock_t =A0 =A0 =A0 =A0 =A0 =A0 =A0macaddr_lock;
> =A0 =A0 =A0 =A0spinlock_t =A0 =A0 =A0 =A0 =A0 =A0 =A0rxmcs_lock;
> + =A0 =A0 =A0 spinlock_t =A0 =A0 =A0 =A0 =A0 =A0 =A0vlgrp_lock;
> =A0 =A0 =A0 =A0struct tasklet_struct =A0 rxempty_task;
> =A0 =A0 =A0 =A0struct tasklet_struct =A0 rxclean_task;
> =A0 =A0 =A0 =A0struct tasklet_struct =A0 txclean_task;
> --
> 1.6.4.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
