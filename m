From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH iproute2 V2 1/4] rdma: Add basic infrastructure for RDMA
 tool
Date: Tue, 4 Jul 2017 10:31:26 +0300
Message-ID: <20170704073126.GB1528@mtr-leonro.local>
References: <20170703140658.4091-1-leon@kernel.org>
 <20170703140658.4091-2-leon@kernel.org>
 <20170703143355.GA5086@yuvallap>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="i0/AhcQY5QxfSsSZ"
Cc: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux RDMA <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170703143355.GA5086@yuvallap>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--i0/AhcQY5QxfSsSZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jul 03, 2017 at 05:33:56PM +0300, Yuval Shaia wrote:
> On Mon, Jul 03, 2017 at 05:06:55PM +0300, Leon Romanovsky wrote:
> > From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> >
> > RDMA devices are cross-functional devices from one side,
> > but very tailored for the specific markets from another.
> >
> > Such diversity caused to spread of RDMA related configuration
> > across various tools, e.g. devlink, ip, ethtool, ib specific and
> > vendor specific solutions.
> >
> > This patch adds ability to fill device and port information
> > by reading RDMA netlink.
> >
> > Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> > ---
> >  Makefile        |   2 +-
> >  rdma/.gitignore |   1 +
> >  rdma/Makefile   |  22 ++++++
> >  rdma/rdma.c     | 116 ++++++++++++++++++++++++++++
> >  rdma/rdma.h     |  71 +++++++++++++++++
> >  rdma/utils.c    | 232 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
> >  6 files changed, 443 insertions(+), 1 deletion(-)
> >  create mode 100644 rdma/.gitignore
> >  create mode 100644 rdma/Makefile
> >  create mode 100644 rdma/rdma.c
> >  create mode 100644 rdma/rdma.h
> >  create mode 100644 rdma/utils.c
> >
> > diff --git a/Makefile b/Makefile
> > index 18de7dcb..c255063b 100644
> > --- a/Makefile
> > +++ b/Makefile
> > @@ -52,7 +52,7 @@ WFLAGS += -Wmissing-declarations -Wold-style-definition -Wformat=2
> >  CFLAGS := $(WFLAGS) $(CCOPTS) -I../include $(DEFINES) $(CFLAGS)
> >  YACCFLAGS = -d -t -v
> >
> > -SUBDIRS=lib ip tc bridge misc netem genl tipc devlink man
> > +SUBDIRS=lib ip tc bridge misc netem genl tipc devlink rdma man
> >
> >  LIBNETLINK=../lib/libnetlink.a ../lib/libutil.a
> >  LDLIBS += $(LIBNETLINK)
> > diff --git a/rdma/.gitignore b/rdma/.gitignore
> > new file mode 100644
> > index 00000000..51fb172b
> > --- /dev/null
> > +++ b/rdma/.gitignore
> > @@ -0,0 +1 @@
> > +rdma
> > diff --git a/rdma/Makefile b/rdma/Makefile
> > new file mode 100644
> > index 00000000..64da2142
> > --- /dev/null
> > +++ b/rdma/Makefile
> > @@ -0,0 +1,22 @@
> > +include ../Config
> > +
> > +ifeq ($(HAVE_MNL),y)
> > +
> > +RDMA_OBJ = rdma.o utils.o
> > +
> > +TARGETS=rdma
> > +CFLAGS += $(shell $(PKG_CONFIG) libmnl --cflags)
> > +LDLIBS += $(shell $(PKG_CONFIG) libmnl --libs)
> > +
> > +endif
> > +
> > +all:	$(TARGETS) $(LIBS)
> > +
> > +rdma:	$(RDMA_OBJ) $(LIBS)
> > +	$(QUIET_LINK)$(CC) $^ $(LDFLAGS) $(LDLIBS) -o $@
> > +
> > +install: all
> > +	install -m 0755 $(TARGETS) $(DESTDIR)$(SBINDIR)
> > +
> > +clean:
> > +	rm -f $(RDMA_OBJ) $(TARGETS)
> > diff --git a/rdma/rdma.c b/rdma/rdma.c
> > new file mode 100644
> > index 00000000..29273839
> > --- /dev/null
> > +++ b/rdma/rdma.c
> > @@ -0,0 +1,116 @@
> > +/*
> > + * rdma.c	RDMA tool
> > + *
> > + *              This program is free software; you can redistribute it and/or
> > + *              modify it under the terms of the GNU General Public License
> > + *              as published by the Free Software Foundation; either version
> > + *              2 of the License, or (at your option) any later version.
> > + *
> > + * Authors:     Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> > + */
> > +
> > +#include <limits.h>
> > +#include <rdma/rdma_netlink.h>
> > +
> > +#include "rdma.h"
> > +#include "SNAPSHOT.h"
> > +
> > +static void help(char *name)
> > +{
> > +	pr_out("Usage: %s [ OPTIONS ] OBJECT { COMMAND | help }\n"
> > +	       "where  OBJECT := { help }\n"
> > +	       "       OPTIONS := { -V[ersion] | -d[etails]}\n", name);
> > +}
> > +
> > +static int cmd_help(struct rdma *rd)
> > +{
> > +	help(rd->filename);
> > +	return 0;
>
> Can we change it to void?

I did it on purpose to reuse the common command executor code
(rdma_exec_cmd) and don't introduce explicit if-else constructions
just for the "help" command.

<...>

> > +/*
> > + * This macro will be moved to generic layer,
> > + * after code will be accepted.
> > + * it is placed here to avoid rebases with upstream code.
> > + */
> > +#define MAX(a, b)	((a) > (b) ? (a) : (b))
>
> Can we use /usr/include/sys/param.h?

Thanks for pointing it to me. This is leftover from previous versions when I
filled all structures during init phase. It is not used anymore and I'll
remove it.

>
> > +
> > +static int rd_argc(struct rdma *rd)
> > +{
> > +	return rd->argc;
> > +}
> > +
> > +static char *rd_argv(struct rdma *rd)
> > +{
> > +	if (!rd_argc(rd))
> > +		return NULL;
> > +	return *rd->argv;
> > +}
> > +
> > +static int strcmpx(const char *str1, const char *str2)
> > +{
> > +	if (strlen(str1) > strlen(str2))
> > +			return -1;
> > +	return strncmp(str1, str2, strlen(str1));
> > +}
> > +
> > +bool rd_argv_match(struct rdma *rd, const char *pattern)
> > +{
> > +	if (!rd_argc(rd))
> > +		return false;
> > +	return strcmpx(rd_argv(rd), pattern) == 0;
>
> rd_argv might return NULL.

This function is called only once in this file (in new version, I'll
mark it as "static") and it is called only after we checked that "rd"
has arguments (see function rdma_exec_cmd).
>
> > +}
> > +
> > +void rd_arg_inc(struct rdma *rd)
> > +{
> > +	if (!rd_argc(rd))
> > +		return;
> > +	rd->argc--;
> > +	rd->argv++;
> > +}
> > +
> > +bool rd_no_arg(struct rdma *rd)
> > +{
> > +	return rd_argc(rd) == 0;
> > +}
> > +
> > +static struct dev_map *dev_map_alloc(const char *dev_name)
> > +{
> > +	struct dev_map *dev_map;
> > +
> > +	dev_map = calloc(1, sizeof(*dev_map));
> > +	if (!dev_map)
> > +		return NULL;
> > +	dev_map->dev_name = strdup(dev_name);
> > +
> > +	return dev_map;
> > +}
> > +
> > +static void dev_map_free(struct dev_map *dev_map)
> > +{
> > +	if(!dev_map)
> > +		return;
> > +
> > +	free(dev_map->dev_name);
> > +	free(dev_map);
> > +}
> > +
> > +static void dev_map_cleanup(struct rdma *rd)
> > +{
> > +	struct dev_map *dev_map, *tmp;
> > +
> > +	list_for_each_entry_safe(dev_map, tmp,
> > +				 &rd->dev_map_list, list) {
> > +		list_del(&dev_map->list);
> > +		dev_map_free(dev_map);
> > +	}
> > +}
> > +
> > +static const enum mnl_attr_data_type nldev_policy[RDMA_NLDEV_ATTR_MAX] = {
> > +	[RDMA_NLDEV_ATTR_DEV_NAME] = MNL_TYPE_NUL_STRING,
> > +	[RDMA_NLDEV_ATTR_PORT_INDEX] = MNL_TYPE_U32,
> > +};
> > +
> > +int rd_attr_cb(const struct nlattr *attr, void *data)
> > +{
> > +	const struct nlattr **tb = data;
> > +	int type;
> > +
> > +	if (mnl_attr_type_valid(attr, RDMA_NLDEV_ATTR_MAX) < 0)
> > +		return MNL_CB_ERROR;
> > +
> > +	type = mnl_attr_get_type(attr);
> > +
> > +	if (mnl_attr_validate(attr, nldev_policy[type]) < 0)
> > +		return MNL_CB_ERROR;
> > +
> > +	tb[type] = attr;
> > +	return MNL_CB_OK;
> > +}
> > +
> > +int rd_dev_init_cb(const struct nlmsghdr *nlh, void *data)
> > +{
> > +	struct nlattr *tb[RDMA_NLDEV_ATTR_MAX] = {};
> > +	struct dev_map *dev_map;
> > +	struct rdma *rd = data;
> > +	const char *dev_name;
> > +
> > +	mnl_attr_parse(nlh, 0, rd_attr_cb, tb);
> > +	if (!tb[RDMA_NLDEV_ATTR_DEV_NAME] || !tb[RDMA_NLDEV_ATTR_DEV_INDEX])
> > +		return MNL_CB_ERROR;
> > +	if (!tb[RDMA_NLDEV_ATTR_PORT_INDEX]) {
> > +		pr_err("This tool doesn't support switches yet\n");
> > +		return MNL_CB_ERROR;
> > +	}
> > +
> > +	dev_name = mnl_attr_get_str(tb[RDMA_NLDEV_ATTR_DEV_NAME]);
> > +
> > +	dev_map = dev_map_alloc(dev_name);
> > +	if (!dev_map)
> > +		/* The main function will cleanup the allocations */
> > +		return MNL_CB_ERROR;
> > +	list_add_tail(&dev_map->list, &rd->dev_map_list);
> > +
> > +	dev_map->num_ports = mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_PORT_INDEX]);
> > +	dev_map->idx = mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_DEV_INDEX]);
> > +
> > +	return MNL_CB_OK;
> > +}
> > +
> > +void rdma_free_devmap(struct rdma *rd)
> > +{
> > +	if(!rd)
> > +		return;
> > +	dev_map_cleanup(rd);
> > +	return;
>
> Redundant

Fixed

>
> > +}
> > +
> > +int rdma_exec_cmd(struct rdma *rd, const struct rdma_cmd *cmds, const char *str)
> > +{
> > +	const struct rdma_cmd *c;
> > +
> > +	/* First argument in objs table is default variant */
> > +	if (rd_no_arg(rd))
> > +		return cmds->func(rd);
> > +
> > +	for (c = cmds + 1; c->cmd; ++c) {
> > +		if (rd_argv_match(rd, c->cmd)) {
> > +			/* Move to next argument */
> > +			rd_arg_inc(rd);
> > +			return c->func(rd);
> > +		}
> > +	}
> > +
> > +	pr_err("Unknown %s '%s'.\n", str, rd_argv(rd));
> > +	return 0;
> > +}
> > +
> > +int rdma_prepare_msg(struct rdma *rd, uint32_t cmd, uint32_t *seq, uint16_t flags)
> > +{
> > +	*seq = time(NULL);
> > +
> > +	rd->nlh = mnl_nlmsg_put_header(rd->buff);
> > +	rd->nlh->nlmsg_type = RDMA_NL_GET_TYPE(RDMA_NL_NLDEV, cmd);
> > +	rd->nlh->nlmsg_seq = *seq;
> > +	rd->nlh->nlmsg_flags = flags;
> > +
> > +	return 0;
>
> Can we change it to void?

Done

>
> > +}
> > +
> > +int rdma_send_msg(struct rdma *rd)
> > +{
> > +	int ret;
> > +
> > +	rd->nl = mnl_socket_open(NETLINK_RDMA);
> > +	if (!rd->nl) {
> > +		pr_err("Failed to open NETLINK_RDMA socket\n");
> > +		return -ENODEV;
> > +	}
> > +
> > +	ret = mnl_socket_bind(rd->nl, 0, MNL_SOCKET_AUTOPID);
> > +	if (ret < 0) {
> > +		pr_err("Failed to bind socket with err %d\n", ret);
> > +		goto err;
> > +	}
> > +
> > +	ret = mnl_socket_sendto(rd->nl, rd->nlh, rd->nlh->nlmsg_len);
> > +	if (ret < 0) {
> > +		pr_err("Failed to send to socket with err %d\n", ret);
> > +		goto err;
> > +	}
> > +	return 0;
> > +
> > +err:	mnl_socket_close(rd->nl);
>
> Suggesting to break the above line.

Done

>
> > +	return ret;
> > +}
> > +
> > +int rdma_recv_msg(struct rdma *rd, mnl_cb_t callback, void *data, unsigned int seq)
> > +{
> > +	int ret;
> > +	unsigned int portid;
> > +	char buf[MNL_SOCKET_BUFFER_SIZE];
> > +
> > +	portid = mnl_socket_get_portid(rd->nl);
> > +	do {
> > +		ret = mnl_socket_recvfrom(rd->nl, buf, sizeof(buf));
> > +		if (ret <= 0)
> > +			break;
> > +
> > +		ret = mnl_cb_run(buf, ret, seq, portid, callback, data);
> > +	} while (ret > 0);
> > +
> > +	mnl_socket_close(rd->nl);
> > +	return ret;
> > +}
> > --
> > 2.13.2
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> > the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html

--i0/AhcQY5QxfSsSZ
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAllbRE0ACgkQ5GN7iDZy
WKdboRAAnpt8SLFR9P5EW4uVDMFI9MzSuBtYW0uYPAOZ46SwRqodCFxvAttMgR0S
CPskonNWkYOHkt5+8u1vg31NBATHVZkpB4pd2t3mhRZSioVp1TAIxkPapNBI0MIQ
oMyyEn7riNTRskD+t3b65K6YPem5vP8MRT59TN+lLfIKzEzzR7jr54Cl2nh0eMTy
bZzea0pfeo1H59FNm8zaGP5bp469v/L48ecMfrvDZWS4QgKmKAY3M5kimRBOOi+y
b0deZOfpkbdiqGxMOtYvJlq2LTobfhIWz5MElZy27Pc065crqdu9tnvxqhdwkHOf
FHj/L7owtRCqsXh3OR5IJ1AKFU34MtaL8yP17JpdqZD+R62UbgLdSOS4LadtA4je
DvCqBEG4w2sL9ycMso730PM4MuiLvVc+L2GDL7Inh8q2HRMbhXVhWhS369YmYXRY
vbjP9TcDYQpbiGZ69hy0TRJfINNtLkffYgLaQRu29K+/oA28SDmbwTBlBgNCEXec
eeQ5vdcThJygjSCuW1h0Kv0+mtBvFIE12JPoQhRJ24DRfZxipCb1dzq+0WCQ3IZ9
AcQfsJZnZfdxZoaKN3DeHQgh5nQSgV1Mhgvb06g39qDISs75ygEEmvQIvSc6Aif0
/ihEuwU9lGEn/81GJSFTq0lf3GBKTub+sUIZdVbnJ9nO/DNbNng=
=4/nY
-----END PGP SIGNATURE-----

--i0/AhcQY5QxfSsSZ--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
