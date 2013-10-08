From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] veth: Showing peer of veth type dev in ip link (kernel
 side)
Date: Tue, 8 Oct 2013 14:13:37 -0700
Message-ID: <20131008141337.1a8a556c@nehalam.linuxnetplumber.net>
References: <1380854061-30091-1-git-send-email-yamato@redhat.com>
	<20131008.152349.729447337097758010.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yamato@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:50554 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755505Ab3JHVNl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 17:13:41 -0400
Received: by mail-pa0-f48.google.com with SMTP id bj1so26147pad.7
        for <netdev@vger.kernel.org>; Tue, 08 Oct 2013 14:13:41 -0700 (PDT)
In-Reply-To: <20131008.152349.729447337097758010.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 08 Oct 2013 15:23:49 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Masatake YAMATO <yamato@redhat.com>
> Date: Fri,  4 Oct 2013 11:34:21 +0900
> 
> > ip link has ability to show extra information of net work device if
> > kernel provides sunh information. With this patch veth driver can
> > provide its peer ifindex information to ip command via netlink
> > interface.
> > 
> > Signed-off-by: Masatake YAMATO <yamato@redhat.com>
> 
> Applied to net-next, thank you.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Please revert this. It is incorrect.
The info returned by any netlink message should be equal to the message
for setting.

I think the correct patch would be something like this (compile tested only).

--- a/drivers/net/veth.c	2013-10-06 14:48:23.806461177 -0700
+++ b/drivers/net/veth.c	2013-10-08 14:11:42.434074690 -0700
@@ -434,6 +434,35 @@ static const struct nla_policy veth_poli
 	[VETH_INFO_PEER]	= { .len = sizeof(struct ifinfomsg) },
 };
 
+static size_t veth_get_size(const struct net_device *dev)
+{
+	return nla_total_size(sizeof(struct ifinfomsg)) + /* VETH_INFO_PEER */
+		0;
+}
+
+static int veth_fill_info(struct sk_buff *skb, const struct net_device *dev)
+{
+	struct veth_priv *priv = netdev_priv(dev);
+	struct net_device *peer = rtnl_dereference(priv->peer);
+
+	if (peer) {
+		struct ifinfomsg ifi = {
+			.ifi_family = AF_UNSPEC,
+			.ifi_type = peer->type,
+			.ifi_index = peer->ifindex,
+			.ifi_flags = dev_get_flags(peer),
+		};
+
+		if (nla_put(skb, VETH_INFO_PEER, sizeof(ifi), &ifi))
+			goto nla_put_failure;
+	}
+
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
 static struct rtnl_link_ops veth_link_ops = {
 	.kind		= DRV_NAME,
 	.priv_size	= sizeof(struct veth_priv),
@@ -443,6 +472,8 @@ static struct rtnl_link_ops veth_link_op
 	.dellink	= veth_dellink,
 	.policy		= veth_policy,
 	.maxtype	= VETH_INFO_MAX,
+	.get_size	= veth_get_size,
+	.fill_info	= veth_fill_info,
 };
 
 /*
