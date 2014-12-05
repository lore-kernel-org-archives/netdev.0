From: roopa@cumulusnetworks.com
Subject: [PATCH net-next 0/3] switchdev offload flags
Date: Thu,  4 Dec 2014 18:26:38 -0800
Message-ID: <1417746401-8140-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	nhorman@tuxdriver.com, nicolas.dichtel@6wind.com,
	vyasevic@redhat.com, f.fainelli@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:38120 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932378AbaLEC0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 21:26:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch series only addresses bridge link attribute offloads to hardware.

It is a continuation of my previous series on switchdev policy attributes:
http://www.spinics.net/lists/netdev/msg305469.html

Looking at the current state of bridge l2 offload in the kernel,
    - flag 'self' is the way to directly manage the bridge device in hw via
      the ndo_bridge_setlink/ndo_bridge_getlink calls
 
    - flag 'master' is always used to manage the in kernel bridge devices
      via the same ndo_bridge_setlink/ndo_bridge_getlink calls

Today these are used separately. The nic offloads use hwmode "vepa/veb" to go
directly to hw with the "self" flag.

At this point i am trying not to introduce any new user facing flags/attributes.

In the model where we want the kernel bridge device to be offloaded to
hardware (In other words, sync kernel bridge state to hw),
we very much want the bridge driver to be involved.

With this patch series,
When the user sends a bridge setlink message, it will come in with 'master',
        - go to the bridge device,
        - set settings in the kernel
        - if offload mode is set on the port, also call the port driver
          offload ndo_bridge_setlink
        If you want to act on the hw alone, you can still use the self flag to
        go to the hw or port driver directly.
        (There is no need to specify a hardware mode to go to the port driver)

(To selectively offload bridge port attributes,
example learning in hw only etc, we can introduce offload bits for 
per bridge port flag attribute as in my previous patch
https://patchwork.ozlabs.org/patch/413211/. I have not included that in this
series)


Roopa Prabhu (3):
  netdev: introduce new NETIF_F_HW_SWITCH_OFFLOAD feature flag for
    switch device offloads
  bridge: offload bridge port attributes to switch asic if feature flag
    set
  rocker: set feature NETIF_F_HW_SWITCH_OFFLOAD

 drivers/net/ethernet/rocker/rocker.c |    3 ++-
 include/linux/netdev_features.h      |    2 ++
 net/bridge/br_netlink.c              |   27 ++++++++++++++++++++++++++-
 3 files changed, 30 insertions(+), 2 deletions(-)

-- 
1.7.10.4
