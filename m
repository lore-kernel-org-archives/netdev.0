From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next 4/5] bridge: vlan lwt and dst_metadata netlink
 support
Date: Sun, 22 Jan 2017 07:23:09 -0800
Message-ID: <5884CE5D.6060401@cumulusnetworks.com>
References: <1484977616-1541-1-git-send-email-roopa@cumulusnetworks.com> <1484977616-1541-5-git-send-email-roopa@cumulusnetworks.com> <fc3f3b38-2a97-65c9-6759-fb243d523813@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        stephen@networkplumber.org, tgraf@suug.ch,
        hannes@stressinduktion.org, jbenc@redhat.com, pshelar@ovn.org,
        dsa@cumulusnetworks.com, hadi@mojatatu.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35837 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750978AbdAVPaS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 10:30:18 -0500
Received: by mail-pf0-f171.google.com with SMTP id f144so34463192pfa.2
        for <netdev@vger.kernel.org>; Sun, 22 Jan 2017 07:30:18 -0800 (PST)
In-Reply-To: <fc3f3b38-2a97-65c9-6759-fb243d523813@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/22/17, 4:05 AM, Nikolay Aleksandrov wrote:
> On 21/01/17 06:46, Roopa Prabhu wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> This patch adds support to attach per vlan tunnel info dst
>> metadata. This enables bridge driver to map vlan to tunnel_info
>> at ingress and egress
>>
>> The initial use case is vlan to vni bridging, but the api is generic
>> to extend to any tunnel_info in the future:
>>     - Uapi to configure/unconfigure/dump per vlan tunnel data
>>     - netlink functions to configure vlan and tunnel_info mapping
>>     - Introduces bridge port flag BR_LWT_VLAN to enable attach/detach
>>     dst_metadata to bridged packets on ports.
>>
>> Use case:
>> example use for this is a vxlan bridging gateway or vtep
>> which maps vlans to vn-segments (or vnis). User can configure
>> per-vlan tunnel information which the bridge driver can use
>> to bridge vlan into the corresponding tunnel.
>>
>> CC: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> ---
>> CC'ing Nikolay for some more eyes as he has been trying to keep the
>> bridge driver fast path lite.
>>
>>  include/linux/if_bridge.h |    1 +
>>  net/bridge/br_input.c     |    1 +
>>  net/bridge/br_netlink.c   |  410 ++++++++++++++++++++++++++++++++++++++-------
>>  net/bridge/br_private.h   |   18 ++
>>  net/bridge/br_vlan.c      |  138 ++++++++++++++-
>>  5 files changed, 507 insertions(+), 61 deletions(-)
>>
>> diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
>> index c6587c0..36ff611 100644
>> --- a/include/linux/if_bridge.h
>> +++ b/include/linux/if_bridge.h
>> @@ -46,6 +46,7 @@ struct br_ip_list {
>>  #define BR_LEARNING_SYNC	BIT(9)
>>  #define BR_PROXYARP_WIFI	BIT(10)
>>  #define BR_MCAST_FLOOD		BIT(11)
>> +#define BR_LWT_VLAN		BIT(12)
>>  
>>  #define BR_DEFAULT_AGEING_TIME	(300 * HZ)
>>  
>> diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
>> index 855b72f..83f356f 100644
>> --- a/net/bridge/br_input.c
>> +++ b/net/bridge/br_input.c
>> @@ -20,6 +20,7 @@
>>  #include <net/arp.h>
>>  #include <linux/export.h>
>>  #include <linux/rculist.h>
>> +#include <net/dst_metadata.h>
>>  #include "br_private.h"
>>  
>>  /* Hook for brouter */
>> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
>> index 71c7453..df997ad 100644
>> --- a/net/bridge/br_netlink.c
>> +++ b/net/bridge/br_netlink.c
>> @@ -17,17 +17,30 @@
>>  #include <net/net_namespace.h>
>>  #include <net/sock.h>
>>  #include <uapi/linux/if_bridge.h>
>> +#include <net/dst_metadata.h>
>>  
>>  #include "br_private.h"
>>  #include "br_private_stp.h"
>>  
>> -static int __get_num_vlan_infos(struct net_bridge_vlan_group *vg,
>> -				u32 filter_mask)
>> +static size_t br_get_vlan_tinfo_size(void)
>>  {
>> +	return nla_total_size(0) + /* nest IFLA_BRIDGE_VLAN_TUNNEL_INFO */
>> +		  nla_total_size(sizeof(u32)) + /* IFLA_BRIDGE_VLAN_TUNNEL_ID */
>> +		  nla_total_size(sizeof(u16)) + /* IFLA_BRIDGE_VLAN_TUNNEL_VID */
>> +		  nla_total_size(sizeof(u16)); /* IFLA_BRIDGE_VLAN_TUNNEL_FLAGS */
>> +}
>> +
>> +static int __get_num_vlan_infos(struct net_bridge_port *p,
>> +				struct net_bridge_vlan_group *vg,
>> +				u32 filter_mask, int *num_vtinfos)
>> +{
>> +	struct net_bridge_vlan *vbegin = NULL, *vend = NULL;
>> +	struct net_bridge_vlan *vtbegin = NULL, *vtend = NULL;
>>  	struct net_bridge_vlan *v;
>> -	u16 vid_range_start = 0, vid_range_end = 0, vid_range_flags = 0;
>> +	bool get_tinfos = (p && p->flags & BR_LWT_VLAN) ? true: false;
>> +	bool vcontinue, vtcontinue;
>> +	int num_vinfos = 0;
>>  	u16 flags, pvid;
>> -	int num_vlans = 0;
>>  
>>  	if (!(filter_mask & RTEXT_FILTER_BRVLAN_COMPRESSED))
>>  		return 0;
>> @@ -36,6 +49,8 @@ static int __get_num_vlan_infos(struct net_bridge_vlan_group *vg,
>>  	/* Count number of vlan infos */
>>  	list_for_each_entry_rcu(v, &vg->vlan_list, vlist) {
>>  		flags = 0;
>> +		vcontinue = false;
>> +		vtcontinue = false;
>>  		/* only a context, bridge vlan not activated */
>>  		if (!br_vlan_should_use(v))
>>  			continue;
>> @@ -45,47 +60,79 @@ static int __get_num_vlan_infos(struct net_bridge_vlan_group *vg,
>>  		if (v->flags & BRIDGE_VLAN_INFO_UNTAGGED)
>>  			flags |= BRIDGE_VLAN_INFO_UNTAGGED;
>>  
>> -		if (vid_range_start == 0) {
>> -			goto initvars;
>> -		} else if ((v->vid - vid_range_end) == 1 &&
>> -			flags == vid_range_flags) {
>> -			vid_range_end = v->vid;
>> +		if (!vbegin) {
>> +			vbegin = v;
>> +			vend = v;
>> +			vcontinue = true;
>> +		} else if ((v->vid - vend->vid) == 1 &&
>> +			flags == vbegin->flags) {
>> +			vend = v;
>> +			vcontinue = true;
>> +		}
>> +
>> +		if (!vcontinue) {
>> +			if ((vend->vid - vbegin->vid) > 0)
>> +				num_vinfos += 2;
>> +			else
>> +				num_vinfos += 1;
>> +		}
>> +
>> +		if (!get_tinfos && !v->tinfo.tunnel_id)
>>  			continue;
>> -		} else {
>> -			if ((vid_range_end - vid_range_start) > 0)
>> -				num_vlans += 2;
>> +
>> +		if (!vtbegin) {
>> +			vtbegin = v;
>> +			vtend = v;
>> +			vtcontinue = true;
>> +		} else if ((v->vid - vtend->vid) == 1 &&
>> +		    vlan_tunnel_id_isrange(vtend, v)) {
>> +			vtend = v;
>> +			vtcontinue = true;
>> +		}
>> +
>> +		if (!vtcontinue) {
>> +			if ((vtend->vid - vtbegin->vid) > 0)
>> +				num_vtinfos += 2;
>>  			else
>> -				num_vlans += 1;
>> +				num_vtinfos += 1;
>> +			vbegin = NULL;
>> +			vend = NULL;
>>  		}
>> -initvars:
>> -		vid_range_start = v->vid;
>> -		vid_range_end = v->vid;
>> -		vid_range_flags = flags;
>>  	}
>>  
>> -	if (vid_range_start != 0) {
>> -		if ((vid_range_end - vid_range_start) > 0)
>> -			num_vlans += 2;
>> +	if (vbegin) {
>> +		if ((vend->vid - vbegin->vid) > 0)
>> +			num_vinfos += 2;
>>  		else
>> -			num_vlans += 1;
>> +			num_vinfos += 1;
>>  	}
>>  
>> -	return num_vlans;
>> +	if (get_tinfos && vtbegin && vtbegin->tinfo.tunnel_id) {
>> +		if ((vtend->vid - vtbegin->vid) > 0)
>> +			*num_vtinfos += 2;
>> +		else
>> +			*num_vtinfos += 1;
>> +	}
>> +
>> +	return num_vinfos;
>>  }
> I think this whole function should be broken into at least a few. It's really difficult
> to parse what's going on.

ack, the vlan range handling is a bit painful and getting uglier. I will see what i can do.
I have added a few more things in this area in my latest code...ie reject tunnel info sets
if the per port flag is not set and fix some error handling paths...will send out next set
early next week.

>
>>  
>> -static int br_get_num_vlan_infos(struct net_bridge_vlan_group *vg,
>> -				 u32 filter_mask)
>> +static int br_get_num_vlan_infos(struct net_bridge_port *p,
>> +				 struct net_bridge_vlan_group *vg,
>> +				 int *num_tinfos, u32 filter_mask)
>>  {
>>  	int num_vlans;
>>  
>>  	if (!vg)
>>  		return 0;
>>  
>> -	if (filter_mask & RTEXT_FILTER_BRVLAN)
>> +	if (filter_mask & RTEXT_FILTER_BRVLAN) {
>> +		*num_tinfos = vg->num_vlans;
>>  		return vg->num_vlans;
>> +	}
>>  
>>  	rcu_read_lock();
>> -	num_vlans = __get_num_vlan_infos(vg, filter_mask);
>> +	num_vlans = __get_num_vlan_infos(p, vg, filter_mask, num_tinfos);
>>  	rcu_read_unlock();
>>  
>>  	return num_vlans;
>> @@ -95,9 +142,10 @@ static size_t br_get_link_af_size_filtered(const struct net_device *dev,
>>  					   u32 filter_mask)
>>  {
>>  	struct net_bridge_vlan_group *vg = NULL;
>> -	struct net_bridge_port *p;
>> +	struct net_bridge_port *p = NULL;
>>  	struct net_bridge *br;
>> -	int num_vlan_infos;
>> +	int num_vlan_infos, num_vlan_tinfos = 0;
>> +	size_t retsize = 0;
>>  
>>  	rcu_read_lock();
>>  	if (br_port_exists(dev)) {
>> @@ -107,11 +155,15 @@ static size_t br_get_link_af_size_filtered(const struct net_device *dev,
>>  		br = netdev_priv(dev);
>>  		vg = br_vlan_group_rcu(br);
>>  	}
>> -	num_vlan_infos = br_get_num_vlan_infos(vg, filter_mask);
>> +	num_vlan_infos = br_get_num_vlan_infos(p, vg, &num_vlan_tinfos,
>> +					       filter_mask);
>>  	rcu_read_unlock();
>>  
>>  	/* Each VLAN is returned in bridge_vlan_info along with flags */
>> -	return num_vlan_infos * nla_total_size(sizeof(struct bridge_vlan_info));
>> +	retsize =  num_vlan_infos * nla_total_size(sizeof(struct bridge_vlan_info)) +
>> +			num_vlan_tinfos * br_get_vlan_tinfo_size();
>> +
>> +	return retsize;
>>  }
>>  
>>  static inline size_t br_port_info_size(void)
>> @@ -191,7 +243,8 @@ static int br_port_fill_attrs(struct sk_buff *skb,
>>  	    nla_put_u16(skb, IFLA_BRPORT_NO, p->port_no) ||
>>  	    nla_put_u8(skb, IFLA_BRPORT_TOPOLOGY_CHANGE_ACK,
>>  		       p->topology_change_ack) ||
>> -	    nla_put_u8(skb, IFLA_BRPORT_CONFIG_PENDING, p->config_pending))
>> +	    nla_put_u8(skb, IFLA_BRPORT_CONFIG_PENDING, p->config_pending) ||
>> +	    nla_put_u8(skb, IFLA_BRPORT_LWT_VLAN, !!(p->flags & BR_LWT_VLAN)))
>>  		return -EMSGSIZE;
>>  
>>  	timerval = br_timer_value(&p->message_age_timer);
>> @@ -216,6 +269,34 @@ static int br_port_fill_attrs(struct sk_buff *skb,
>>  	return 0;
>>  }
>>  
>> +static int br_fill_vlan_tinfo(struct sk_buff *skb, u16 vid,
>> +                              __be64 tunnel_id, u16 flags)
>> +{
>> +    __be32 tid = tunnel_id_to_key32(tunnel_id);
>> +    struct nlattr *tmap;
>> +
>> +	tmap = nla_nest_start(skb, IFLA_BRIDGE_VLAN_TUNNEL_INFO);
>> +	if (!tmap)
>> +		return -EMSGSIZE;
>> +	if (nla_put_u32(skb, IFLA_BRIDGE_VLAN_TUNNEL_ID,
>> +            be32_to_cpu(tid)))
>> +		goto nla_put_failure;
>> +	if (nla_put_u16(skb, IFLA_BRIDGE_VLAN_TUNNEL_VID,
>> +			vid))
>> +		goto nla_put_failure;
>> +	if (nla_put_u16(skb, IFLA_BRIDGE_VLAN_TUNNEL_FLAGS,
>> +			flags))
>> +		goto nla_put_failure;
>> +	nla_nest_end(skb, tmap);
>> +
>> +	return 0;
>> +
>> +nla_put_failure:
>> +	nla_nest_cancel(skb, tmap);
>> +
>> +	return -EMSGSIZE;
>> +}
>> +
>>  static int br_fill_ifvlaninfo_range(struct sk_buff *skb, u16 vid_start,
>>  				    u16 vid_end, u16 flags)
>>  {
>> @@ -249,20 +330,24 @@ static int br_fill_ifvlaninfo_range(struct sk_buff *skb, u16 vid_start,
>>  }
>>  
>>  static int br_fill_ifvlaninfo_compressed(struct sk_buff *skb,
>> +					 struct net_bridge_port *p,
>>  					 struct net_bridge_vlan_group *vg)
>>  {
>> +	struct net_bridge_vlan *vbegin = NULL, *vend = NULL;
>> +	struct net_bridge_vlan *vtbegin = NULL, *vtend = NULL;
>> +	bool fill_tinfos = (p && p->flags & BR_LWT_VLAN) ? true: false;
>>  	struct net_bridge_vlan *v;
>> -	u16 vid_range_start = 0, vid_range_end = 0, vid_range_flags = 0;
>> +	bool vcontinue, vtcontinue;
>>  	u16 flags, pvid;
>> -	int err = 0;
>> +	int err;
>>  
>> -	/* Pack IFLA_BRIDGE_VLAN_INFO's for every vlan
>> -	 * and mark vlan info with begin and end flags
>> -	 * if vlaninfo represents a range
>> -	 */
>>  	pvid = br_get_pvid(vg);
>> +	/* Count number of vlan infos */
>>  	list_for_each_entry_rcu(v, &vg->vlan_list, vlist) {
>>  		flags = 0;
>> +		vcontinue = false;
>> +		vtcontinue = false;
>> +		/* only a context, bridge vlan not activated */
>>  		if (!br_vlan_should_use(v))
>>  			continue;
>>  		if (v->vid == pvid)
>> @@ -271,44 +356,103 @@ static int br_fill_ifvlaninfo_compressed(struct sk_buff *skb,
>>  		if (v->flags & BRIDGE_VLAN_INFO_UNTAGGED)
>>  			flags |= BRIDGE_VLAN_INFO_UNTAGGED;
>>  
>> -		if (vid_range_start == 0) {
>> -			goto initvars;
>> -		} else if ((v->vid - vid_range_end) == 1 &&
>> -			flags == vid_range_flags) {
>> -			vid_range_end = v->vid;
>> -			continue;
>> -		} else {
>> -			err = br_fill_ifvlaninfo_range(skb, vid_range_start,
>> -						       vid_range_end,
>> -						       vid_range_flags);
>> +		if (!vbegin) {
>> +			vbegin = v;
>> +			vend = v;
>> +			vcontinue = true;
>> +		} else if ((v->vid - vend->vid) == 1 &&
>> +			flags == vbegin->flags) {
>> +			vend = v;
>> +			vcontinue = true;
>> +		}
>> +
>> +		if (!vcontinue) {
>> +			err = br_fill_ifvlaninfo_range(skb,
>> +						       vbegin->vid,
>> +						       vend->vid,
>> +						       vbegin->flags);
>>  			if (err)
>>  				return err;
>> +			vbegin = vend = NULL;
>> +		}
>> +
>> +		if (!fill_tinfos || !v->tinfo.tunnel_id)
>> +			continue;
>> +
>> +		if (!vtbegin) {
>> +			vtbegin = v;
>> +			vtend = v;
>> +			vtcontinue = true;
>> +		} else if ((v->vid - vtend->vid) == 1 &&
>> +		    vlan_tunnel_id_isrange(vtend, v)) {
>> +			vtend = v;
>> +			vtcontinue = true;
>>  		}
>>  
>> -initvars:
>> -		vid_range_start = v->vid;
>> -		vid_range_end = v->vid;
>> -		vid_range_flags = flags;
>> +		if (!vtcontinue && vtbegin->tinfo.tunnel_id) {
>> +			if ((vtend->vid - vtbegin->vid) > 0) {
>> +				err = br_fill_vlan_tinfo(skb, vbegin->vid,
>> +							 vbegin->tinfo.tunnel_id,
>> +						BRIDGE_VLAN_INFO_RANGE_BEGIN);
>> +				if (err)
>> +					return err;
>> +				err = br_fill_vlan_tinfo(skb, vend->vid,
>> +							 vend->tinfo.tunnel_id,
>> +						BRIDGE_VLAN_INFO_RANGE_END);
>> +				if (err)
>> +					return err;
>> +			} else {
>> +				err = br_fill_vlan_tinfo(skb, vbegin->vid,
>> +							 vbegin->tinfo.tunnel_id,
>> +							 0);
>> +				if (err)
>> +					return err;
>> +			}
>> +			vbegin = NULL;
>> +			vend = NULL;
>> +		}
>>  	}
>>  
>> -	if (vid_range_start != 0) {
>> -		/* Call it once more to send any left over vlans */
>> -		err = br_fill_ifvlaninfo_range(skb, vid_range_start,
>> -					       vid_range_end,
>> -					       vid_range_flags);
>> +	if (vbegin) {
>> +		err = br_fill_ifvlaninfo_range(skb, vbegin->vid,
>> +					       vend->vid,
>> +					       vbegin->flags);
>>  		if (err)
>>  			return err;
>>  	}
>>  
>> +	if (fill_tinfos && vtbegin && vtbegin->tinfo.tunnel_id) {
>> +		if ((vtend->vid - vtbegin->vid) > 0) {
>> +			err = br_fill_vlan_tinfo(skb, vbegin->vid,
>> +						 vbegin->tinfo.tunnel_id,
>> +						 BRIDGE_VLAN_INFO_RANGE_BEGIN);
>> +			if (err)
>> +				return err;
>> +			err = br_fill_vlan_tinfo(skb, vend->vid,
>> +						 vend->tinfo.tunnel_id,
>> +						 BRIDGE_VLAN_INFO_RANGE_END);
>> +			if (err)
>> +				return err;
>> +		} else {
>> +			err = br_fill_vlan_tinfo(skb, vbegin->vid,
>> +						 vbegin->tinfo.tunnel_id, 0);
>> +			if (err)
>> +				return err;
>> +		}
>> +	}
>> +
>>  	return 0;
>>  }
> Maybe look into breaking this one, too. It's getting huge and hard to follow..
>
>>  
>>  static int br_fill_ifvlaninfo(struct sk_buff *skb,
>> +			      struct net_bridge_port *p,
>>  			      struct net_bridge_vlan_group *vg)
>>  {
>>  	struct bridge_vlan_info vinfo;
>>  	struct net_bridge_vlan *v;
>> +	bool fill_tinfos = (p && p->flags & BR_LWT_VLAN) ? true : false;
>>  	u16 pvid;
>> +	int err;
>>  
>>  	pvid = br_get_pvid(vg);
>>  	list_for_each_entry_rcu(v, &vg->vlan_list, vlist) {
>> @@ -326,6 +470,14 @@ static int br_fill_ifvlaninfo(struct sk_buff *skb,
>>  		if (nla_put(skb, IFLA_BRIDGE_VLAN_INFO,
>>  			    sizeof(vinfo), &vinfo))
>>  			goto nla_put_failure;
>> +
>> +		if (!fill_tinfos || !v->tinfo.tunnel_id)
>> +			continue;
>> +
>> +		err = br_fill_vlan_tinfo(skb, v->vid,
>> +					 v->tinfo.tunnel_id, 0);
>> +		if (err)
>> +			return err;
>>  	}
>>  
>>  	return 0;
>> @@ -411,9 +563,9 @@ static int br_fill_ifinfo(struct sk_buff *skb,
>>  			goto nla_put_failure;
>>  		}
>>  		if (filter_mask & RTEXT_FILTER_BRVLAN_COMPRESSED)
>> -			err = br_fill_ifvlaninfo_compressed(skb, vg);
>> +			err = br_fill_ifvlaninfo_compressed(skb, port, vg);
>>  		else
>> -			err = br_fill_ifvlaninfo(skb, vg);
>> +			err = br_fill_ifvlaninfo(skb, port, vg);
>>  		rcu_read_unlock();
>>  		if (err)
>>  			goto nla_put_failure;
>> @@ -514,6 +666,127 @@ static int br_vlan_info(struct net_bridge *br, struct net_bridge_port *p,
>>  	return err;
>>  }
>>  
>> +static const struct nla_policy vlan_tunnel_policy[IFLA_BRIDGE_VLAN_TUNNEL_MAX + 1] = {
>> +	[IFLA_BRIDGE_VLAN_TUNNEL_ID]= { .type = NLA_U32 },
>> +	[IFLA_BRIDGE_VLAN_TUNNEL_VID] = { .type = NLA_U16 },
>> +	[IFLA_BRIDGE_VLAN_TUNNEL_FLAGS] = { .type = NLA_U16 },
>> +};
>> +
>> +static int br_add_vlan_tunnel_info(struct net_bridge *br,
>> +				   struct net_bridge_port *p, int cmd,
>> +				   u16 vid, u32 tun_id)
>> +{
>> +	int err;
>> +
>> +	switch (cmd) {
>> +	case RTM_SETLINK:
>> +		if (p) {
>> +			/* if the MASTER flag is set this will act on the global
>> +			 * per-VLAN entry as well
>> +			 */
>> +			err = nbp_vlan_tunnel_info_add(p, vid, tun_id);
>> +			if (err)
>> +				break;
>> +		} else {
>> +			return -EINVAL;
>> +		}
>> +
>> +		break;
>> +
>> +	case RTM_DELLINK:
>> +		if (p)
>> +			nbp_vlan_tunnel_info_delete(p, vid);
>> +		else
>> +			return -EINVAL;
>> +		break;
>> +	}
> so if (!p) return -einval in the beginning ? :-)
>
>> +
>> +	return 0;
>> +}
>> +
>> +struct vtunnel_info {
>> +	u32	tunid;
>> +	u16	vid;
>> +	u16	flags;
>> +};
>> +
>> +static int br_parse_vlan_tunnel_info(struct nlattr *attr,
>> +				     struct vtunnel_info *tinfo)
>> +{
>> +	struct nlattr *tb[IFLA_BRIDGE_VLAN_TUNNEL_MAX + 1];
>> +	u32 tun_id;
>> +	u16 vid, flags;
>> +	int err;
>> +
>> +	err = nla_parse_nested(tb, IFLA_BRIDGE_VLAN_TUNNEL_MAX,
>> +			       attr, vlan_tunnel_policy);
>> +	if (err < 0)
>> +		return err;
>> +
>> +	if (tb[IFLA_BRIDGE_VLAN_TUNNEL_ID])
>> +		tun_id = nla_get_u32(tb[IFLA_BRIDGE_VLAN_TUNNEL_ID]);
>> +	else
>> +		return -EINVAL;
>> +
>> +	if (tb[IFLA_BRIDGE_VLAN_TUNNEL_VID]) {
>> +		vid = nla_get_u16(tb[IFLA_BRIDGE_VLAN_TUNNEL_VID]);
>> +		if (vid >= VLAN_VID_MASK)
>> +			return -ERANGE;
> !vid || 
>
>> +	} else {
>> +		return -EINVAL;
>> +	}
> these attr checks can be moved in the beginning, usually there's a check for existence
> of the mandatory attributes, then you can continue just using them and avoid these
> "else" statements
>
>> +
>> +	if (tb[IFLA_BRIDGE_VLAN_TUNNEL_FLAGS])
>> +		flags = nla_get_u16(tb[IFLA_BRIDGE_VLAN_TUNNEL_FLAGS]);
>> +
>> +	tinfo->tunid = tun_id;
>> +	tinfo->vid = vid;
>> +	tinfo->flags = flags;
>> +
>> +	return 0;
>> +}
>> +
>> +static int br_process_vlan_tunnel_info(struct net_bridge *br,
>> +				       struct net_bridge_port *p, int cmd,
>> +				       struct vtunnel_info *tinfo_curr,
>> +				       struct vtunnel_info *tinfo_last)
>> +{
>> +	int t, v;
>> +	int err;
>> +
>> +	if (tinfo_curr->flags & BRIDGE_VLAN_INFO_RANGE_BEGIN) {
>> +		if (tinfo_last->flags & BRIDGE_VLAN_INFO_RANGE_BEGIN)
>> +			return -EINVAL;
>> +		memcpy(tinfo_last, tinfo_curr, sizeof(struct vtunnel_info));
>> +	} else if (tinfo_curr->flags & BRIDGE_VLAN_INFO_RANGE_END) {
>> +		if (!(tinfo_last->flags & BRIDGE_VLAN_INFO_RANGE_BEGIN))
>> +			return -EINVAL;
>> +		if ((tinfo_curr->vid - tinfo_last->vid) !=
>> +		    (tinfo_curr->tunid - tinfo_last->tunid))
>> +			return -EINVAL;
>> +		/* XXX: tun id and vlan id attrs must be same
>> +		 */
>> +		t = tinfo_last->tunid;
>> +		for (v = tinfo_last->vid; v <= tinfo_curr->vid; v++) {
>> +			err = br_add_vlan_tunnel_info(br, p, cmd,
>> +							  v, t);
>> +			if (err)
>> +				return err;
>> +			t++;
>> +		}
>> +		memset(tinfo_last, 0, sizeof(struct vtunnel_info));
>> +		memset(tinfo_curr, 0, sizeof(struct vtunnel_info));
>> +	} else {
>> +		err = br_add_vlan_tunnel_info(br, p, cmd,
>> +					      tinfo_curr->vid,
>> +					      tinfo_curr->tunid);
>> +		if (err)
>> +			return err;
>> +	}
>> +
>> +	return 0;
>> +}
>> +
>>  static int br_afspec(struct net_bridge *br,
>>  		     struct net_bridge_port *p,
>>  		     struct nlattr *af_spec,
>> @@ -522,10 +795,30 @@ static int br_afspec(struct net_bridge *br,
>>  	struct bridge_vlan_info *vinfo_start = NULL;
>>  	struct bridge_vlan_info *vinfo = NULL;
>>  	struct nlattr *attr;
>> +	struct vtunnel_info tinfo_last = {
>> +		.tunid = 0,
>> +		.vid = 0,
>> +		.flags = 0};
>> +	struct vtunnel_info tinfo_curr = {
>> +		.tunid = 0,
>> +		.vid = 0,
>> +		.flags = 0};
> just { } should be enough to zero the structs

ack
>
>>  	int err = 0;
>>  	int rem;
>>  
>>  	nla_for_each_nested(attr, af_spec, rem) {
>> +		if (nla_type(attr) == IFLA_BRIDGE_VLAN_TUNNEL_INFO) {
>> +			err = br_parse_vlan_tunnel_info(attr, &tinfo_curr);
>> +			if (err)
>> +				return err;
>> +			err = br_process_vlan_tunnel_info(br, p, cmd,
>> +							  &tinfo_curr,
>> +							  &tinfo_last);
>> +			if (err)
>> +				return err;
>> +			continue;
>> +		}
>> +
>>  		if (nla_type(attr) != IFLA_BRIDGE_VLAN_INFO)
>>  			continue;
>>  		if (nla_len(attr) != sizeof(struct bridge_vlan_info))
>> @@ -638,6 +931,7 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
>>  	br_set_port_flag(p, tb, IFLA_BRPORT_MCAST_FLOOD, BR_MCAST_FLOOD);
>>  	br_set_port_flag(p, tb, IFLA_BRPORT_PROXYARP, BR_PROXYARP);
>>  	br_set_port_flag(p, tb, IFLA_BRPORT_PROXYARP_WIFI, BR_PROXYARP_WIFI);
>> +	br_set_port_flag(p, tb, IFLA_BRPORT_LWT_VLAN, BR_LWT_VLAN);
>>  
>>  	if (tb[IFLA_BRPORT_COST]) {
>>  		err = br_stp_set_path_cost(p, nla_get_u32(tb[IFLA_BRPORT_COST]));
>> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
>> index 8ce621e..f68e360 100644
>> --- a/net/bridge/br_private.h
>> +++ b/net/bridge/br_private.h
>> @@ -91,6 +91,11 @@ struct br_vlan_stats {
>>  	struct u64_stats_sync syncp;
>>  };
>>  
>> +struct br_tunnel_info {
>> +	__be64			tunnel_id;
>> +	struct metadata_dst	*tunnel_dst;
>> +};
>> +
>>  /**
>>   * struct net_bridge_vlan - per-vlan entry
>>   *
>> @@ -113,6 +118,7 @@ struct br_vlan_stats {
>>   */
>>  struct net_bridge_vlan {
>>  	struct rhash_head		vnode;
>> +	struct rhash_head		tnode;
>>  	u16				vid;
>>  	u16				flags;
>>  	struct br_vlan_stats __percpu	*stats;
>> @@ -124,6 +130,9 @@ struct net_bridge_vlan {
>>  		atomic_t		refcnt;
>>  		struct net_bridge_vlan	*brvlan;
>>  	};
>> +
>> +	struct br_tunnel_info		tinfo;
>> +
>>  	struct list_head		vlist;
>>  
>>  	struct rcu_head			rcu;
>> @@ -145,6 +154,7 @@ struct net_bridge_vlan {
>>   */
>>  struct net_bridge_vlan_group {
>>  	struct rhashtable		vlan_hash;
>> +	struct rhashtable		tunnel_hash;
>>  	struct list_head		vlan_list;
>>  	u16				num_vlans;
>>  	u16				pvid;
>> @@ -786,6 +796,14 @@ struct sk_buff *br_handle_vlan(struct net_bridge *br,
>>  int nbp_get_num_vlan_infos(struct net_bridge_port *p, u32 filter_mask);
>>  void br_vlan_get_stats(const struct net_bridge_vlan *v,
>>  		       struct br_vlan_stats *stats);
>> +int __vlan_tunnel_info_add(struct net_bridge_vlan_group *vg,
>> +			   struct net_bridge_vlan *vlan, u32 tun_id);
>> +int __vlan_tunnel_info_del(struct net_bridge_vlan_group *vg,
>> +                           struct net_bridge_vlan *vlan);
>> +int nbp_vlan_tunnel_info_delete(struct net_bridge_port *port, u16 vid);
>> +int nbp_vlan_tunnel_info_add(struct net_bridge_port *port, u16 vid, u32 tun_id);
>> +bool vlan_tunnel_id_isrange(struct net_bridge_vlan *v_end,
>> +			    struct net_bridge_vlan *v);
>>  
>>  static inline struct net_bridge_vlan_group *br_vlan_group(
>>  					const struct net_bridge *br)
>> diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
>> index b6de4f4..2040f08 100644
>> --- a/net/bridge/br_vlan.c
>> +++ b/net/bridge/br_vlan.c
>> @@ -3,6 +3,7 @@
>>  #include <linux/rtnetlink.h>
>>  #include <linux/slab.h>
>>  #include <net/switchdev.h>
>> +#include <net/dst_metadata.h>
>>  
>>  #include "br_private.h"
>>  
>> @@ -31,6 +32,31 @@ static struct net_bridge_vlan *br_vlan_lookup(struct rhashtable *tbl, u16 vid)
>>  	return rhashtable_lookup_fast(tbl, &vid, br_vlan_rht_params);
>>  }
>>  
>> +static inline int br_vlan_tunid_cmp(struct rhashtable_compare_arg *arg,
>> +				    const void *ptr)
>> +{
>> +	const struct net_bridge_vlan *vle = ptr;
>> +	__be64 tunid = *(__be64 *)arg->key;
>> +
>> +	return vle->tinfo.tunnel_id != tunid;
>> +}
>> +
>> +static const struct rhashtable_params br_vlan_tunnel_rht_params = {
>> +	.head_offset = offsetof(struct net_bridge_vlan, tnode),
>> +	.key_offset = offsetof(struct net_bridge_vlan, tinfo.tunnel_id),
>> +	.key_len = sizeof(__be64),
>> +	.nelem_hint = 3,
>> +	.locks_mul = 1,
>> +	.obj_cmpfn = br_vlan_tunid_cmp,
>> +	.automatic_shrinking = true,
>> +};
>> +
>> +static struct net_bridge_vlan *br_vlan_tunnel_lookup(struct rhashtable *tbl,
>> +						     u64 tunnel_id)
>> +{
>> +	return rhashtable_lookup_fast(tbl, &tunnel_id, br_vlan_tunnel_rht_params);
>> +}
>> +
>>  static void __vlan_add_pvid(struct net_bridge_vlan_group *vg, u16 vid)
>>  {
>>  	if (vg->pvid == vid)
>> @@ -325,6 +351,7 @@ static void __vlan_group_free(struct net_bridge_vlan_group *vg)
>>  {
>>  	WARN_ON(!list_empty(&vg->vlan_list));
>>  	rhashtable_destroy(&vg->vlan_hash);
>> +	rhashtable_destroy(&vg->tunnel_hash);
>>  	kfree(vg);
>>  }
>>  
>> @@ -613,6 +640,8 @@ int br_vlan_delete(struct net_bridge *br, u16 vid)
>>  	br_fdb_find_delete_local(br, NULL, br->dev->dev_addr, vid);
>>  	br_fdb_delete_by_port(br, NULL, vid, 0);
>>  
>> +	__vlan_tunnel_info_del(vg, v);
>> +
>>  	return __vlan_del(v);
>>  }
>>  
>> @@ -918,6 +947,9 @@ int br_vlan_init(struct net_bridge *br)
>>  	ret = rhashtable_init(&vg->vlan_hash, &br_vlan_rht_params);
>>  	if (ret)
>>  		goto err_rhtbl;
>> +	ret = rhashtable_init(&vg->tunnel_hash, &br_vlan_tunnel_rht_params);
>> +	if (ret)
>> +		goto err_rhtbl2;
>>  	INIT_LIST_HEAD(&vg->vlan_list);
>>  	br->vlan_proto = htons(ETH_P_8021Q);
>>  	br->default_pvid = 1;
>> @@ -932,6 +964,8 @@ int br_vlan_init(struct net_bridge *br)
>>  	return ret;
>>  
>>  err_vlan_add:
>> +	rhashtable_destroy(&vg->tunnel_hash);
>> +err_rhtbl2:
>>  	rhashtable_destroy(&vg->vlan_hash);
>>  err_rhtbl:
>>  	kfree(vg);
>> @@ -960,7 +994,10 @@ int nbp_vlan_init(struct net_bridge_port *p)
>>  
>>  	ret = rhashtable_init(&vg->vlan_hash, &br_vlan_rht_params);
>>  	if (ret)
>> -		goto err_rhtbl;
>> +		goto err_rhtbl1;
>> +	ret = rhashtable_init(&vg->tunnel_hash, &br_vlan_tunnel_rht_params);
>> +	if (ret)
>> +		goto err_rhtbl2;
>>  	INIT_LIST_HEAD(&vg->vlan_list);
>>  	rcu_assign_pointer(p->vlgrp, vg);
>>  	if (p->br->default_pvid) {
>> @@ -976,9 +1013,11 @@ int nbp_vlan_init(struct net_bridge_port *p)
>>  err_vlan_add:
>>  	RCU_INIT_POINTER(p->vlgrp, NULL);
>>  	synchronize_rcu();
>> -	rhashtable_destroy(&vg->vlan_hash);
>> +	rhashtable_destroy(&vg->tunnel_hash);
>>  err_vlan_enabled:
>> -err_rhtbl:
>> +err_rhtbl2:
>> +	rhashtable_destroy(&vg->vlan_hash);
>> +err_rhtbl1:
>>  	kfree(vg);
>>  
>>  	goto out;
>> @@ -1081,3 +1120,96 @@ void br_vlan_get_stats(const struct net_bridge_vlan *v,
>>  		stats->tx_packets += txpackets;
>>  	}
>>  }
>> +
>> +bool vlan_tunnel_id_isrange(struct net_bridge_vlan *v_end,
>> +			    struct net_bridge_vlan *v)
>> +{
>> +	/* XXX: check other tunnel attributes */
>> +	return (be32_to_cpu(tunnel_id_to_key32(v_end->tinfo.tunnel_id)) -
>> +		be32_to_cpu(tunnel_id_to_key32(v->tinfo.tunnel_id)) == 1);
>> +}
>> +
>> +int __vlan_tunnel_info_add(struct net_bridge_vlan_group *vg,
>> +			   struct net_bridge_vlan *vlan, u32 tun_id)
>> +{
>> +	struct metadata_dst *metadata = NULL;
>> +	__be64 key = key32_to_tunnel_id(cpu_to_be32(tun_id));
>> +	int err;
>> +
>> +	if (vlan->tinfo.tunnel_dst)
>> +		return -EEXIST;
>> +
>> +	metadata = __ip_tun_set_dst(0, 0, 0, 0, 0, TUNNEL_KEY,
>> +				    key, 0);
>> +	if (!metadata)
>> +		return -EINVAL;
>> +
>> +	metadata->u.tun_info.mode |= IP_TUNNEL_INFO_TX | IP_TUNNEL_INFO_BRIDGE;
>> +	vlan->tinfo.tunnel_dst = metadata;
>> +	vlan->tinfo.tunnel_id = key;
>> +
>> +	err = rhashtable_lookup_insert_fast(&vg->tunnel_hash, &vlan->tnode,
>> +					    br_vlan_tunnel_rht_params);
>> +	if (err)
>> +		goto out;
>> +
>> +	return 0;
>> +out:
>> +	dst_release(&vlan->tinfo.tunnel_dst->dst);
>> +
>> +	return err;
>> +}
>> +
>> +int __vlan_tunnel_info_del(struct net_bridge_vlan_group *vg,
>> +			   struct net_bridge_vlan *vlan)
>> +{
>> +	if (vlan->tinfo.tunnel_dst) {
>> +		vlan->tinfo.tunnel_id = 0;
>> +		dst_release(&vlan->tinfo.tunnel_dst->dst);
>> +
>> +		rhashtable_remove_fast(&vg->tunnel_hash, &vlan->vnode,
>> +				       br_vlan_tunnel_rht_params);
>> +	}
>> +
>> +	return 0;
>> +}
> I think all of these should be static, if I haven't missed something I don't see them
> being used anywhere else.

yep, moved most of them to static....in the latest version.
>
>> +
>> +/* Must be protected by RTNL.
>> + * Must be called with vid in range from 1 to 4094 inclusive.
>> + */
>> +int nbp_vlan_tunnel_info_add(struct net_bridge_port *port, u16 vid, u32 tun_id)
>> +{
>> +	struct net_bridge_vlan_group *vg;
>> +	struct net_bridge_vlan *vlan;
>> +
>> +	ASSERT_RTNL();
>> +
>> +	vg = nbp_vlan_group(port);
>> +	vlan = br_vlan_find(vg, vid);
>> +	if (!vlan)
>> +		return -EINVAL;
>> +
>> +	__vlan_tunnel_info_add(vg, vlan, tun_id);
>> +
>> +	return 0;
>> +}
>> +
>> +/* Must be protected by RTNL.
>> + * Must be called with vid in range from 1 to 4094 inclusive.
>> + */
>> +int nbp_vlan_tunnel_info_delete(struct net_bridge_port *port, u16 vid)
>> +{
>> +	struct net_bridge_vlan_group *vg;
>> +	struct net_bridge_vlan *v;
>> +
>> +	ASSERT_RTNL();
>> +
>> +	vg = nbp_vlan_group(port);
>> +	v = br_vlan_find(vg, vid);
>> +	if (!v)
>> +		return -ENOENT;
>> +
>> +	__vlan_tunnel_info_del(vg, v);
>> +
>> +	return 0;
>> +}
>>
thanks
