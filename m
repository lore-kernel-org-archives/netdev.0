From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH iproute2 V3 3/4] rdma: Add link object
Date: Mon, 10 Jul 2017 19:22:23 +0300
Message-ID: <20170710162223.GO1528@mtr-leonro.local>
References: <20170704075541.12544-1-leon@kernel.org>
 <20170704075541.12544-4-leon@kernel.org>
 <20170710081307.GE1853@nanopsycho>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="hCRFYJKfs6IGypzU"
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Doug Ledford <dledford@redhat.com>,
        Ariel Almog <ariela@mellanox.com>,
        Linux RDMA <linux-rdma@vger.kernel.org>,
        Linux Netdev <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:47810 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754491AbdGJQW1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Jul 2017 12:22:27 -0400
Content-Disposition: inline
In-Reply-To: <20170710081307.GE1853@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--hCRFYJKfs6IGypzU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jul 10, 2017 at 10:13:07AM +0200, Jiri Pirko wrote:
> Tue, Jul 04, 2017 at 09:55:40AM CEST, leon@kernel.org wrote:
> >From: Leon Romanovsky <leonro@mellanox.com>
> >
> >Link (port) object represent struct ib_port to the user space.
> >
> >Link properties:
> > * Port capabilities
> > * IB subnet prefix
> > * LID, SM_LID and LMC
> > * Port state
> > * Physical state
> >
> >Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
> >---
> > rdma/Makefile |   2 +-
> > rdma/link.c   | 280 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
> > rdma/rdma.c   |   3 +-
> > rdma/utils.c  |   5 ++
> > 4 files changed, 288 insertions(+), 2 deletions(-)
> > create mode 100644 rdma/link.c
> >
> >diff --git a/rdma/Makefile b/rdma/Makefile
> >index 123d7ac5..1a9e4b1a 100644
> >--- a/rdma/Makefile
> >+++ b/rdma/Makefile
> >@@ -2,7 +2,7 @@ include ../Config
> >
> > ifeq ($(HAVE_MNL),y)
> >
> >-RDMA_OBJ = rdma.o utils.o dev.o
> >+RDMA_OBJ = rdma.o utils.o dev.o link.o
> >
> > TARGETS=rdma
> > CFLAGS += $(shell $(PKG_CONFIG) libmnl --cflags)
> >diff --git a/rdma/link.c b/rdma/link.c
> >new file mode 100644
> >index 00000000..f92b4cef
> >--- /dev/null
> >+++ b/rdma/link.c
> >@@ -0,0 +1,280 @@
> >+/*
> >+ * link.c	RDMA tool
> >+ *
> >+ *              This program is free software; you can redistribute it and/or
> >+ *              modify it under the terms of the GNU General Public License
> >+ *              as published by the Free Software Foundation; either version
> >+ *              2 of the License, or (at your option) any later version.
> >+ *
> >+ * Authors:     Leon Romanovsky <leonro@mellanox.com>
> >+ */
> >+
> >+#include "rdma.h"
> >+
> >+static int link_help(struct rdma *rd)
> >+{
> >+	pr_out("Usage: %s link show [DEV/PORT_INDEX]\n", rd->filename);
> >+	return 0;
> >+}
> >+
> >+static void link_print_caps(struct nlattr **tb)
> >+{
> >+	uint64_t caps;
> >+	uint32_t idx;
> >+
> >+	/*
> >+	 * FIXME: move to indexes when kernel will start exporting them.
>
> Not exported yet?

Not yet, I want to minimize the UAPI export from kernel before user-space
part is accepted.

>
>
>
> >+	 */
> >+	static const char *link_caps[64] = {
>
> []

It will require from me to fill all 64 fields.
In current version, I'm leveraging the fact that static is initialized
to zero (NULL).

>
>
> >+		"UNKNOWN",
> >+		"SM",
> >+		"NOTICE",
> >+		"TRAP",
> >+		"OPT_IPD",
> >+		"AUTO_MIGR",
> >+		"SL_MAP",
> >+		"MKEY_NVRAM",
> >+		"PKEY_NVRAM",
> >+		"LED_INFO",
> >+		"SM_DISABLED",
> >+		"SYS_IMAGE_GUID",
> >+		"PKEY_SW_EXT_PORT_TRAP",
> >+		"UNKNOWN",
> >+		"EXTENDED_SPEEDS",
> >+		"UNKNOWN",
> >+		"CM",
> >+		"SNMP_TUNNEL",
> >+		"REINIT",
> >+		"DEVICE_MGMT",
> >+		"VENDOR_CLASS",
> >+		"DR_NOTICE",
> >+		"CAP_MASK_NOTICE",
> >+		"BOOT_MGMT",
> >+		"LINK_LATENCY",
> >+		"CLIENT_REG",
> >+		"IP_BASED_GIDS",
> >+	};
> >+
> >+	if (!tb[RDMA_NLDEV_ATTR_CAP_FLAGS])
> >+		return;
> >+
> >+	caps = mnl_attr_get_u64(tb[RDMA_NLDEV_ATTR_CAP_FLAGS]);
> >+
> >+	pr_out("\n    caps: <");
> >+	for (idx = 0; idx < 64; idx++) {
> >+		if (caps & 0x1) {
> >+			pr_out("%s", link_caps[idx]?link_caps[idx]:"UNKNONW");
>
> "link_caps[idx] ? link_caps[idx] : "UNKNOWN""
>
> note the s/UNKNONW/UNKNOWN/

Right

>
>
> >+			if (caps >> 0x1)
> >+				pr_out(", ");
> >+		}
> >+		caps >>= 0x1;
>
> Interesting.
>
>
> >+	}
> >+
> >+	pr_out(">");
> >+}
> >+
> >+static void link_print_subnet_prefix(struct nlattr **tb)
> >+{
> >+	uint64_t subnet_prefix;
> >+	uint16_t sp[4];
> >+
> >+	if (!tb[RDMA_NLDEV_ATTR_SUBNET_PREFIX])
> >+		return;
> >+
> >+	subnet_prefix = mnl_attr_get_u64(tb[RDMA_NLDEV_ATTR_SUBNET_PREFIX]);
> >+	memcpy(sp, &subnet_prefix, sizeof(uint64_t));
> >+	pr_out("subnet_prefix %04x:%04x:%04x:%04x ", sp[3], sp[2], sp[1], sp[0]);
>
> You have similar pr_out helper in the previous patch. Perhaps you can
> re-use it?

Sure

>
>
> >+}
> >+
> >+static void link_print_lid(struct nlattr **tb)
> >+{
> >+	if (!tb[RDMA_NLDEV_ATTR_LID])
> >+		return;
> >+
> >+	pr_out("lid %u ",
> >+	       mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_LID]));
> >+}
> >+
> >+static void link_print_sm_lid(struct nlattr **tb)
> >+{
> >+
>
> Avoid the extra empty line.
>

Will remove

>
> >+	if (!tb[RDMA_NLDEV_ATTR_SM_LID])
> >+		return;
> >+
> >+	pr_out("sm_lid %u ",
> >+	       mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_SM_LID]));
> >+}
> >+
> >+static void link_print_lmc(struct nlattr **tb)
> >+{
> >+	if (!tb[RDMA_NLDEV_ATTR_LMC])
> >+		return;
> >+
> >+	pr_out("lmc %u ", mnl_attr_get_u8(tb[RDMA_NLDEV_ATTR_LMC]));
> >+}
> >+
> >+static void link_print_state(struct nlattr **tb)
> >+{
> >+	uint8_t state;
> >+	/*
> >+	 * FIXME: move to index exported by the kernel
>
> Again, can't this be fixed now?
>

Not yet, it will be fixed in the second step.

>
> >+	 */
> >+	static const char *str[] = {
> >+		"NOP",
> >+		"DOWN",
> >+		"INIT",
> >+		"ARMED",
> >+		"ACTIVE",
> >+		"ACTIVE_DEFER",
> >+	};
> >+
> >+	if (!tb[RDMA_NLDEV_ATTR_PORT_STATE])
> >+		return;
> >+
> >+	state = mnl_attr_get_u8(tb[RDMA_NLDEV_ATTR_PORT_STATE]);
> >+
> >+	if (state < 6 )
>
> Magic?
>
>
> >+		pr_out("state %s ", str[state]);
> >+	else
> >+		pr_out("state UNKNOWN ");
> >+}
> >+
> >+static void link_print_phys_state(struct nlattr **tb)
> >+{
> >+	uint8_t phys_state;
> >+	/*
> >+	 * FIXME: move to index exported by the kernel
>
> Again, can't this be fixed now?
>
>
> >+	 */
> >+	static const char *str[] = {
> >+		"UNKNOWN",
> >+		"SLEEP",
> >+		"POLLING",
> >+		"DISABLED",
> >+		"PORT_CONFIGURATION_TRAINING",
> >+		"LINK_UP",
> >+		"LINK_ERROR_RECOVER",
> >+		"PHY_TEST",
> >+	};
> >+
> >+	if (!tb[RDMA_NLDEV_ATTR_PORT_PHYS_STATE])
> >+		return;
> >+
> >+	phys_state = mnl_attr_get_u8(tb[RDMA_NLDEV_ATTR_PORT_PHYS_STATE]);
> >+	if (phys_state < 8)
>
> Magic?
>
>
> >+		pr_out("physical_state %s ", str[phys_state]);
> >+	else
> >+		pr_out("physical_state UNKNOWN ");
> >+}
> >+
> >+static int link_parse_cb(const struct nlmsghdr *nlh, void *data)
> >+{
> >+	struct nlattr *tb[RDMA_NLDEV_ATTR_MAX] = {};
> >+	struct rdma *rd = data;
> >+
> >+	mnl_attr_parse(nlh, 0, rd_attr_cb, tb);
> >+	if (!tb[RDMA_NLDEV_ATTR_DEV_INDEX] || !tb[RDMA_NLDEV_ATTR_DEV_NAME])
> >+		return MNL_CB_ERROR;
> >+
> >+	if (!tb[RDMA_NLDEV_ATTR_PORT_INDEX]) {
> >+		pr_err("This tool doesn't support switches yet\n");
> >+		return MNL_CB_ERROR;
> >+	}
> >+
> >+	pr_out("%u/%u: %s/%u: ",
> >+	       mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_DEV_INDEX]),
> >+	       mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_PORT_INDEX]),
> >+	       mnl_attr_get_str(tb[RDMA_NLDEV_ATTR_DEV_NAME]),
> >+	       mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_PORT_INDEX]));
> >+	link_print_subnet_prefix(tb);
> >+	link_print_lid(tb);
> >+	link_print_sm_lid(tb);
> >+	link_print_lmc(tb);
> >+	link_print_state(tb);
> >+	link_print_phys_state(tb);
> >+	if (rd->show_details)
> >+		link_print_caps(tb);
> >+
> >+	pr_out("\n");
> >+	return MNL_CB_OK;
> >+}
> >+
> >+static int link_no_args(struct rdma *rd)
> >+{
> >+	uint32_t seq;
> >+	int ret;
> >+
> >+	rdma_prepare_msg(rd, RDMA_NLDEV_CMD_PORT_GET, &seq, (NLM_F_REQUEST | NLM_F_ACK));
> >+	mnl_attr_put_u32(rd->nlh, RDMA_NLDEV_ATTR_DEV_INDEX, rd->dev_idx);
> >+	mnl_attr_put_u32(rd->nlh, RDMA_NLDEV_ATTR_PORT_INDEX, rd->port_idx);
> >+	if ((ret = rdma_send_msg(rd)))
> >+		return ret;
> >+
> >+	return rdma_recv_msg(rd, link_parse_cb, rd, seq);
> >+}
> >+
> >+static int link_one_show(struct rdma *rd)
> >+{
> >+	const struct rdma_cmd cmds[] = {
> >+		{ NULL,		link_no_args},
> >+		{ 0 }
> >+	};
> >+
> >+	return rdma_exec_cmd(rd, cmds, "parameter");
> >+
>
> Avoid the extra empty line.
>
>
> >+}
> >+
> >+static int link_show(struct rdma *rd)
> >+{
> >+	struct dev_map *dev_map;
> >+	uint32_t port;
> >+	int ret = 0;
> >+
> >+	if (rd_no_arg(rd)) {
> >+		list_for_each_entry(dev_map, &rd->dev_map_list, list) {
> >+			rd->dev_idx = dev_map->idx;
> >+			for (port = 1; port < dev_map->num_ports + 1; port++) {
> >+				rd->port_idx = port;
> >+				ret = link_one_show(rd);
> >+				if (ret)
> >+					return ret;
> >+			}
> >+		}
> >+
> >+	}
> >+	else {
> >+		dev_map = dev_map_lookup(rd, true);
> >+		port = get_port_from_argv(rd);
> >+		if (!dev_map || port > dev_map->num_ports) {
> >+			pr_err("Wrong device name\n");
> >+			return -ENOENT;
> >+		}
> >+		rd_arg_inc(rd);
> >+		rd->port_idx = port ? :1;
>
> "port ? : 1"

Yeah, legal C, the same as (port) ? port : 1
ihttps://en.wikipedia.org/wiki/%3F:#C

>
> >+		for (; port < dev_map->num_ports + 1; port++, rd->port_idx++) {
> >+			ret = link_one_show(rd);
> >+			if (ret)
> >+				return ret;
> >+			if (port)
> >+				/*
> >+				 * We got request to show link for devname
> >+				 * without port index.
> >+				 */
> >+				break;
> >+		}
> >+
> >+	}
> >+	return ret;
>
> 	You can do return 0 here and avoid ret initialization.
>

Sure,

Thank you for the review.


>
> >+}
> >+
> >+int cmd_link(struct rdma *rd)
> >+{
> >+	const struct rdma_cmd cmds[] = {
> >+		{ NULL,		link_show },
> >+		{ "show",	link_show },
> >+		{ "list",	link_show },
> >+		{ "help",	link_help },
> >+		{ 0 }
> >+	};
> >+
> >+	return rdma_exec_cmd(rd, cmds, "link command");
> >+}
> >diff --git a/rdma/rdma.c b/rdma/rdma.c
> >index dfebd71e..f597f614 100644
> >--- a/rdma/rdma.c
> >+++ b/rdma/rdma.c
> >@@ -18,7 +18,7 @@
> > static void help(char *name)
> > {
> > 	pr_out("Usage: %s [ OPTIONS ] OBJECT { COMMAND | help }\n"
> >-	       "where  OBJECT := { dev | help }\n"
> >+	       "where  OBJECT := { dev | link | help }\n"
> > 	       "       OPTIONS := { -V[ersion] | -d[etails]}\n", name);
> > }
> >
> >@@ -34,6 +34,7 @@ static int rd_cmd(struct rdma *rd)
> > 		{ NULL,		cmd_help },
> > 		{ "help",	cmd_help },
> > 		{ "dev",	cmd_dev },
> >+		{ "link",	cmd_link },
> > 		{ 0 }
> > 	};
> >
> >diff --git a/rdma/utils.c b/rdma/utils.c
> >index bee490da..ca61ccc1 100644
> >--- a/rdma/utils.c
> >+++ b/rdma/utils.c
> >@@ -104,6 +104,11 @@ static const enum mnl_attr_data_type nldev_policy[RDMA_NLDEV_ATTR_MAX] = {
> > 	[RDMA_NLDEV_ATTR_FW_VERSION] = MNL_TYPE_NUL_STRING,
> > 	[RDMA_NLDEV_ATTR_NODE_GUID] = MNL_TYPE_U64,
> > 	[RDMA_NLDEV_ATTR_SYS_IMAGE_GUID] = MNL_TYPE_U64,
> >+	[RDMA_NLDEV_ATTR_LID] = MNL_TYPE_U32,
> >+	[RDMA_NLDEV_ATTR_SM_LID] = MNL_TYPE_U32,
> >+	[RDMA_NLDEV_ATTR_LMC] = MNL_TYPE_U8,
> >+	[RDMA_NLDEV_ATTR_PORT_STATE] = MNL_TYPE_U8,
> >+	[RDMA_NLDEV_ATTR_PORT_PHYS_STATE] = MNL_TYPE_U8,
> > 	[RDMA_NLDEV_ATTR_DEV_NODE_TYPE] = MNL_TYPE_U8,
> > };
> >
> >--
> >2.13.2
> >
> >--
> >To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> >the body of a message to majordomo@vger.kernel.org
> >More majordomo info at  http://vger.kernel.org/majordomo-info.html

--hCRFYJKfs6IGypzU
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlljqb8ACgkQ5GN7iDZy
WKe7/Q//Xp6tmNxfXfwXGbuGWTqTiEXwFcsb2MyfVzlwVVAbY8+nnMYuXSNoa2ts
CWLKEJsQSQPBcdH6kDhC8AahkcXW6WEqtSYWKRZvN7AV8eZ9vXU0M8CytXl9YWkp
TeGqxR76FzMjMXo48GXCkz0fzrZuj59QFgHagrmFmJ0eiJIIFYF8Psq8nve9fjFd
QSSv8tjhASCrF8NXf0BJ7qzfE9RM16sXDzoctqyYTDvZ9N4lI6FeiWN78l6KbYhA
GCzkUIk3UODNC5Yy2EPIVx2XpvzQN3By7xX11BqupcDobDcsHF3HhFp34R+FMP2R
ceHoLWij8T8ZcmLJz2ZQ8+KopUpo0ePGjvQoYE0c16tlXev/G452Jdho/Wce+IAb
P1fQJ0RtYyUq0Cqmy+0XIicC/cbCgnRn6kxvR5oqDQ+JBJKl5DAnt2R9ZwnB5vPn
8QeCqQI4uaO/Cf6g8qT/YRAJIDVgMCzL6zwd3rG5amroCYSQ78e0QG7YUgs/SJ2N
zxFJonxNPUx1KmG0X07cF9HpDKgN5EEe50cbePUZzxeg+ImLQ65XYu51EkLQyWzD
q7O3ATcGRGJvZTrOKNBCZP4HRRw8oZSi4c6qpd5bKnaJkYlQvrWyQlnkUxi9eJ98
1Wn8cUeDe4O3rFRMAibo5e1AJgTXwnOKcVsTxdkigsmTQWu0oFU=
=S6Zv
-----END PGP SIGNATURE-----

--hCRFYJKfs6IGypzU--
