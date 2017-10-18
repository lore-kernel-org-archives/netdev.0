From: Andrei Vagin <avagin@virtuozzo.com>
Subject: Re: [10/26] netfilter: Allow xt_owner in any user namespace
Date: Wed, 18 Oct 2017 16:00:41 -0700
Message-ID: <20171018230040.GA3134@outlook.office365.com>
References: <1467815048-2240-11-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr50119.outbound.protection.outlook.com ([40.107.5.119]:55917
        "EHLO EUR03-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750926AbdJRXA7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Oct 2017 19:00:59 -0400
Content-Disposition: inline
In-Reply-To: <1467815048-2240-11-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 06, 2016 at 04:23:52PM +0200, Pablo Neira Ayuso wrote:
> From: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> Making this work is a little tricky as it really isn't kosher to
> change the xt_owner_match_info in a check function.
> 
> Without changing xt_owner_match_info we need to know the user
> namespace the uids and gids are specified in.  In the common case
> net->user_ns == current_user_ns().  Verify net->user_ns ==
> current_user_ns() in owner_check so we can later assume it in
> owner_mt.
> 
> In owner_check also verify that all of the uids and gids specified are
> in net->user_ns and that the expected min/max relationship exists
> between the uids and gids in xt_owner_match_info.
> 
> In owner_mt get the network namespace from the outgoing socket, as this
> must be the same network namespace as the netfilter rules, and use that
> network namespace to find the user namespace the uids and gids in
> xt_match_owner_info are encoded in.  Then convert from their encoded
> from into the kernel internal format for uids and gids and perform the
> owner match.
> 
> Similar to ping_group_range, this code does not try to detect
> noncontiguous UID/GID ranges.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> Signed-off-by: Kevin Cernekee <cernekee@chromium.org>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> ---
>  net/netfilter/xt_owner.c | 41 +++++++++++++++++++++++++++++++++++------
>  1 file changed, 35 insertions(+), 6 deletions(-)
> 
> diff --git a/net/netfilter/xt_owner.c b/net/netfilter/xt_owner.c
> index 1302b47..a20e731 100644
> --- a/net/netfilter/xt_owner.c
> +++ b/net/netfilter/xt_owner.c
> @@ -21,11 +21,39 @@
>  static int owner_check(const struct xt_mtchk_param *par)
>  {
>  	struct xt_owner_match_info *info = par->matchinfo;
> +	struct net *net = par->net;
>  
> -	/* For now only allow adding matches from the initial user namespace */
> +	/* Only allow the common case where the userns of the writer
> +	 * matches the userns of the network namespace.
> +	 */
>  	if ((info->match & (XT_OWNER_UID|XT_OWNER_GID)) &&
> -	    (current_user_ns() != &init_user_ns))
> +	    (current_user_ns() != net->user_ns))
>  		return -EINVAL;

Here is an issue. If we once added an xt_owner rule, we will not be able to
add/delete/change any other iptables rules from other user namespaces even from
init_user_ns.

We meet this issue in CRIU. We add a few rules to block all traffic in a
network namespace before dumping sockets:

[avagin@laptop ~]$ cat criu-netlock.nf 
*filter
:CRIU - [0:0]
-I INPUT -j CRIU
-I OUTPUT -j CRIU
-A CRIU -j DROP
COMMIT

We execute iptables-restore in a target netns from init_user_ns, and it's
always worked for us before we meet xt_owner rules.

[avagin@laptop ~]$ unshare -Urn sh -c 'iptables -t filter -A OUTPUT -p tcp --dport 666 -m owner --uid-owner 0 -j DROP && echo $$; sleep 1000'
16375
^Z
[1]+  Stopped                 unshare -Urn sh -c 'iptables -t filter -A OUTPUT -p tcp --dport 666 -m owner --uid-owner 0 -j DROP && echo $$; sleep 1000'

[avagin@laptop ~]$ sudo nsenter -n -t 16375 -- /usr/sbin/iptables-restore -n < criu-netlock.nf 
iptables-restore: line 6 failed

# now let's try to remove the xt_owner rule and check that everything works as expected
[avagin@laptop ~]$ sudo nsenter -n -t 16375 -- iptables -t filter -D OUTPUT -p tcp --dport 666 -m owner --uid-owner 0 -j DROP
[avagin@laptop ~]$ sudo nsenter -n -t 16375 -- /usr/sbin/iptables-restore -n < criu-netlock.nf 

> +
> +	/* Ensure the uids are valid */
> +	if (info->match & XT_OWNER_UID) {
> +		kuid_t uid_min = make_kuid(net->user_ns, info->uid_min);
> +		kuid_t uid_max = make_kuid(net->user_ns, info->uid_max);
> +
> +		if (!uid_valid(uid_min) || !uid_valid(uid_max) ||
> +		    (info->uid_max < info->uid_min) ||
> +		    uid_lt(uid_max, uid_min)) {
> +			return -EINVAL;
> +		}
> +	}
> +
> +	/* Ensure the gids are valid */
> +	if (info->match & XT_OWNER_GID) {
> +		kgid_t gid_min = make_kgid(net->user_ns, info->gid_min);
> +		kgid_t gid_max = make_kgid(net->user_ns, info->gid_max);
> +
> +		if (!gid_valid(gid_min) || !gid_valid(gid_max) ||
> +		    (info->gid_max < info->gid_min) ||
> +		    gid_lt(gid_max, gid_min)) {
> +			return -EINVAL;
> +		}
> +	}
> +
>  	return 0;
>  }
>  
> @@ -35,6 +63,7 @@ owner_mt(const struct sk_buff *skb, struct xt_action_param *par)
>  	const struct xt_owner_match_info *info = par->matchinfo;
>  	const struct file *filp;
>  	struct sock *sk = skb_to_full_sk(skb);
> +	struct net *net = par->net;
>  
>  	if (sk == NULL || sk->sk_socket == NULL)
>  		return (info->match ^ info->invert) == 0;
> @@ -51,8 +80,8 @@ owner_mt(const struct sk_buff *skb, struct xt_action_param *par)
>  		       (XT_OWNER_UID | XT_OWNER_GID)) == 0;
>  
>  	if (info->match & XT_OWNER_UID) {
> -		kuid_t uid_min = make_kuid(&init_user_ns, info->uid_min);
> -		kuid_t uid_max = make_kuid(&init_user_ns, info->uid_max);
> +		kuid_t uid_min = make_kuid(net->user_ns, info->uid_min);
> +		kuid_t uid_max = make_kuid(net->user_ns, info->uid_max);
>  		if ((uid_gte(filp->f_cred->fsuid, uid_min) &&
>  		     uid_lte(filp->f_cred->fsuid, uid_max)) ^
>  		    !(info->invert & XT_OWNER_UID))
> @@ -60,8 +89,8 @@ owner_mt(const struct sk_buff *skb, struct xt_action_param *par)
>  	}
>  
>  	if (info->match & XT_OWNER_GID) {
> -		kgid_t gid_min = make_kgid(&init_user_ns, info->gid_min);
> -		kgid_t gid_max = make_kgid(&init_user_ns, info->gid_max);
> +		kgid_t gid_min = make_kgid(net->user_ns, info->gid_min);
> +		kgid_t gid_max = make_kgid(net->user_ns, info->gid_max);
>  		if ((gid_gte(filp->f_cred->fsgid, gid_min) &&
>  		     gid_lte(filp->f_cred->fsgid, gid_max)) ^
>  		    !(info->invert & XT_OWNER_GID))
