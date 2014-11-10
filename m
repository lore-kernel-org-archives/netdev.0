From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 03/10] rtnl: expose physical switch id for
 particular device
Date: Mon, 10 Nov 2014 23:14:19 +0100
Message-ID: <20141110221419.GA2061@nanopsycho.orion>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us>
 <1415530280-9190-4-git-send-email-jiri@resnulli.us>
 <5460FCB0.1040409@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, linville@tuxdriver.com, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com,
	simon.horman@netronome.com, alexander.h.duyck@redhat.com,
	john.ronciak@intel.com, mleitner@redhat.com, shrijeet@gmail.com,
	gospo@cumulusnetworks.com, bcrl@kvack.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:64910 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138AbaKJWOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 17:14:21 -0500
Received: by mail-wi0-f170.google.com with SMTP id r20so101497wiv.5
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 14:14:20 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <5460FCB0.1040409@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Nov 10, 2014 at 06:58:08PM CET, roopa@cumulusnetworks.com wrote:
>On 11/9/14, 2:51 AM, Jiri Pirko wrote:
>>The netdevice represents a port in a switch, it will expose
>>IFLA_PHYS_SWITCH_ID value via rtnl. Two netdevices with the same value
>>belong to one physical switch.
>>
>>Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>---
>>  include/uapi/linux/if_link.h |  1 +
>>  net/core/rtnetlink.c         | 26 +++++++++++++++++++++++++-
>>  2 files changed, 26 insertions(+), 1 deletion(-)
>>
>>diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
>>index 7072d83..4163753 100644
>>--- a/include/uapi/linux/if_link.h
>>+++ b/include/uapi/linux/if_link.h
>>@@ -145,6 +145,7 @@ enum {
>>  	IFLA_CARRIER,
>>  	IFLA_PHYS_PORT_ID,
>>  	IFLA_CARRIER_CHANGES,
>>+	IFLA_PHYS_SWITCH_ID,
>
>Jiri, since we have not really converged on the switchdev class or having a
>separate switchdev instance,
>am thinking it is better if we dont expose any such switch_id to userspace
>yet until absolutely needed. Do you need it today ?
>There is no real in kernel hw switch driver that will use it today. And quite
>likely this will need to change when we introduce real hw switch drivers.

When and if the switchdev class is introduced, switch id can happily
live on. It is nothing against it. Userspace should use this id to group
the ports of physical switch.

>
>
>>  	__IFLA_MAX
>>  };
>>diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
>>index 1087c6d..f839354 100644
>>--- a/net/core/rtnetlink.c
>>+++ b/net/core/rtnetlink.c
>>@@ -43,6 +43,7 @@
>>  #include <linux/inet.h>
>>  #include <linux/netdevice.h>
>>+#include <net/switchdev.h>
>>  #include <net/ip.h>
>>  #include <net/protocol.h>
>>  #include <net/arp.h>
>>@@ -868,7 +869,8 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
>>  	       + rtnl_port_size(dev, ext_filter_mask) /* IFLA_VF_PORTS + IFLA_PORT_SELF */
>>  	       + rtnl_link_get_size(dev) /* IFLA_LINKINFO */
>>  	       + rtnl_link_get_af_size(dev) /* IFLA_AF_SPEC */
>>-	       + nla_total_size(MAX_PHYS_ITEM_ID_LEN); /* IFLA_PHYS_PORT_ID */
>>+	       + nla_total_size(MAX_PHYS_ITEM_ID_LEN) /* IFLA_PHYS_PORT_ID */
>>+	       + nla_total_size(MAX_PHYS_ITEM_ID_LEN); /* IFLA_PHYS_SWITCH_ID */
>>  }
>>  static int rtnl_vf_ports_fill(struct sk_buff *skb, struct net_device *dev)
>>@@ -967,6 +969,24 @@ static int rtnl_phys_port_id_fill(struct sk_buff *skb, struct net_device *dev)
>>  	return 0;
>>  }
>>+static int rtnl_phys_switch_id_fill(struct sk_buff *skb, struct net_device *dev)
>>+{
>>+	int err;
>>+	struct netdev_phys_item_id psid;
>>+
>>+	err = netdev_sw_parent_id_get(dev, &psid);
>>+	if (err) {
>>+		if (err == -EOPNOTSUPP)
>>+			return 0;
>>+		return err;
>>+	}
>>+
>>+	if (nla_put(skb, IFLA_PHYS_SWITCH_ID, psid.id_len, psid.id))
>>+		return -EMSGSIZE;
>>+
>>+	return 0;
>>+}
>>+
>>  static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>>  			    int type, u32 pid, u32 seq, u32 change,
>>  			    unsigned int flags, u32 ext_filter_mask)
>>@@ -1039,6 +1059,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>>  	if (rtnl_phys_port_id_fill(skb, dev))
>>  		goto nla_put_failure;
>>+	if (rtnl_phys_switch_id_fill(skb, dev))
>>+		goto nla_put_failure;
>>+
>>  	attr = nla_reserve(skb, IFLA_STATS,
>>  			sizeof(struct rtnl_link_stats));
>>  	if (attr == NULL)
>>@@ -1198,6 +1221,7 @@ static const struct nla_policy ifla_policy[IFLA_MAX+1] = {
>>  	[IFLA_NUM_RX_QUEUES]	= { .type = NLA_U32 },
>>  	[IFLA_PHYS_PORT_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_ITEM_ID_LEN },
>>  	[IFLA_CARRIER_CHANGES]	= { .type = NLA_U32 },  /* ignored */
>>+	[IFLA_PHYS_SWITCH_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_ITEM_ID_LEN },
>>  };
>>  static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
>
