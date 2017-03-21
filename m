From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/8021q: create device with all possible
 features in wanted_features
Date: Tue, 21 Mar 2017 15:28:11 -0700 (PDT)
Message-ID: <20170321.152811.737733862441297207.davem@davemloft.net>
References: <20170316004114.17059-1-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@virtuozzo.com
To: avagin@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57836 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757217AbdCUWgy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 18:36:54 -0400
In-Reply-To: <20170316004114.17059-1-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrei Vagin <avagin@openvz.org>
Date: Wed, 15 Mar 2017 17:41:14 -0700

> wanted_features is a set of features which have to be enabled if a
> hardware allows that.
> 
> Currently when a vlan device is created, its wanted_features is set to
> current features of its base device.
> 
> The problem is that the base device can get new features and they are
> not propagated to vlan-s of this device.
> 
> If we look at bonding devices, they doesn't have this problem and this
> patch suggests to fix this issue by the same way how it works for bonding
> devices.
> 
> We meet this problem, when we try to create a vlan device over a bonding
> device. When a system are booting, real devices require time to be
> initialized, so bonding devices created without slaves, then vlan
> devices are created and only then ethernet devices are added to the
> bonding device. As a result we have vlan devices with disabled
> scatter-gather.
> 
> * create a bonding device
>   $ ip link add bond0 type bond
>   $ ethtool -k bond0 | grep scatter
>   scatter-gather: off
> 	tx-scatter-gather: off [requested on]
> 	tx-scatter-gather-fraglist: off [requested on]
> 
> * create a vlan device
>   $ ip link add link bond0 name bond0.10 type vlan id 10
>   $ ethtool -k bond0.10 | grep scatter
>   scatter-gather: off
> 	tx-scatter-gather: off
> 	tx-scatter-gather-fraglist: off
> 
> * Add a slave device to bond0
>   $ ip link set dev eth0 master bond0
> 
> And now we can see that the bond0 device has got the scatter-gather
> feature, but the bond0.10 hasn't got it.
> [root@laptop linux-task-diag]# ethtool -k bond0 | grep scatter
> scatter-gather: on
> 	tx-scatter-gather: on
> 	tx-scatter-gather-fraglist: on
> [root@laptop linux-task-diag]# ethtool -k bond0.10 | grep scatter
> scatter-gather: off
> 	tx-scatter-gather: off
> 	tx-scatter-gather-fraglist: off
> 
> With this patch the vlan device will get all new features from the
> bonding device.
> 
> Here is a call trace how features which are set in this patch reach
> dev->wanted_features.
> 
> register_netdevice
>    vlan_dev_init
> 	...
> 	dev->hw_features = NETIF_F_HW_CSUM | NETIF_F_SG |
> 		       NETIF_F_FRAGLIST | NETIF_F_GSO_SOFTWARE |
> 		       NETIF_F_HIGHDMA | NETIF_F_SCTP_CRC |
> 		       NETIF_F_ALL_FCOE;
> 
> 	dev->features |= dev->hw_features;
> 	...
>     dev->wanted_features = dev->features & dev->hw_features;
>     __netdev_update_features(dev);
>         vlan_dev_fix_features
> 	   ...
> 
> Signed-off-by: Andrei Vagin <avagin@openvz.org>

Applied, thanks.
