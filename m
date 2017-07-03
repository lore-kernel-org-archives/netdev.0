From: Yuval Shaia <yuval.shaia@oracle.com>
Subject: Re: [PATCH iproute2 V2 1/4] rdma: Add basic infrastructure for RDMA
 tool
Date: Mon, 3 Jul 2017 17:33:56 +0300
Message-ID: <20170703143355.GA5086@yuvallap>
References: <20170703140658.4091-1-leon@kernel.org>
 <20170703140658.4091-2-leon@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Leon Romanovsky <leonro@mellanox.com>,
        Doug Ledford <dledford@redhat.com>,
        Ariel Almog <ariela@mellanox.com>,
        Linux RDMA <linux-rdma@vger.kernel.org>,
        Linux Netdev <netdev@vger.kernel.org>
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:38652 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756489AbdGCOeQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2017 10:34:16 -0400
Content-Disposition: inline
In-Reply-To: <20170703140658.4091-2-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 03, 2017 at 05:06:55PM +0300, Leon Romanovsky wrote:
> From: Leon Romanovsky <leonro@mellanox.com>
> 
> RDMA devices are cross-functional devices from one side,
> but very tailored for the specific markets from another.
> 
> Such diversity caused to spread of RDMA related configuration
> across various tools, e.g. devlink, ip, ethtool, ib specific and
> vendor specific solutions.
> 
> This patch adds ability to fill device and port information
> by reading RDMA netlink.
> 
> Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
> ---
>  Makefile        |   2 +-
>  rdma/.gitignore |   1 +
>  rdma/Makefile   |  22 ++++++
>  rdma/rdma.c     | 116 ++++++++++++++++++++++++++++
>  rdma/rdma.h     |  71 +++++++++++++++++
>  rdma/utils.c    | 232 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  6 files changed, 443 insertions(+), 1 deletion(-)
>  create mode 100644 rdma/.gitignore
>  create mode 100644 rdma/Makefile
>  create mode 100644 rdma/rdma.c
>  create mode 100644 rdma/rdma.h
>  create mode 100644 rdma/utils.c
> 
> diff --git a/Makefile b/Makefile
> index 18de7dcb..c255063b 100644
> --- a/Makefile
> +++ b/Makefile
> @@ -52,7 +52,7 @@ WFLAGS += -Wmissing-declarations -Wold-style-definition -Wformat=2
>  CFLAGS := $(WFLAGS) $(CCOPTS) -I../include $(DEFINES) $(CFLAGS)
>  YACCFLAGS = -d -t -v
>  
> -SUBDIRS=lib ip tc bridge misc netem genl tipc devlink man
> +SUBDIRS=lib ip tc bridge misc netem genl tipc devlink rdma man
>  
>  LIBNETLINK=../lib/libnetlink.a ../lib/libutil.a
>  LDLIBS += $(LIBNETLINK)
> diff --git a/rdma/.gitignore b/rdma/.gitignore
> new file mode 100644
> index 00000000..51fb172b
> --- /dev/null
> +++ b/rdma/.gitignore
> @@ -0,0 +1 @@
> +rdma
> diff --git a/rdma/Makefile b/rdma/Makefile
> new file mode 100644
> index 00000000..64da2142
> --- /dev/null
> +++ b/rdma/Makefile
> @@ -0,0 +1,22 @@
> +include ../Config
> +
> +ifeq ($(HAVE_MNL),y)
> +
> +RDMA_OBJ = rdma.o utils.o
> +
> +TARGETS=rdma
> +CFLAGS += $(shell $(PKG_CONFIG) libmnl --cflags)
> +LDLIBS += $(shell $(PKG_CONFIG) libmnl --libs)
> +
> +endif
> +
> +all:	$(TARGETS) $(LIBS)
> +
> +rdma:	$(RDMA_OBJ) $(LIBS)
> +	$(QUIET_LINK)$(CC) $^ $(LDFLAGS) $(LDLIBS) -o $@
> +
> +install: all
> +	install -m 0755 $(TARGETS) $(DESTDIR)$(SBINDIR)
> +
> +clean:
> +	rm -f $(RDMA_OBJ) $(TARGETS)
> diff --git a/rdma/rdma.c b/rdma/rdma.c
> new file mode 100644
> index 00000000..29273839
> --- /dev/null
> +++ b/rdma/rdma.c
> @@ -0,0 +1,116 @@
> +/*
> + * rdma.c	RDMA tool
> + *
> + *              This program is free software; you can redistribute it and/or
> + *              modify it under the terms of the GNU General Public License
> + *              as published by the Free Software Foundation; either version
> + *              2 of the License, or (at your option) any later version.
> + *
> + * Authors:     Leon Romanovsky <leonro@mellanox.com>
> + */
> +
> +#include <limits.h>
> +#include <rdma/rdma_netlink.h>
> +
> +#include "rdma.h"
> +#include "SNAPSHOT.h"
> +
> +static void help(char *name)
> +{
> +	pr_out("Usage: %s [ OPTIONS ] OBJECT { COMMAND | help }\n"
> +	       "where  OBJECT := { help }\n"
> +	       "       OPTIONS := { -V[ersion] | -d[etails]}\n", name);
> +}
> +
> +static int cmd_help(struct rdma *rd)
> +{
> +	help(rd->filename);
> +	return 0;

Can we change it to void?

> +}
> +
> +static int rd_cmd(struct rdma *rd)
> +{
> +	const struct rdma_cmd cmds[] = {
> +		{ NULL,		cmd_help },
> +		{ "help",	cmd_help },
> +		{ 0 }
> +	};
> +
> +	return rdma_exec_cmd(rd, cmds, "object");
> +}
> +
> +static int rd_init(struct rdma *rd, int argc, char **argv, char *filename)
> +{
> +	uint32_t seq;
> +	int ret;
> +
> +	rd->filename = filename;
> +	rd->argc = argc;
> +	rd->argv = argv;
> +	INIT_LIST_HEAD(&rd->dev_map_list);
> +	rd->buff = malloc(MNL_SOCKET_BUFFER_SIZE);
> +	if (!rd->buff)
> +		return -ENOMEM;
> +
> +	rdma_prepare_msg(rd, RDMA_NLDEV_CMD_GET, &seq, (NLM_F_REQUEST | NLM_F_ACK | NLM_F_DUMP));
> +	if ((ret = rdma_send_msg(rd)))
> +		return ret;

Maybe it is only my perspective but as i see it - if some init function
fails at one of the steps it needs to rollback to starting point before
returning an error. A caller expect that if init fails then no reason to
call the free.

Caller here calls free when init fails so we are fine but just razing a
point here.

> +
> +	return rdma_recv_msg(rd, rd_dev_init_cb, rd, seq);
> +}
> +
> +static void rd_free(struct rdma *rd)
> +{
> +	free(rd->buff);
> +	rdma_free_devmap(rd);
> +}
> +int main(int argc, char **argv)
> +{
> +	static const struct option long_options[] = {
> +		{ "version",		no_argument,		NULL, 'V' },
> +		{ "help",		no_argument,		NULL, 'h' },
> +		{ "details",		no_argument,		NULL, 'd' },
> +		{ NULL, 0, NULL, 0 }
> +	};
> +	bool show_details = false;
> +	char *filename;
> +	struct rdma rd;
> +	int opt;
> +	int err;
> +
> +	filename = basename(argv[0]);
> +
> +	while ((opt = getopt_long(argc, argv, "Vhd",
> +				  long_options, NULL)) >= 0) {
> +
> +		switch (opt) {
> +		case 'V':
> +			printf("%s utility, iproute2-ss%s\n", filename, SNAPSHOT);
> +			return EXIT_SUCCESS;
> +		case 'd':
> +			show_details = true;
> +			break;
> +		case 'h':
> +			help(filename);
> +			return EXIT_SUCCESS;
> +		default:
> +			pr_err("Unknown option.\n");
> +			help(filename);
> +			return EXIT_FAILURE;
> +		}
> +	}
> +
> +	argc -= optind;
> +	argv += optind;
> +
> +	err = rd_init(&rd, argc, argv, filename);
> +	if (err)
> +		goto out;
> +
> +	rd.show_details = show_details;
> +	err = rd_cmd(&rd);
> +out:
> +	/* Always cleanup */
> +	rd_free(&rd);
> +	return (err) ? EXIT_FAILURE:EXIT_SUCCESS;
> +}
> diff --git a/rdma/rdma.h b/rdma/rdma.h
> new file mode 100644
> index 00000000..3c070836
> --- /dev/null
> +++ b/rdma/rdma.h
> @@ -0,0 +1,71 @@
> +/*
> + * rdma.c	RDMA tool
> + *
> + *              This program is free software; you can redistribute it and/or
> + *              modify it under the terms of the GNU General Public License
> + *              as published by the Free Software Foundation; either version
> + *              2 of the License, or (at your option) any later version.
> + *
> + * Authors:     Leon Romanovsky <leonro@mellanox.com>
> + */
> +#ifndef _RDMA_TOOL_H_
> +#define _RDMA_TOOL_H_
> +
> +#include <stdlib.h>
> +#include <string.h>
> +#include <errno.h>
> +#include <getopt.h>
> +#include <libmnl/libmnl.h>
> +
> +#include <rdma/rdma_netlink.h>
> +#include "list.h"
> +
> +#define pr_err(args...) fprintf(stderr, ##args)
> +#define pr_out(args...) fprintf(stdout, ##args)
> +
> +struct dev_map {
> +	struct list_head list;
> +	char *dev_name;
> +	uint32_t num_ports;
> +	uint32_t idx;
> +};
> +
> +struct rdma {
> +	int argc;
> +	char **argv;
> +	char *filename;
> +	bool show_details;
> +	struct list_head dev_map_list;
> +	struct mnl_socket *nl;
> +	struct nlmsghdr *nlh;
> +	char *buff;
> +};
> +
> +struct rdma_cmd {
> +	const char *cmd;
> +	int (*func)(struct rdma *rd);
> +};
> +
> +/*
> + * Parser interface
> + */
> +bool rd_no_arg(struct rdma *rd);
> +bool rd_argv_match(struct rdma *rd, const char *pattern);
> +void rd_arg_inc(struct rdma *rd);
> +
> +int rdma_exec_cmd(struct rdma *rd, const struct rdma_cmd *c, const char *str);
> +
> +/*
> + * Device manipulation
> + */
> +void rdma_free_devmap(struct rdma *rd);
> +
> +/*
> + * Netlink
> + */
> +int rdma_send_msg(struct rdma *rd);
> +int rdma_recv_msg(struct rdma *rd, mnl_cb_t callback, void *data, uint32_t seq);
> +int rdma_prepare_msg(struct rdma *rd, uint32_t cmd, uint32_t *seq, uint16_t flags);
> +int rd_dev_init_cb(const struct nlmsghdr *nlh, void *data);
> +int rd_attr_cb(const struct nlattr *attr, void *data);
> +#endif /* _RDMA_TOOL_H_ */
> diff --git a/rdma/utils.c b/rdma/utils.c
> new file mode 100644
> index 00000000..cabec6e7
> --- /dev/null
> +++ b/rdma/utils.c
> @@ -0,0 +1,232 @@
> +/*
> + * utils.c	RDMA tool
> + *
> + *              This program is free software; you can redistribute it and/or
> + *              modify it under the terms of the GNU General Public License
> + *              as published by the Free Software Foundation; either version
> + *              2 of the License, or (at your option) any later version.
> + *
> + * Authors:     Leon Romanovsky <leonro@mellanox.com>
> + */
> +
> +#include <sys/types.h>
> +#include <dirent.h>
> +#include <time.h>
> +
> +#include "rdma.h"
> +#include <rdma/rdma_netlink.h>
> +
> +/*
> + * This macro will be moved to generic layer,
> + * after code will be accepted.
> + * it is placed here to avoid rebases with upstream code.
> + */
> +#define MAX(a, b)	((a) > (b) ? (a) : (b))

Can we use /usr/include/sys/param.h?

> +
> +static int rd_argc(struct rdma *rd)
> +{
> +	return rd->argc;
> +}
> +
> +static char *rd_argv(struct rdma *rd)
> +{
> +	if (!rd_argc(rd))
> +		return NULL;
> +	return *rd->argv;
> +}
> +
> +static int strcmpx(const char *str1, const char *str2)
> +{
> +	if (strlen(str1) > strlen(str2))
> +			return -1;
> +	return strncmp(str1, str2, strlen(str1));
> +}
> +
> +bool rd_argv_match(struct rdma *rd, const char *pattern)
> +{
> +	if (!rd_argc(rd))
> +		return false;
> +	return strcmpx(rd_argv(rd), pattern) == 0;

rd_argv might return NULL.

> +}
> +
> +void rd_arg_inc(struct rdma *rd)
> +{
> +	if (!rd_argc(rd))
> +		return;
> +	rd->argc--;
> +	rd->argv++;
> +}
> +
> +bool rd_no_arg(struct rdma *rd)
> +{
> +	return rd_argc(rd) == 0;
> +}
> +
> +static struct dev_map *dev_map_alloc(const char *dev_name)
> +{
> +	struct dev_map *dev_map;
> +
> +	dev_map = calloc(1, sizeof(*dev_map));
> +	if (!dev_map)
> +		return NULL;
> +	dev_map->dev_name = strdup(dev_name);
> +
> +	return dev_map;
> +}
> +
> +static void dev_map_free(struct dev_map *dev_map)
> +{
> +	if(!dev_map)
> +		return;
> +
> +	free(dev_map->dev_name);
> +	free(dev_map);
> +}
> +
> +static void dev_map_cleanup(struct rdma *rd)
> +{
> +	struct dev_map *dev_map, *tmp;
> +
> +	list_for_each_entry_safe(dev_map, tmp,
> +				 &rd->dev_map_list, list) {
> +		list_del(&dev_map->list);
> +		dev_map_free(dev_map);
> +	}
> +}
> +
> +static const enum mnl_attr_data_type nldev_policy[RDMA_NLDEV_ATTR_MAX] = {
> +	[RDMA_NLDEV_ATTR_DEV_NAME] = MNL_TYPE_NUL_STRING,
> +	[RDMA_NLDEV_ATTR_PORT_INDEX] = MNL_TYPE_U32,
> +};
> +
> +int rd_attr_cb(const struct nlattr *attr, void *data)
> +{
> +	const struct nlattr **tb = data;
> +	int type;
> +
> +	if (mnl_attr_type_valid(attr, RDMA_NLDEV_ATTR_MAX) < 0)
> +		return MNL_CB_ERROR;
> +
> +	type = mnl_attr_get_type(attr);
> +
> +	if (mnl_attr_validate(attr, nldev_policy[type]) < 0)
> +		return MNL_CB_ERROR;
> +
> +	tb[type] = attr;
> +	return MNL_CB_OK;
> +}
> +
> +int rd_dev_init_cb(const struct nlmsghdr *nlh, void *data)
> +{
> +	struct nlattr *tb[RDMA_NLDEV_ATTR_MAX] = {};
> +	struct dev_map *dev_map;
> +	struct rdma *rd = data;
> +	const char *dev_name;
> +
> +	mnl_attr_parse(nlh, 0, rd_attr_cb, tb);
> +	if (!tb[RDMA_NLDEV_ATTR_DEV_NAME] || !tb[RDMA_NLDEV_ATTR_DEV_INDEX])
> +		return MNL_CB_ERROR;
> +	if (!tb[RDMA_NLDEV_ATTR_PORT_INDEX]) {
> +		pr_err("This tool doesn't support switches yet\n");
> +		return MNL_CB_ERROR;
> +	}
> +
> +	dev_name = mnl_attr_get_str(tb[RDMA_NLDEV_ATTR_DEV_NAME]);
> +
> +	dev_map = dev_map_alloc(dev_name);
> +	if (!dev_map)
> +		/* The main function will cleanup the allocations */
> +		return MNL_CB_ERROR;
> +	list_add_tail(&dev_map->list, &rd->dev_map_list);
> +
> +	dev_map->num_ports = mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_PORT_INDEX]);
> +	dev_map->idx = mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_DEV_INDEX]);
> +
> +	return MNL_CB_OK;
> +}
> +
> +void rdma_free_devmap(struct rdma *rd)
> +{
> +	if(!rd)
> +		return;
> +	dev_map_cleanup(rd);
> +	return;

Redundant

> +}
> +
> +int rdma_exec_cmd(struct rdma *rd, const struct rdma_cmd *cmds, const char *str)
> +{
> +	const struct rdma_cmd *c;
> +
> +	/* First argument in objs table is default variant */
> +	if (rd_no_arg(rd))
> +		return cmds->func(rd);
> +
> +	for (c = cmds + 1; c->cmd; ++c) {
> +		if (rd_argv_match(rd, c->cmd)) {
> +			/* Move to next argument */
> +			rd_arg_inc(rd);
> +			return c->func(rd);
> +		}
> +	}
> +
> +	pr_err("Unknown %s '%s'.\n", str, rd_argv(rd));
> +	return 0;
> +}
> +
> +int rdma_prepare_msg(struct rdma *rd, uint32_t cmd, uint32_t *seq, uint16_t flags)
> +{
> +	*seq = time(NULL);
> +
> +	rd->nlh = mnl_nlmsg_put_header(rd->buff);
> +	rd->nlh->nlmsg_type = RDMA_NL_GET_TYPE(RDMA_NL_NLDEV, cmd);
> +	rd->nlh->nlmsg_seq = *seq;
> +	rd->nlh->nlmsg_flags = flags;
> +
> +	return 0;

Can we change it to void?

> +}
> +
> +int rdma_send_msg(struct rdma *rd)
> +{
> +	int ret;
> +
> +	rd->nl = mnl_socket_open(NETLINK_RDMA);
> +	if (!rd->nl) {
> +		pr_err("Failed to open NETLINK_RDMA socket\n");
> +		return -ENODEV;
> +	}
> +
> +	ret = mnl_socket_bind(rd->nl, 0, MNL_SOCKET_AUTOPID);
> +	if (ret < 0) {
> +		pr_err("Failed to bind socket with err %d\n", ret);
> +		goto err;
> +	}
> +
> +	ret = mnl_socket_sendto(rd->nl, rd->nlh, rd->nlh->nlmsg_len);
> +	if (ret < 0) {
> +		pr_err("Failed to send to socket with err %d\n", ret);
> +		goto err;
> +	}
> +	return 0;
> +
> +err:	mnl_socket_close(rd->nl);

Suggesting to break the above line.

> +	return ret;
> +}
> +
> +int rdma_recv_msg(struct rdma *rd, mnl_cb_t callback, void *data, unsigned int seq)
> +{
> +	int ret;
> +	unsigned int portid;
> +	char buf[MNL_SOCKET_BUFFER_SIZE];
> +
> +	portid = mnl_socket_get_portid(rd->nl);
> +	do {
> +		ret = mnl_socket_recvfrom(rd->nl, buf, sizeof(buf));
> +		if (ret <= 0)
> +			break;
> +
> +		ret = mnl_cb_run(buf, ret, seq, portid, callback, data);
> +	} while (ret > 0);
> +
> +	mnl_socket_close(rd->nl);
> +	return ret;
> +}
> -- 
> 2.13.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
