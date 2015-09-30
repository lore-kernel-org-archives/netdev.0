From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH wpan-tools 1/2] security: add nl802154 security support
Date: Wed, 30 Sep 2015 19:46:08 +0200
Message-ID: <20150930174604.GA1246@omega>
References: <1443425134-27910-1-git-send-email-alex.aring@gmail.com>
 <560BF5C6.9090506@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-wpan@vger.kernel.org, kernel@pengutronix.de,
	netdev@vger.kernel.org, phoebe.buckheister@itwm.fraunhofer.de
To: Stefan Schmidt <stefan@osg.samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:32937 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753913AbbI3RqS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 13:46:18 -0400
Content-Disposition: inline
In-Reply-To: <560BF5C6.9090506@osg.samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Sep 30, 2015 at 04:46:30PM +0200, Stefan Schmidt wrote:
> Hello.
> 
> A really huge patch. I will start on it. Not sure I can do a full review in
> one go though.
> 
> On 28/09/15 09:25, Alexander Aring wrote:
> >This patch introduce support for the experimental seucirty support for
> 
> Type. Security.
> >nl802154. We currently support add/del settings for manipulating
> >security table entries. The dump functionality is a "really" keep it
> 
> is really a
> >short and stupid handling, the dump will printout the printout the right
> 
> dump will printout the right calls to add the entry

ok.

> >add calls which was called to add the entry. This can be used for
> >storing the current security tables by some script. The interface
> >argument is replaced by $WPAN_DEV variable, so it's possible to move one
> >interface configuration to another one.
> >
> >Signed-off-by: Alexander Aring <alex.aring@gmail.com>
> >---
> >  src/Makefile.am |    1 +
> >  src/interface.c |  100 +++++
> >  src/nl802154.h  |  191 ++++++++++
> >  src/security.c  | 1118 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
> >  4 files changed, 1410 insertions(+)
> >  create mode 100644 src/security.c
> >
> >diff --git a/src/Makefile.am b/src/Makefile.am
> >index 2d54576..b2177a2 100644
> >--- a/src/Makefile.am
> >+++ b/src/Makefile.am
> >@@ -9,6 +9,7 @@ iwpan_SOURCES = \
> >  	interface.c \
> >  	phy.c \
> >  	mac.c \
> >+	security.c \
> >  	nl_extras.h \
> >  	nl802154.h
> >diff --git a/src/interface.c b/src/interface.c
> >index 85d40a8..076e7c3 100644
> >--- a/src/interface.c
> >+++ b/src/interface.c
> >@@ -10,6 +10,7 @@
> >  #include <netlink/msg.h>
> >  #include <netlink/attr.h>
> >+#define CONFIG_IEEE802154_NL802154_EXPERIMENTAL
> >  #include "nl802154.h"
> >  #include "nl_extras.h"
> >  #include "iwpan.h"
> >@@ -226,6 +227,105 @@ static int print_iface_handler(struct nl_msg *msg, void *arg)
> >  	if (tb_msg[NL802154_ATTR_ACKREQ_DEFAULT])
> >  		printf("%s\tackreq_default %d\n", indent, nla_get_u8(tb_msg[NL802154_ATTR_ACKREQ_DEFAULT]));
> >+	if (tb_msg[NL802154_ATTR_SEC_ENABLED])
> >+		printf("%s\tsecurity %d\n", indent, nla_get_u8(tb_msg[NL802154_ATTR_SEC_ENABLED]));
> >+	if (tb_msg[NL802154_ATTR_SEC_OUT_LEVEL])
> >+		printf("%s\tout_level %d\n", indent, nla_get_u8(tb_msg[NL802154_ATTR_SEC_OUT_LEVEL]));
> >+	if (tb_msg[NL802154_ATTR_SEC_OUT_KEY_ID]) {
> >+		struct nlattr *tb_key_id[NL802154_KEY_ID_ATTR_MAX + 1];
> >+		static struct nla_policy key_id_policy[NL802154_KEY_ID_ATTR_MAX + 1] = {
> >+		        [NL802154_KEY_ID_ATTR_MODE] = { .type = NLA_U32 },
> >+		        [NL802154_KEY_ID_ATTR_INDEX] = { .type = NLA_U8 },
> >+		        [NL802154_KEY_ID_ATTR_IMPLICIT] = { .type = NLA_NESTED },
> >+		        [NL802154_KEY_ID_ATTR_SOURCE_SHORT] = { .type = NLA_U32 },
> >+		        [NL802154_KEY_ID_ATTR_SOURCE_EXTENDED] = { .type = NLA_U64 },
> >+		};
> >+
> >+		nla_parse_nested(tb_key_id, NL802154_KEY_ID_ATTR_MAX,
> >+				 tb_msg[NL802154_ATTR_SEC_OUT_KEY_ID], key_id_policy);
> >+		printf("%s\tout_key_id\n", indent);
> >+
> >+		if (tb_key_id[NL802154_KEY_ID_ATTR_MODE]) {
> >+			enum nl802154_key_id_modes key_id_mode;
> >+
> >+			key_id_mode = nla_get_u32(tb_key_id[NL802154_KEY_ID_ATTR_MODE]);
...
> >+enum nl802154_dev_addr_modes {
> >+	NL802154_DEV_ADDR_NONE,
> >+	__NL802154_DEV_ADDR_INVALID,
> >+	NL802154_DEV_ADDR_SHORT,
> >+	NL802154_DEV_ADDR_EXTENDED,
> >+
> >+	/* keep last */
> >+	__NL802154_DEV_ADDR_AFTER_LAST,
> 
> Hmm, why bother with AFTER_LAST here and not just use ADDR_MAX as sentinal
> for this enum? Looks redundant to me.
> 

At first I want to keep the wireless nl80211 userspace uapi header,
which declarate this hidden __FOOBAR enum in "mostly" every their enum
declaration. See [0], I simple adapt this convention for nl802154.

The reason is probaly they want some automatic mechanism to increment
the MAX value. Also it differs if you declare an array for netlink
policy [1] or give the length argument for parsing [2], which occurs
sometimes in off-by-one errors. 

...
> >+
> >+static int handle_out_key_id_set(struct nl802154_state *state, struct nl_cb *cb,
> >+				 struct nl_msg *msg, int argc, char **argv,
> >+				 enum id_input id)
> >+{
> >+	return handle_parse_key_id(msg, NL802154_ATTR_SEC_OUT_KEY_ID, &argc, &argv);
> >+
> >+}
> >+COMMAND(set, out_key_id,
> >+	"<0 <pan_id> <2 <short_addr>|3 <extended_addr>>>|"
> >+	"<1 <index>>|"
> >+	"<2 <index> <source_short>>|"
> >+	"<3 <index> <source_extended>>",
> 
> What are these extra >>| for ?
> 

The numbers are acutally the enums value which is usually some specific
mode, in this case the key_id_mode. Of course each of them has a proper
name and we should add some helper functions to map these enums to a
string.

The '>' should symbolize brackets and the '|' an "xor". This help text
shows you can use key_id_mode '0' xor '1' xor '2' ... and each of them
has different parameters.

> >+	NL802154_CMD_SET_SEC_PARAMS, 0, CIB_NETDEV,
> >+	handle_out_key_id_set, NULL);
> >+
> >+static int handle_out_seclevel_set(struct nl802154_state *state, struct nl_cb *cb,
> >+				   struct nl_msg *msg, int argc, char **argv,
> >+				   enum id_input id)
> >+{
> >+	unsigned long seclevel;
> >+	char *end;
> >+
> >+	if (argc < 1)
> >+		return 1;
> >+
> >+	/* seclevel */
> >+	seclevel = strtoul(argv[0], &end, 0);
> >+	if (*end != '\0')
> >+		return 1;
> >+
> >+	NLA_PUT_U32(msg, NL802154_ATTR_SEC_OUT_LEVEL, seclevel);
> >+
> >+	return 0;
> >+
> >+nla_put_failure:
> >+	return -ENOBUFS;
> >+}
> >+COMMAND(set, out_level, "<out_level>", NL802154_CMD_SET_SEC_PARAMS, 0, CIB_NETDEV,
> >+	handle_out_seclevel_set, NULL);
> >+
> >+static int handle_frame_counter_set(struct nl802154_state *state, struct nl_cb *cb,
> >+				   struct nl_msg *msg, int argc, char **argv,
> >+				   enum id_input id)
> >+{
> >+	unsigned long frame_counter;
> >+	char *end;
> >+
> >+	/* frame_counter */
> 
> This command and the other above (index, etc) which just state the variable
> name below are not really needed as they give no extra information imho.

ok.

- Alex

[0] http://lxr.free-electrons.com/source/include/uapi/linux/nl80211.h#L3159
    http://lxr.free-electrons.com/source/include/uapi/linux/nl80211.h#L3518
[1] http://lxr.free-electrons.com/source/net/ieee802154/nl802154.c#L196
[2] http://lxr.free-electrons.com/source/net/ieee802154/nl802154.c#L41
