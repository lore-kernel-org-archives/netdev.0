From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] openvswitch: allow management from inside user namespaces
Date: Fri, 29 Jan 2016 08:29:55 -0600
Message-ID: <8760yccvbw.fsf@x220.int.ebiederm.org>
References: <1454072433-20137-1-git-send-email-tycho.andersen@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pravin Shelar <pshelar-LZ6Gd1LRuIk@public.gmane.org>,
	Justin Pettit <jpettit-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1454072433-20137-1-git-send-email-tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
	(Tycho Andersen's message of "Fri, 29 Jan 2016 14:00:33 +0100")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> writes:

> Operations with the GENL_ADMIN_PERM flag fail permissions checks because
> this flag means we call netlink_capable, which uses the init user ns.
>
> Instead, let's do permissions checks in each function, but use the netlink
> socket's user ns instead of the initial one, to allow management of
> openvswitch resources from inside a user ns.
>
> The motivation for this is to be able to run openvswitch in unprivileged
> containers. I've tested this and it seems to work, but I really have no
> idea about the security consequences of this patch, so thoughts would be
> much appreciated.

So at a quick look using ns_capable this way is probably buggy.

netlink is goofy (because historically we got this wrong), and I forget
what the specific rules are.  The general rule is that you need to do
your permission checks on open/create/connect and not inside send/write
while processing data.  Otherwise there is a class of privileged
applications where you can set their stdout to some precreated file
descriptor and their output can be made to act as a command, bypassing
your permission checks.

Eric

> Reported-by: James Page <james.page-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> Signed-off-by: Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> CC: Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> CC: Pravin Shelar <pshelar-LZ6Gd1LRuIk@public.gmane.org>
> CC: Justin Pettit <jpettit-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
> CC: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> ---
>  net/openvswitch/datapath.c | 63 ++++++++++++++++++++++++++++++++++++++--------
>  1 file changed, 53 insertions(+), 10 deletions(-)
>
> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> index deadfda..aacfb11 100644
> --- a/net/openvswitch/datapath.c
> +++ b/net/openvswitch/datapath.c
> @@ -557,6 +557,10 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
>  	int err;
>  	bool log = !a[OVS_PACKET_ATTR_PROBE];
>  
> +	err = -EPERM;
> +	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
> +		goto err;
> +
>  	err = -EINVAL;
>  	if (!a[OVS_PACKET_ATTR_PACKET] || !a[OVS_PACKET_ATTR_KEY] ||
>  	    !a[OVS_PACKET_ATTR_ACTIONS])
> @@ -654,7 +658,7 @@ static const struct nla_policy packet_policy[OVS_PACKET_ATTR_MAX + 1] = {
>  
>  static const struct genl_ops dp_packet_genl_ops[] = {
>  	{ .cmd = OVS_PACKET_CMD_EXECUTE,
> -	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
> +	  .flags = 0,
>  	  .policy = packet_policy,
>  	  .doit = ovs_packet_cmd_execute
>  	}
> @@ -920,6 +924,10 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
>  	int error;
>  	bool log = !a[OVS_FLOW_ATTR_PROBE];
>  
> +	error = -EPERM;
> +	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
> +		goto error;
> +
>  	/* Must have key and actions. */
>  	error = -EINVAL;
>  	if (!a[OVS_FLOW_ATTR_KEY]) {
> @@ -1104,6 +1112,10 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
>  	bool log = !a[OVS_FLOW_ATTR_PROBE];
>  	bool ufid_present;
>  
> +	error = -EPERM;
> +	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
> +		goto error;
> +
>  	/* Extract key. */
>  	error = -EINVAL;
>  	if (!a[OVS_FLOW_ATTR_KEY]) {
> @@ -1274,6 +1286,9 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
>  	bool log = !a[OVS_FLOW_ATTR_PROBE];
>  	bool ufid_present;
>  
> +	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
> +		return -EPERM;
> +
>  	ufid_present = ovs_nla_get_ufid(&ufid, a[OVS_FLOW_ATTR_UFID], log);
>  	if (a[OVS_FLOW_ATTR_KEY]) {
>  		ovs_match_init(&match, &key, NULL);
> @@ -1391,12 +1406,12 @@ static const struct nla_policy flow_policy[OVS_FLOW_ATTR_MAX + 1] = {
>  
>  static const struct genl_ops dp_flow_genl_ops[] = {
>  	{ .cmd = OVS_FLOW_CMD_NEW,
> -	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
> +	  .flags = 0,
>  	  .policy = flow_policy,
>  	  .doit = ovs_flow_cmd_new
>  	},
>  	{ .cmd = OVS_FLOW_CMD_DEL,
> -	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
> +	  .flags = 0,
>  	  .policy = flow_policy,
>  	  .doit = ovs_flow_cmd_del
>  	},
> @@ -1407,7 +1422,7 @@ static const struct genl_ops dp_flow_genl_ops[] = {
>  	  .dumpit = ovs_flow_cmd_dump
>  	},
>  	{ .cmd = OVS_FLOW_CMD_SET,
> -	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
> +	  .flags = 0,
>  	  .policy = flow_policy,
>  	  .doit = ovs_flow_cmd_set,
>  	},
> @@ -1530,8 +1545,12 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
>  	struct datapath *dp;
>  	struct vport *vport;
>  	struct ovs_net *ovs_net;
> +	struct net *net = sock_net(skb->sk);
>  	int err, i;
>  
> +	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
> +		return -EPERM;
> +
>  	err = -EINVAL;
>  	if (!a[OVS_DP_ATTR_NAME] || !a[OVS_DP_ATTR_UPCALL_PID])
>  		goto err;
> @@ -1655,8 +1674,12 @@ static int ovs_dp_cmd_del(struct sk_buff *skb, struct genl_info *info)
>  {
>  	struct sk_buff *reply;
>  	struct datapath *dp;
> +	struct net *net = sock_net(skb->sk);
>  	int err;
>  
> +	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
> +		return -EPERM;
> +
>  	reply = ovs_dp_cmd_alloc_info(info);
>  	if (!reply)
>  		return -ENOMEM;
> @@ -1688,8 +1711,12 @@ static int ovs_dp_cmd_set(struct sk_buff *skb, struct genl_info *info)
>  {
>  	struct sk_buff *reply;
>  	struct datapath *dp;
> +	struct net *net = sock_net(skb->sk);
>  	int err;
>  
> +	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
> +		return -EPERM;
> +
>  	reply = ovs_dp_cmd_alloc_info(info);
>  	if (!reply)
>  		return -ENOMEM;
> @@ -1721,8 +1748,12 @@ static int ovs_dp_cmd_get(struct sk_buff *skb, struct genl_info *info)
>  {
>  	struct sk_buff *reply;
>  	struct datapath *dp;
> +	struct net *net = sock_net(skb->sk);
>  	int err;
>  
> +	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
> +		return -EPERM;
> +
>  	reply = ovs_dp_cmd_alloc_info(info);
>  	if (!reply)
>  		return -ENOMEM;
> @@ -1777,12 +1808,12 @@ static const struct nla_policy datapath_policy[OVS_DP_ATTR_MAX + 1] = {
>  
>  static const struct genl_ops dp_datapath_genl_ops[] = {
>  	{ .cmd = OVS_DP_CMD_NEW,
> -	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
> +	  .flags = 0,
>  	  .policy = datapath_policy,
>  	  .doit = ovs_dp_cmd_new
>  	},
>  	{ .cmd = OVS_DP_CMD_DEL,
> -	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
> +	  .flags = 0,
>  	  .policy = datapath_policy,
>  	  .doit = ovs_dp_cmd_del
>  	},
> @@ -1793,7 +1824,7 @@ static const struct genl_ops dp_datapath_genl_ops[] = {
>  	  .dumpit = ovs_dp_cmd_dump
>  	},
>  	{ .cmd = OVS_DP_CMD_SET,
> -	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
> +	  .flags = 0,
>  	  .policy = datapath_policy,
>  	  .doit = ovs_dp_cmd_set,
>  	},
> @@ -1920,9 +1951,13 @@ static int ovs_vport_cmd_new(struct sk_buff *skb, struct genl_info *info)
>  	struct sk_buff *reply;
>  	struct vport *vport;
>  	struct datapath *dp;
> +	struct net *net = sock_net(skb->sk);
>  	u32 port_no;
>  	int err;
>  
> +	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
> +		return -EPERM;
> +
>  	if (!a[OVS_VPORT_ATTR_NAME] || !a[OVS_VPORT_ATTR_TYPE] ||
>  	    !a[OVS_VPORT_ATTR_UPCALL_PID])
>  		return -EINVAL;
> @@ -1994,8 +2029,12 @@ static int ovs_vport_cmd_set(struct sk_buff *skb, struct genl_info *info)
>  	struct nlattr **a = info->attrs;
>  	struct sk_buff *reply;
>  	struct vport *vport;
> +	struct net *net = sock_net(skb->sk);
>  	int err;
>  
> +	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
> +		return -EPERM;
> +
>  	reply = ovs_vport_cmd_alloc_info();
>  	if (!reply)
>  		return -ENOMEM;
> @@ -2046,8 +2085,12 @@ static int ovs_vport_cmd_del(struct sk_buff *skb, struct genl_info *info)
>  	struct nlattr **a = info->attrs;
>  	struct sk_buff *reply;
>  	struct vport *vport;
> +	struct net *net = sock_net(skb->sk);
>  	int err;
>  
> +	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
> +		return -EPERM;
> +
>  	reply = ovs_vport_cmd_alloc_info();
>  	if (!reply)
>  		return -ENOMEM;
> @@ -2158,12 +2201,12 @@ static const struct nla_policy vport_policy[OVS_VPORT_ATTR_MAX + 1] = {
>  
>  static const struct genl_ops dp_vport_genl_ops[] = {
>  	{ .cmd = OVS_VPORT_CMD_NEW,
> -	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
> +	  .flags = 0,
>  	  .policy = vport_policy,
>  	  .doit = ovs_vport_cmd_new
>  	},
>  	{ .cmd = OVS_VPORT_CMD_DEL,
> -	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
> +	  .flags = 0,
>  	  .policy = vport_policy,
>  	  .doit = ovs_vport_cmd_del
>  	},
> @@ -2174,7 +2217,7 @@ static const struct genl_ops dp_vport_genl_ops[] = {
>  	  .dumpit = ovs_vport_cmd_dump
>  	},
>  	{ .cmd = OVS_VPORT_CMD_SET,
> -	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
> +	  .flags = 0,
>  	  .policy = vport_policy,
>  	  .doit = ovs_vport_cmd_set,
>  	},
