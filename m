From: Kevin Wilson <wkevils@gmail.com>
Subject: Re: [PATCH 5/7] bridge: allow creating/deleting fdb entries via netlink
Date: Wed, 5 Oct 2011 21:06:54 +0200
Message-ID: <CAGXs5wXc0RLE9KbTVVYRa0xuLEKh8mTM7AR7hMBe86HNfDX0HQ@mail.gmail.com>
References: <20110405000326.714524584@vyatta.com>
	<20110405000537.372602366@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:57342 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934299Ab1JETGz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 15:06:55 -0400
Received: by vws1 with SMTP id 1so1609907vws.19
        for <netdev@vger.kernel.org>; Wed, 05 Oct 2011 12:06:54 -0700 (PDT)
In-Reply-To: <20110405000537.372602366@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,
I would appreciate if someone can elaborate about "bridge extensions
to iproute2" mentioned here.
I downloaded latest iproute2 git tree and did not find it there.
googling for it did not gave much info about it.
I will appreciate if someone can tell  who develop it, what is the
status, site, repository tree, etc.

rgs,
Kevin

On Tue, Apr 5, 2011 at 3:03 AM, Stephen Hemminger <shemminger@vyatta.co=
m> wrote:
> Use RTM_NEWNEIGH and RTM_DELNEIGH to allow updating of entries
> in bridge forwarding table. This allows manipulating static entries
> which is not possible with existing tools.
>
> Example (using bridge extensions to iproute2)
> =A0 # br fdb add 00:02:03:04:05:06 dev eth0
>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>
> ---
> =A0net/bridge/br_fdb.c =A0 =A0 | =A0139 +++++++++++++++++++++++++++++=
+++++++++++++++++++
> =A0net/bridge/br_netlink.c | =A0 =A03 +
> =A0net/bridge/br_private.h | =A0 =A02
> =A03 files changed, 144 insertions(+)
>
> --- a/net/bridge/br_fdb.c =A0 =A0 =A0 2011-03-22 10:25:00.329008182 -=
0700
> +++ b/net/bridge/br_fdb.c =A0 =A0 =A0 2011-03-22 10:25:01.057042585 -=
0700
> @@ -555,3 +555,142 @@ skip:
>
> =A0 =A0 =A0 =A0return skb->len;
> =A0}
> +
> +/* Create new static fdb entry */
> +static int fdb_add_entry(struct net_bridge_port *source, const __u8 =
*addr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__u16 state)
> +{
> + =A0 =A0 =A0 struct net_bridge *br =3D source->br;
> + =A0 =A0 =A0 struct hlist_head *head =3D &br->hash[br_mac_hash(addr)=
];
> + =A0 =A0 =A0 struct net_bridge_fdb_entry *fdb;
> +
> + =A0 =A0 =A0 fdb =3D fdb_find(head, addr);
> + =A0 =A0 =A0 if (fdb)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EEXIST;
> +
> + =A0 =A0 =A0 fdb =3D fdb_create(head, source, addr);
> + =A0 =A0 =A0 if (!fdb)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> +
> + =A0 =A0 =A0 if (state & NUD_PERMANENT)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 fdb->is_local =3D fdb->is_static =3D 1;
> + =A0 =A0 =A0 else if (state & NUD_NOARP)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 fdb->is_static =3D 1;
> + =A0 =A0 =A0 return 0;
> +}
> +
> +/* Add new permanent fdb entry with RTM_NEWNEIGH */
> +int br_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
> +{
> + =A0 =A0 =A0 struct net *net =3D sock_net(skb->sk);
> + =A0 =A0 =A0 struct ndmsg *ndm;
> + =A0 =A0 =A0 struct nlattr *tb[NDA_MAX+1];
> + =A0 =A0 =A0 struct net_device *dev;
> + =A0 =A0 =A0 struct net_bridge_port *p;
> + =A0 =A0 =A0 const __u8 *addr;
> + =A0 =A0 =A0 int err;
> +
> + =A0 =A0 =A0 ASSERT_RTNL();
> + =A0 =A0 =A0 err =3D nlmsg_parse(nlh, sizeof(*ndm), tb, NDA_MAX, NUL=
L);
> + =A0 =A0 =A0 if (err < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
> +
> + =A0 =A0 =A0 ndm =3D nlmsg_data(nlh);
> + =A0 =A0 =A0 if (ndm->ndm_ifindex =3D=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_info("bridge: RTM_NEWNEIGH with inva=
lid ifindex\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 dev =3D __dev_get_by_index(net, ndm->ndm_ifindex);
> + =A0 =A0 =A0 if (dev =3D=3D NULL) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_info("bridge: RTM_NEWNEIGH with unkn=
own ifindex\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (!tb[NDA_LLADDR] || nla_len(tb[NDA_LLADDR]) !=3D ETH=
_ALEN) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_info("bridge: RTM_NEWNEIGH with inva=
lid address\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 addr =3D nla_data(tb[NDA_LLADDR]);
> + =A0 =A0 =A0 if (!is_valid_ether_addr(addr)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_info("bridge: RTM_NEWNEIGH with inva=
lid ether address\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 p =3D br_port_get_rtnl(dev);
> + =A0 =A0 =A0 if (p =3D=3D NULL) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_info("bridge: RTM_NEWNEIGH %s not a =
bridge port\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->name);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 spin_lock_bh(&p->br->hash_lock);
> + =A0 =A0 =A0 err =3D fdb_add_entry(p, addr, ndm->ndm_state);
> + =A0 =A0 =A0 spin_unlock_bh(&p->br->hash_lock);
> +
> + =A0 =A0 =A0 return err;
> +}
> +
> +static int fdb_delete_by_addr(struct net_bridge_port *p, const u8 *a=
ddr)
> +{
> + =A0 =A0 =A0 struct net_bridge *br =3D p->br;
> + =A0 =A0 =A0 struct hlist_head *head =3D &br->hash[br_mac_hash(addr)=
];
> + =A0 =A0 =A0 struct net_bridge_fdb_entry *fdb;
> +
> + =A0 =A0 =A0 fdb =3D fdb_find(head, addr);
> + =A0 =A0 =A0 if (!fdb)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOENT;
> +
> + =A0 =A0 =A0 fdb_delete(fdb);
> + =A0 =A0 =A0 return 0;
> +}
> +
> +/* Remove neighbor entry with RTM_DELNEIGH */
> +int br_fdb_delete(struct sk_buff *skb, struct nlmsghdr *nlh, void *a=
rg)
> +{
> + =A0 =A0 =A0 struct net *net =3D sock_net(skb->sk);
> + =A0 =A0 =A0 struct ndmsg *ndm;
> + =A0 =A0 =A0 struct net_bridge_port *p;
> + =A0 =A0 =A0 struct nlattr *llattr;
> + =A0 =A0 =A0 const __u8 *addr;
> + =A0 =A0 =A0 struct net_device *dev;
> + =A0 =A0 =A0 int err;
> +
> + =A0 =A0 =A0 ASSERT_RTNL();
> + =A0 =A0 =A0 if (nlmsg_len(nlh) < sizeof(*ndm))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> +
> + =A0 =A0 =A0 ndm =3D nlmsg_data(nlh);
> + =A0 =A0 =A0 if (ndm->ndm_ifindex =3D=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_info("bridge: RTM_DELNEIGH with inva=
lid ifindex\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 dev =3D __dev_get_by_index(net, ndm->ndm_ifindex);
> + =A0 =A0 =A0 if (dev =3D=3D NULL) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_info("bridge: RTM_DELNEIGH with unkn=
own ifindex\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 llattr =3D nlmsg_find_attr(nlh, sizeof(*ndm), NDA_LLADD=
R);
> + =A0 =A0 =A0 if (llattr =3D=3D NULL || nla_len(llattr) !=3D ETH_ALEN=
) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_info("bridge: RTM_DELNEIGH with inva=
lid address\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 addr =3D nla_data(llattr);
> +
> + =A0 =A0 =A0 p =3D br_port_get_rtnl(dev);
> + =A0 =A0 =A0 if (p =3D=3D NULL) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_info("bridge: RTM_DELNEIGH %s not a =
bridge port\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->name);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 spin_lock_bh(&p->br->hash_lock);
> + =A0 =A0 =A0 err =3D fdb_delete_by_addr(p, addr);
> + =A0 =A0 =A0 spin_unlock_bh(&p->br->hash_lock);
> +
> + =A0 =A0 =A0 return err;
> +}
> --- a/net/bridge/br_netlink.c =A0 2011-03-22 10:25:00.329008182 -0700
> +++ b/net/bridge/br_netlink.c =A0 2011-03-22 10:25:01.057042585 -0700
> @@ -196,6 +196,9 @@ int __init br_netlink_init(void)
>
> =A0 =A0 =A0 =A0/* Only the first call to __rtnl_register can fail */
> =A0 =A0 =A0 =A0__rtnl_register(PF_BRIDGE, RTM_SETLINK, br_rtm_setlink=
, NULL);
> +
> + =A0 =A0 =A0 __rtnl_register(PF_BRIDGE, RTM_NEWNEIGH, br_fdb_add, NU=
LL);
> + =A0 =A0 =A0 __rtnl_register(PF_BRIDGE, RTM_DELNEIGH, br_fdb_delete,=
 NULL);
> =A0 =A0 =A0 =A0__rtnl_register(PF_BRIDGE, RTM_GETNEIGH, NULL, br_fdb_=
dump);
>
> =A0 =A0 =A0 =A0return 0;
> --- a/net/bridge/br_private.h =A0 2011-03-22 10:25:00.329008182 -0700
> +++ b/net/bridge/br_private.h =A0 2011-03-22 10:25:01.057042585 -0700
> @@ -355,6 +355,8 @@ extern void br_fdb_update(struct net_bri
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct net_bridge_=
port *source,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const unsigned cha=
r *addr);
> =A0extern int br_fdb_dump(struct sk_buff *skb, struct netlink_callbac=
k *cb);
> +extern int br_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh, voi=
d *arg);
> +extern int br_fdb_delete(struct sk_buff *skb, struct nlmsghdr *nlh, =
void *arg);
>
> =A0/* br_forward.c */
> =A0extern void br_deliver(const struct net_bridge_port *to,
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
