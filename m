From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH net-next v10 1/4] net netlink: Add new type NLA_FLAG_BITS
Date: Sun, 11 Jun 2017 07:53:43 -0400
Message-ID: <1497182026-11594-2-git-send-email-jhs@emojatatu.com>
References: <1497182026-11594-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, jiri@resnulli.us, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, simon.horman@netronome.com,
        mrv@mojatatu.com, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33845 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751595AbdFKLx6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 07:53:58 -0400
Received: by mail-io0-f193.google.com with SMTP id a96so8383444ioj.1
        for <netdev@vger.kernel.org>; Sun, 11 Jun 2017 04:53:58 -0700 (PDT)
In-Reply-To: <1497182026-11594-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Generic bitflags attribute content sent to the kernel by user.
With this type the user can either set or unset a flag in the
kernel.

The nla_flag_values is a bitmap that defines the values being set
The nla_flag_selector is a bitmask that defines which value is legit.

A check is made to ensure the rules that a kernel subsystem always
conforms to bitflags the kernel already knows about. i.e
if the user tries to set a bit flag that is not understood then
the _it will be rejected_.

In the most basic form, the user specifies the attribute policy as:
[ATTR_GOO] = { .type = NLA_FLAG_BITS, .validation_data = &myvalidflags },

where myvalidflags is the bit mask of the flags the kernel understands.

If the user _does not_ provide myvalidflags then the attribute will
also be rejected.

Examples:
nla_flag_values = 0x0, and nla_flag_selector = 0x1
implies we are selecting bit 1 and we want to set its value to 0.

nla_flag_values = 0x2, and nla_flag_selector = 0x2
implies we are selecting bit 2 and we want to set its value to 1.

This patch also provides an extra feature: a validation callback
that could be speaciliazed for other types.
This feature is intended to be used by a kernel subsystem to check
for a combination of bits being present. Example "bit x is valid
only if bit y and z are present".

So a kernel subsystem could specify validation rules of the following
nature:

[ATTR_GOO] = { .type = MYTYPE,
	       .validation_data = &myvalidation_data,
               .validate_content = mycontent_validator },

With validator callback looking like:

int mycontent_validator(const struct nlattr *nla, void *valid_data)
{
       const struct myattribute *user_data = nla_data(nla);
       struct myvalidation_struct *valid_data_constraint = valid_data;

      ... return appropriate error code etc ...
}


Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 include/net/netlink.h          | 11 +++++++++++
 include/uapi/linux/rtnetlink.h | 17 +++++++++++++++++
 lib/nlattr.c                   | 25 +++++++++++++++++++++++++
 3 files changed, 53 insertions(+)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index 0170917..8ab9784 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -6,6 +6,11 @@
 #include <linux/jiffies.h>
 #include <linux/in6.h>
 
+struct nla_bit_flags {
+	u32 nla_flag_values;
+	u32 nla_flag_selector;
+};
+
 /* ========================================================================
  *         Netlink Messages and Attributes Interface (As Seen On TV)
  * ------------------------------------------------------------------------
@@ -178,6 +183,7 @@ enum {
 	NLA_S16,
 	NLA_S32,
 	NLA_S64,
+	NLA_FLAG_BITS,
 	__NLA_TYPE_MAX,
 };
 
@@ -206,6 +212,7 @@ enum {
  *    NLA_MSECS            Leaving the length field zero will verify the
  *                         given type fits, using it verifies minimum length
  *                         just like "All other"
+ *    NLA_FLAG_BITS        A bitmap/bitselector attribute
  *    All other            Minimum length of attribute payload
  *
  * Example:
@@ -213,11 +220,15 @@ enum {
  * 	[ATTR_FOO] = { .type = NLA_U16 },
  *	[ATTR_BAR] = { .type = NLA_STRING, .len = BARSIZ },
  *	[ATTR_BAZ] = { .len = sizeof(struct mystruct) },
+ *	[ATTR_GOO] = { .type = NLA_FLAG_BITS, .validation_data = &myvalidflags },
  * };
  */
 struct nla_policy {
 	u16		type;
 	u16		len;
+	void            *validation_data;
+	int             (*validate_content)(const struct nlattr *nla,
+					    const void *validation_data);
 };
 
 /**
diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 564790e..8f07957 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -179,6 +179,23 @@ struct rtattr {
 #define RTA_DATA(rta)   ((void*)(((char*)(rta)) + RTA_LENGTH(0)))
 #define RTA_PAYLOAD(rta) ((int)((rta)->rta_len) - RTA_LENGTH(0))
 
+/* Generic bitflags attribute content sent to the kernel.
+ *
+ * The nla_flag_values is a bitmap that defines the values being set
+ * The nla_flag_selector is a bitmask that defines which value is legit
+ *
+ * Examples:
+ *  nla_flag_values = 0x0, and nla_flag_selector = 0x1
+ *  implies we are selecting bit 1 and we want to set its value to 0.
+ *
+ *  nla_flag_values = 0x2, and nla_flag_selector = 0x2
+ *  implies we are selecting bit 2 and we want to set its value to 1.
+ *
+ */
+struct __nla_bit_flags {
+	__u32 nla_flag_values;
+	__u32 nla_flag_selector;
+};
 
 
 
diff --git a/lib/nlattr.c b/lib/nlattr.c
index a7e0b16..78fed43 100644
--- a/lib/nlattr.c
+++ b/lib/nlattr.c
@@ -27,6 +27,21 @@
 	[NLA_S64]	= sizeof(s64),
 };
 
+static int validate_nla_bit_flags(const struct nlattr *nla, void *valid_data)
+{
+	const struct nla_bit_flags *nbf = nla_data(nla);
+	u32 *valid_flags_mask = valid_data;
+
+	if (!valid_data)
+		return -EINVAL;
+
+
+	if (nbf->nla_flag_values & ~*valid_flags_mask)
+		return -EINVAL;
+
+	return 0;
+}
+
 static int validate_nla(const struct nlattr *nla, int maxtype,
 			const struct nla_policy *policy)
 {
@@ -46,6 +61,13 @@ static int validate_nla(const struct nlattr *nla, int maxtype,
 			return -ERANGE;
 		break;
 
+	case NLA_FLAG_BITS:
+		if (attrlen != 8) /* 2 x 32 bits */
+			return -ERANGE;
+
+		return validate_nla_bit_flags(nla, pt->validation_data);
+		break;
+
 	case NLA_NUL_STRING:
 		if (pt->len)
 			minlen = min_t(int, attrlen, pt->len + 1);
@@ -103,6 +125,9 @@ static int validate_nla(const struct nlattr *nla, int maxtype,
 			return -ERANGE;
 	}
 
+	if (pt->validate_content)
+		return pt->validate_content(nla, pt->validation_data);
+
 	return 0;
 }
 
-- 
1.9.1
