From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH net-2.6] macvlan: do a proper cleanup in
 macvlan_common_newlink()
Date: Mon, 24 May 2010 19:02:25 +0200
Message-ID: <20100524170224.GA2816@psychotron.redhat.com>
References: <20100524155857.GO2810@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23830 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757828Ab0EXRC3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 May 2010 13:02:29 -0400
Content-Disposition: inline
In-Reply-To: <20100524155857.GO2810@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, May 24, 2010 at 05:58:58PM CEST, jpirko@redhat.com wrote:
>Fixes possible memory leak.
>
>Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>---
> drivers/net/macvlan.c |    8 +++++++-
> 1 files changed, 7 insertions(+), 1 deletions(-)
>
>diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
>index 4e238af..5f4694b 100644
>--- a/drivers/net/macvlan.c
>+++ b/drivers/net/macvlan.c
>@@ -634,11 +634,17 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
> 
> 	err = register_netdevice(dev);
> 	if (err < 0)
>-		return err;
>+		goto destroy_port;
> 
> 	list_add_tail(&vlan->list, &port->vlans);
> 	netif_stacked_transfer_operstate(lowerdev, dev);
>+
> 	return 0;
>+
>+destroy_port:
>+	macvlan_port_destroy(lowerdev);
>+
>+	return err;
> }
> EXPORT_SYMBOL_GPL(macvlan_common_newlink);
> 
>-- 
>1.6.6.1

Actually it should be rather like this:

Subject: [PATCH net-2.6] macvlan: do proper cleanup in macvlan_common_newlink() V2

Fixes possible memory leak.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/macvlan.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 4e238af..87e8d4c 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -634,11 +634,18 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 
 	err = register_netdevice(dev);
 	if (err < 0)
-		return err;
+		goto destroy_port;
 
 	list_add_tail(&vlan->list, &port->vlans);
 	netif_stacked_transfer_operstate(lowerdev, dev);
+
 	return 0;
+
+destroy_port:
+	if (list_empty(&port->vlans))
+		macvlan_port_destroy(lowerdev);
+
+	return err;
 }
 EXPORT_SYMBOL_GPL(macvlan_common_newlink);
 
-- 
1.6.6.1

