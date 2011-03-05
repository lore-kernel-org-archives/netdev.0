From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 2/8] bonding: register slave pointer for
 rx_handler
Date: Sat, 5 Mar 2011 15:27:33 +0100
Message-ID: <20110305142732.GB8573@psychotron.redhat.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com>
 <1299320969-7951-3-git-send-email-jpirko@redhat.com>
 <4D724382.7010705@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14614 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751947Ab1CEO1r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 09:27:47 -0500
Content-Disposition: inline
In-Reply-To: <4D724382.7010705@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Mar 05, 2011 at 03:06:58PM CET, nicolas.2p.debian@gmail.com wrote:
>Le 05/03/2011 11:29, Jiri Pirko a =E9crit :
>>Register slave pointer as rx_handler data. That would eventually prev=
ent
>>need to loop over slave devices to find the right slave.
>>
>>Use synchronize_net to ensure that bond_handle_frame does not get sla=
ve
>>structure freed when working with that.
>>
>>Signed-off-by: Jiri Pirko<jpirko@redhat.com>
>>---
>>  drivers/net/bonding/bond_main.c |   17 +++++++++++------
>>  drivers/net/bonding/bonding.h   |    3 +++
>>  2 files changed, 14 insertions(+), 6 deletions(-)
>>
>>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
>>index 0592e6d..1c19368 100644
>>--- a/drivers/net/bonding/bond_main.c
>>+++ b/drivers/net/bonding/bond_main.c
>>@@ -1495,21 +1495,22 @@ static bool bond_should_deliver_exact_match(s=
truct sk_buff *skb,
>>
>>  static struct sk_buff *bond_handle_frame(struct sk_buff *skb)
>>  {
>>-	struct net_device *slave_dev;
>>+	struct slave *slave;
>>  	struct net_device *bond_dev;
>>
>>  	skb =3D skb_share_check(skb, GFP_ATOMIC);
>>  	if (unlikely(!skb))
>>  		return NULL;
>>-	slave_dev =3D skb->dev;
>>-	bond_dev =3D ACCESS_ONCE(slave_dev->master);
>>+
>>+	slave =3D bond_slave_get_rcu(skb->dev);
>>+	bond_dev =3D ACCESS_ONCE(slave->dev->master);
>>  	if (unlikely(!bond_dev))
>>  		return skb;
>>
>>  	if (bond_dev->priv_flags&  IFF_MASTER_ARPMON)
>>-		slave_dev->last_rx =3D jiffies;
>>+		slave->dev->last_rx =3D jiffies;
>>
>>-	if (bond_should_deliver_exact_match(skb, slave_dev, bond_dev)) {
>>+	if (bond_should_deliver_exact_match(skb, slave->dev, bond_dev)) {
>>  		skb->deliver_no_wcard =3D 1;
>>  		return skb;
>>  	}
>
>Up to this point, it looks like cleanup, and unrelated to the title an=
d description of the patch.

Nope - these are changes connected to the ability to get slave struct
via bond_slave_get_rcu. Very related.

>
>Anyway, the cleanup looks good to me. Should just be in a separate pat=
ch.
>
>>@@ -1703,7 +1704,8 @@ int bond_enslave(struct net_device *bond_dev, s=
truct net_device *slave_dev)
>>  		pr_debug("Error %d calling netdev_set_bond_master\n", res);
>>  		goto err_restore_mac;
>>  	}
>>-	res =3D netdev_rx_handler_register(slave_dev, bond_handle_frame, NU=
LL);
>>+	res =3D netdev_rx_handler_register(slave_dev, bond_handle_frame,
>>+					 new_slave);
>
>And using rx_handler data for this purpose sounds good to me.
>
>Reviewed-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>
>
>>  	if (res) {
>>  		pr_debug("Error %d calling netdev_rx_handler_register\n", res);
>>  		goto err_unset_master;
>>@@ -1925,6 +1927,7 @@ err_close:
>>
>>  err_unreg_rxhandler:
>>  	netdev_rx_handler_unregister(slave_dev);
>>+	synchronize_net();
>>
>>  err_unset_master:
>>  	netdev_set_bond_master(slave_dev, NULL);
>>@@ -2108,6 +2111,7 @@ int bond_release(struct net_device *bond_dev, s=
truct net_device *slave_dev)
>>  	}
>>
>>  	netdev_rx_handler_unregister(slave_dev);
>>+	synchronize_net();
>>  	netdev_set_bond_master(slave_dev, NULL);
>>
>>  	slave_disable_netpoll(slave);
>>@@ -2222,6 +2226,7 @@ static int bond_release_all(struct net_device *=
bond_dev)
>>  		}
>>
>>  		netdev_rx_handler_unregister(slave_dev);
>>+		synchronize_net();
>>  		netdev_set_bond_master(slave_dev, NULL);
>>
>>  		slave_disable_netpoll(slave);
>>diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bond=
ing.h
>>index ff4e269..1aac5cd 100644
>>--- a/drivers/net/bonding/bonding.h
>>+++ b/drivers/net/bonding/bonding.h
>>@@ -264,6 +264,9 @@ struct bonding {
>>  #endif /* CONFIG_DEBUG_FS */
>>  };
>>
>>+#define bond_slave_get_rcu(dev) \
>>+	((struct slave *) rcu_dereference(dev->rx_handler_data))
>>+
>>  /**
>>   * Returns NULL if the net_device does not belong to any of the bon=
d's slaves
>>   *
>
