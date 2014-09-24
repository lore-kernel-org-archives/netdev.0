From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [RFC PATCH 08/24] net: rbridge: Add Rbridge netlink message skeleton
Date: Wed, 24 Sep 2014 13:52:28 -0400
Message-ID: <542304DC.4090105@gmail.com>
References: <1411573940-14079-1-git-send-email-ahmed@gandi.net> <1411573940-14079-9-git-send-email-ahmed@gandi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: william@gandi.net, f.cachereul@alphalink.fr,
	Kamel Haddadou <kamel@gandi.net>
To: Ahmed Amamou <ahmed@gandi.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:64999 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750793AbaIXRwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 13:52:31 -0400
Received: by mail-qg0-f54.google.com with SMTP id a108so6386531qge.13
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 10:52:30 -0700 (PDT)
In-Reply-To: <1411573940-14079-9-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/24/2014 11:52 AM, Ahmed Amamou wrote:
> add data plane and control plane basic message skeleton
> add netlink socket registration and unregistration respectively within module init and deinit function
> 
> Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
> Signed-off-by: Kamel Haddadou <kamel@gandi.net>
> ---
>  net/bridge/Makefile              |   2 +-
>  net/bridge/br.c                  |   6 ++
>  net/bridge/br_private.h          |   1 +
>  net/bridge/rbridge/rbr_netlink.c | 152 +++++++++++++++++++++++++++++++++++++++
>  net/bridge/rbridge/rbr_netlink.h |  62 ++++++++++++++++
>  5 files changed, 222 insertions(+), 1 deletion(-)
>  create mode 100644 net/bridge/rbridge/rbr_netlink.c
>  create mode 100644 net/bridge/rbridge/rbr_netlink.h
> 
> diff --git a/net/bridge/Makefile b/net/bridge/Makefile
> index 314783c..b11a22b 100644
> --- a/net/bridge/Makefile
> +++ b/net/bridge/Makefile
> @@ -18,4 +18,4 @@ bridge-$(CONFIG_BRIDGE_VLAN_FILTERING) += br_vlan.o
>  
>  obj-$(CONFIG_NETFILTER) += netfilter/
>  
> -bridge-$(CONFIG_TRILL) += rbridge/rbr.o
> +bridge-$(CONFIG_TRILL) += rbridge/rbr.o rbridge/rbr_netlink.o
> diff --git a/net/bridge/br.c b/net/bridge/br.c
> index 1a755a1..51af134 100644
> --- a/net/bridge/br.c
> +++ b/net/bridge/br.c
> @@ -178,6 +178,9 @@ static int __init br_init(void)
>  #if IS_ENABLED(CONFIG_ATM_LANE)
>  	br_fdb_test_addr_hook = br_fdb_test_addr;
>  #endif
> +#ifdef CONFIG_TRILL
> +	rbridge_register_genl();
> +#endif
>  
>  	return 0;
>  err_out4:
> @@ -210,6 +213,9 @@ static void __exit br_deinit(void)
>  	br_fdb_test_addr_hook = NULL;
>  #endif
>  
> +#ifdef CONFIG_TRILL
> +	rbridge_unregister_genl();
> +#endif
>  	br_fdb_fini();
>  }

The above #defines should be removed and inline noop stubs should
be added.

>  
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index 844c87b..6952db8 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -21,6 +21,7 @@
>  #include <linux/if_vlan.h>
>  #ifdef CONFIG_TRILL
>  #include "rbridge/rbr_private.h"
> +#include "rbridge/rbr_netlink.h"
>  #endif
>  
>  #define BR_HASH_BITS 8
> diff --git a/net/bridge/rbridge/rbr_netlink.c b/net/bridge/rbridge/rbr_netlink.c
> new file mode 100644
> index 0000000..eb7c902
> --- /dev/null
> +++ b/net/bridge/rbridge/rbr_netlink.c
> @@ -0,0 +1,152 @@
> +/*
> + *	Generic parts
> + *	Linux ethernet Rbridge
> + *
> + *	Authors:
> + *	Ahmed AMAMOU	<ahmed@gandi.net>
> + *	Kamel Haddadou	<kamel@gandi.net>
> + *
> + *	This program is free software; you can redistribute it and/or
> + *	modify it under the terms of the GNU General Public License
> + *	as published by the Free Software Foundation; either version
> + *	2 of the License, or (at your option) any later version.
> + */
> +
> +#include <net/genetlink.h>
> +#include <net/netlink.h>
> +#include <linux/if_trill.h>
> +#include <linux/socket.h>
> +#include <linux/socket.h>
> +#include "br_private.h"
> +#include "rbr_private.h"
> +#include "rbr_netlink.h"
> +
> +static struct nla_policy attrs_policy[TRILL_ATTR_MAX + 1] = {
> +	[TRILL_ATTR_U16] = {.type = NLA_U16},
> +	[TRILL_ATTR_BIN] = {.type = NLA_UNSPEC},
> +};
> +
> +static struct genl_family trill_genl_family = {
> +	.id = GENL_ID_GENERATE,
> +	.hdrsize = sizeof(struct trill_nl_header),
> +	.name = TRILL_NL_FAMILY,
> +	.version = TRILL_NL_VERSION,
> +	.maxattr = TRILL_ATTR_MAX
> +};
> +
> +static struct genl_multicast_group trill_mcgrps[] = {
> +	[TRILL_MCGRP_OFFSET] = {.name = TRILL_MCAST_NAME,},
> +};
> +
> +static int trill_cmd_set_nicks_info(struct sk_buff *skb, struct genl_info *info)
> +{
> +	return 0;
> +}
> +
> +static int trill_cmd_get_nicks_info(struct sk_buff *skb, struct genl_info *info)
> +{
> +	return 0;
> +}
> +
> +static int trill_cmd_add_nicks_info(struct sk_buff *skb, struct genl_info *info)
> +{
> +	return 0;
> +}
> +
> +static int trill_cmd_set_treeroot_id(struct sk_buff *skb,
> +				     struct genl_info *info)
> +{
> +	return 0;
> +}
> +
> +static int trill_cmd_get_rbridge(struct sk_buff *skb, struct genl_info *info)
> +{
> +	return 0;
> +}
> +
> +static int trill_cmd_set_rbridge(struct sk_buff *skb, struct genl_info *info)
> +{
> +	return 0;
> +}
> +
> +static int trill_cmd_port_flush(struct sk_buff *skb, struct genl_info *info)
> +{
> +	return 0;
> +}
> +
> +static int trill_cmd_nick_flush(struct sk_buff *skb, struct genl_info *info)
> +{
> +	return 0;
> +}
> +
> +static struct genl_ops trill_genl_ops[] = {
> +	{
> +	 .cmd = TRILL_CMD_SET_NICKS_INFO,
> +	 .flags = GENL_ADMIN_PERM,	/* Requires CAP_NET_ADMIN privilege. */
> +	 .policy = attrs_policy,
> +	 .doit = trill_cmd_set_nicks_info,
> +	 },
> +	{
> +	 .cmd = TRILL_CMD_GET_NICKS_INFO,
> +	 .flags = GENL_ADMIN_PERM,	/* Requires CAP_NET_ADMIN privilege. */
> +	 .policy = attrs_policy,
> +	 .doit = trill_cmd_get_nicks_info,
> +	 },
> +	{
> +	 .cmd = TRILL_CMD_ADD_NICKS_INFO,
> +	 .flags = GENL_ADMIN_PERM,	/* Requires CAP_NET_ADMIN privilege. */
> +	 .policy = attrs_policy,
> +	 .doit = trill_cmd_add_nicks_info,
> +	 },
> +	{
> +	 .cmd = TRILL_CMD_SET_TREEROOT_ID,
> +	 .flags = GENL_ADMIN_PERM,	/* Requires CAP_NET_ADMIN privilege. */
> +	 .policy = attrs_policy,
> +	 .doit = trill_cmd_set_treeroot_id,
> +	 },
> +	{
> +	 .cmd = TRILL_CMD_GET_RBRIDGE,
> +	 .flags = GENL_ADMIN_PERM,	/* Requires CAP_NET_ADMIN privilege. */
> +	 .policy = attrs_policy,
> +	 .doit = trill_cmd_get_rbridge,
> +	 },
> +	{
> +	 .cmd = TRILL_CMD_SET_RBRIDGE,
> +	 .flags = GENL_ADMIN_PERM,	/* Requires CAP_NET_ADMIN privilege. */
> +	 .policy = attrs_policy,
> +	 .doit = trill_cmd_set_rbridge,
> +	 },
> +	{
> +	 .cmd = TRILL_CMD_PORT_FLUSH,
> +	 .flags = GENL_ADMIN_PERM,	/* Requires CAP_NET_ADMIN privilege. */
> +	 .doit = trill_cmd_port_flush,
> +	 },
> +	{
> +	 .cmd = TRILL_CMD_NICK_FLUSH,
> +	 .flags = GENL_ADMIN_PERM,	/* Requires CAP_NET_ADMIN privilege. */
> +	 .policy = attrs_policy,
> +	 .doit = trill_cmd_nick_flush,
> +	 },
> +};
> +
> +void __exit rbridge_unregister_genl(void)
> +{
> +	genl_unregister_family(&trill_genl_family);
> +}
> +
> +int __init rbridge_register_genl(void)
> +{
> +	int err;
> +
> +	err =
> +	    genl_register_family_with_ops_groups(&trill_genl_family,
> +						 trill_genl_ops, trill_mcgrps);
> +	if (err)
> +		goto fail_genl_register_family;
> +
> +	return 0;
> +
> + fail_genl_register_family:
> +
> +	return err;
> +}
> diff --git a/net/bridge/rbridge/rbr_netlink.h b/net/bridge/rbridge/rbr_netlink.h
> new file mode 100644
> index 0000000..0556323
> --- /dev/null
> +++ b/net/bridge/rbridge/rbr_netlink.h
> @@ -0,0 +1,62 @@
> +/*
> + *	Generic parts
> + *	Linux ethernet Rbridge
> + *
> + *	Authors:
> + *	Ahmed AMAMOU	<ahmed@gandi.net>
> + *	Kamel Haddadou	<kamel@gandi.net>
> + *
> + *	This program is free software; you can redistribute it and/or
> + *	modify it under the terms of the GNU General Public License
> + *	as published by the Free Software Foundation; either version
> + *	2 of the License, or (at your option) any later version.
> + */
> +
> +#ifndef RBR_NETLINK_H_
> +#define RBR_NETLINK_H_
> +
> +/* TRILL Generic Netlink attributes definition*/
> +#define TRILL_NL_VERSION	0x1
> +#define TRILL_NL_FAMILY		"TRILL_NL"
> +#define TRILL_MCAST_NAME	"TR_NL_MCAST"
> +#define TRILL_MCGRP_OFFSET     0
> +
> +struct trill_nl_header {
> +	int ifindex;		/* port id */
> +	int total_length;	/* message total length for mutipart messages check */
> +	int msg_number;		/* message number for multipart messages check */
> +};
> +
> +enum {
> +	TRILL_ATTR_UNSPEC,
> +	TRILL_ATTR_U16,
> +	TRILL_ATTR_BIN,
> +	__TRILL_ATTR_MAX,
> +};
> +#define TRILL_ATTR_MAX (__TRILL_ATTR_MAX-1)
> +
> +/* GET and set are from user space perspective  example TRILL_CMD_GET_BRIDGE
> + * means that the kernel will send this bridge name to userspace
> + */
> +enum {
> +	TRILL_CMD_UNSPEC,
> +	TRILL_CMD_SET_NICKS_INFO,
> +	TRILL_CMD_GET_NICKS_INFO,
> +	TRILL_CMD_ADD_NICKS_INFO,
> +	TRILL_CMD_DEL_NICK,
> +	TRILL_CMD_SET_TREEROOT_ID,
> +	TRILL_CMD_GET_RBRIDGE,
> +	TRILL_CMD_SET_RBRIDGE,
> +	TRILL_CMD_PORT_FLUSH,
> +	TRILL_CMD_NICK_FLUSH,
> +	__TRILL_CMD_MAX,
> +};
> +#define TRILL_CMD_MAX (__TRILL_CMD_MAX - 1)
> +
> +int __init rbridge_register_genl(void);
> +void __exit rbridge_unregister_genl(void);
> +
> +/* used to indicate that message is provided by kernel to user space */
> +#define KERNL_RESPONSE_INTERFACE -1
> +
> +#endif				/* RBR_NETLINK_H_ */
> 

Bridge is typically configured through rtnetlink and there is an
effort to make this configuration easier.  Switching to genl means
there will be yet another tool to configure some part of the bridge.

-vlad
