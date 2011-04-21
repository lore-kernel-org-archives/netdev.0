From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: Re: [PATCH v5] net: bnx2x: convert to hw_features
Date: Thu, 21 Apr 2011 21:49:10 +0300
Message-ID: <1303411750.19212.123.camel@lb-tlvb-vladz>
References: <20110412144940.GA26043@rere.qmqm.pl>
 <20110411202630.C079D13909@rere.qmqm.pl>
 <1302610228.32697.298.camel@lb-tlvb-vladz>
 <20110412140708.GA21835@rere.qmqm.pl>
 <1302619012.6750.8.camel@lb-tlvb-vladz>
 <20110412193823.0823213A65@rere.qmqm.pl>
 <1303397531.3685.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4749 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752120Ab1DUStY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2011 14:49:24 -0400
In-Reply-To: <1303397531.3685.16.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-04-21 at 07:52 -0700, Eric Dumazet wrote:
> Le mardi 12 avril 2011  21:38 +0200, Micha Mirosaw a crit :
> > Since ndo_fix_features callback is postponing features change when
> > bp->recovery_state != BNX2X_RECOVERY_DONE, netdev_update_features()
> > has to be called again when this condition changes. Previously,
> > ethtool_ops->set_flags callback returned -EBUSY in that case
> > (it's not possible in the new model).
> > 
> > Signed-off-by: Micha Mirosaw <mirq-linux@rere.qmqm.pl>
> > 
> > v5: - don't delay set_features, as it's rtnl_locked - same as recovery process
> > v4: - complete bp->rx_csum -> NETIF_F_RXCSUM conversion
> >     - add check for failed ndo_set_features in ndo_open callback
> > v3: - include NETIF_F_LRO in hw_features
> >     - don't call netdev_update_features() if bnx2x_nic_load() failed
> > v2: - comment in ndo_fix_features callback
> > ---
> 
> Hi guys
> 
> I am not sure its related to these changes, but I now have in
> net-next-2.6 :
> 
> [   23.674263] ------------[ cut here ]------------
> [   23.674266] WARNING: at net/core/dev.c:1318 dev_disable_lro+0x83/0x90()
> [   23.674270] Hardware name: ProLiant BL460c G6
> [   23.674273] Modules linked in: tg3 libphy sg
> [   23.674280] Pid: 3070, comm: sysctl Tainted: G        W   2.6.39-rc2-01242-g3ef22b9-dirty #669
> [   23.674282] Call Trace:
> [   23.674285]  [<ffffffff813b94f3>] ? dev_disable_lro+0x83/0x90
> [   23.674291]  [<ffffffff81042c9b>] warn_slowpath_common+0x8b/0xc0
> [   23.674298]  [<ffffffff81042ce5>] warn_slowpath_null+0x15/0x20
> [   23.674304]  [<ffffffff813b94f3>] dev_disable_lro+0x83/0x90
> [   23.674309]  [<ffffffff81429789>] devinet_sysctl_forward+0x199/0x210
> [   23.674313]  [<ffffffff814296e4>] ? devinet_sysctl_forward+0xf4/0x210
> [   23.674318]  [<ffffffff8104e712>] ? capable+0x12/0x20
> [   23.674324]  [<ffffffff81168f45>] proc_sys_call_handler+0xb5/0xd0
> [   23.674328]  [<ffffffff81168f6f>] proc_sys_write+0xf/0x20
> [   23.674334]  [<ffffffff81105f39>] vfs_write+0xc9/0x170
> [   23.674339]  [<ffffffff81106550>] sys_write+0x50/0x90
> [   23.674345]  [<ffffffff814b95a0>] sysenter_dispatch+0x7/0x33
> [   23.674350] ---[ end trace 051ec497c66b228e ]---
> 
> Thanks
> 

More than that, in addition it is impossible to disable the LRO with 
the current bnx2x upstream driver (ethtool -K ethX lro off) and this is
because dev_disable_lro passes to __ethtool_set_flags() flags based on
the current value of dev->features while __ethtool_set_flags() expects
only the flags set in dev->hw_features. bnx2x has NETIF_F_HW_VLAN_RX
that is set in dev->features and not set in dev->hw_features and it's
passed down to the __ethtool_set_flags(). 

Regarding the 'ethtool -K ethX lro off' I noticed that there is the same
problem: the flags that are passed to the __ethtool_set_flags() include
NETIF_F_HW_VLAN_RX. The userspace app gets the flags set in
dev->features to be able to display them, then clears the needed bits
and passes the resulting value down to kernel. So, I don't know how to
fix this without changing __ethtool_set_flags() not to check the bits or
by the taking care of the bit mask before it's passed to the
__ethtool_set_flags(). Below is the implementation of the second
option: 

diff --git a/net/core/dev.c b/net/core/dev.c
index 3871bf6..fd9175b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1314,7 +1314,7 @@ void dev_disable_lro(struct net_device *dev)
 	if (!(flags & ETH_FLAG_LRO))
 		return;
 
-	__ethtool_set_flags(dev, flags & ~ETH_FLAG_LRO);
+	__ethtool_set_flags(dev, flags & ~ETH_FLAG_LRO & dev->hw_features);
 	WARN_ON(dev->features & NETIF_F_LRO);
 }
 EXPORT_SYMBOL(dev_disable_lro);
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 13d79f5..bbf75fc 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1810,7 +1810,7 @@ static int ethtool_set_value(struct net_device *dev, char __user *useraddr,
 	if (copy_from_user(&edata, useraddr, sizeof(edata)))
 		return -EFAULT;
 
-	return actor(dev, edata.data);
+	return actor(dev, edata.data & dev->hw_features);
 }
 
 static noinline_for_stack int ethtool_flash_device(struct net_device *dev,

Pls., comment.

Thanks,
vlad



> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 



