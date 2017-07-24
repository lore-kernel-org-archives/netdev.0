From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v11 1/4] net netlink: Add new type
 NLA_BITFIELD_32
Date: Mon, 24 Jul 2017 13:14:52 +0200
Message-ID: <20170724111452.GA1868@nanopsycho>
References: <1500860146-26970-1-git-send-email-jhs@emojatatu.com>
 <1500860146-26970-2-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, dsahern@gmail.com,
        eric.dumazet@gmail.com, mrv@mojatatu.com,
        simon.horman@netronome.com, alex.aring@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:32882 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754108AbdGXLOz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 07:14:55 -0400
Received: by mail-wr0-f193.google.com with SMTP id y43so17174431wrd.0
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 04:14:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1500860146-26970-2-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jul 24, 2017 at 03:35:43AM CEST, jhs@mojatatu.com wrote:
>From: Jamal Hadi Salim <jhs@mojatatu.com>
>
>Generic bitflags attribute content sent to the kernel by user.
>With this type the user can either set or unset a flag in the
>kernel.
>
>The nla_value is a bitmap that defines the values being set
>The nla_selector is a bitmask that defines which value is legit.
>
>A check is made to ensure the rules that a kernel subsystem always
>conforms to bitflags the kernel already knows about. i.e
>if the user tries to set a bit flag that is not understood then
>the _it will be rejected_.
>
>In the most basic form, the user specifies the attribute policy as:
>[ATTR_GOO] = { .type = NLA_BITFIELD_32, .validation_data = &myvalidflags },
>
>where myvalidflags is the bit mask of the flags the kernel understands.
>
>If the user _does not_ provide myvalidflags then the attribute will
>also be rejected.
>
>Examples:
>nla_value = 0x0, and nla_selector = 0x1
>implies we are selecting bit 1 and we want to set its value to 0.
>
>nla_value = 0x2, and nla_selector = 0x2
>implies we are selecting bit 2 and we want to set its value to 1.
>
>Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
>---
> include/net/netlink.h        |  4 ++++
> include/uapi/linux/netlink.h | 17 +++++++++++++++++
> lib/nlattr.c                 | 21 +++++++++++++++++++++
> 3 files changed, 42 insertions(+)
>
>diff --git a/include/net/netlink.h b/include/net/netlink.h
>index ef8e6c3..e33d1fb 100644
>--- a/include/net/netlink.h
>+++ b/include/net/netlink.h
>@@ -178,6 +178,7 @@ enum {
> 	NLA_S16,
> 	NLA_S32,
> 	NLA_S64,
>+	NLA_BITFIELD_32,
> 	__NLA_TYPE_MAX,
> };
> 
>@@ -206,6 +207,7 @@ enum {
>  *    NLA_MSECS            Leaving the length field zero will verify the
>  *                         given type fits, using it verifies minimum length
>  *                         just like "All other"
>+ *    NLA_BITFIELD_32      A 32-bit bitmap/bitselector attribute
>  *    All other            Minimum length of attribute payload
>  *
>  * Example:
>@@ -213,11 +215,13 @@ enum {
>  * 	[ATTR_FOO] = { .type = NLA_U16 },
>  *	[ATTR_BAR] = { .type = NLA_STRING, .len = BARSIZ },
>  *	[ATTR_BAZ] = { .len = sizeof(struct mystruct) },
>+ *	[ATTR_GOO] = { .type = NLA_BITFIELD_32, .validation_data = &myvalidflags },
>  * };
>  */
> struct nla_policy {
> 	u16		type;
> 	u16		len;
>+	void            *validation_data;
> };
> 
> /**
>diff --git a/include/uapi/linux/netlink.h b/include/uapi/linux/netlink.h
>index f86127a..0ac05a6 100644
>--- a/include/uapi/linux/netlink.h
>+++ b/include/uapi/linux/netlink.h
>@@ -226,5 +226,22 @@ struct nlattr {
> #define NLA_ALIGN(len)		(((len) + NLA_ALIGNTO - 1) & ~(NLA_ALIGNTO - 1))
> #define NLA_HDRLEN		((int) NLA_ALIGN(sizeof(struct nlattr)))
> 
>+/* Generic 32 bitflags attribute content sent to the kernel.
>+ *
>+ * The nla_value is a bitmap that defines the values being set
>+ * The nla_selector is a bitmask that defines which value is legit
>+ *
>+ * Examples:
>+ *  nla_value = 0x0, and nla_selector = 0x1
>+ *  implies we are selecting bit 1 and we want to set its value to 0.
>+ *
>+ *  nla_value = 0x2, and nla_selector = 0x2
>+ *  implies we are selecting bit 2 and we want to set its value to 1.
>+ *
>+ */
>+struct nla_bitfield_32 {
>+	__u32 nla_value;
>+	__u32 nla_selector;

I would just have "value" and "selector" here. "nla_" prefix indicates
netlink attrubute, like in struct nlattr - nla_type, nla_len,
and that is wrong indication. 



>+};
> 
> #endif /* _UAPI__LINUX_NETLINK_H */
>diff --git a/lib/nlattr.c b/lib/nlattr.c
>index fb52435..c8aad7e 100644
>--- a/lib/nlattr.c
>+++ b/lib/nlattr.c
>@@ -27,6 +27,20 @@
> 	[NLA_S64]	= sizeof(s64),
> };
> 
>+static int validate_nla_bitfield_32(const struct nlattr *nla, void *valid_data)

This should be:
static int validate_nla_bitfield_32(const struct nlattr *nla, u32 *valid_flags_allowed)


Other than this 2 nits, this looks good.



>+{
>+	const struct nla_bitfield_32 *nbf = nla_data(nla);
>+	u32 *valid_flags_mask = valid_data;
>+
>+	if (!valid_data)
>+		return -EINVAL;
>+
>+	if (nbf->nla_value & ~*valid_flags_mask)
>+		return -EINVAL;
>+
>+	return 0;
>+}
>+
> static int validate_nla(const struct nlattr *nla, int maxtype,
> 			const struct nla_policy *policy)
> {
>@@ -46,6 +60,13 @@ static int validate_nla(const struct nlattr *nla, int maxtype,
> 			return -ERANGE;
> 		break;
> 
>+	case NLA_BITFIELD_32:
>+		if (attrlen != sizeof(struct nla_bitfield_32))
>+			return -ERANGE;
>+
>+		return validate_nla_bitfield_32(nla, pt->validation_data);
>+		break;
>+
> 	case NLA_NUL_STRING:
> 		if (pt->len)
> 			minlen = min_t(int, attrlen, pt->len + 1);
>-- 
>1.9.1
>
