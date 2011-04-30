From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH net-next-2.6] veth: remove unneeded ifname code from
 veth_newlink()
Date: Sat, 30 Apr 2011 13:28:17 +0200
Message-ID: <20110430112817.GD2658@psychotron.orion>
References: <20110124154546.GA2689@psychotron.brq.redhat.com>
 <BANLkTi=x8xi7-g3SZdva7Ndg0a4EY1NK8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, xemul@openvz.org
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7309 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752639Ab1D3L2W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Apr 2011 07:28:22 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTi=x8xi7-g3SZdva7Ndg0a4EY1NK8g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Apr 22, 2011 at 11:43:10AM CEST, mirqus@gmail.com wrote:
>2011/1/24 Jiri Pirko <jpirko@redhat.com>:
>> The code is not needed because tb[IFLA_IFNAME] is already
>> processed in rtnl_newlink(). Remove this redundancy.
>>
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>
>Hi. This patch broke creation of veth devices. Reverting it fixes the issue.

Sorry for troubles.

For net-next-2.6 this is fixed by:
http://patchwork.ozlabs.org/patch/93498/

For net-2.6 I suggest to revert this patch:

Subject: [PATCH net-2.6] Revert: veth: remove unneeded ifname code from veth_newlink()

84c49d8c3e4abefb0a41a77b25aa37ebe8d6b743 caused regression on veth
creation. This patch reverts the original one.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/veth.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 2de9b90..3b99f64 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -403,6 +403,17 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 	if (tb[IFLA_ADDRESS] == NULL)
 		random_ether_addr(dev->dev_addr);
 
+	if (tb[IFLA_IFNAME])
+		nla_strlcpy(dev->name, tb[IFLA_IFNAME], IFNAMSIZ);
+	else
+		snprintf(dev->name, IFNAMSIZ, DRV_NAME "%%d");
+
+	if (strchr(dev->name, '%')) {
+		err = dev_alloc_name(dev, dev->name);
+		if (err < 0)
+			goto err_alloc_name;
+	}
+
 	err = register_netdevice(dev);
 	if (err < 0)
 		goto err_register_dev;
@@ -422,6 +433,7 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 
 err_register_dev:
 	/* nothing to do */
+err_alloc_name:
 err_configure_peer:
 	unregister_netdevice(peer);
 	return err;
-- 
1.7.4.2

