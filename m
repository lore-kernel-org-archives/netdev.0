From: Stefan Schmidt <stefan@osg.samsung.com>
Subject: Re: [PATCH wpan-tools 1/2] security: add nl802154 security support
Date: Wed, 30 Sep 2015 16:46:30 +0200
Message-ID: <560BF5C6.9090506@osg.samsung.com>
References: <1443425134-27910-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel@pengutronix.de, netdev@vger.kernel.org,
	phoebe.buckheister@itwm.fraunhofer.de
To: Alexander Aring <alex.aring@gmail.com>, linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.s-osg.org ([54.187.51.154]:40116 "EHLO lists.s-osg.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751436AbbI3Oqf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 10:46:35 -0400
In-Reply-To: <1443425134-27910-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

A really huge patch. I will start on it. Not sure I can do a full review 
in one go though.

On 28/09/15 09:25, Alexander Aring wrote:
> This patch introduce support for the experimental seucirty support for

Type. Security.
> nl802154. We currently support add/del settings for manipulating
> security table entries. The dump functionality is a "really" keep it

is really a
> short and stupid handling, the dump will printout the printout the right

dump will printout the right calls to add the entry
> add calls which was called to add the entry. This can be used for
> storing the current security tables by some script. The interface
> argument is replaced by $WPAN_DEV variable, so it's possible to move one
> interface configuration to another one.
>
> Signed-off-by: Alexander Aring <alex.aring@gmail.com>
> ---
>   src/Makefile.am |    1 +
>   src/interface.c |  100 +++++
>   src/nl802154.h  |  191 ++++++++++
>   src/security.c  | 1118 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
>   4 files changed, 1410 insertions(+)
>   create mode 100644 src/security.c
>
> diff --git a/src/Makefile.am b/src/Makefile.am
> index 2d54576..b2177a2 100644
> --- a/src/Makefile.am
> +++ b/src/Makefile.am
> @@ -9,6 +9,7 @@ iwpan_SOURCES = \
>   	interface.c \
>   	phy.c \
>   	mac.c \
> +	security.c \
>   	nl_extras.h \
>   	nl802154.h
>   
> diff --git a/src/interface.c b/src/interface.c
> index 85d40a8..076e7c3 100644
> --- a/src/interface.c
> +++ b/src/interface.c
> @@ -10,6 +10,7 @@
>   #include <netlink/msg.h>
>   #include <netlink/attr.h>
>   
> +#define CONFIG_IEEE802154_NL802154_EXPERIMENTAL
>   #include "nl802154.h"
>   #include "nl_extras.h"
>   #include "iwpan.h"
> @@ -226,6 +227,105 @@ static int print_iface_handler(struct nl_msg *msg, void *arg)
>   	if (tb_msg[NL802154_ATTR_ACKREQ_DEFAULT])
>   		printf("%s\tackreq_default %d\n", indent, nla_get_u8(tb_msg[NL802154_ATTR_ACKREQ_DEFAULT]));
>   
> +	if (tb_msg[NL802154_ATTR_SEC_ENABLED])
> +		printf("%s\tsecurity %d\n", indent, nla_get_u8(tb_msg[NL802154_ATTR_SEC_ENABLED]));
> +	if (tb_msg[NL802154_ATTR_SEC_OUT_LEVEL])
> +		printf("%s\tout_level %d\n", indent, nla_get_u8(tb_msg[NL802154_ATTR_SEC_OUT_LEVEL]));
> +	if (tb_msg[NL802154_ATTR_SEC_OUT_KEY_ID]) {
> +		struct nlattr *tb_key_id[NL802154_KEY_ID_ATTR_MAX + 1];
> +		static struct nla_policy key_id_policy[NL802154_KEY_ID_ATTR_MAX + 1] = {
> +		        [NL802154_KEY_ID_ATTR_MODE] = { .type = NLA_U32 },
> +		        [NL802154_KEY_ID_ATTR_INDEX] = { .type = NLA_U8 },
> +		        [NL802154_KEY_ID_ATTR_IMPLICIT] = { .type = NLA_NESTED },
> +		        [NL802154_KEY_ID_ATTR_SOURCE_SHORT] = { .type = NLA_U32 },
> +		        [NL802154_KEY_ID_ATTR_SOURCE_EXTENDED] = { .type = NLA_U64 },
> +		};
> +
> +		nla_parse_nested(tb_key_id, NL802154_KEY_ID_ATTR_MAX,
> +				 tb_msg[NL802154_ATTR_SEC_OUT_KEY_ID], key_id_policy);
> +		printf("%s\tout_key_id\n", indent);
> +
> +		if (tb_key_id[NL802154_KEY_ID_ATTR_MODE]) {
> +			enum nl802154_key_id_modes key_id_mode;
> +
> +			key_id_mode = nla_get_u32(tb_key_id[NL802154_KEY_ID_ATTR_MODE]);
> +			switch (key_id_mode) {
> +			case NL802154_KEY_ID_MODE_IMPLICIT:
> +				printf("%s\t\tmode implicit\n", indent);
> +				if (tb_key_id[NL802154_KEY_ID_ATTR_IMPLICIT]) {
> +					struct nlattr *tb_dev_addr[NL802154_DEV_ADDR_ATTR_MAX + 1];
> +					static struct nla_policy dev_addr_policy[NL802154_DEV_ADDR_ATTR_MAX + 1] = {
> +						[NL802154_DEV_ADDR_ATTR_PAN_ID] = { .type = NLA_U16 },
> +						[NL802154_DEV_ADDR_ATTR_MODE] = { .type = NLA_U32 },
> +						[NL802154_DEV_ADDR_ATTR_SHORT] = { .type = NLA_U16 },
> +						[NL802154_DEV_ADDR_ATTR_EXTENDED] = { .type = NLA_U64 },
> +					};
> +
> +					nla_parse_nested(tb_dev_addr, NL802154_DEV_ADDR_ATTR_MAX,
> +							 tb_key_id[NL802154_KEY_ID_ATTR_IMPLICIT],
> +							 dev_addr_policy);
> +
> +					if (tb_dev_addr[NL802154_DEV_ADDR_ATTR_PAN_ID])
> +						printf("%s\t\tpan_id 0x%04x\n", indent,
> +						       le16toh(nla_get_u16(tb_dev_addr[NL802154_DEV_ADDR_ATTR_PAN_ID])));
> +
> +					if (tb_dev_addr[NL802154_DEV_ADDR_ATTR_MODE]) {
> +						enum nl802154_dev_addr_modes dev_addr_mode;
> +						dev_addr_mode = nla_get_u32(tb_dev_addr[NL802154_DEV_ADDR_ATTR_MODE]);
> +						printf("%s\t\taddr_mode %d\n", indent, dev_addr_mode);
> +						switch (dev_addr_mode) {
> +						case NL802154_DEV_ADDR_SHORT:
> +							if (tb_dev_addr[NL802154_DEV_ADDR_ATTR_SHORT])
> +								printf("%s\t\tshort_addr 0x%04x\n", indent,
> +								       le16toh(nla_get_u16(tb_dev_addr[NL802154_DEV_ADDR_ATTR_SHORT])));
> +							break;
> +						case NL802154_DEV_ADDR_EXTENDED:
> +							if (tb_dev_addr[NL802154_DEV_ADDR_ATTR_EXTENDED])
> +								printf("%s\t\textended_addr 0x%016" PRIx64 "\n", indent,
> +								       le64toh(nla_get_u64(tb_dev_addr[NL802154_DEV_ADDR_ATTR_EXTENDED])));
> +							break;
> +						default:
> +							printf("%s\t\tunkown address\n", indent);
> +							break;
> +						}
> +					}
> +				}
> +				break;
> +			case NL802154_KEY_ID_MODE_INDEX:
> +				printf("%s\t\tmode index\n", indent);
> +				if (tb_key_id[NL802154_KEY_ID_ATTR_INDEX])
> +					printf("%s\t\tindex 0x%02x\n", indent,
> +					       nla_get_u8(tb_key_id[NL802154_KEY_ID_ATTR_INDEX]));
> +				break;
> +			case NL802154_KEY_ID_MODE_INDEX_SHORT:
> +				printf("%s\t\tmode index_short\n", indent);
> +				if (tb_key_id[NL802154_KEY_ID_ATTR_INDEX])
> +					printf("%s\t\tindex 0x%02x\n", indent,
> +					       nla_get_u8(tb_key_id[NL802154_KEY_ID_ATTR_INDEX]));
> +
> +				if (tb_key_id[NL802154_KEY_ID_ATTR_SOURCE_SHORT])
> +					printf("%s\t\tsource_short 0x%08lx\n", indent,
> +					       le32toh(nla_get_u32(tb_key_id[NL802154_KEY_ID_ATTR_SOURCE_SHORT])));
> +				break;
> +			case NL802154_KEY_ID_MODE_INDEX_EXTENDED:
> +				printf("%s\t\tmode index_extended\n", indent);
> +				if (tb_key_id[NL802154_KEY_ID_ATTR_INDEX])
> +					printf("%s\t\tindex 0x%02x\n", indent,
> +					       nla_get_u8(tb_key_id[NL802154_KEY_ID_ATTR_INDEX]));
> +
> +				if (tb_key_id[NL802154_KEY_ID_ATTR_SOURCE_EXTENDED])
> +					printf("%s\t\tsource_extended 0x%" PRIx64 "\n", indent,
> +					       le64toh(nla_get_u64(tb_key_id[NL802154_KEY_ID_ATTR_SOURCE_EXTENDED])));
> +				break;
> +			default:
> +				printf("%s\t\tkey_mode unknown\n", indent);
> +			}
> +		}
> +	}
> +
> +	if (tb_msg[NL802154_ATTR_SEC_FRAME_COUNTER])
> +		printf("%s\tframe_counter 0x%08lx\n", indent, be32toh(nla_get_u32(tb_msg[NL802154_ATTR_SEC_FRAME_COUNTER])));
> +
>   	return NL_SKIP;
>   }
>   
> diff --git a/src/nl802154.h b/src/nl802154.h
> index cf2713d..32cb3e5 100644
> --- a/src/nl802154.h
> +++ b/src/nl802154.h
> @@ -56,6 +56,22 @@ enum nl802154_commands {
>   
>   	/* add new commands above here */
>   
> +#ifdef CONFIG_IEEE802154_NL802154_EXPERIMENTAL
> +	NL802154_CMD_SET_SEC_PARAMS,
> +	NL802154_CMD_GET_SEC_KEY,		/* can dump */
> +	NL802154_CMD_NEW_SEC_KEY,
> +	NL802154_CMD_DEL_SEC_KEY,
> +	NL802154_CMD_GET_SEC_DEV,		/* can dump */
> +	NL802154_CMD_NEW_SEC_DEV,
> +	NL802154_CMD_DEL_SEC_DEV,
> +	NL802154_CMD_GET_SEC_DEVKEY,		/* can dump */
> +	NL802154_CMD_NEW_SEC_DEVKEY,
> +	NL802154_CMD_DEL_SEC_DEVKEY,
> +	NL802154_CMD_GET_SEC_LEVEL,		/* can dump */
> +	NL802154_CMD_NEW_SEC_LEVEL,
> +	NL802154_CMD_DEL_SEC_LEVEL,
> +#endif /* CONFIG_IEEE802154_NL802154_EXPERIMENTAL */
> +
>   	/* used to define NL802154_CMD_MAX below */
>   	__NL802154_CMD_AFTER_LAST,
>   	NL802154_CMD_MAX = __NL802154_CMD_AFTER_LAST - 1
> @@ -110,6 +126,18 @@ enum nl802154_attrs {
>   
>   	/* add attributes here, update the policy in nl802154.c */
>   
> +#ifdef CONFIG_IEEE802154_NL802154_EXPERIMENTAL
> +	NL802154_ATTR_SEC_ENABLED,
> +	NL802154_ATTR_SEC_OUT_LEVEL,
> +	NL802154_ATTR_SEC_OUT_KEY_ID,
> +	NL802154_ATTR_SEC_FRAME_COUNTER,
> +
> +	NL802154_ATTR_SEC_LEVEL,
> +	NL802154_ATTR_SEC_DEVICE,
> +	NL802154_ATTR_SEC_DEVKEY,
> +	NL802154_ATTR_SEC_KEY,
> +#endif /* CONFIG_IEEE802154_NL802154_EXPERIMENTAL */
> +
>   	__NL802154_ATTR_AFTER_LAST,
>   	NL802154_ATTR_MAX = __NL802154_ATTR_AFTER_LAST - 1
>   };
> @@ -247,4 +275,167 @@ enum nl802154_supported_bool_states {
>   	NL802154_SUPPORTED_BOOL_MAX = __NL802154_SUPPORTED_BOOL_AFTER_LAST - 1
>   };
>   
> +#ifdef CONFIG_IEEE802154_NL802154_EXPERIMENTAL
> +
> +enum nl802154_dev_addr_modes {
> +	NL802154_DEV_ADDR_NONE,
> +	__NL802154_DEV_ADDR_INVALID,
> +	NL802154_DEV_ADDR_SHORT,
> +	NL802154_DEV_ADDR_EXTENDED,
> +
> +	/* keep last */
> +	__NL802154_DEV_ADDR_AFTER_LAST,

Hmm, why bother with AFTER_LAST here and not just use ADDR_MAX as 
sentinal for this enum? Looks redundant to me.

> +	NL802154_DEV_ADDR_MAX = __NL802154_DEV_ADDR_AFTER_LAST - 1
> +};
> +
> +enum nl802154_dev_addr_attrs {
> +	NL802154_DEV_ADDR_ATTR_UNSPEC,
> +
> +	NL802154_DEV_ADDR_ATTR_PAN_ID,
> +	NL802154_DEV_ADDR_ATTR_MODE,
> +	NL802154_DEV_ADDR_ATTR_SHORT,
> +	NL802154_DEV_ADDR_ATTR_EXTENDED,
> +
> +	/* keep last */
> +	__NL802154_DEV_ADDR_ATTR_AFTER_LAST,
> +	NL802154_DEV_ADDR_ATTR_MAX = __NL802154_DEV_ADDR_ATTR_AFTER_LAST - 1

Same as above

> +};
> +
> +enum nl802154_key_id_modes {
> +	NL802154_KEY_ID_MODE_IMPLICIT,
> +	NL802154_KEY_ID_MODE_INDEX,
> +	NL802154_KEY_ID_MODE_INDEX_SHORT,
> +	NL802154_KEY_ID_MODE_INDEX_EXTENDED,
> +
> +	/* keep last */
> +	__NL802154_KEY_ID_MODE_AFTER_LAST,
> +	NL802154_KEY_ID_MODE_MAX = __NL802154_KEY_ID_MODE_AFTER_LAST - 1

Same as above.

> +};
> +
> +enum nl802154_key_id_attrs {
> +	NL802154_KEY_ID_ATTR_UNSPEC,
> +
> +	NL802154_KEY_ID_ATTR_MODE,
> +	NL802154_KEY_ID_ATTR_INDEX,
> +	NL802154_KEY_ID_ATTR_IMPLICIT,
> +	NL802154_KEY_ID_ATTR_SOURCE_SHORT,
> +	NL802154_KEY_ID_ATTR_SOURCE_EXTENDED,
> +
> +	/* keep last */
> +	__NL802154_KEY_ID_ATTR_AFTER_LAST,
> +	NL802154_KEY_ID_ATTR_MAX = __NL802154_KEY_ID_ATTR_AFTER_LAST - 1

Above

> +};
> +
> +enum nl802154_seclevels {
> +	NL802154_SECLEVEL_NONE,
> +	NL802154_SECLEVEL_MIC32,
> +	NL802154_SECLEVEL_MIC64,
> +	NL802154_SECLEVEL_MIC128,
> +	NL802154_SECLEVEL_ENC,
> +	NL802154_SECLEVEL_ENC_MIC32,
> +	NL802154_SECLEVEL_ENC_MIC64,
> +	NL802154_SECLEVEL_ENC_MIC128,
> +
> +	/* keep last */
> +	__NL802154_SECLEVEL_AFTER_LAST,
> +	NL802154_SECLEVEL_MAX = __NL802154_SECLEVEL_AFTER_LAST - 1

Above
> +};
> +
> +enum nl802154_frames {
> +	NL802154_FRAME_BEACON,
> +	NL802154_FRAME_DATA,
> +	NL802154_FRAME_ACK,
> +	NL802154_FRAME_CMD,
> +
> +	/* keep last */
> +	__NL802154_FRAME_AFTER_LAST,
> +	NL802154_FRAME_MAX = __NL802154_FRAME_AFTER_LAST - 1

Above
> +};
> +
> +enum nl802154_cmd_frames {
> +	__NL802154_CMD_FRAME_INVALID,
> +	NL802154_CMD_FRAME_ASSOC_REQUEST,
> +	NL802154_CMD_FRAME_ASSOC_RESPONSE,
> +	NL802154_CMD_FRAME_DISASSOC_NOTIFY,
> +	NL802154_CMD_FRAME_DATA_REQUEST,
> +	NL802154_CMD_FRAME_PAN_ID_CONFLICT_NOTIFY,
> +	NL802154_CMD_FRAME_ORPHAN_NOTIFY,
> +	NL802154_CMD_FRAME_BEACON_REQUEST,
> +	NL802154_CMD_FRAME_COORD_REALIGNMENT,
> +	NL802154_CMD_FRAME_GTS_REQUEST,
> +
> +	/* keep last */
> +	__NL802154_CMD_FRAME_AFTER_LAST,
> +	NL802154_CMD_FRAME_MAX = __NL802154_CMD_FRAME_AFTER_LAST - 1

Above, and for all other below.
> +};
> +
> +enum nl802154_seclevel_attrs {
> +	NL802154_SECLEVEL_ATTR_UNSPEC,
> +
> +	NL802154_SECLEVEL_ATTR_LEVELS,
> +	NL802154_SECLEVEL_ATTR_FRAME,
> +	NL802154_SECLEVEL_ATTR_CMD_FRAME,
> +	NL802154_SECLEVEL_ATTR_DEV_OVERRIDE,
> +
> +	/* keep last */
> +	__NL802154_SECLEVEL_ATTR_AFTER_LAST,
> +	NL802154_SECLEVEL_ATTR_MAX = __NL802154_SECLEVEL_ATTR_AFTER_LAST - 1
> +};
> +
> +/* TODO what is this? couldn't find in mib */
> +enum {
> +	NL802154_DEVKEY_IGNORE,
> +	NL802154_DEVKEY_RESTRICT,
> +	NL802154_DEVKEY_RECORD,
> +
> +	/* keep last */
> +	__NL802154_DEVKEY_AFTER_LAST,
> +	NL802154_DEVKEY_MAX = __NL802154_DEVKEY_AFTER_LAST - 1
> +};
> +
> +enum nl802154_dev {
> +	NL802154_DEV_ATTR_UNSPEC,
> +
> +	NL802154_DEV_ATTR_FRAME_COUNTER,
> +	NL802154_DEV_ATTR_PAN_ID,
> +	NL802154_DEV_ATTR_SHORT_ADDR,
> +	NL802154_DEV_ATTR_EXTENDED_ADDR,
> +	NL802154_DEV_ATTR_SECLEVEL_EXEMPT,
> +	NL802154_DEV_ATTR_KEY_MODE,
> +
> +	/* keep last */
> +	__NL802154_DEV_ATTR_AFTER_LAST,
> +	NL802154_DEV_ATTR_MAX = __NL802154_DEV_ATTR_AFTER_LAST - 1
> +};
> +
> +enum nl802154_devkey {
> +	NL802154_DEVKEY_ATTR_UNSPEC,
> +
> +	NL802154_DEVKEY_ATTR_FRAME_COUNTER,
> +	NL802154_DEVKEY_ATTR_EXTENDED_ADDR,
> +	NL802154_DEVKEY_ATTR_ID,
> +
> +	/* keep last */
> +	__NL802154_DEVKEY_ATTR_AFTER_LAST,
> +	NL802154_DEVKEY_ATTR_MAX = __NL802154_DEVKEY_ATTR_AFTER_LAST - 1
> +};
> +
> +enum nl802154_key {
> +	NL802154_KEY_ATTR_UNSPEC,
> +
> +	NL802154_KEY_ATTR_ID,
> +	NL802154_KEY_ATTR_USAGE_FRAMES,
> +	NL802154_KEY_ATTR_USAGE_CMDS,
> +	NL802154_KEY_ATTR_BYTES,
> +
> +	/* keep last */
> +	__NL802154_KEY_ATTR_AFTER_LAST,
> +	NL802154_KEY_ATTR_MAX = __NL802154_KEY_ATTR_AFTER_LAST - 1
> +};
> +
> +#define NL802154_KEY_SIZE		16
> +#define NL802154_CMD_FRAME_NR_IDS	256
> +
> +#endif /* CONFIG_IEEE802154_NL802154_EXPERIMENTAL */
> +
>   #endif /* __NL802154_H */
> diff --git a/src/security.c b/src/security.c
> new file mode 100644
> index 0000000..3928dee
> --- /dev/null
> +++ b/src/security.c
> @@ -0,0 +1,1118 @@
> +#include <net/if.h>
> +#include <errno.h>
> +#include <string.h>
> +#include <stdbool.h>
> +#include <inttypes.h>
> +
> +#include <netlink/genl/genl.h>
> +#include <netlink/genl/family.h>
> +#include <netlink/genl/ctrl.h>
> +#include <netlink/msg.h>
> +#include <netlink/attr.h>
> +
> +#include "nl_extras.h"
> +#define CONFIG_IEEE802154_NL802154_EXPERIMENTAL
> +#include "nl802154.h"
> +#include "iwpan.h"
> +
> +static int handle_security_set(struct nl802154_state *state, struct nl_cb *cb,
> +			       struct nl_msg *msg, int argc, char **argv,
> +			       enum id_input id)
> +{
> +	unsigned long enabled;
> +	char *end;
> +
> +	if (argc < 1)
> +		return 1;
> +
> +	/* enabled */
> +	enabled = strtoul(argv[0], &end, 0);
> +	if (*end != '\0')
> +		return 1;
> +
> +	if (enabled > UINT8_MAX)
> +		return 1;
> +
> +	NLA_PUT_U8(msg, NL802154_ATTR_SEC_ENABLED, enabled);
> +
> +	return 0;
> +
> +nla_put_failure:
> +	return -ENOBUFS;
> +}
> +COMMAND(set, security, "<1|0>", NL802154_CMD_SET_SEC_PARAMS, 0, CIB_NETDEV,
> +	handle_security_set, NULL);
> +
> +static int handle_parse_key_id(struct nl_msg *msg, int attrtype,
> +			       int *argc, char ***argv)
> +{
> +	struct nl_msg *key_id_msg, *dev_addr_msg = NULL;
> +	unsigned long key_mode, dev_addr_mode, short_addr, pan_id, index;
> +	unsigned long long extended_addr;
> +	char *end;
> +
> +	if ((*argc) < 1)
> +		return 1;
> +
> +	/* key_mode */
> +	key_mode = strtoul((*argv)[0], &end, 0);
> +	if (*end != '\0')
> +		return 1;
> +
> +	(*argc)--;
> +	(*argv)++;
> +
> +	switch (key_mode) {
> +	case NL802154_KEY_ID_MODE_IMPLICIT:
> +		if ((*argc) < 2)
> +			return 1;
> +
> +		/* pan_id */
> +		pan_id = strtoul((*argv)[0], &end, 0);
> +		if (*end != '\0')
> +			return 1;
> +
> +		if (pan_id > UINT16_MAX)
> +			return 1;
> +
> +		(*argc)--;
> +		(*argv)++;
> +
> +		/* dev_addr_mode */
> +		dev_addr_mode = strtoul((*argv)[0], &end, 0);
> +		if (*end != '\0')
> +			return 1;
> +
> +		(*argc)--;
> +		(*argv)++;
> +
> +		switch (dev_addr_mode) {
> +		case NL802154_DEV_ADDR_SHORT:
> +			if ((*argc) < 1)
> +				return 1;
> +
> +			/* dev_addr_short */
> +			short_addr = strtoul((*argv)[0], &end, 0);
> +			if (*end != '\0')
> +				return 1;
> +
> +			if (short_addr > UINT16_MAX)
> +				return 1;
> +			break;
> +		case NL802154_DEV_ADDR_EXTENDED:
> +			if ((*argc) < 1)
> +				return 1;
> +
> +			/* dev_addr_short */
> +			extended_addr = strtoull((*argv)[0], &end, 0);
> +			if (*end != '\0')
> +				return 1;
> +			break;
> +		default:
> +			return 1;
> +		}
> +
> +		key_id_msg = nlmsg_alloc();
> +		if (!key_id_msg)
> +			return -ENOMEM;
> +
> +		dev_addr_msg = nlmsg_alloc();
> +		if (!dev_addr_msg)
> +			return -ENOMEM;
> +
> +		NLA_PUT_U16(dev_addr_msg, NL802154_DEV_ADDR_ATTR_PAN_ID, pan_id);
> +		NLA_PUT_U32(dev_addr_msg, NL802154_DEV_ADDR_ATTR_MODE, dev_addr_mode);
> +		NLA_PUT_U16(dev_addr_msg, NL802154_DEV_ADDR_ATTR_SHORT, htole16(short_addr));
> +		NLA_PUT_U64(dev_addr_msg, NL802154_DEV_ADDR_ATTR_EXTENDED, htole64(extended_addr));
> +
> +		nla_put_nested(key_id_msg, NL802154_KEY_ID_ATTR_IMPLICIT, dev_addr_msg);
> +
> +		nlmsg_free(dev_addr_msg);
> +		dev_addr_msg = NULL;
> +
> +		break;
> +	case NL802154_KEY_ID_MODE_INDEX:
> +		if ((*argc) < 1)
> +			return 1;
> +
> +		/* index */
> +		index = strtoul((*argv)[0], &end, 0);
> +		if (*end != '\0')
> +			return 1;
> +
> +		if (index > UINT8_MAX)
> +			return 1;
> +
> +		key_id_msg = nlmsg_alloc();
> +		if (!key_id_msg)
> +			return -ENOMEM;
> +
> +		NLA_PUT_U8(key_id_msg, NL802154_KEY_ID_ATTR_INDEX, index);
> +		break;
> +	case NL802154_KEY_ID_MODE_INDEX_SHORT:
> +		if ((*argc) < 2)
> +			return 1;
> +
> +		/* index */
> +		index = strtoul((*argv)[0], &end, 0);
> +		if (*end != '\0')
> +			return 1;
> +
> +		if (index > UINT8_MAX)
> +			return 1;
> +
> +		(*argc)--;
> +		(*argv)++;
> +
> +		/* source_short */
> +		short_addr = strtoul((*argv)[0], &end, 0);
> +		if (*end != '\0')
> +			return 1;
> +
> +		key_id_msg = nlmsg_alloc();
> +		if (!key_id_msg)
> +			return -ENOMEM;
> +
> +		NLA_PUT_U8(key_id_msg, NL802154_KEY_ID_ATTR_INDEX, index);
> +		NLA_PUT_U32(key_id_msg, NL802154_KEY_ID_ATTR_SOURCE_SHORT,
> +			    htole32(short_addr));
> +		break;
> +	case NL802154_KEY_ID_MODE_INDEX_EXTENDED:
> +		if ((*argc) < 2)
> +			return 1;
> +
> +		/* index */
> +		index = strtoul((*argv)[0], &end, 0);
> +		if (*end != '\0')
> +			return 1;
> +
> +		if (index > UINT8_MAX)
> +			return 1;
> +
> +		(*argc)--;
> +		(*argv)++;
> +
> +		/* source_extended */
> +		extended_addr = strtoull((*argv)[0], &end, 0);
> +		if (*end != '\0')
> +			return 1;
> +
> +		key_id_msg = nlmsg_alloc();
> +		if (!key_id_msg)
> +			return -ENOMEM;
> +
> +		NLA_PUT_U8(key_id_msg, NL802154_KEY_ID_ATTR_INDEX, index);
> +		NLA_PUT_U64(key_id_msg, NL802154_KEY_ID_ATTR_SOURCE_EXTENDED,
> +			    htole64(extended_addr));
> +		break;
> +	default:
> +		return 1;
> +	}
> +
> +	NLA_PUT_U32(key_id_msg, NL802154_KEY_ID_ATTR_MODE, key_mode);
> +	nla_put_nested(msg, attrtype, key_id_msg);
> +
> +	nlmsg_free(key_id_msg);
> +
> +	return 0;
> +
> +nla_put_failure:
> +	if (!dev_addr_msg)
> +		nlmsg_free(dev_addr_msg);
> +
> +	nlmsg_free(key_id_msg);
> +	return -ENOBUFS;
> +}
> +
> +static int handle_out_key_id_set(struct nl802154_state *state, struct nl_cb *cb,
> +				 struct nl_msg *msg, int argc, char **argv,
> +				 enum id_input id)
> +{
> +	return handle_parse_key_id(msg, NL802154_ATTR_SEC_OUT_KEY_ID, &argc, &argv);
> +
> +}
> +COMMAND(set, out_key_id,
> +	"<0 <pan_id> <2 <short_addr>|3 <extended_addr>>>|"
> +	"<1 <index>>|"
> +	"<2 <index> <source_short>>|"
> +	"<3 <index> <source_extended>>",

What are these extra >>| for ?

> +	NL802154_CMD_SET_SEC_PARAMS, 0, CIB_NETDEV,
> +	handle_out_key_id_set, NULL);
> +
> +static int handle_out_seclevel_set(struct nl802154_state *state, struct nl_cb *cb,
> +				   struct nl_msg *msg, int argc, char **argv,
> +				   enum id_input id)
> +{
> +	unsigned long seclevel;
> +	char *end;
> +
> +	if (argc < 1)
> +		return 1;
> +
> +	/* seclevel */
> +	seclevel = strtoul(argv[0], &end, 0);
> +	if (*end != '\0')
> +		return 1;
> +
> +	NLA_PUT_U32(msg, NL802154_ATTR_SEC_OUT_LEVEL, seclevel);
> +
> +	return 0;
> +
> +nla_put_failure:
> +	return -ENOBUFS;
> +}
> +COMMAND(set, out_level, "<out_level>", NL802154_CMD_SET_SEC_PARAMS, 0, CIB_NETDEV,
> +	handle_out_seclevel_set, NULL);
> +
> +static int handle_frame_counter_set(struct nl802154_state *state, struct nl_cb *cb,
> +				   struct nl_msg *msg, int argc, char **argv,
> +				   enum id_input id)
> +{
> +	unsigned long frame_counter;
> +	char *end;
> +
> +	/* frame_counter */

This command and the other above (index, etc) which just state the 
variable name below are not really needed as they give no extra 
information imho.
> +	frame_counter = strtoul(argv[0], &end, 0);
> +	if (*end != '\0')
> +		return 1;
> +
> +	NLA_PUT_U32(msg, NL802154_ATTR_SEC_FRAME_COUNTER, htobe32(frame_counter));
> +
> +	return 0;
> +
> +nla_put_failure:
> +	return -ENOBUFS;
> +}
> +COMMAND(set, frame_counter, "<frame_counter>", NL802154_CMD_SET_SEC_PARAMS, 0, CIB_NETDEV,
> +	handle_frame_counter_set, NULL);
> +
> +SECTION(seclevel);
> +
> +static int print_seclevel_handler(struct nl_msg *msg, void *arg)
> +{
> +	struct nlattr *tb[NL802154_ATTR_MAX + 1];
> +	struct genlmsghdr *gnlh = nlmsg_data(nlmsg_hdr(msg));
> +
> +	nla_parse(tb, NL802154_ATTR_MAX, genlmsg_attrdata(gnlh, 0),
> +		  genlmsg_attrlen(gnlh, 0), NULL);
> +
> +	if (tb[NL802154_ATTR_SEC_LEVEL]) {
> +		struct nlattr *tb_seclevel[NL802154_SECLEVEL_ATTR_MAX + 1];
> +		static struct nla_policy seclevel_policy[NL802154_SECLEVEL_ATTR_MAX + 1] = {
> +			[NL802154_SECLEVEL_ATTR_LEVELS] = { .type = NLA_U32 },
> +			[NL802154_SECLEVEL_ATTR_FRAME] = { .type = NLA_U32 },
> +			[NL802154_SECLEVEL_ATTR_CMD_FRAME] = { .type = NLA_U32 },
> +			[NL802154_SECLEVEL_ATTR_DEV_OVERRIDE] = { .type = NLA_U8 },
> +		};
> +
> +		if (nla_parse_nested(tb_seclevel, NL802154_SECLEVEL_ATTR_MAX,
> +				     tb[NL802154_ATTR_SEC_LEVEL],
> +				     seclevel_policy)) {
> +			fprintf(stderr, "failed to parse nested attributes!\n");
> +			return NL_SKIP;
> +		}
> +
> +		printf("iwpan dev $WPAN_DEV seclevel add ");
> +
> +		if (tb_seclevel[NL802154_SECLEVEL_ATTR_LEVELS])
> +			printf("0x%02lx ", nla_get_u8(tb_seclevel[NL802154_SECLEVEL_ATTR_LEVELS]));
> +		if (tb_seclevel[NL802154_SECLEVEL_ATTR_FRAME])
> +			printf("%d ", nla_get_u32(tb_seclevel[NL802154_SECLEVEL_ATTR_FRAME]));
> +		if (tb_seclevel[NL802154_SECLEVEL_ATTR_CMD_FRAME])
> +			printf("%d ", nla_get_u32(tb_seclevel[NL802154_SECLEVEL_ATTR_CMD_FRAME]));
> +		if (tb_seclevel[NL802154_SECLEVEL_ATTR_DEV_OVERRIDE])
> +			printf("%d ", nla_get_u8(tb_seclevel[NL802154_SECLEVEL_ATTR_DEV_OVERRIDE]));
> +	}
> +
> +	printf("\n");
> +
> +	return NL_SKIP;
> +}
> +
> +static int handle_seclevel_dump(struct nl802154_state *state,
> +				struct nl_cb *cb,
> +				struct nl_msg *msg,
> +				int argc, char **argv,
> +				enum id_input id)
> +{
> +	nl_cb_set(cb, NL_CB_VALID, NL_CB_CUSTOM, print_seclevel_handler, NULL);
> +	return 0;
> +}
> +COMMAND(seclevel, dump, NULL,
> +	NL802154_CMD_GET_SEC_LEVEL, NLM_F_DUMP, CIB_NETDEV, handle_seclevel_dump,
> +	NULL);
> +
> +static int handle_seclevel_add(struct nl802154_state *state, struct nl_cb *cb,
> +			       struct nl_msg *msg, int argc, char **argv,
> +			       enum id_input id)
> +{
> +	struct nl_msg *seclevel_msg;
> +	unsigned long levels, frame, cmd_id, dev_override;
> +	char *end;
> +
> +	if (argc < 1)
> +		return 1;
> +
> +	/* levels */
> +	levels = strtoul(argv[0], &end, 0);
> +	if (*end != '\0')
> +		return 1;
> +
> +	argc--;
> +	argv++;
> +
> +	if (argc < 1)
> +		return 1;
> +
> +	/* frame */
> +	frame = strtoul(argv[0], &end, 0);
> +	if (*end != '\0')
> +		return 1;
> +
> +	if (frame == NL802154_FRAME_CMD) {
> +		argc--;
> +		argv++;
> +
> +		if (argc < 1)
> +			return 1;
> +
> +		/* cmd_frame */
> +		cmd_id = strtoul(argv[0], &end, 0);
> +		if (*end != '\0')
> +			return 1;
> +	}
> +
> +	argc--;
> +	argv++;
> +
> +	if (argc < 1)
> +		return 1;
> +
> +	/* dev_override */
> +	dev_override = strtoul(argv[0], &end, 0);
> +	if (*end != '\0')
> +		return 1;
> +
> +	if (dev_override > UINT8_MAX)
> +		return 1;
> +
> +	seclevel_msg = nlmsg_alloc();
> +	if (!seclevel_msg)
> +		return -ENOMEM;
> +
> +	NLA_PUT_U32(seclevel_msg, NL802154_SECLEVEL_ATTR_LEVELS, levels);
> +	NLA_PUT_U32(seclevel_msg, NL802154_SECLEVEL_ATTR_FRAME, frame);
> +	if (frame == NL802154_FRAME_CMD)
> +		NLA_PUT_U32(seclevel_msg, NL802154_SECLEVEL_ATTR_CMD_FRAME, cmd_id);
> +	NLA_PUT_U8(seclevel_msg, NL802154_SECLEVEL_ATTR_DEV_OVERRIDE, dev_override);
> +
> +	nla_put_nested(msg, NL802154_ATTR_SEC_LEVEL, seclevel_msg);
> +	nlmsg_free(seclevel_msg);
> +
> +	return 0;
> +
> +nla_put_failure:
> +	nlmsg_free(seclevel_msg);
> +	return -ENOBUFS;
> +}
> +COMMAND(seclevel, add, "<levels> <frame_type|3 <cmd_id>> <dev_override>", NL802154_CMD_NEW_SEC_LEVEL, 0, CIB_NETDEV,
> +	handle_seclevel_add, NULL);
> +COMMAND(seclevel, del, "<levels> <frame_type|3 <cmd_id>> <dev_override>", NL802154_CMD_DEL_SEC_LEVEL, 0, CIB_NETDEV,
> +	handle_seclevel_add, NULL);
> +
> +SECTION(device);
> +
> +static int print_device_handler(struct nl_msg *msg, void *arg)
> +{
> +	struct nlattr *tb[NL802154_ATTR_MAX + 1];
> +	struct genlmsghdr *gnlh = nlmsg_data(nlmsg_hdr(msg));
> +
> +	nla_parse(tb, NL802154_ATTR_MAX, genlmsg_attrdata(gnlh, 0),
> +		  genlmsg_attrlen(gnlh, 0), NULL);
> +
> +	if (tb[NL802154_ATTR_SEC_DEVICE]) {
> +		struct nlattr *tb_device[NL802154_DEV_ATTR_MAX + 1];
> +		static struct nla_policy device_policy[NL802154_DEV_ATTR_MAX + 1] = {
> +			[NL802154_DEV_ATTR_FRAME_COUNTER] = { NLA_U32 },
> +			[NL802154_DEV_ATTR_PAN_ID] = { .type = NLA_U16 },
> +			[NL802154_DEV_ATTR_SHORT_ADDR] = { .type = NLA_U16 },
> +			[NL802154_DEV_ATTR_EXTENDED_ADDR] = { .type = NLA_U64 },
> +			[NL802154_DEV_ATTR_SECLEVEL_EXEMPT] = { NLA_U8 },
> +			[NL802154_DEV_ATTR_KEY_MODE] = { NLA_U32 },
> +		};
> +
> +		if (nla_parse_nested(tb_device, NL802154_DEV_ATTR_MAX,
> +				     tb[NL802154_ATTR_SEC_DEVICE],
> +				     device_policy)) {
> +			fprintf(stderr, "failed to parse nested attributes!\n");
> +			return NL_SKIP;
> +		}
> +
> +		printf("iwpan dev $WPAN_DEV device add ");
> +
> +		if (tb_device[NL802154_DEV_ATTR_FRAME_COUNTER])
> +			printf("0x%08lx ", nla_get_u32(tb_device[NL802154_DEV_ATTR_FRAME_COUNTER]));
> +		if (tb_device[NL802154_DEV_ATTR_PAN_ID])
> +			printf("0x%04lx ", le16toh(nla_get_u16(tb_device[NL802154_DEV_ATTR_PAN_ID])));
> +		if (tb_device[NL802154_DEV_ATTR_SHORT_ADDR])
> +			printf("0x%04lx ", le16toh(nla_get_u16(tb_device[NL802154_DEV_ATTR_SHORT_ADDR])));
> +		if (tb_device[NL802154_DEV_ATTR_EXTENDED_ADDR])
> +			printf("0x%016" PRIx64 " ", le64toh(nla_get_u64(tb_device[NL802154_DEV_ATTR_EXTENDED_ADDR])));
> +		if (tb_device[NL802154_DEV_ATTR_SECLEVEL_EXEMPT])
> +			printf("%d ", nla_get_u8(tb_device[NL802154_DEV_ATTR_SECLEVEL_EXEMPT]));
> +		if (tb_device[NL802154_DEV_ATTR_KEY_MODE])
> +			printf("%d ", nla_get_u32(tb_device[NL802154_DEV_ATTR_KEY_MODE]));
> +	}
> +
> +	printf("\n");
> +
> +	return NL_SKIP;
> +}
> +
> +static int handle_device_dump(struct nl802154_state *state,
> +				struct nl_cb *cb,
> +				struct nl_msg *msg,
> +				int argc, char **argv,
> +				enum id_input id)
> +{
> +	nl_cb_set(cb, NL_CB_VALID, NL_CB_CUSTOM, print_device_handler, NULL);
> +	return 0;
> +}
> +COMMAND(device, dump, NULL,
> +	NL802154_CMD_GET_SEC_DEV, NLM_F_DUMP, CIB_NETDEV, handle_device_dump,
> +	NULL);
> +
> +static int handle_device_add(struct nl802154_state *state, struct nl_cb *cb,
> +			     struct nl_msg *msg, int argc, char **argv,
> +			     enum id_input id)
> +{
> +	struct nl_msg *device_msg;
> +	unsigned long long extended_addr;
> +	unsigned long frame_counter, pan_id, short_addr,
> +		      seclevel_exempt, key_mode;
> +	char *end;
> +
> +	if (argc < 1)
> +		return 1;
> +
> +	/* frame_counter */
> +	frame_counter = strtoul(argv[0], &end, 0);
> +	if (*end != '\0')
> +		return 1;
> +
> +	argc--;
> +	argv++;
> +
> +	if (argc < 1)
> +		return 1;
> +
> +	/* pan_id */
> +	pan_id = strtoul(argv[0], &end, 0);
> +	if (*end != '\0')
> +		return 1;
> +
> +	if (pan_id > UINT16_MAX)
> +		return 1;
> +
> +	argc--;
> +	argv++;
> +
> +	if (argc < 1)
> +		return 1;
> +
> +	/* short_addr */
> +	short_addr = strtoul(argv[0], &end, 0);
> +	if (*end != '\0')
> +		return 1;
> +
> +	if (short_addr > UINT16_MAX)
> +		return 1;
> +
> +	argc--;
> +	argv++;
> +
> +	if (argc < 1)
> +		return 1;
> +
> +	/* extended_addr */
> +	extended_addr = strtoull(argv[0], &end, 0);
> +	if (*end != '\0')
> +		return 1;
> +
> +	argc--;
> +	argv++;
> +
> +	if (argc < 1)
> +		return 1;
> +
> +	/* seclevel_exempt */
> +	seclevel_exempt = strtoul(argv[0], &end, 0);
> +	if (*end != '\0')
> +		return 1;
> +
> +	if (seclevel_exempt > UINT8_MAX)
> +		return 1;
> +
> +	argc--;
> +	argv++;
> +
> +	if (argc < 1)
> +		return 1;
> +
> +	/* key_mode */
> +	key_mode = strtoul(argv[0], &end, 0);
> +	if (*end != '\0')
> +		return 1;
> +
> +	device_msg = nlmsg_alloc();
> +	if (!device_msg)
> +		return -ENOMEM;
> +
> +	NLA_PUT_U32(device_msg, NL802154_DEV_ATTR_FRAME_COUNTER, frame_counter);
> +	NLA_PUT_U16(device_msg, NL802154_DEV_ATTR_PAN_ID, htole16(pan_id));
> +	NLA_PUT_U16(device_msg, NL802154_DEV_ATTR_SHORT_ADDR, htole16(short_addr));
> +	NLA_PUT_U64(device_msg, NL802154_DEV_ATTR_EXTENDED_ADDR, htole64(extended_addr));
> +	NLA_PUT_U8(device_msg, NL802154_DEV_ATTR_SECLEVEL_EXEMPT, seclevel_exempt);
> +	NLA_PUT_U32(device_msg, NL802154_DEV_ATTR_KEY_MODE, key_mode);
> +
> +	nla_put_nested(msg, NL802154_ATTR_SEC_DEVICE, device_msg);
> +	nlmsg_free(device_msg);
> +
> +	return 0;
> +
> +nla_put_failure:
> +	nlmsg_free(device_msg);
> +	return -ENOBUFS;
> +}
> +COMMAND(device, add, "<frame_counter> <pan_id> <short_addr> <extended_addr> <seclevel_exempt> <key_mode>",
> +	NL802154_CMD_NEW_SEC_DEV, 0, CIB_NETDEV, handle_device_add, NULL);
> +
> +static int handle_device_del(struct nl802154_state *state, struct nl_cb *cb,
> +			     struct nl_msg *msg, int argc, char **argv,
> +			     enum id_input id)
> +{
> +	struct nl_msg *device_msg;
> +	unsigned long long extended_addr;
> +	char *end;
> +
> +	if (argc < 1)
> +		return 1;
> +
> +	/* extended_addr */
> +	extended_addr = strtoull(argv[0], &end, 0);
> +	if (*end != '\0')
> +		return 1;
> +
> +	device_msg = nlmsg_alloc();
> +	if (!device_msg)
> +		return -ENOMEM;
> +
> +	NLA_PUT_U64(device_msg, NL802154_DEV_ATTR_EXTENDED_ADDR, htole64(extended_addr));
> +
> +	nla_put_nested(msg, NL802154_ATTR_SEC_DEVICE, device_msg);
> +	nlmsg_free(device_msg);
> +
> +	return 0;
> +
> +nla_put_failure:
> +	nlmsg_free(device_msg);
> +	return -ENOBUFS;
> +}
> +COMMAND(device, del, "<extended_addr>",
> +	NL802154_CMD_DEL_SEC_DEV, 0, CIB_NETDEV, handle_device_del, NULL);
> +
> +SECTION(devkey);
> +
> +static int print_key_id(struct nlattr *tb) {
> +	struct nlattr *tb_key_id[NL802154_KEY_ID_ATTR_MAX + 1];
> +	static struct nla_policy key_id_policy[NL802154_KEY_ID_ATTR_MAX + 1] = {
> +		[NL802154_KEY_ID_ATTR_MODE] = { .type = NLA_U32 },
> +		[NL802154_KEY_ID_ATTR_INDEX] = { .type = NLA_U8 },
> +		[NL802154_KEY_ID_ATTR_IMPLICIT] = { .type = NLA_NESTED },
> +		[NL802154_KEY_ID_ATTR_SOURCE_SHORT] = { .type = NLA_U32 },
> +		[NL802154_KEY_ID_ATTR_SOURCE_EXTENDED] = { .type = NLA_U64 },
> +	};
> +
> +	nla_parse_nested(tb_key_id, NL802154_KEY_ID_ATTR_MAX, tb, key_id_policy);
> +
> +	if (tb_key_id[NL802154_KEY_ID_ATTR_MODE]) {
> +		enum nl802154_key_id_modes key_id_mode;
> +
> +		key_id_mode = nla_get_u32(tb_key_id[NL802154_KEY_ID_ATTR_MODE]);
> +		printf("%d ", key_id_mode);
> +		switch (key_id_mode) {
> +		case NL802154_KEY_ID_MODE_IMPLICIT:
> +			if (tb_key_id[NL802154_KEY_ID_ATTR_IMPLICIT]) {
> +				struct nlattr *tb_dev_addr[NL802154_DEV_ADDR_ATTR_MAX + 1];
> +				static struct nla_policy dev_addr_policy[NL802154_DEV_ADDR_ATTR_MAX + 1] = {
> +					[NL802154_DEV_ADDR_ATTR_PAN_ID] = { .type = NLA_U16 },
> +					[NL802154_DEV_ADDR_ATTR_MODE] = { .type = NLA_U32 },
> +					[NL802154_DEV_ADDR_ATTR_SHORT] = { .type = NLA_U16 },
> +					[NL802154_DEV_ADDR_ATTR_EXTENDED] = { .type = NLA_U64 },
> +				};
> +
> +				nla_parse_nested(tb_dev_addr, NL802154_DEV_ADDR_ATTR_MAX,
> +						 tb_key_id[NL802154_KEY_ID_ATTR_IMPLICIT],
> +						 dev_addr_policy);
> +
> +				if (tb_dev_addr[NL802154_DEV_ADDR_ATTR_PAN_ID])
> +					printf("0x%04x ",
> +					       le16toh(nla_get_u16(tb_dev_addr[NL802154_DEV_ADDR_ATTR_PAN_ID])));
> +
> +				if (tb_dev_addr[NL802154_DEV_ADDR_ATTR_MODE]) {
> +					enum nl802154_dev_addr_modes dev_addr_mode;
> +					dev_addr_mode = nla_get_u32(tb_dev_addr[NL802154_DEV_ADDR_ATTR_MODE]);
> +					printf("%d ", dev_addr_mode);
> +					switch (dev_addr_mode) {
> +					case NL802154_DEV_ADDR_SHORT:
> +						printf("0x%04x ",
> +						       le16toh(nla_get_u16(tb_dev_addr[NL802154_DEV_ADDR_ATTR_SHORT])));
> +						break;
> +					case NL802154_DEV_ADDR_EXTENDED:
> +						printf("0x%016" PRIx64 " ",
> +						       le64toh(nla_get_u64(tb_dev_addr[NL802154_DEV_ADDR_ATTR_SHORT])));
> +						break;
> +					default:
> +						/* TODO error handling */
> +						break;
> +					}
> +				}
> +			}
> +			break;
> +		case NL802154_KEY_ID_MODE_INDEX:
> +			if (tb_key_id[NL802154_KEY_ID_ATTR_INDEX])
> +				printf("0x%02x ",
> +				       nla_get_u8(tb_key_id[NL802154_KEY_ID_ATTR_INDEX]));
> +			break;
> +		case NL802154_KEY_ID_MODE_INDEX_SHORT:
> +			if (tb_key_id[NL802154_KEY_ID_ATTR_INDEX])
> +				printf("0x%02x ",
> +				       nla_get_u8(tb_key_id[NL802154_KEY_ID_ATTR_INDEX]));
> +
> +			if (tb_key_id[NL802154_KEY_ID_ATTR_SOURCE_SHORT])
> +				printf("0x%08lx ",
> +				       le32toh(nla_get_u32(tb_key_id[NL802154_KEY_ID_ATTR_SOURCE_SHORT])));
> +			break;
> +		case NL802154_KEY_ID_MODE_INDEX_EXTENDED:
> +			if (tb_key_id[NL802154_KEY_ID_ATTR_INDEX])
> +				printf("0x%02x ",
> +				       nla_get_u8(tb_key_id[NL802154_KEY_ID_ATTR_INDEX]));
> +
> +			if (tb_key_id[NL802154_KEY_ID_ATTR_SOURCE_EXTENDED])
> +				printf("0x%016" PRIx64 " ",
> +				       le64toh(nla_get_u64(tb_key_id[NL802154_KEY_ID_ATTR_SOURCE_EXTENDED])));
> +			break;
> +		default:
> +			/* TODO error handling */
> +			return 0;
> +		}
> +	}
> +
> +	return 0;
> +}
> +
> +static int print_devkey_handler(struct nl_msg *msg, void *arg)
> +{
> +	struct nlattr *tb[NL802154_ATTR_MAX + 1];
> +	struct genlmsghdr *gnlh = nlmsg_data(nlmsg_hdr(msg));
> +
> +	nla_parse(tb, NL802154_ATTR_MAX, genlmsg_attrdata(gnlh, 0),
> +		  genlmsg_attrlen(gnlh, 0), NULL);
> +
> +	if (tb[NL802154_ATTR_SEC_DEVKEY]) {
> +		struct nlattr *tb_devkey[NL802154_DEVKEY_ATTR_MAX + 1];
> +		static struct nla_policy devkey_policy[NL802154_DEVKEY_ATTR_MAX + 1] = {
> +			[NL802154_DEVKEY_ATTR_FRAME_COUNTER] = { NLA_U32 },
> +			[NL802154_DEVKEY_ATTR_EXTENDED_ADDR] = { .type = NLA_U64 },
> +			[NL802154_DEVKEY_ATTR_ID] = { .type = NLA_NESTED },
> +		};
> +
> +		if (nla_parse_nested(tb_devkey, NL802154_DEVKEY_ATTR_MAX,
> +				     tb[NL802154_ATTR_SEC_DEVKEY],
> +				     devkey_policy)) {
> +			fprintf(stderr, "failed to parse nested attributes!\n");
> +			return NL_SKIP;
> +		}
> +
> +		printf("iwpan dev $WPAN_DEV devkey add ");
> +
> +		if (tb_devkey[NL802154_DEV_ATTR_FRAME_COUNTER])
> +			printf("0x%08lx ", nla_get_u32(tb_devkey[NL802154_DEVKEY_ATTR_FRAME_COUNTER]));
> +		if (tb_devkey[NL802154_DEVKEY_ATTR_EXTENDED_ADDR])
> +			printf("0x%016" PRIx64 " ", le64toh(nla_get_u64(tb_devkey[NL802154_DEVKEY_ATTR_EXTENDED_ADDR])));
> +
> +		if (tb_devkey[NL802154_DEVKEY_ATTR_ID])
> +			print_key_id(tb_devkey[NL802154_DEVKEY_ATTR_ID]);
> +	}
> +
> +	printf("\n");
> +
> +	return NL_SKIP;
> +}
> +
> +static int handle_devkey_dump(struct nl802154_state *state,
> +				struct nl_cb *cb,
> +				struct nl_msg *msg,
> +				int argc, char **argv,
> +				enum id_input id)
> +{
> +	nl_cb_set(cb, NL_CB_VALID, NL_CB_CUSTOM, print_devkey_handler, NULL);
> +	return 0;
> +}
> +COMMAND(devkey, dump, NULL,
> +	NL802154_CMD_GET_SEC_DEVKEY, NLM_F_DUMP, CIB_NETDEV, handle_devkey_dump,
> +	NULL);
> +
> +static int handle_devkey_add(struct nl802154_state *state, struct nl_cb *cb,
> +			     struct nl_msg *msg, int argc, char **argv,
> +			     enum id_input id)
> +{
> +	struct nl_msg *devkey_msg = NULL;
> +	unsigned long long extended_addr;
> +	unsigned long frame_counter;
> +	char *end;
> +	int ret;
> +
> +	if (argc < 1)
> +		return 1;
> +
> +	/* frame_counter */
> +	frame_counter = strtoul(argv[0], &end, 0);
> +	if (*end != '\0')
> +		return 1;
> +
> +	argc--;
> +	argv++;
> +
> +	if (argc < 1)
> +		return 1;
> +
> +	/* extended_addr */
> +	extended_addr = strtoull(argv[0], &end, 0);
> +	if (*end != '\0')
> +		return 1;
> +
> +	argc--;
> +	argv++;
> +
> +	devkey_msg = nlmsg_alloc();
> +	if (!devkey_msg)
> +		return -ENOMEM;
> +
> +	NLA_PUT_U32(devkey_msg, NL802154_DEVKEY_ATTR_FRAME_COUNTER, frame_counter);
> +	NLA_PUT_U64(devkey_msg, NL802154_DEVKEY_ATTR_EXTENDED_ADDR, htole64(extended_addr));
> +
> +	ret = handle_parse_key_id(devkey_msg, NL802154_DEVKEY_ATTR_ID, &argc, &argv);
> +	if (ret) {
> +		nlmsg_free(devkey_msg);
> +		return ret;
> +	}
> +
> +	nla_put_nested(msg, NL802154_ATTR_SEC_DEVKEY, devkey_msg);
> +	nlmsg_free(devkey_msg);
> +
> +	return 0;
> +
> +nla_put_failure:
> +	nlmsg_free(devkey_msg);
> +	return -ENOBUFS;
> +
> +}
> +COMMAND(devkey, add, "<frame_counter> <extended_addr> "
> +	"<0 <pan_id> <2 <short_addr>|3 <extended_addr>>>|"
> +	"<1 <index>>|"
> +	"<2 <index> <source_short>>|"
> +	"<3 <index> <source_extended>>",
> +	NL802154_CMD_NEW_SEC_DEVKEY, 0, CIB_NETDEV, handle_devkey_add, NULL);
> +
> +static int handle_devkey_del(struct nl802154_state *state, struct nl_cb *cb,
> +			     struct nl_msg *msg, int argc, char **argv,
> +			     enum id_input id)
> +{
> +	struct nl_msg *devkey_msg = NULL;
> +	unsigned long long extended_addr;
> +	char *end;
> +	int ret;
> +
> +	if (argc < 1)
> +		return 1;
> +
> +	/* extended_addr */
> +	extended_addr = strtoull(argv[0], &end, 0);
> +	if (*end != '\0')
> +		return 1;
> +
> +	argc--;
> +	argv++;
> +
> +	devkey_msg = nlmsg_alloc();
> +	if (!devkey_msg)
> +		return -ENOMEM;
> +
> +	NLA_PUT_U64(devkey_msg, NL802154_DEVKEY_ATTR_EXTENDED_ADDR, htole64(extended_addr));
> +
> +	ret = handle_parse_key_id(devkey_msg, NL802154_DEVKEY_ATTR_ID, &argc, &argv);
> +	if (ret) {
> +		nlmsg_free(devkey_msg);
> +		return ret;
> +	}
> +
> +	nla_put_nested(msg, NL802154_ATTR_SEC_DEVKEY, devkey_msg);
> +	nlmsg_free(devkey_msg);
> +
> +	return 0;
> +
> +nla_put_failure:
> +	nlmsg_free(devkey_msg);
> +	return -ENOBUFS;
> +
> +}
> +COMMAND(devkey, del, "<extended_addr> "
> +	"<0 <pan_id> <2 <short_addr>|3 <extended_addr>>>|"
> +	"<1 <index>>|"
> +	"<2 <index> <source_short>>|"
> +	"<3 <index> <source_extended>>",
> +	NL802154_CMD_DEL_SEC_DEVKEY, 0, CIB_NETDEV, handle_devkey_del, NULL);
> +
> +SECTION(key);
> +
> +static void key_to_str(char *key, unsigned char *arg)
> +{
> +	int i, l;
> +
> +	l = 0;
> +	for (i = 0; i < NL802154_KEY_SIZE ; i++) {
> +		if (i == 0) {
> +			sprintf(key+l, "%02x", arg[i]);
> +			l += 2;
> +		} else {
> +			sprintf(key+l, ":%02x", arg[i]);
> +			l += 3;
> +		}
> +	}
> +}
> +
> +static int print_key_handler(struct nl_msg *msg, void *arg)
> +{
> +	struct nlattr *tb[NL802154_ATTR_MAX + 1];
> +	struct genlmsghdr *gnlh = nlmsg_data(nlmsg_hdr(msg));
> +
> +	nla_parse(tb, NL802154_ATTR_MAX, genlmsg_attrdata(gnlh, 0),
> +		  genlmsg_attrlen(gnlh, 0), NULL);
> +
> +	if (tb[NL802154_ATTR_SEC_KEY]) {
> +		struct nlattr *tb_key[NL802154_KEY_ATTR_MAX + 1];
> +		static struct nla_policy key_policy[NL802154_KEY_ATTR_MAX + 1] = {
> +			[NL802154_KEY_ATTR_ID] = { NLA_NESTED },
> +			[NL802154_KEY_ATTR_USAGE_FRAMES] = { NLA_U8 },
> +			[NL802154_KEY_ATTR_USAGE_CMDS] = { .minlen = NL802154_CMD_FRAME_NR_IDS / 8 },
> +			[NL802154_KEY_ATTR_BYTES] = { .minlen = NL802154_KEY_SIZE },
> +		};
> +
> +		if (nla_parse_nested(tb_key, NL802154_KEY_ATTR_MAX,
> +				     tb[NL802154_ATTR_SEC_KEY],
> +				     key_policy)) {
> +			fprintf(stderr, "failed to parse nested attributes!\n");
> +			return NL_SKIP;
> +		}
> +
> +		printf("iwpan dev $WPAN_DEV key add ");
> +
> +		if (tb_key[NL802154_KEY_ATTR_USAGE_FRAMES])
> +			printf("0x%02x ", nla_get_u8(tb_key[NL802154_KEY_ATTR_USAGE_FRAMES]));
> +
> +		if (tb_key[NL802154_KEY_ATTR_USAGE_CMDS]) {
> +			uint32_t cmds[NL802154_CMD_FRAME_NR_IDS / 32];
> +
> +			nla_memcpy(cmds, tb_key[NL802154_KEY_ATTR_USAGE_CMDS],
> +				   NL802154_CMD_FRAME_NR_IDS / 8);
> +			printf("0x%08x ", cmds[7]);
> +		}
> +
> +		if (tb_key[NL802154_KEY_ATTR_BYTES]) {
> +			uint8_t key[NL802154_KEY_SIZE];
> +			char key_str[512] = "";
> +
> +			nla_memcpy(key, tb_key[NL802154_KEY_ATTR_BYTES],
> +				   NL802154_KEY_SIZE);
> +
> +			key_to_str(key_str, key);
> +			printf("%s ", key_str);
> +		}
> +
> +		if (tb_key[NL802154_KEY_ATTR_ID])
> +			print_key_id(tb_key[NL802154_KEY_ATTR_ID]);
> +	}
> +
> +	printf("\n");
> +
> +	return NL_SKIP;
> +}
> +
> +static int handle_key_dump(struct nl802154_state *state,
> +			   struct nl_cb *cb,
> +			   struct nl_msg *msg,
> +			   int argc, char **argv,
> +			   enum id_input id)
> +{
> +	nl_cb_set(cb, NL_CB_VALID, NL_CB_CUSTOM, print_key_handler, NULL);
> +	return 0;
> +}
> +COMMAND(key, dump, NULL,
> +	NL802154_CMD_GET_SEC_KEY, NLM_F_DUMP, CIB_NETDEV, handle_key_dump,
> +	NULL);
> +
> +#define BIT(x)  (1 << (x))
> +
> +static int str_to_key(unsigned char *key, char *arg)
> +{
> +	int i;
> +
> +	for (i = 0; i < NL802154_KEY_SIZE; i++) {
> +		int temp;
> +		char *cp = strchr(arg, ':');
> +		if (cp) {
> +			*cp = 0;
> +			cp++;
> +		}
> +		if (sscanf(arg, "%x", &temp) != 1)
> +			return -1;
> +		if (temp < 0 || temp > 255)
> +			return -1;
> +
> +		key[i] = temp;
> +		if (!cp)
> +			break;
> +		arg = cp;
> +	}
> +	if (i < NL802154_KEY_SIZE - 1)
> +		return -1;
> +
> +	return 0;
> +}
> +
> +static int handle_key_add(struct nl802154_state *state, struct nl_cb *cb,
> +			     struct nl_msg *msg, int argc, char **argv,
> +			     enum id_input id)
> +{
> +	struct nl_msg *key_msg = NULL;
> +	uint8_t key_bytes[NL802154_KEY_SIZE] = { };
> +	uint32_t commands[NL802154_CMD_FRAME_NR_IDS / 32] = { };
> +	unsigned long tmp;
> +	char *end;
> +	int ret, i;
> +
> +	key_msg = nlmsg_alloc();
> +	if (!key_msg)
> +		return -ENOMEM;
> +
> +	if (argc < 1) {
> +		nlmsg_free(key_msg);
> +		return 1;
> +	}
> +
> +	/* frame_types */
> +	tmp = strtoul(argv[0], &end, 0);
> +	if (*end != '\0') {
> +		nlmsg_free(key_msg);
> +		return 1;
> +	}
> +
> +	if (tmp > UINT8_MAX) {
> +		nlmsg_free(key_msg);
> +		return 1;
> +	}
> +
> +	NLA_PUT_U8(key_msg, NL802154_KEY_ATTR_USAGE_FRAMES, tmp);
> +
> +	argc--;
> +	argv++;
> +
> +	if (tmp & BIT(NL802154_FRAME_CMD)) {
> +		if (argc < 1) {
> +			nlmsg_free(key_msg);
> +			return 1;
> +		}
> +
> +		/* commands[7] */
> +		commands[7] = strtoul(argv[0], &end, 0);
> +		if (*end != '\0') {
> +			nlmsg_free(key_msg);
> +			return 1;
> +		}
> +
> +		NLA_PUT(key_msg, NL802154_KEY_ATTR_USAGE_CMDS,
> +			NL802154_CMD_FRAME_NR_IDS / 8, commands);
> +
> +		argc--;
> +		argv++;
> +	}
> +
> +	if (argc < 1) {
> +		nlmsg_free(key_msg);
> +		return 1;
> +	}
> +
> +	str_to_key(key_bytes, argv[0]);
> +
> +	NLA_PUT(key_msg, NL802154_KEY_ATTR_BYTES, NL802154_KEY_SIZE, key_bytes);
> +
> +	argc--;
> +	argv++;
> +
> +	ret = handle_parse_key_id(key_msg, NL802154_KEY_ATTR_ID, &argc, &argv);
> +	if (ret) {
> +		nlmsg_free(key_msg);
> +		return ret;
> +	}
> +
> +	nla_put_nested(msg, NL802154_ATTR_SEC_KEY, key_msg);
> +	nlmsg_free(key_msg);
> +
> +	return 0;
> +
> +nla_put_failure:
> +	nlmsg_free(key_msg);
> +	return -ENOBUFS;
> +
> +}
> +COMMAND(key, add, "<frame_types <if 0x4 is set commands[7]>>> <key <hex as 00:11:..>> "
> +	"<0 <pan_id> <2 <short_addr>|3 <extended_addr>>>|"
> +	"<1 <index>>|"
> +	"<2 <index> <source_short>>|"
> +	"<3 <index> <source_extended>>",
> +	NL802154_CMD_NEW_SEC_KEY, 0, CIB_NETDEV, handle_key_add, NULL);
> +
> +static int handle_key_del(struct nl802154_state *state, struct nl_cb *cb,
> +			     struct nl_msg *msg, int argc, char **argv,
> +			     enum id_input id)
> +{
> +	struct nl_msg *key_msg = NULL;
> +	int ret;
> +
> +	key_msg = nlmsg_alloc();
> +	if (!key_msg)
> +		return -ENOMEM;
> +
> +	ret = handle_parse_key_id(key_msg, NL802154_KEY_ATTR_ID, &argc, &argv);
> +	if (ret) {
> +		nlmsg_free(key_msg);
> +		return ret;
> +	}
> +
> +	nla_put_nested(msg, NL802154_ATTR_SEC_KEY, key_msg);
> +	nlmsg_free(key_msg);
> +
> +	return 0;
> +
> +nla_put_failure:
> +	nlmsg_free(key_msg);
> +	return -ENOBUFS;
> +
> +}
> +COMMAND(key, del,
> +	"<0 <pan_id> <2 <short_addr>|3 <extended_addr>>>|"
> +	"<1 <index>>|"
> +	"<2 <index> <source_short>>|"
> +	"<3 <index> <source_extended>>",
> +	NL802154_CMD_DEL_SEC_KEY, 0, CIB_NETDEV, handle_key_del, NULL);

regards
Stefan Schmidt
