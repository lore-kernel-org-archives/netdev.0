From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v3 2/3] nsh: logging module
Date: Tue, 01 Mar 2016 10:25:11 -0800
Message-ID: <1456856711.4436.28.camel@perches.com>
References: <1456830709-32052-1-git-send-email-brussell@brocade.com>
	 <1456830709-32052-3-git-send-email-brussell@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Brian Russell <brussell@brocade.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0147.hostedemail.com ([216.40.44.147]:54651 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752440AbcCASZP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 13:25:15 -0500
In-Reply-To: <1456830709-32052-3-git-send-email-brussell@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-03-01 at 11:11 +0000, Brian Russell wrote:
> Module can register for Type 1 or specified classes of Type 2 metadat=
a
> and will then log incoming matching packets.

This logging mechanism seems like a way to fill/DoS logs.

Maybe use pr_info_ratelimit?
Maybe use the trace_events mechanisms instead?

> Signed-off-by: Brian Russell <brussell@brocade.com>
> ---
> =A0net/ipv4/Kconfig=A0=A0=A0|=A0=A0=A08 ++++
> =A0net/ipv4/Makefile=A0=A0|=A0=A0=A01 +
> =A0net/ipv4/nsh_log.c | 135 +++++++++++++++++++++++++++++++++++++++++=
++++++++++++
> =A03 files changed, 144 insertions(+)
> =A0create mode 100644 net/ipv4/nsh_log.c
>=20
> diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
> index df14c59..87b6dde 100644
> --- a/net/ipv4/Kconfig
> +++ b/net/ipv4/Kconfig
> @@ -223,6 +223,14 @@ config NET_NSH
> =A0
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0To compile it as a module, choose M =
here.=A0=A0If unsure, say N.
> =A0
> +config NET_NSH_LOG
> +=A0=A0=A0=A0=A0=A0=A0=A0tristate 'NSH Metadata Logger'
> +	depends on NET_NSH
> +	help
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0Log packets with incoming NSH metadata=
=2E
> +
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0To compile it as a module, choose M he=
re.=A0=A0If unsure, say N.
> +
> =A0config IP_MROUTE
> =A0	bool "IP: multicast routing"
> =A0	depends on IP_MULTICAST
> diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
> index 14b7995..69377fb 100644
> --- a/net/ipv4/Makefile
> +++ b/net/ipv4/Makefile
> @@ -25,6 +25,7 @@ obj-$(CONFIG_NET_FOU) +=3D fou.o
> =A0obj-$(CONFIG_NET_IPGRE_DEMUX) +=3D gre.o
> =A0obj-$(CONFIG_NET_IPGRE) +=3D ip_gre.o
> =A0obj-$(CONFIG_NET_NSH) +=3D nsh.o
> +obj-$(CONFIG_NET_NSH_LOG) +=3D nsh_log.o
> =A0obj-$(CONFIG_NET_UDP_TUNNEL) +=3D udp_tunnel.o
> =A0obj-$(CONFIG_NET_IPVTI) +=3D ip_vti.o
> =A0obj-$(CONFIG_SYN_COOKIES) +=3D syncookies.o
> diff --git a/net/ipv4/nsh_log.c b/net/ipv4/nsh_log.c
> new file mode 100644
> index 0000000..3d774ed
> --- /dev/null
> +++ b/net/ipv4/nsh_log.c
> @@ -0,0 +1,135 @@
> +/*
> + * Network Service Header (NSH) logging module.
> + *
> + * Copyright (c) 2016 by Brocade Communications Systems, Inc.
> + *
> + * This program is free software; you can redistribute it and/or mod=
ify
> + * it under the terms of the GNU General Public License version 2 as
> + * published by the Free Software Foundation.
> + */
> +#include=20
> +#include=20
> +#include=20
> +
> +static bool t1_enabled =3D false;
> +module_param(t1_enabled, bool, 0444);
> +MODULE_PARM_DESC(t1_enabled, "Type 1 Metadata log enabled");
> +
> +#define MAX_T2_CLASSES 10
> +static unsigned int t2_classes[MAX_T2_CLASSES];
> +static int num_t2 =3D 0;
> +module_param_array(t2_classes, uint, &num_t2, 0444);
> +MODULE_PARM_DESC(t2_classes, "Type 2 Metadata classes log enabled");
> +
> +static const char *nsh_next_proto(u8 next_proto)
> +{
> +	switch (next_proto) {
> +	case NSH_NEXT_PROTO_IPv4:
> +		return "IPv4";
> +	case NSH_NEXT_PROTO_IPv6:
> +		return "IPv6";
> +	case NSH_NEXT_PROTO_ETH:
> +		return "Eth";
> +	default:
> +		return "Unknown";
> +	}
> +}
> +
> +/* Type 1 metadata has fixed length, 4 x 32-bit words */
> +static int nsh_log_t1(struct sk_buff *skb, u32 service_path_id,
> +		=A0=A0=A0=A0=A0=A0u8 service_index, u8 next_proto,
> +		=A0=A0=A0=A0=A0=A0struct nsh_metadata *ctx_hdr, unsigned int num_c=
tx_hdrs)
> +{
> +	u32 *data;
> +
> +	if ((ctx_hdr->class !=3D NSH_MD_CLASS_TYPE_1) ||
> +	=A0=A0=A0=A0(ctx_hdr->type !=3D NSH_MD_TYPE_TYPE_1) ||
> +	=A0=A0=A0=A0(ctx_hdr->len !=3D NSH_MD_LEN_TYPE_1) ||
> +	=A0=A0=A0=A0(num_ctx_hdrs !=3D 1))
> +		return -EINVAL;
> +
> +	data =3D ctx_hdr->data;
> +	pr_info("NSH T1 Rx(%s): SPI=3D%u SI=3D%u Next=3D%s"
> +		" MD 0x%08x 0x%08x 0x%08x 0x%08x\n", skb->dev->name,
> +		service_path_id, service_index, nsh_next_proto(next_proto),
> +		data[0], data[1], data[2], data[3]);
> +
> +	return 0;
> +}
> +
> +/* Type 2 metadata consists of a variable number of TLVs */
> +#define T2_BUFSIZE 512
> +static int nsh_log_t2(struct sk_buff *skb, u32 service_path_id,
> +		=A0=A0=A0=A0=A0=A0u8 service_index, u8 next_proto,
> +		=A0=A0=A0=A0=A0=A0struct nsh_metadata *ctx_hdrs, unsigned int num_=
ctx_hdrs)
> +{
> +	char t2_buf[T2_BUFSIZE];
> +	int wrlen;
> +	u32 *data;
> +	int i,j;
> +
> +	wrlen =3D snprintf(t2_buf, T2_BUFSIZE,
> +			=A0"NSH T2 Class %u Rx(%s): SPI=3D%u SI=3D%u Next=3D%s MD",
> +			=A0ctx_hdrs[0].class, skb->dev->name, service_path_id,
> +			=A0service_index, nsh_next_proto(next_proto));
> +
> +	for (i =3D 0; i < num_ctx_hdrs; i++) {
> +		wrlen +=3D snprintf(t2_buf+wrlen, T2_BUFSIZE-wrlen,
> +				=A0=A0" TLV%d Type=3D%u Len=3D%u", i+1,
> +				=A0=A0ctx_hdrs[i].type, ctx_hdrs[i].len);
> +		data =3D ctx_hdrs[i].data;
> +		for (j =3D 0; j < ctx_hdrs[i].len; j++)
> +			wrlen +=3D snprintf(t2_buf+wrlen, T2_BUFSIZE-wrlen,
> +					=A0=A0" 0x%08x", data[j]);
> +	}
> +	pr_info("%s\n", t2_buf);
> +	return 0;
> +}
> +
> +static struct nsh_listener nsh_log_t1_entry =3D {
> +	.class =3D NSH_MD_CLASS_TYPE_1,
> +	.notify =3D nsh_log_t1,
> +};
> +
> +static struct nsh_listener nsh_log_t2_entry[MAX_T2_CLASSES];
> +
> +static int __init nsh_log_init(void)
> +{
> +	int i, err;
> +
> +	if (t1_enabled) {
> +		err =3D nsh_register_listener(&nsh_log_t1_entry);
> +
> +		if (err)
> +			return err;
> +	}
> +
> +	for (i =3D 0; i < num_t2; i++) {
> +		nsh_log_t2_entry[i].class =3D t2_classes[i];
> +		nsh_log_t2_entry[i].notify =3D nsh_log_t2;
> +
> +		err =3D nsh_register_listener(&nsh_log_t2_entry[i]);
> +
> +		if (err)
> +			return err;
> +	}
> +	return 0;
> +}
> +
> +static void __exit nsh_log_exit(void)
> +{
> +	int i;
> +
> +	if (t1_enabled)
> +		nsh_unregister_listener(&nsh_log_t1_entry);
> +
> +	for (i =3D 0; i < num_t2; i++)
> +		nsh_unregister_listener(&nsh_log_t2_entry[i]);
> +}
> +
> +module_init(nsh_log_init);
> +module_exit(nsh_log_exit);
> +
> +MODULE_LICENSE("GPL");
> +MODULE_AUTHOR("Brian Russell <brussell@brocade.com>");
> +MODULE_DESCRIPTION("NSH Metadata logger");
