From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v2 1/3] net: add support for phys_port_name
Date: Tue, 17 Mar 2015 08:23:19 +0100
Message-ID: <20150317072319.GH2042@nanopsycho.orion>
References: <1426562837-13126-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Scott Feldman <sfeldma@gmail.com>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:35980 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752486AbbCQHXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 03:23:22 -0400
Received: by wibg7 with SMTP id g7so55817437wib.1
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 00:23:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1426562837-13126-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Mar 17, 2015 at 04:27:15AM CET, dsahern@gmail.com wrote:
>Similar to port id allow netdevices to specify port names and export
>the name via sysfs. Drivers can implement the netdevice operation to
>assist udev in having sane default names for the devices using the
>rule:
>
>$ cat /etc/udev/rules.d/80-net-setup-link.rules
>SUBSYSTEM=="net", ACTION=="add", ATTR{phys_port_name}!="",
>NAME="$attr{phys_port_name}"
>
>Use of phys_name versus phys_id was suggested-by Jiri Pirko.
>
>v2:
>- replaced netdev_phys_item_name with buffer and length per Jiri's comment
>
>Signed-off-by: David Ahern <dsahern@gmail.com>
>Cc: Jiri Pirko <jiri@resnulli.us>
>Cc: Scott Feldman <sfeldma@gmail.com>
>---
> include/linux/netdevice.h    |  4 ++++
> include/uapi/linux/if_link.h |  1 +
> net/core/dev.c               | 18 ++++++++++++++++++
> net/core/net-sysfs.c         | 23 +++++++++++++++++++++++
> net/core/rtnetlink.c         | 21 +++++++++++++++++++++
> 5 files changed, 67 insertions(+)
>
>diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>index dd1d069758be..d4df818d6606 100644
>--- a/include/linux/netdevice.h
>+++ b/include/linux/netdevice.h
>@@ -1159,6 +1159,8 @@ struct net_device_ops {
> 						      bool new_carrier);
> 	int			(*ndo_get_phys_port_id)(struct net_device *dev,
> 							struct netdev_phys_item_id *ppid);
>+	int			(*ndo_get_phys_port_name)(struct net_device *dev,
>+							  char *buf, int len);

							please change
							this to "char
							*name" and
							"size_t len"

With that changes, feel free to add my
Acked-by: Jiri Pirko <jiri@resnulli.us>

Thanks David for taking care of this.


> 	void			(*ndo_add_vxlan_port)(struct  net_device *dev,
> 						      sa_family_t sa_family,
> 						      __be16 port);
>@@ -2939,6 +2941,8 @@ int dev_set_mac_address(struct net_device *, struct sockaddr *);
> int dev_change_carrier(struct net_device *, bool new_carrier);
> int dev_get_phys_port_id(struct net_device *dev,
> 			 struct netdev_phys_item_id *ppid);
>+int dev_get_phys_port_name(struct net_device *dev,
>+			   char *buf, int len);
> struct sk_buff *validate_xmit_skb_list(struct sk_buff *skb, struct net_device *dev);
> struct sk_buff *dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
> 				    struct netdev_queue *txq, int *ret);
>diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
>index 756436e1ce89..7158fd00a109 100644
>--- a/include/uapi/linux/if_link.h
>+++ b/include/uapi/linux/if_link.h
>@@ -147,6 +147,7 @@ enum {
> 	IFLA_CARRIER_CHANGES,
> 	IFLA_PHYS_SWITCH_ID,
> 	IFLA_LINK_NETNSID,
>+	IFLA_PHYS_PORT_NAME,
> 	__IFLA_MAX
> };
> 
>diff --git a/net/core/dev.c b/net/core/dev.c
>index 39fe369b46ad..ae2a1ecf33be 100644
>--- a/net/core/dev.c
>+++ b/net/core/dev.c
>@@ -5912,6 +5912,24 @@ int dev_get_phys_port_id(struct net_device *dev,
> EXPORT_SYMBOL(dev_get_phys_port_id);
> 
> /**
>+ *	dev_get_phys_port_name - Get device physical port name
>+ *	@dev: device
>+ *	@name: port name
>+ *
>+ *	Get device physical port name
>+ */
>+int dev_get_phys_port_name(struct net_device *dev,
>+			   char *buf, int len)
>+{
>+	const struct net_device_ops *ops = dev->netdev_ops;
>+
>+	if (!ops->ndo_get_phys_port_name)
>+		return -EOPNOTSUPP;
>+	return ops->ndo_get_phys_port_name(dev, buf, len);
>+}
>+EXPORT_SYMBOL(dev_get_phys_port_name);
>+
>+/**
>  *	dev_new_index	-	allocate an ifindex
>  *	@net: the applicable net namespace
>  *
>diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
>index cf30620a88e1..b2a673870c4b 100644
>--- a/net/core/net-sysfs.c
>+++ b/net/core/net-sysfs.c
>@@ -418,6 +418,28 @@ static ssize_t phys_port_id_show(struct device *dev,
> }
> static DEVICE_ATTR_RO(phys_port_id);
> 
>+static ssize_t phys_port_name_show(struct device *dev,
>+				   struct device_attribute *attr, char *buf)
>+{
>+	struct net_device *netdev = to_net_dev(dev);
>+	ssize_t ret = -EINVAL;
>+
>+	if (!rtnl_trylock())
>+		return restart_syscall();
>+
>+	if (dev_isalive(netdev)) {
>+		char name[IFNAMSIZ];
>+
>+		ret = dev_get_phys_port_name(netdev, name, sizeof(name));
>+		if (!ret)
>+			ret = sprintf(buf, "%s\n", name);
>+	}
>+	rtnl_unlock();
>+
>+	return ret;
>+}
>+static DEVICE_ATTR_RO(phys_port_name);
>+
> static ssize_t phys_switch_id_show(struct device *dev,
> 				   struct device_attribute *attr, char *buf)
> {
>@@ -465,6 +487,7 @@ static struct attribute *net_class_attrs[] = {
> 	&dev_attr_tx_queue_len.attr,
> 	&dev_attr_gro_flush_timeout.attr,
> 	&dev_attr_phys_port_id.attr,
>+	&dev_attr_phys_port_name.attr,
> 	&dev_attr_phys_switch_id.attr,
> 	NULL,
> };
>diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
>index 25b4b5d23485..7227b5695394 100644
>--- a/net/core/rtnetlink.c
>+++ b/net/core/rtnetlink.c
>@@ -982,6 +982,24 @@ static int rtnl_phys_port_id_fill(struct sk_buff *skb, struct net_device *dev)
> 	return 0;
> }
> 
>+static int rtnl_phys_port_name_fill(struct sk_buff *skb, struct net_device *dev)
>+{
>+	char buf[IFNAMSIZ];
>+	int err;
>+
>+	err = dev_get_phys_port_name(dev, buf, sizeof(buf));
>+	if (err) {
>+		if (err == -EOPNOTSUPP)
>+			return 0;
>+		return err;
>+	}
>+
>+	if (nla_put(skb, IFLA_PHYS_PORT_NAME, strlen(buf), buf))
>+		return -EMSGSIZE;
>+
>+	return 0;
>+}
>+
> static int rtnl_phys_switch_id_fill(struct sk_buff *skb, struct net_device *dev)
> {
> 	int err;
>@@ -1072,6 +1090,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
> 	if (rtnl_phys_port_id_fill(skb, dev))
> 		goto nla_put_failure;
> 
>+	if (rtnl_phys_port_name_fill(skb, dev))
>+		goto nla_put_failure;
>+
> 	if (rtnl_phys_switch_id_fill(skb, dev))
> 		goto nla_put_failure;
> 
>-- 
>2.2.1
>
