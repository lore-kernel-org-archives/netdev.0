From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH iproute2 V3 1/4] rdma: Add basic infrastructure for RDMA
 tool
Date: Mon, 10 Jul 2017 09:47:17 +0200
Message-ID: <20170710074717.GB1853@nanopsycho>
References: <20170704075541.12544-1-leon@kernel.org>
 <20170704075541.12544-2-leon@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Doug Ledford <dledford@redhat.com>,
        Ariel Almog <ariela@mellanox.com>,
        Linux RDMA <linux-rdma@vger.kernel.org>,
        Linux Netdev <netdev@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f175.google.com ([209.85.128.175]:33753 "EHLO
        mail-wr0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753497AbdGJHrV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 03:47:21 -0400
Received: by mail-wr0-f175.google.com with SMTP id r103so126910294wrb.0
        for <netdev@vger.kernel.org>; Mon, 10 Jul 2017 00:47:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170704075541.12544-2-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jul 04, 2017 at 09:55:38AM CEST, leon@kernel.org wrote:
>From: Leon Romanovsky <leonro@mellanox.com>
>
>RDMA devices are cross-functional devices from one side,
>but very tailored for the specific markets from another.
>
>Such diversity caused to spread of RDMA related configuration
>across various tools, e.g. devlink, ip, ethtool, ib specific and
>vendor specific solutions.
>
>This patch adds ability to fill device and port information
>by reading RDMA netlink.
>
>Signed-off-by: Leon Romanovsky <leonro@mellanox.com>

[...]

	
>+
>+int rd_dev_init_cb(const struct nlmsghdr *nlh, void *data)
>+{
>+	struct nlattr *tb[RDMA_NLDEV_ATTR_MAX] = {};
>+	struct dev_map *dev_map;
>+	struct rdma *rd = data;
>+	const char *dev_name;
>+
>+	mnl_attr_parse(nlh, 0, rd_attr_cb, tb);
>+	if (!tb[RDMA_NLDEV_ATTR_DEV_NAME] || !tb[RDMA_NLDEV_ATTR_DEV_INDEX])
>+		return MNL_CB_ERROR;
>+	if (!tb[RDMA_NLDEV_ATTR_PORT_INDEX]) {
>+		pr_err("This tool doesn't support switches yet\n");
>+		return MNL_CB_ERROR;
>+	}
>+
>+	dev_name = mnl_attr_get_str(tb[RDMA_NLDEV_ATTR_DEV_NAME]);
>+
>+	dev_map = dev_map_alloc(dev_name);
>+	if (!dev_map)
>+		/* The main function will cleanup the allocations */
>+		return MNL_CB_ERROR;
>+	list_add_tail(&dev_map->list, &rd->dev_map_list);
>+
>+	dev_map->num_ports = mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_PORT_INDEX]);
>+	dev_map->idx = mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_DEV_INDEX]);
>+
>+	return MNL_CB_OK;
>+}
>+
>+void rdma_free_devmap(struct rdma *rd)
>+{
>+	if(!rd)
>+		return;
>+	dev_map_cleanup(rd);
>+}
>+
>+int rdma_exec_cmd(struct rdma *rd, const struct rdma_cmd *cmds, const char *str)

Sometimes the functions are prefixed "rd_", sometimes "rdma_".
I think it would be nice to unify this with "rd_".


>+{
>+	const struct rdma_cmd *c;
>+
>+	/* First argument in objs table is default variant */
>+	if (rd_no_arg(rd))
>+		return cmds->func(rd);
>+
>+	for (c = cmds + 1; c->cmd; ++c) {
>+		if (rd_argv_match(rd, c->cmd)) {
>+			/* Move to next argument */
>+			rd_arg_inc(rd);
>+			return c->func(rd);
>+		}
>+	}
>+
>+	pr_err("Unknown %s '%s'.\n", str, rd_argv(rd));
>+	return 0;
>+}
>+
