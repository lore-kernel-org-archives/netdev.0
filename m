From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net v3] xen-netback: fix race condition on XenBus
 disconnect
Date: Fri, 10 Mar 2017 07:36:20 +0800
Message-ID: <201703100713.sZb9Gsru%fengguang.wu@intel.com>
References: <1489088497-9027-1-git-send-email-igor.druzhinin@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org,
        xen-devel@lists.xenproject.org, paul.durrant@citrix.com,
        jgross@suse.com, wei.liu2@citrix.com,
        Igor Druzhinin <igor.druzhinin@citrix.com>
To: Igor Druzhinin <igor.druzhinin@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:47353 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754596AbdCIXhJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 18:37:09 -0500
Content-Disposition: inline
In-Reply-To: <1489088497-9027-1-git-send-email-igor.druzhinin@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Igor,

[auto build test WARNING on net/master]

url:    https://github.com/0day-ci/linux/commits/Igor-Druzhinin/xen-netback-fix-race-condition-on-XenBus-disconnect/20170310-055447
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   include/linux/compiler.h:264:8: sparse: attribute 'no_sanitize_address': unknown attribute
>> drivers/net/xen-netback/interface.c:178:22: sparse: incompatible types in comparison expression (different address spaces)
   drivers/net/xen-netback/interface.c:237:22: sparse: incompatible types in comparison expression (different address spaces)
   drivers/net/xen-netback/interface.c:389:22: sparse: incompatible types in comparison expression (different address spaces)

vim +178 drivers/net/xen-netback/interface.c

   162	}
   163	
   164	static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
   165	{
   166		struct xenvif *vif = netdev_priv(dev);
   167		struct xenvif_queue *queue = NULL;
   168		unsigned int num_queues;
   169		u16 index;
   170		struct xenvif_rx_cb *cb;
   171	
   172		BUG_ON(skb->dev != dev);
   173	
   174		/* Drop the packet if queues are not set up.
   175		 * This handler should be called inside an RCU read section
   176		 * so we don't need to enter it here explicitly.
   177		 */
 > 178		num_queues = rcu_dereference(vif)->num_queues;
   179		if (num_queues < 1)
   180			goto drop;
   181	
   182		/* Obtain the queue to be used to transmit this packet */
   183		index = skb_get_queue_mapping(skb);
   184		if (index >= num_queues) {
   185			pr_warn_ratelimited("Invalid queue %hu for packet on interface %s\n.",
   186					    index, vif->dev->name);

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
