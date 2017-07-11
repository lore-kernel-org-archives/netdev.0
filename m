From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH iproute2 V3 2/4] rdma: Add dev object
Date: Tue, 11 Jul 2017 10:22:00 +0300
Message-ID: <20170711072200.GT1528@mtr-leonro.local>
References: <20170704075541.12544-1-leon@kernel.org>
 <20170704075541.12544-3-leon@kernel.org>
 <20170710080102.GC1853@nanopsycho>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="tJpRIM2aoWGz8Rwb"
Cc: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux RDMA <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170710080102.GC1853@nanopsycho>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--tJpRIM2aoWGz8Rwb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jul 10, 2017 at 10:01:02AM +0200, Jiri Pirko wrote:
> Tue, Jul 04, 2017 at 09:55:39AM CEST, leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org wrote:
> >From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> >
> >Device (dev) object represents struct ib_device to the user space.
> >
> >Device properties:
> > * Device capabilities
> > * FW version to the device output
> > * node_guid and sys_image_guid
> > * node_type
> >
> >Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> >---
> > rdma/Makefile |   2 +-
> > rdma/dev.c    | 235 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
> > rdma/rdma.c   |   3 +-
> > rdma/rdma.h   |  12 ++-
> > rdma/utils.c  |  46 +++++++++++-
> > 5 files changed, 293 insertions(+), 5 deletions(-)
> > create mode 100644 rdma/dev.c
> >
> >diff --git a/rdma/Makefile b/rdma/Makefile
> >index 64da2142..123d7ac5 100644
> >--- a/rdma/Makefile
> >+++ b/rdma/Makefile
> >@@ -2,7 +2,7 @@ include ../Config
> >
> > ifeq ($(HAVE_MNL),y)
> >
> >-RDMA_OBJ = rdma.o utils.o
> >+RDMA_OBJ = rdma.o utils.o dev.o
> >
> > TARGETS=rdma
> > CFLAGS += $(shell $(PKG_CONFIG) libmnl --cflags)
> >diff --git a/rdma/dev.c b/rdma/dev.c
> >new file mode 100644
> >index 00000000..b80e5288
> >--- /dev/null
> >+++ b/rdma/dev.c
> >@@ -0,0 +1,235 @@
> >+/*
> >+ * dev.c	RDMA tool
> >+ *
> >+ *              This program is free software; you can redistribute it and/or
> >+ *              modify it under the terms of the GNU General Public License
> >+ *              as published by the Free Software Foundation; either version
> >+ *              2 of the License, or (at your option) any later version.
> >+ *
> >+ * Authors:     Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> >+ */
> >+
> >+#include "rdma.h"
> >+
> >+static int dev_help(struct rdma *rd)
> >+{
> >+	pr_out("Usage: %s dev show [DEV]\n", rd->filename);
> >+	return 0;
> >+}
> >+
> >+static void dev_print_caps(struct nlattr **tb)
> >+{
> >+	uint64_t caps;
> >+	uint32_t idx;
> >+
> >+	/*
> >+	 * FIXME: move to indexes when kernel will start exporting them.
> >+	 */
> >+	static const char *dev_caps[64] = {
>
> 	static const char *dev_caps[] = {

The same as for the "link" object.

>
>
> >+		"RESIZE_MAX_WR",
> >+		"BAD_PKEY_CNTR",
> >+		"BAD_QKEY_CNTR",
> >+		"RAW_MULTI",
> >+		"AUTO_PATH_MIG",
> >+		"CHANGE_PHY_PORT",
> >+		"UD_AV_PORT_ENFORCE",
> >+		"CURR_QP_STATE_MOD",
> >+		"SHUTDOWN_PORT",
> >+		"INIT_TYPE",
> >+		"PORT_ACTIVE_EVENT",
> >+		"SYS_IMAGE_GUID",
> >+		"RC_RNR_NAK_GEN",
> >+		"SRQ_RESIZE",
> >+		"N_NOTIFY_CQ",
> >+		"LOCAL_DMA_LKEY",
> >+		"RESERVED",
> >+		"MEM_WINDOW",
> >+		"UD_IP_CSUM",
> >+		"UD_TSO",
> >+		"XRC",
> >+		"MEM_MGT_EXTENSIONS",
> >+		"BLOCK_MULTICAST_LOOPBACK",
> >+		"MEM_WINDOW_TYPE_2A",
> >+		"MEM_WINDOW_TYPE_2B",
> >+		"RC_IP_CSUM",
> >+		"RAW_IP_CSUM",
> >+		"CROSS_CHANNEL",
> >+		"MANAGED_FLOW_STEERING",
> >+		"SIGNATURE_HANDOVER",
> >+		"ON_DEMAND_PAGING",
> >+		"SG_GAPS_REG",
> >+		"VIRTUAL_FUNCTION",
> >+		"RAW_SCATTER_FCS",
> >+		"RDMA_NETDEV_OPA_VNIC",
> >+	};
> >+

<...>

> >+	if (!tb[RDMA_NLDEV_ATTR_FW_VERSION])
> >+		return;
> >+
> >+	pr_out("fw %s ",
> >+	       mnl_attr_get_str(tb[RDMA_NLDEV_ATTR_FW_VERSION]));
> >+}
> >+
> >+static void _dev_print_be64(char *name, uint64_t val)
>
> Why the initial "_"? I think it could be avoided.
>
> Wait, I'm confused. Does kernel actually exposes BE64 in U64 attribute?
> That is wrong. Please fix it while there is still a time (if it is).

It was, I fixed it in the last version of my RDMA netlink patches as a
response to Jason's comment.

The "_be64" suffix in the name is a leftover from dark ages. I'll fix it.

>
>
> >+{
> >+	uint16_t vp[4];
> >+
> >+	memcpy(vp, &val, sizeof(uint64_t));
> >+	pr_out("%s %04x:%04x:%04x:%04x ", name, vp[3], vp[2], vp[1], vp[0]);
> >+}
> >+

<...>
>
>
> >+	}
> >+	else {
>
> "} else {"
>
> Checkpatch should warn you. Did you run it?
>

Partially.

Thanks

--tJpRIM2aoWGz8Rwb
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAllkfJgACgkQ5GN7iDZy
WKdxmg/8DIRkjw7S7MnN89EEAXHdhij5DFkKQKFIEWQyxC5/U7uRR60coOUOgsJG
6CT+yIXsH4YuzXhZqQyd9PTWDCR3h16USz+89gMY7VCETmoxDNbtaOP+JrUX245X
ox1O/Nk4xWC50Bfc6G7sb3urDJrB4uXaO9j1YefybtM4W9CGIjQ0yRqAu2djPFBm
mLsbUOZ8aroT/aKt6ODtl++ht3wJNPuje8j3hCgTQMw15oTeSqOwze2iiJHnCsJo
GMVFj82CwK2f6grN0NZLSwrWxCnExWLjrll6FboOSmbmSluUOBrGhaumTTQCpyV5
3LUyG/OlTaG0g88pVyB3JYZOkdcFb+eeSAkpDU0kcboPV+cDKi6K2D5nywPr2MZK
kHsKCGpUsacijepSBW9TMcSeBbw8oIeun0KLPN0UaAPjGcVa0vWLMh6gPvwb36Ev
/Tgoc06awAgCyj5BqZoVllGM8zR/jDOEp9KSoQ4IQHlA3GEwWAr3vrvTPjRpK9BN
wW3sUNdVzcGPLL263hT1fdku5X287FldYJwpjVWe4XJRf4G7diBQ2Y7m42QeJugb
QpZSgcKElCSxnoi4wiX+JvNnZA3N04Ripk5/ZVcYV+XB+N4/qxiRU1GyJubBAS/j
QVjcf1q14GmRWgEcdoN2ofgPBlRAjowjnPbMqgu33a+/4vnvmx0=
=EaK8
-----END PGP SIGNATURE-----

--tJpRIM2aoWGz8Rwb--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
