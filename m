From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH net-next v3 13/13] net: switchdev: Remove bridge bypass
 support from switchdev
Date: Mon, 7 Aug 2017 12:31:30 +0200
Message-ID: <e3e8fe54-019c-43ae-91bd-cb61ef1e5b18@redhat.com>
References: <1502025351-41261-1-git-send-email-arkadis@mellanox.com>
 <1502025351-41261-14-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jiri@resnulli.us, f.fainelli@gmail.com,
        andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        Woojung.Huh@microchip.com, mlxsw@mellanox.com
To: Arkadi Sharshevsky <arkadis@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46108 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752766AbdHGKbd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 7 Aug 2017 06:31:33 -0400
In-Reply-To: <1502025351-41261-14-git-send-email-arkadis@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6.8.2017 15:15, Arkadi Sharshevsky wrote:
> Currently the bridge port flags, vlans, FDBs and MDBs can be offloaded
> through the bridge code, making the switchdev's SELF bridge bypass
> implementation to be redundant. This implies several changes:
> - No need for dump infra in switchdev, DSA's special case is handled
>   privately.
> - Remove obj_dump from switchdev_ops.
> - FDBs are removed from obj_add/del routines, due to the fact that they
>   are offloaded through the bridge notification chain.
> - The switchdev_port_bridge_xx() and switchdev_port_fdb_xx() functions
>   can be removed.
> 
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
> Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
> v1->v2
> - Fix typo in commit message.
> ---
>  include/net/switchdev.h   |  75 --------
>  net/switchdev/switchdev.c | 435 ----------------------------------------------
>  2 files changed, 510 deletions(-)
> 
> diff --git a/include/net/switchdev.h b/include/net/switchdev.h
> index d2637a6..d767b79 100644
> --- a/include/net/switchdev.h
> +++ b/include/net/switchdev.h
> @@ -74,7 +74,6 @@ struct switchdev_attr {
>  enum switchdev_obj_id {
>  	SWITCHDEV_OBJ_ID_UNDEFINED,
>  	SWITCHDEV_OBJ_ID_PORT_VLAN,
> -	SWITCHDEV_OBJ_ID_PORT_FDB,
>  	SWITCHDEV_OBJ_ID_PORT_MDB,
>  };
>  
> @@ -97,17 +96,6 @@ struct switchdev_obj_port_vlan {
>  #define SWITCHDEV_OBJ_PORT_VLAN(obj) \
>  	container_of(obj, struct switchdev_obj_port_vlan, obj)
>  
> -/* SWITCHDEV_OBJ_ID_PORT_FDB */
> -struct switchdev_obj_port_fdb {
> -	struct switchdev_obj obj;
> -	unsigned char addr[ETH_ALEN];
> -	u16 vid;
> -	u16 ndm_state;
> -};
> -
> -#define SWITCHDEV_OBJ_PORT_FDB(obj) \
> -	container_of(obj, struct switchdev_obj_port_fdb, obj)
> -
>  /* SWITCHDEV_OBJ_ID_PORT_MDB */
>  struct switchdev_obj_port_mdb {
>  	struct switchdev_obj obj;
> @@ -135,8 +123,6 @@ typedef int switchdev_obj_dump_cb_t(struct switchdev_obj *obj);
>   * @switchdev_port_obj_add: Add an object to port (see switchdev_obj_*).
>   *
>   * @switchdev_port_obj_del: Delete an object from port (see switchdev_obj_*).
> - *
> - * @switchdev_port_obj_dump: Dump port objects (see switchdev_obj_*).
>   */
>  struct switchdev_ops {
>  	int	(*switchdev_port_attr_get)(struct net_device *dev,
> @@ -149,9 +135,6 @@ struct switchdev_ops {
>  					  struct switchdev_trans *trans);
>  	int	(*switchdev_port_obj_del)(struct net_device *dev,
>  					  const struct switchdev_obj *obj);
> -	int	(*switchdev_port_obj_dump)(struct net_device *dev,
> -					   struct switchdev_obj *obj,
> -					   switchdev_obj_dump_cb_t *cb);
>  };
>  
>  enum switchdev_notifier_type {
> @@ -189,25 +172,10 @@ int switchdev_port_obj_add(struct net_device *dev,
>  			   const struct switchdev_obj *obj);
>  int switchdev_port_obj_del(struct net_device *dev,
>  			   const struct switchdev_obj *obj);
> -int switchdev_port_obj_dump(struct net_device *dev, struct switchdev_obj *obj,
> -			    switchdev_obj_dump_cb_t *cb);
>  int register_switchdev_notifier(struct notifier_block *nb);
>  int unregister_switchdev_notifier(struct notifier_block *nb);
>  int call_switchdev_notifiers(unsigned long val, struct net_device *dev,
>  			     struct switchdev_notifier_info *info);
> -int switchdev_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
> -				  struct net_device *dev, u32 filter_mask,
> -				  int nlflags);
> -int switchdev_port_bridge_setlink(struct net_device *dev,
> -				  struct nlmsghdr *nlh, u16 flags);
> -int switchdev_port_bridge_dellink(struct net_device *dev,
> -				  struct nlmsghdr *nlh, u16 flags);
> -int switchdev_port_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
> -			   struct net_device *dev, const unsigned char *addr,
> -			   u16 vid, u16 nlm_flags);
> -int switchdev_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
> -			   struct net_device *dev, const unsigned char *addr,
> -			   u16 vid);
>  void switchdev_port_fwd_mark_set(struct net_device *dev,
>  				 struct net_device *group_dev,
>  				 bool joining);
> @@ -246,13 +214,6 @@ static inline int switchdev_port_obj_del(struct net_device *dev,
>  	return -EOPNOTSUPP;
>  }
>  
> -static inline int switchdev_port_obj_dump(struct net_device *dev,
> -					  const struct switchdev_obj *obj,
> -					  switchdev_obj_dump_cb_t *cb)
> -{
> -	return -EOPNOTSUPP;
> -}
> -
>  static inline int register_switchdev_notifier(struct notifier_block *nb)
>  {
>  	return 0;
> @@ -270,42 +231,6 @@ static inline int call_switchdev_notifiers(unsigned long val,
>  	return NOTIFY_DONE;
>  }
>  
> -static inline int switchdev_port_bridge_getlink(struct sk_buff *skb, u32 pid,
> -					    u32 seq, struct net_device *dev,
> -					    u32 filter_mask, int nlflags)
> -{
> -	return -EOPNOTSUPP;
> -}
> -
> -static inline int switchdev_port_bridge_setlink(struct net_device *dev,
> -						struct nlmsghdr *nlh,
> -						u16 flags)
> -{
> -	return -EOPNOTSUPP;
> -}
> -
> -static inline int switchdev_port_bridge_dellink(struct net_device *dev,
> -						struct nlmsghdr *nlh,
> -						u16 flags)
> -{
> -	return -EOPNOTSUPP;
> -}
> -
> -static inline int switchdev_port_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
> -					 struct net_device *dev,
> -					 const unsigned char *addr,
> -					 u16 vid, u16 nlm_flags)
> -{
> -	return -EOPNOTSUPP;
> -}
> -
> -static inline int switchdev_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
> -					 struct net_device *dev,
> -					 const unsigned char *addr, u16 vid)
> -{
> -	return -EOPNOTSUPP;
> -}
> -
>  static inline bool switchdev_port_same_parent_id(struct net_device *a,
>  						 struct net_device *b)
>  {
> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
> index 3d32981..0531b41 100644
> --- a/net/switchdev/switchdev.c
> +++ b/net/switchdev/switchdev.c
> @@ -343,8 +343,6 @@ static size_t switchdev_obj_size(const struct switchdev_obj *obj)
>  	switch (obj->id) {
>  	case SWITCHDEV_OBJ_ID_PORT_VLAN:
>  		return sizeof(struct switchdev_obj_port_vlan);
> -	case SWITCHDEV_OBJ_ID_PORT_FDB:
> -		return sizeof(struct switchdev_obj_port_fdb);
>  	case SWITCHDEV_OBJ_ID_PORT_MDB:
>  		return sizeof(struct switchdev_obj_port_mdb);
>  	default:
> @@ -534,43 +532,6 @@ int switchdev_port_obj_del(struct net_device *dev,
>  }
>  EXPORT_SYMBOL_GPL(switchdev_port_obj_del);
>  
> -/**
> - *	switchdev_port_obj_dump - Dump port objects
> - *
> - *	@dev: port device
> - *	@id: object ID
> - *	@obj: object to dump
> - *	@cb: function to call with a filled object
> - *
> - *	rtnl_lock must be held.
> - */
> -int switchdev_port_obj_dump(struct net_device *dev, struct switchdev_obj *obj,
> -			    switchdev_obj_dump_cb_t *cb)
> -{
> -	const struct switchdev_ops *ops = dev->switchdev_ops;
> -	struct net_device *lower_dev;
> -	struct list_head *iter;
> -	int err = -EOPNOTSUPP;
> -
> -	ASSERT_RTNL();
> -
> -	if (ops && ops->switchdev_port_obj_dump)
> -		return ops->switchdev_port_obj_dump(dev, obj, cb);
> -
> -	/* Switch device port(s) may be stacked under
> -	 * bond/team/vlan dev, so recurse down to dump objects on
> -	 * first port at bottom of stack.
> -	 */
> -
> -	netdev_for_each_lower_dev(dev, lower_dev, iter) {
> -		err = switchdev_port_obj_dump(lower_dev, obj, cb);
> -		break;
> -	}
> -
> -	return err;
> -}
> -EXPORT_SYMBOL_GPL(switchdev_port_obj_dump);
> -
>  static ATOMIC_NOTIFIER_HEAD(switchdev_notif_chain);
>  
>  /**
> @@ -613,402 +574,6 @@ int call_switchdev_notifiers(unsigned long val, struct net_device *dev,
>  }
>  EXPORT_SYMBOL_GPL(call_switchdev_notifiers);
>  
> -struct switchdev_vlan_dump {
> -	struct switchdev_obj_port_vlan vlan;
> -	struct sk_buff *skb;
> -	u32 filter_mask;
> -	u16 flags;
> -	u16 begin;
> -	u16 end;
> -};
> -
> -static int switchdev_port_vlan_dump_put(struct switchdev_vlan_dump *dump)
> -{
> -	struct bridge_vlan_info vinfo;
> -
> -	vinfo.flags = dump->flags;
> -
> -	if (dump->begin == 0 && dump->end == 0) {
> -		return 0;
> -	} else if (dump->begin == dump->end) {
> -		vinfo.vid = dump->begin;
> -		if (nla_put(dump->skb, IFLA_BRIDGE_VLAN_INFO,
> -			    sizeof(vinfo), &vinfo))
> -			return -EMSGSIZE;
> -	} else {
> -		vinfo.vid = dump->begin;
> -		vinfo.flags |= BRIDGE_VLAN_INFO_RANGE_BEGIN;
> -		if (nla_put(dump->skb, IFLA_BRIDGE_VLAN_INFO,
> -			    sizeof(vinfo), &vinfo))
> -			return -EMSGSIZE;
> -		vinfo.vid = dump->end;
> -		vinfo.flags &= ~BRIDGE_VLAN_INFO_RANGE_BEGIN;
> -		vinfo.flags |= BRIDGE_VLAN_INFO_RANGE_END;
> -		if (nla_put(dump->skb, IFLA_BRIDGE_VLAN_INFO,
> -			    sizeof(vinfo), &vinfo))
> -			return -EMSGSIZE;
> -	}
> -
> -	return 0;
> -}
> -
> -static int switchdev_port_vlan_dump_cb(struct switchdev_obj *obj)
> -{
> -	struct switchdev_obj_port_vlan *vlan = SWITCHDEV_OBJ_PORT_VLAN(obj);
> -	struct switchdev_vlan_dump *dump =
> -		container_of(vlan, struct switchdev_vlan_dump, vlan);
> -	int err = 0;
> -
> -	if (vlan->vid_begin > vlan->vid_end)
> -		return -EINVAL;
> -
> -	if (dump->filter_mask & RTEXT_FILTER_BRVLAN) {
> -		dump->flags = vlan->flags;
> -		for (dump->begin = dump->end = vlan->vid_begin;
> -		     dump->begin <= vlan->vid_end;
> -		     dump->begin++, dump->end++) {
> -			err = switchdev_port_vlan_dump_put(dump);
> -			if (err)
> -				return err;
> -		}
> -	} else if (dump->filter_mask & RTEXT_FILTER_BRVLAN_COMPRESSED) {
> -		if (dump->begin > vlan->vid_begin &&
> -		    dump->begin >= vlan->vid_end) {
> -			if ((dump->begin - 1) == vlan->vid_end &&
> -			    dump->flags == vlan->flags) {
> -				/* prepend */
> -				dump->begin = vlan->vid_begin;
> -			} else {
> -				err = switchdev_port_vlan_dump_put(dump);
> -				dump->flags = vlan->flags;
> -				dump->begin = vlan->vid_begin;
> -				dump->end = vlan->vid_end;
> -			}
> -		} else if (dump->end <= vlan->vid_begin &&
> -		           dump->end < vlan->vid_end) {
> -			if ((dump->end  + 1) == vlan->vid_begin &&
> -			    dump->flags == vlan->flags) {
> -				/* append */
> -				dump->end = vlan->vid_end;
> -			} else {
> -				err = switchdev_port_vlan_dump_put(dump);
> -				dump->flags = vlan->flags;
> -				dump->begin = vlan->vid_begin;
> -				dump->end = vlan->vid_end;
> -			}
> -		} else {
> -			err = -EINVAL;
> -		}
> -	}
> -
> -	return err;
> -}
> -
> -static int switchdev_port_vlan_fill(struct sk_buff *skb, struct net_device *dev,
> -				    u32 filter_mask)
> -{
> -	struct switchdev_vlan_dump dump = {
> -		.vlan.obj.orig_dev = dev,
> -		.vlan.obj.id = SWITCHDEV_OBJ_ID_PORT_VLAN,
> -		.skb = skb,
> -		.filter_mask = filter_mask,
> -	};
> -	int err = 0;
> -
> -	if ((filter_mask & RTEXT_FILTER_BRVLAN) ||
> -	    (filter_mask & RTEXT_FILTER_BRVLAN_COMPRESSED)) {
> -		err = switchdev_port_obj_dump(dev, &dump.vlan.obj,
> -					      switchdev_port_vlan_dump_cb);
> -		if (err)
> -			goto err_out;
> -		if (filter_mask & RTEXT_FILTER_BRVLAN_COMPRESSED)
> -			/* last one */
> -			err = switchdev_port_vlan_dump_put(&dump);
> -	}
> -
> -err_out:
> -	return err == -EOPNOTSUPP ? 0 : err;
> -}
> -
> -/**
> - *	switchdev_port_bridge_getlink - Get bridge port attributes
> - *
> - *	@dev: port device
> - *
> - *	Called for SELF on rtnl_bridge_getlink to get bridge port
> - *	attributes.
> - */
> -int switchdev_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
> -				  struct net_device *dev, u32 filter_mask,
> -				  int nlflags)
> -{
> -	struct switchdev_attr attr = {
> -		.orig_dev = dev,
> -		.id = SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS,
> -	};
> -	u16 mode = BRIDGE_MODE_UNDEF;
> -	u32 mask = BR_LEARNING | BR_LEARNING_SYNC | BR_FLOOD;
> -	int err;
> -
> -	if (!netif_is_bridge_port(dev))
> -		return -EOPNOTSUPP;
> -
> -	err = switchdev_port_attr_get(dev, &attr);
> -	if (err && err != -EOPNOTSUPP)
> -		return err;
> -
> -	return ndo_dflt_bridge_getlink(skb, pid, seq, dev, mode,
> -				       attr.u.brport_flags, mask, nlflags,
> -				       filter_mask, switchdev_port_vlan_fill);
> -}
> -EXPORT_SYMBOL_GPL(switchdev_port_bridge_getlink);
> -
> -static int switchdev_port_br_setflag(struct net_device *dev,
> -				     struct nlattr *nlattr,
> -				     unsigned long brport_flag)
> -{
> -	struct switchdev_attr attr = {
> -		.orig_dev = dev,
> -		.id = SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS,
> -	};
> -	u8 flag = nla_get_u8(nlattr);
> -	int err;
> -
> -	err = switchdev_port_attr_get(dev, &attr);
> -	if (err)
> -		return err;
> -
> -	if (flag)
> -		attr.u.brport_flags |= brport_flag;
> -	else
> -		attr.u.brport_flags &= ~brport_flag;
> -
> -	return switchdev_port_attr_set(dev, &attr);
> -}
> -
> -static const struct nla_policy
> -switchdev_port_bridge_policy[IFLA_BRPORT_MAX + 1] = {
> -	[IFLA_BRPORT_STATE]		= { .type = NLA_U8 },
> -	[IFLA_BRPORT_COST]		= { .type = NLA_U32 },
> -	[IFLA_BRPORT_PRIORITY]		= { .type = NLA_U16 },
> -	[IFLA_BRPORT_MODE]		= { .type = NLA_U8 },
> -	[IFLA_BRPORT_GUARD]		= { .type = NLA_U8 },
> -	[IFLA_BRPORT_PROTECT]		= { .type = NLA_U8 },
> -	[IFLA_BRPORT_FAST_LEAVE]	= { .type = NLA_U8 },
> -	[IFLA_BRPORT_LEARNING]		= { .type = NLA_U8 },
> -	[IFLA_BRPORT_LEARNING_SYNC]	= { .type = NLA_U8 },
> -	[IFLA_BRPORT_UNICAST_FLOOD]	= { .type = NLA_U8 },
> -};
> -
> -static int switchdev_port_br_setlink_protinfo(struct net_device *dev,
> -					      struct nlattr *protinfo)
> -{
> -	struct nlattr *attr;
> -	int rem;
> -	int err;
> -
> -	err = nla_validate_nested(protinfo, IFLA_BRPORT_MAX,
> -				  switchdev_port_bridge_policy, NULL);
> -	if (err)
> -		return err;
> -
> -	nla_for_each_nested(attr, protinfo, rem) {
> -		switch (nla_type(attr)) {
> -		case IFLA_BRPORT_LEARNING:
> -			err = switchdev_port_br_setflag(dev, attr,
> -							BR_LEARNING);
> -			break;
> -		case IFLA_BRPORT_LEARNING_SYNC:
> -			err = switchdev_port_br_setflag(dev, attr,
> -							BR_LEARNING_SYNC);
> -			break;
> -		case IFLA_BRPORT_UNICAST_FLOOD:
> -			err = switchdev_port_br_setflag(dev, attr, BR_FLOOD);
> -			break;
> -		default:
> -			err = -EOPNOTSUPP;
> -			break;
> -		}
> -		if (err)
> -			return err;
> -	}
> -
> -	return 0;
> -}
> -
> -static int switchdev_port_br_afspec(struct net_device *dev,
> -				    struct nlattr *afspec,
> -				    int (*f)(struct net_device *dev,
> -					     const struct switchdev_obj *obj))
> -{
> -	struct nlattr *attr;
> -	struct bridge_vlan_info *vinfo;
> -	struct switchdev_obj_port_vlan vlan = {
> -		.obj.orig_dev = dev,
> -		.obj.id = SWITCHDEV_OBJ_ID_PORT_VLAN,
> -	};
> -	int rem;
> -	int err;
> -
> -	nla_for_each_nested(attr, afspec, rem) {
> -		if (nla_type(attr) != IFLA_BRIDGE_VLAN_INFO)
> -			continue;
> -		if (nla_len(attr) != sizeof(struct bridge_vlan_info))
> -			return -EINVAL;
> -		vinfo = nla_data(attr);
> -		if (!vinfo->vid || vinfo->vid >= VLAN_VID_MASK)
> -			return -EINVAL;
> -		vlan.flags = vinfo->flags;
> -		if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_BEGIN) {
> -			if (vlan.vid_begin)
> -				return -EINVAL;
> -			vlan.vid_begin = vinfo->vid;
> -			/* don't allow range of pvids */
> -			if (vlan.flags & BRIDGE_VLAN_INFO_PVID)
> -				return -EINVAL;
> -		} else if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_END) {
> -			if (!vlan.vid_begin)
> -				return -EINVAL;
> -			vlan.vid_end = vinfo->vid;
> -			if (vlan.vid_end <= vlan.vid_begin)
> -				return -EINVAL;
> -			err = f(dev, &vlan.obj);
> -			if (err)
> -				return err;
> -			vlan.vid_begin = 0;
> -		} else {
> -			if (vlan.vid_begin)
> -				return -EINVAL;
> -			vlan.vid_begin = vinfo->vid;
> -			vlan.vid_end = vinfo->vid;
> -			err = f(dev, &vlan.obj);
> -			if (err)
> -				return err;
> -			vlan.vid_begin = 0;
> -		}
> -	}
> -
> -	return 0;
> -}
> -
> -/**
> - *	switchdev_port_bridge_setlink - Set bridge port attributes
> - *
> - *	@dev: port device
> - *	@nlh: netlink header
> - *	@flags: netlink flags
> - *
> - *	Called for SELF on rtnl_bridge_setlink to set bridge port
> - *	attributes.
> - */
> -int switchdev_port_bridge_setlink(struct net_device *dev,
> -				  struct nlmsghdr *nlh, u16 flags)
> -{
> -	struct nlattr *protinfo;
> -	struct nlattr *afspec;
> -	int err = 0;
> -
> -	if (!netif_is_bridge_port(dev))
> -		return -EOPNOTSUPP;
> -
> -	protinfo = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg),
> -				   IFLA_PROTINFO);
> -	if (protinfo) {
> -		err = switchdev_port_br_setlink_protinfo(dev, protinfo);
> -		if (err)
> -			return err;
> -	}
> -
> -	afspec = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg),
> -				 IFLA_AF_SPEC);
> -	if (afspec)
> -		err = switchdev_port_br_afspec(dev, afspec,
> -					       switchdev_port_obj_add);
> -
> -	return err;
> -}
> -EXPORT_SYMBOL_GPL(switchdev_port_bridge_setlink);
> -
> -/**
> - *	switchdev_port_bridge_dellink - Set bridge port attributes
> - *
> - *	@dev: port device
> - *	@nlh: netlink header
> - *	@flags: netlink flags
> - *
> - *	Called for SELF on rtnl_bridge_dellink to set bridge port
> - *	attributes.
> - */
> -int switchdev_port_bridge_dellink(struct net_device *dev,
> -				  struct nlmsghdr *nlh, u16 flags)
> -{
> -	struct nlattr *afspec;
> -
> -	if (!netif_is_bridge_port(dev))
> -		return -EOPNOTSUPP;
> -
> -	afspec = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg),
> -				 IFLA_AF_SPEC);
> -	if (afspec)
> -		return switchdev_port_br_afspec(dev, afspec,
> -						switchdev_port_obj_del);
> -
> -	return 0;
> -}
> -EXPORT_SYMBOL_GPL(switchdev_port_bridge_dellink);
> -
> -/**
> - *	switchdev_port_fdb_add - Add FDB (MAC/VLAN) entry to port
> - *
> - *	@ndmsg: netlink hdr
> - *	@nlattr: netlink attributes
> - *	@dev: port device
> - *	@addr: MAC address to add
> - *	@vid: VLAN to add
> - *
> - *	Add FDB entry to switch device.
> - */
> -int switchdev_port_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
> -			   struct net_device *dev, const unsigned char *addr,
> -			   u16 vid, u16 nlm_flags)
> -{
> -	struct switchdev_obj_port_fdb fdb = {
> -		.obj.orig_dev = dev,
> -		.obj.id = SWITCHDEV_OBJ_ID_PORT_FDB,
> -		.vid = vid,
> -	};
> -
> -	ether_addr_copy(fdb.addr, addr);
> -	return switchdev_port_obj_add(dev, &fdb.obj);
> -}
> -EXPORT_SYMBOL_GPL(switchdev_port_fdb_add);
> -
> -/**
> - *	switchdev_port_fdb_del - Delete FDB (MAC/VLAN) entry from port
> - *
> - *	@ndmsg: netlink hdr
> - *	@nlattr: netlink attributes
> - *	@dev: port device
> - *	@addr: MAC address to delete
> - *	@vid: VLAN to delete
> - *
> - *	Delete FDB entry from switch device.
> - */
> -int switchdev_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
> -			   struct net_device *dev, const unsigned char *addr,
> -			   u16 vid)
> -{
> -	struct switchdev_obj_port_fdb fdb = {
> -		.obj.orig_dev = dev,
> -		.obj.id = SWITCHDEV_OBJ_ID_PORT_FDB,
> -		.vid = vid,
> -	};
> -
> -	ether_addr_copy(fdb.addr, addr);
> -	return switchdev_port_obj_del(dev, &fdb.obj);
> -}
> -EXPORT_SYMBOL_GPL(switchdev_port_fdb_del);
> -
>  bool switchdev_port_same_parent_id(struct net_device *a,
>  				   struct net_device *b)
>  {
> 

Reviewed-by: Ivan Vecera <ivecera@redhat.com>
