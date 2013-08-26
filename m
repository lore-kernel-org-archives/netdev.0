From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v1 1/9] net: add netdev_upper_get_next_dev(dev,
 iter)
Date: Mon, 26 Aug 2013 22:57:48 +0200
Message-ID: <20130826205748.GB3723@minipsycho.orion>
References: <1377549162-7522-1-git-send-email-vfalico@redhat.com>
 <1377549162-7522-2-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f170.google.com ([209.85.215.170]:48285 "EHLO
	mail-ea0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751741Ab3HZU5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Aug 2013 16:57:52 -0400
Received: by mail-ea0-f170.google.com with SMTP id h14so1894237eak.1
        for <netdev@vger.kernel.org>; Mon, 26 Aug 2013 13:57:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1377549162-7522-2-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Aug 26, 2013 at 10:32:34PM CEST, vfalico@redhat.com wrote:
>This function returns the next dev in the dev->upper_dev_list after the
>struct list_head **iter position, and updates *iter accordingly. Returns
>NULL if there are no devices left.
>
>v1: new patch
>
>CC: "David S. Miller" <davem@davemloft.net>
>CC: Eric Dumazet <edumazet@google.com>
>CC: Jiri Pirko <jiri@resnulli.us>
>CC: Alexander Duyck <alexander.h.duyck@intel.com>
>CC: Cong Wang <amwang@redhat.com>
>Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
>---
> net/core/dev.c |   25 +++++++++++++++++++++++++
> 1 files changed, 25 insertions(+), 0 deletions(-)
>
>diff --git a/net/core/dev.c b/net/core/dev.c
>index 1ed2b66..566e99a 100644
>--- a/net/core/dev.c
>+++ b/net/core/dev.c
>@@ -4477,6 +4477,31 @@ struct net_device *netdev_master_upper_dev_get(struct net_device *dev)
> }
> EXPORT_SYMBOL(netdev_master_upper_dev_get);
> 
>+/* netdev_upper_get_next_dev - Get the next dev from upper list
>+ * @dev: device
>+ * @iter: list_head ** of the current position
>+ *
>+ * Gets the next device from the dev's upper list, starting from iter
>+ * position. The caller must hold RCU read lock.
>+ */
>+struct net_device *netdev_upper_get_next_dev(struct net_device *dev,
>+					     struct list_head **iter)

		This should be probably rather named
		"netdev_upper_get_next_dev_rcu" That way it is clear
		right away. Also if you introduce non-rcu variant in
		future, you won't introduce confusion :)


>+{
>+	struct netdev_upper *upper;
>+
>+	WARN_ON_ONCE(!rcu_read_lock_held());
>+
>+	upper = list_entry_rcu((*iter)->next, struct netdev_upper, list);
>+
>+	if (&upper->list == &dev->upper_dev_list)
>+		return NULL;
>+
>+	*iter = &upper->list;
>+
>+	return upper->dev;
>+}
>+EXPORT_SYMBOL(netdev_upper_get_next_dev);
>+
> /**
>  * netdev_master_upper_dev_get_rcu - Get master upper device
>  * @dev: device
>-- 
>1.7.1
>
