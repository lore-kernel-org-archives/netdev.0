From: Oskar Berggren <oskar.berggren@gmail.com>
Subject: ipctl - new tool for efficient read/write of net related sysctl
Date: Sat, 5 May 2012 17:13:54 +0200
Message-ID: <CAHOuc7MQiquWxMZ4YApXXKdsRY_StrTfAK9r_DdkstyYe+kCPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:44853 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755391Ab2EEPOP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 May 2012 11:14:15 -0400
Received: by obbtb18 with SMTP id tb18so5556694obb.19
        for <netdev@vger.kernel.org>; Sat, 05 May 2012 08:14:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

In a project of mine I need to read (and possibly set) many of the properties
found under /proc/sys/net/ipv4/conf/. This is simple enough, except that
when you have hundreds of interfaces, it is really slow. In my tests it takes
about 4 seconds to read a single variable for 700 interfaces. For a while I
worked around this using the binary sysctl() interface, but this is deprecated.

In an experiment to get around this limitation I have created "ipctl", a kernel
module and accompanying user space library/tool. Communication between
kernel and user space is based on generic netlink. What used to take
seconds now happen in a few milliseconds.

So far I have only implemented support for the proxy_arp setting. Do you
think it's worthwhile to pursue this to create something more complete? Are
there other ideas on how one might get fast read/write of the IP-related
settings in procfs?

The full source code is available at:
https://github.com/oskarb/ipctl

Kernel module enclosed below. Haven't done much kernel programming
before, so comments are most welcome!

/Oskar


#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/inetdevice.h>
#include <linux/netdevice.h>
#include <net/netlink.h>
#include <net/genetlink.h>
#include "../../include/libipctl/ipctl-nl.h"

#define MOD_AUTHOR "Oskar Berggren <oskar.berggren@gmail.com>"
#define MOD_DESC "A module to offer efficient mass control of the IP
sysctl family traditionally controlled through /proc."
#define MOD_VER "0.1"


static int ipctl_get_proxyarp_by_ifindex(int ifIndex, int *on)
{
	struct net *net = &init_net;
	struct net_device *dev;
	struct in_device *in_dev;

	dev = dev_get_by_index(net, ifIndex);

	if (dev)
	{
		if (__in_dev_get_rtnl(dev))
		{
			in_dev = __in_dev_get_rtnl(dev);
			*on = IN_DEV_CONF_GET(in_dev, PROXY_ARP);
		}

		dev_put(dev);  // Release reference.
	}

	return 0;
}


static int ipctl_set_proxyarp_by_ifindex(int ifIndex, int on)
{
	struct net *net = &init_net;
	struct net_device *dev;
	struct in_device *in_dev;

	dev = dev_get_by_index(net, ifIndex);

	if (dev)
	{
		if (__in_dev_get_rtnl(dev))
		{
			in_dev = __in_dev_get_rtnl(dev);
			IN_DEV_CONF_SET(in_dev, PROXY_ARP, on);
		}

		dev_put(dev);  // Release reference.
	}

	return 0;
}


/* family definition */
static struct genl_family ipctl_gnl_family = {
	.id = GENL_ID_GENERATE,
	.hdrsize = 0,
	.name = IPCTL_GENL_NAME,
	.version = IPCTL_GENL_VERSION,
	.maxattr = IPCTL_ATTR_MAX,
};


static int ipctl_reply(struct sk_buff *skb, struct genl_info *info,
		       int property, int ifIndex, int value)
{
	struct sk_buff *skb_reply;
	void *msg_head;
	int rc;

	pr_debug("ipctl: reply start\n");

	skb_reply = genlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
	if (skb_reply == NULL)
		goto out;

	msg_head = genlmsg_put(skb_reply, 0, info->snd_seq,
&ipctl_gnl_family, 0, IPCTL_CMD_GET);
	if (msg_head == NULL) {
		rc = -ENOMEM;
		goto out;
	}

	rc = nla_put_u32(skb_reply, IPCTL_ATTR_PROPERTY, property);
	if (rc != 0)
		goto out;

	rc = nla_put_u32(skb_reply, IPCTL_ATTR_IFINDEX, ifIndex);
	if (rc != 0)
		goto out;

	rc = nla_put_u8(skb_reply, IPCTL_ATTR_VALUE, value);
	if (rc != 0)
		goto out;
	
	/* finalize the message */
	genlmsg_end(skb_reply, msg_head);

	rc = genlmsg_reply(skb_reply , info);
	if (rc != 0)
		goto out;

	return 0;
out:
	pr_warning("ipctl: Error occured in reply: %d\n", rc);

	return rc;
}


/* handler for SET messages via NETLINK */
int ipctl_set(struct sk_buff *skb, struct genl_info *info)
{
	/* message handling code goes here; return 0 on success, negative
	 * values on failure */

	int property = nla_get_u32(info->attrs[IPCTL_ATTR_PROPERTY]);
	int ifIndex = nla_get_u32(info->attrs[IPCTL_ATTR_IFINDEX]);
	int value = nla_get_u8(info->attrs[IPCTL_ATTR_VALUE]);

	pr_debug("ipctl: set p=%d i=%d v=%d\n", property, ifIndex, value);

	if (property == IPCTL_PROPERTY_PROXYARP)
		return ipctl_set_proxyarp_by_ifindex(ifIndex, value);

	return 0;
}


/* handler for GET messages via NETLINK */
int ipctl_get(struct sk_buff *skb, struct genl_info *info)
{
	/* message handling code goes here; return 0 on success, negative
	 * values on failure */

	int property = nla_get_u32(info->attrs[IPCTL_ATTR_PROPERTY]);
	int ifIndex = nla_get_u32(info->attrs[IPCTL_ATTR_IFINDEX]);
	int value = 0;
	int retval = 0;

	pr_debug("ipctl: get p=%d i=%d\n", property, ifIndex);

	if (property == IPCTL_PROPERTY_PROXYARP)
		retval = ipctl_get_proxyarp_by_ifindex(ifIndex, &value);

	if (retval)
		return retval;

	return ipctl_reply(skb, info, property, ifIndex, value);
}


/* NETLINK operation definition */
struct genl_ops ipctl_gnl_ops_set = {
	.cmd = IPCTL_CMD_SET,
	.flags = GENL_ADMIN_PERM,
	.policy = ipctl_genl_policy,
	.doit = ipctl_set,
	.dumpit = NULL,
};

struct genl_ops ipctl_gnl_ops_get = {
	.cmd = IPCTL_CMD_GET,
	.flags = 0,
	.policy = ipctl_genl_policy,
	.doit = ipctl_get,
	.dumpit = NULL,
};


static int __init ipctl_init(void)
{
	int rc;

	printk(KERN_INFO "ipctl: %s.\n", MOD_VER);

	rc = genl_register_family(&ipctl_gnl_family);
	if (rc)
		printk("ipctl: genl_register_family: %d.\n", rc);

	rc = genl_register_ops(&ipctl_gnl_family, &ipctl_gnl_ops_set);
	if (rc)
		printk("ipctl: genl_register_ops: %d.\n", rc);

	rc = genl_register_ops(&ipctl_gnl_family, &ipctl_gnl_ops_get);
	if (rc)
		printk("ipctl: genl_register_ops: %d.\n", rc);

	/*
	 * A non 0 return means init_module failed; module can't be loaded.
	 */
	return 0;
}


static void __exit ipctl_exit(void)
{
	genl_unregister_family(&ipctl_gnl_family);
}


module_init(ipctl_init);
module_exit(ipctl_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR(MOD_AUTHOR);
MODULE_DESCRIPTION(MOD_DESC);
MODULE_VERSION(MOD_VER);
