From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH iproute2 1/3] sr: add header files for SR-IPv6
Date: Tue, 10 Jan 2017 09:25:00 -0800
Message-ID: <CALx6S35FqnWHGW3tLMy0eqb4qxvPmKwOy+oa0Z8CZahQzHqQBA@mail.gmail.com>
References: <1484066486-22152-1-git-send-email-david.lebrun@uclouvain.be> <1484066486-22152-2-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:34596 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1162658AbdAJRZC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 12:25:02 -0500
Received: by mail-qt0-f195.google.com with SMTP id a29so18976734qtb.1
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 09:25:01 -0800 (PST)
In-Reply-To: <1484066486-22152-2-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Acked-by: Tom Herbert <tom@herbertland.com>



On Tue, Jan 10, 2017 at 8:41 AM, David Lebrun <david.lebrun@uclouvain.be> wrote:
> This patch add the necessary header files to interface with the SR-IPv6 kernel
> implementation.
>
> Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
> ---
>  include/linux/seg6.h          | 54 +++++++++++++++++++++++++++++++++++++++++++
>  include/linux/seg6_genl.h     | 32 +++++++++++++++++++++++++
>  include/linux/seg6_hmac.h     | 21 +++++++++++++++++
>  include/linux/seg6_iptunnel.h | 38 ++++++++++++++++++++++++++++++
>  4 files changed, 145 insertions(+)
>  create mode 100644 include/linux/seg6.h
>  create mode 100644 include/linux/seg6_genl.h
>  create mode 100644 include/linux/seg6_hmac.h
>  create mode 100644 include/linux/seg6_iptunnel.h
>
> diff --git a/include/linux/seg6.h b/include/linux/seg6.h
> new file mode 100644
> index 0000000..8f651bf
> --- /dev/null
> +++ b/include/linux/seg6.h
> @@ -0,0 +1,54 @@
> +/*
> + *  SR-IPv6 implementation
> + *
> + *  Author:
> + *  David Lebrun <david.lebrun@uclouvain.be>
> + *
> + *
> + *  This program is free software; you can redistribute it and/or
> + *      modify it under the terms of the GNU General Public License
> + *      as published by the Free Software Foundation; either version
> + *      2 of the License, or (at your option) any later version.
> + */
> +
> +#ifndef _SEG6_H
> +#define _SEG6_H
> +
> +/*
> + * SRH
> + */
> +struct ipv6_sr_hdr {
> +       __u8    nexthdr;
> +       __u8    hdrlen;
> +       __u8    type;
> +       __u8    segments_left;
> +       __u8    first_segment;
> +       __u8    flag_1;
> +       __u8    flag_2;
> +       __u8    reserved;
> +
> +       struct in6_addr segments[0];
> +};
> +
> +#define SR6_FLAG1_CLEANUP      (1 << 7)
> +#define SR6_FLAG1_PROTECTED    (1 << 6)
> +#define SR6_FLAG1_OAM          (1 << 5)
> +#define SR6_FLAG1_ALERT                (1 << 4)
> +#define SR6_FLAG1_HMAC         (1 << 3)
> +
> +#define SR6_TLV_INGRESS                1
> +#define SR6_TLV_EGRESS         2
> +#define SR6_TLV_OPAQUE         3
> +#define SR6_TLV_PADDING                4
> +#define SR6_TLV_HMAC           5
> +
> +#define sr_has_cleanup(srh) ((srh)->flag_1 & SR6_FLAG1_CLEANUP)
> +#define sr_has_hmac(srh) ((srh)->flag_1 & SR6_FLAG1_HMAC)
> +
> +struct sr6_tlv {
> +       __u8 type;
> +       __u8 len;
> +       __u8 data[0];
> +};
> +
> +#endif
> diff --git a/include/linux/seg6_genl.h b/include/linux/seg6_genl.h
> new file mode 100644
> index 0000000..36fcbc8
> --- /dev/null
> +++ b/include/linux/seg6_genl.h
> @@ -0,0 +1,32 @@
> +#ifndef _SEG6_GENL_H
> +#define _SEG6_GENL_H
> +
> +#define SEG6_GENL_NAME         "SEG6"
> +#define SEG6_GENL_VERSION      0x1
> +
> +enum {
> +       SEG6_ATTR_UNSPEC,
> +       SEG6_ATTR_DST,
> +       SEG6_ATTR_DSTLEN,
> +       SEG6_ATTR_HMACKEYID,
> +       SEG6_ATTR_SECRET,
> +       SEG6_ATTR_SECRETLEN,
> +       SEG6_ATTR_ALGID,
> +       SEG6_ATTR_HMACINFO,
> +       __SEG6_ATTR_MAX,
> +};
> +
> +#define SEG6_ATTR_MAX (__SEG6_ATTR_MAX - 1)
> +
> +enum {
> +       SEG6_CMD_UNSPEC,
> +       SEG6_CMD_SETHMAC,
> +       SEG6_CMD_DUMPHMAC,
> +       SEG6_CMD_SET_TUNSRC,
> +       SEG6_CMD_GET_TUNSRC,
> +       __SEG6_CMD_MAX,
> +};
> +
> +#define SEG6_CMD_MAX (__SEG6_CMD_MAX - 1)
> +
> +#endif
> diff --git a/include/linux/seg6_hmac.h b/include/linux/seg6_hmac.h
> new file mode 100644
> index 0000000..71803d2
> --- /dev/null
> +++ b/include/linux/seg6_hmac.h
> @@ -0,0 +1,21 @@
> +#ifndef _SEG6_HMAC_H
> +#define _SEG6_HMAC_H
> +
> +#include <linux/seg6.h>
> +
> +#define SEG6_HMAC_SECRET_LEN   64
> +#define SEG6_HMAC_FIELD_LEN    32
> +
> +struct sr6_tlv_hmac {
> +       struct sr6_tlv tlvhdr;
> +       __u16 reserved;
> +       __be32 hmackeyid;
> +       __u8 hmac[SEG6_HMAC_FIELD_LEN];
> +};
> +
> +enum {
> +       SEG6_HMAC_ALGO_SHA1 = 1,
> +       SEG6_HMAC_ALGO_SHA256 = 2,
> +};
> +
> +#endif
> diff --git a/include/linux/seg6_iptunnel.h b/include/linux/seg6_iptunnel.h
> new file mode 100644
> index 0000000..0d72a58
> --- /dev/null
> +++ b/include/linux/seg6_iptunnel.h
> @@ -0,0 +1,38 @@
> +/*
> + *  SR-IPv6 implementation
> + *
> + *  Author:
> + *  David Lebrun <david.lebrun@uclouvain.be>
> + *
> + *
> + *  This program is free software; you can redistribute it and/or
> + *      modify it under the terms of the GNU General Public License
> + *      as published by the Free Software Foundation; either version
> + *      2 of the License, or (at your option) any later version.
> + */
> +
> +#ifndef _SEG6_IPTUNNEL_H
> +#define _SEG6_IPTUNNEL_H
> +
> +#include <linux/seg6.h>
> +
> +enum {
> +       SEG6_IPTUNNEL_UNSPEC,
> +       SEG6_IPTUNNEL_SRH,
> +       __SEG6_IPTUNNEL_MAX,
> +};
> +#define SEG6_IPTUNNEL_MAX (__SEG6_IPTUNNEL_MAX - 1)
> +
> +struct seg6_iptunnel_encap {
> +       int mode;
> +       struct ipv6_sr_hdr srh[0];
> +};
> +
> +#define SEG6_IPTUN_ENCAP_SIZE(x) ((sizeof(*x)) + (((x)->srh->hdrlen + 1) << 3))
> +
> +enum {
> +       SEG6_IPTUN_MODE_INLINE,
> +       SEG6_IPTUN_MODE_ENCAP,
> +};
> +
> +#endif
> --
> 2.7.3
>
