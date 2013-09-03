From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH RFC net-next 18/21] net: add a function to get the
 next/prev private
Date: Tue, 3 Sep 2013 10:10:34 +0200
Message-ID: <20130903081034.GC1437@minipsycho.brq.redhat.com>
References: <1378157965-17537-1-git-send-email-vfalico@redhat.com>
 <1378157965-17537-19-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f171.google.com ([209.85.215.171]:55048 "EHLO
	mail-ea0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752298Ab3ICIKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 04:10:39 -0400
Received: by mail-ea0-f171.google.com with SMTP id n15so2783409ead.2
        for <netdev@vger.kernel.org>; Tue, 03 Sep 2013 01:10:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1378157965-17537-19-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Sep 02, 2013 at 11:39:22PM CEST, vfalico@redhat.com wrote:
>The boolean flag specifies which direction to go.
>
>CC: "David S. Miller" <davem@davemloft.net>
>CC: Eric Dumazet <edumazet@google.com>
>CC: Jiri Pirko <jiri@resnulli.us>
>CC: Alexander Duyck <alexander.h.duyck@intel.com>
>Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
>---
> include/linux/netdevice.h |  2 ++
> net/core/dev.c            | 24 ++++++++++++++++++++++++
> 2 files changed, 26 insertions(+)
>
>diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>index bde2244..a112ccc 100644
>--- a/include/linux/netdevice.h
>+++ b/include/linux/netdevice.h
>@@ -2835,6 +2835,8 @@ extern void *netdev_lower_dev_get_private_rcu(struct net_device *dev,
> 					      struct net_device *lower_dev);
> extern void *netdev_lower_dev_get_private(struct net_device *dev,
> 					  struct net_device *lower_dev);
>+extern void *netdev_lower_dev_get_next_private(struct net_device *dev,
>+					       void *private, bool prev);
> extern int skb_checksum_help(struct sk_buff *skb);
> extern struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
> 	netdev_features_t features, bool tx_path);
>diff --git a/net/core/dev.c b/net/core/dev.c
>index 6df11a0..c694059 100644
>--- a/net/core/dev.c
>+++ b/net/core/dev.c
>@@ -5163,6 +5163,30 @@ void *netdev_lower_dev_get_private(struct net_device *dev,
> }
> EXPORT_SYMBOL(netdev_lower_dev_get_private);
> 
>+extern void *netdev_lower_dev_get_next_private(struct net_device *dev,
>+					       void *private, bool prev)

                                                             ^^^^^^^^^^^
				Please rather do this in 2 functions
				Next should return next, not previous...

>+{
>+	struct netdev_adjacent *lower;
>+
>+	list_for_each_entry(lower, &dev->neighbour_dev_list.lower, list)
>+		if (lower->private == private)
>+			break;
>+
>+	if (&lower->list == &dev->neighbour_dev_list.lower)
>+		return NULL;
>+
>+	lower = prev ? list_entry(lower->list.prev, struct netdev_adjacent, list) :
>+		       list_entry(lower->list.next, struct netdev_adjacent, list);
>+	if (&lower->list != &dev->neighbour_dev_list.lower)
>+		return lower->private;
>+
>+	lower = prev ? list_entry(lower->list.prev, struct netdev_adjacent, list) :
>+		       list_entry(lower->list.next, struct netdev_adjacent, list);
>+
>+	return lower->private;
>+}
>+EXPORT_SYMBOL(netdev_lower_dev_get_next_private);
>+
> static void dev_change_rx_flags(struct net_device *dev, int flags)
> {
> 	const struct net_device_ops *ops = dev->netdev_ops;
>-- 
>1.8.4
>
