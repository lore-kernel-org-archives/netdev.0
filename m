From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC net] netconf: set mulitcast family for multicast forwarding
 messages
Date: Mon, 01 Jul 2013 14:38:17 +0200
Message-ID: <51D17839.8010700@6wind.com>
References: <1372376687.21767.10.camel@imac-linux.luckyscavenger.com> <20130628082617.42a802a4@nehalam.linuxnetplumber.net> <51CDB1AD.1020202@6wind.com> <20130628091338.547bd88d@nehalam.linuxnetplumber.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sven-Thorsten Dietrich <sven@vyatta.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Mike Davison <Mike.Davison@vyatta.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130628091338.547bd88d@nehalam.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 28/06/2013 18:13, Stephen Hemminger a =E9crit :
> Revised version of Sven's patch. The idea is that multicast forwardin=
g
> should be under the multicast address family like other multicast net=
link
> messages.
>
> This version generates each family under separate headers when
> doing dump all.
>
> Compile tested only, this is to show some of the issues that need
> to be covered.
I'm ok with the principle, just some comment below.

>
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>
>
> --- a/net/ipv4/devinet.c	2013-06-11 09:50:21.550918636 -0700
> +++ b/net/ipv4/devinet.c	2013-06-28 09:07:18.147829543 -0700
> @@ -1685,6 +1685,11 @@ static int inet_netconf_msgsize_devconf(
>   		size +=3D nla_total_size(4);
>   	if (type =3D=3D -1 || type =3D=3D NETCONFA_RP_FILTER)
>   		size +=3D nla_total_size(4);
> +
> +	/* additional header for MC family */
> +	if (type =3D=3D -1)
> +		size +=3D NLMSG_ALIGN(sizeof(struct netconfmsg))
> +		   + nla_total_size(4);
>   	if (type =3D=3D -1 || type =3D=3D NETCONFA_MC_FORWARDING)
>   		size +=3D nla_total_size(4);
>
> @@ -1694,7 +1699,7 @@ static int inet_netconf_msgsize_devconf(
>   static int inet_netconf_fill_devconf(struct sk_buff *skb, int ifind=
ex,
>   				     struct ipv4_devconf *devconf, u32 portid,
>   				     u32 seq, int event, unsigned int flags,
> -				     int type)
> +				     u8 family, int type)
>   {
>   	struct nlmsghdr  *nlh;
>   	struct netconfmsg *ncm;
> @@ -1705,21 +1710,24 @@ static int inet_netconf_fill_devconf(str
>   		return -EMSGSIZE;
>
>   	ncm =3D nlmsg_data(nlh);
> -	ncm->ncm_family =3D AF_INET;
> +	ncm->ncm_family =3D family;
>
>   	if (nla_put_s32(skb, NETCONFA_IFINDEX, ifindex) < 0)
>   		goto nla_put_failure;
>
>   	/* type -1 is used for ALL */
> -	if ((type =3D=3D -1 || type =3D=3D NETCONFA_FORWARDING) &&
> +	if (((type =3D=3D -1 && family =3D=3D AF_INET) ||
> +	     type =3D=3D NETCONFA_FORWARDING)  &&
>   	    nla_put_s32(skb, NETCONFA_FORWARDING,
>   			IPV4_DEVCONF(*devconf, FORWARDING)) < 0)
>   		goto nla_put_failure;
> -	if ((type =3D=3D -1 || type =3D=3D NETCONFA_RP_FILTER) &&
> +	if (((type =3D=3D -1 && family =3D=3D AF_INET) ||
> +	     type =3D=3D NETCONFA_RP_FILTER) &&
>   	    nla_put_s32(skb, NETCONFA_RP_FILTER,
>   			IPV4_DEVCONF(*devconf, RP_FILTER)) < 0)
>   		goto nla_put_failure;
> -	if ((type =3D=3D -1 || type =3D=3D NETCONFA_MC_FORWARDING) &&
> +	if (((type =3D=3D -1 || family =3D=3D RTNL_FAMILY_IPMR) ||
should be '&&'

> +	     type =3D=3D NETCONFA_MC_FORWARDING) &&
>   	    nla_put_s32(skb, NETCONFA_MC_FORWARDING,
>   			IPV4_DEVCONF(*devconf, MC_FORWARDING)) < 0)
>   		goto nla_put_failure;
> @@ -1737,12 +1745,17 @@ void inet_netconf_notify_devconf(struct
>   	struct sk_buff *skb;
>   	int err =3D -ENOBUFS;
>
> +	BUG_ON(type =3D=3D -1); /* ALL is not valid for notification */
> +
>   	skb =3D nlmsg_new(inet_netconf_msgsize_devconf(type), GFP_ATOMIC);
>   	if (skb =3D=3D NULL)
>   		goto errout;
>
>   	err =3D inet_netconf_fill_devconf(skb, ifindex, devconf, 0, 0,
> -					RTM_NEWNETCONF, 0, type);
> +					RTM_NEWNETCONF, 0,
> +					(type =3D=3D NETCONFA_MC_FORWARDING) ?
> +					RTNL_FAMILY_IPMR : AF_INET,
> +					type);
>   	if (err < 0) {
>   		/* -EMSGSIZE implies BUG in inet_netconf_msgsize_devconf() */
>   		WARN_ON(err =3D=3D -EMSGSIZE);
> @@ -1811,13 +1824,23 @@ static int inet_netconf_get_devconf(stru
>   	err =3D inet_netconf_fill_devconf(skb, ifindex, devconf,
>   					NETLINK_CB(in_skb).portid,
>   					nlh->nlmsg_seq, RTM_NEWNETCONF, 0,
> -					-1);
> +					AF_INET, -1);
>   	if (err < 0) {
>   		/* -EMSGSIZE implies BUG in inet_netconf_msgsize_devconf() */
>   		WARN_ON(err =3D=3D -EMSGSIZE);
>   		kfree_skb(skb);
>   		goto errout;
>   	}
> +
> +	err =3D inet_netconf_fill_devconf(skb, ifindex, devconf,
> +					NETLINK_CB(in_skb).portid,
> +					nlh->nlmsg_seq, RTM_NEWNETCONF, 0,
> +					RTNL_FAMILY_IPMR, -1);
> +	if (err < 0) {
> +		WARN_ON(err =3D=3D -EMSGSIZE);
> +		kfree_skb(skb);
> +		goto errout;
> +	}
inet_netconf_fill_devconf() is called twice, so to be homogeneous, we c=
an call=20
inet_netconf_msgsize_devconf() twice too and add a argument 'family' to=
 this=20
function. Same for IPv6.

>   	err =3D rtnl_unicast(skb, net, NETLINK_CB(in_skb).portid);
>   errout:
>   	return err;
> @@ -1855,10 +1878,23 @@ static int inet_netconf_dump_devconf(str
>   						      cb->nlh->nlmsg_seq,
>   						      RTM_NEWNETCONF,
>   						      NLM_F_MULTI,
> +						      AF_INET,
> +						      -1) <=3D 0) {
> +				rcu_read_unlock();
> +				goto done;
> +			}
> +			if (inet_netconf_fill_devconf(skb, dev->ifindex,
> +						      &in_dev->cnf,
> +						      NETLINK_CB(cb->skb).portid,
> +						      cb->nlh->nlmsg_seq,
> +						      RTM_NEWNETCONF,
> +						      NLM_F_MULTI,
> +						      RTNL_FAMILY_IPMR,
>   						      -1) <=3D 0) {
>   				rcu_read_unlock();
>   				goto done;
>   			}
> +
>   			nl_dump_check_consistent(cb, nlmsg_hdr(skb));
>   cont:
>   			idx++;
> @@ -1871,10 +1907,18 @@ cont:
>   					      NETLINK_CB(cb->skb).portid,
>   					      cb->nlh->nlmsg_seq,
>   					      RTM_NEWNETCONF, NLM_F_MULTI,
> -					      -1) <=3D 0)
> +					      AF_INET, -1) <=3D 0)
> +			goto done;
> +
> +		if (inet_netconf_fill_devconf(skb, NETCONFA_IFINDEX_ALL,
> +					      net->ipv4.devconf_all,
> +					      NETLINK_CB(cb->skb).portid,
> +					      cb->nlh->nlmsg_seq,
> +					      RTM_NEWNETCONF, NLM_F_MULTI,
> +					      RTNL_FAMILY_IPMR, -1) <=3D 0)
>   			goto done;
> -		else
> -			h++;
> +
> +		h++;
>   	}
>   	if (h =3D=3D NETDEV_HASHENTRIES + 1) {
>   		if (inet_netconf_fill_devconf(skb, NETCONFA_IFINDEX_DEFAULT,
> @@ -1882,10 +1926,18 @@ cont:
>   					      NETLINK_CB(cb->skb).portid,
>   					      cb->nlh->nlmsg_seq,
>   					      RTM_NEWNETCONF, NLM_F_MULTI,
> -					      -1) <=3D 0)
> +					      AF_INET, -1) <=3D 0)
>   			goto done;
> -		else
> -			h++;
> +
> +		if (inet_netconf_fill_devconf(skb, NETCONFA_IFINDEX_DEFAULT,
> +					      net->ipv4.devconf_dflt,
> +					      NETLINK_CB(cb->skb).portid,
> +					      cb->nlh->nlmsg_seq,
> +					      RTM_NEWNETCONF, NLM_F_MULTI,
> +					      RTNL_FAMILY_IPMR, -1) <=3D 0)
> +			goto done;
> +
> +		h++;
>   	}
>   done:
>   	cb->args[0] =3D h;
> --- a/net/ipv6/addrconf.c	2013-06-28 08:17:16.424664740 -0700
> +++ b/net/ipv6/addrconf.c	2013-06-28 09:10:32.336959806 -0700
> @@ -471,6 +471,9 @@ static int inet6_netconf_msgsize_devconf
>   	if (type =3D=3D -1 || type =3D=3D NETCONFA_FORWARDING)
>   		size +=3D nla_total_size(4);
>   #ifdef CONFIG_IPV6_MROUTE
> +	if (type =3D=3D -1)
> +		size +=3D NLMSG_ALIGN(sizeof(struct netconfmsg))
> +			+ nla_total_size(4);
>   	if (type =3D=3D -1 || type =3D=3D NETCONFA_MC_FORWARDING)
>   		size +=3D nla_total_size(4);
>   #endif
> @@ -481,7 +484,7 @@ static int inet6_netconf_msgsize_devconf
>   static int inet6_netconf_fill_devconf(struct sk_buff *skb, int ifin=
dex,
>   				      struct ipv6_devconf *devconf, u32 portid,
>   				      u32 seq, int event, unsigned int flags,
> -				      int type)
> +				      u8 family, int type)
>   {
>   	struct nlmsghdr  *nlh;
>   	struct netconfmsg *ncm;
> @@ -492,17 +495,19 @@ static int inet6_netconf_fill_devconf(st
>   		return -EMSGSIZE;
>
>   	ncm =3D nlmsg_data(nlh);
> -	ncm->ncm_family =3D AF_INET6;
> +	ncm->ncm_family =3D family;
>
>   	if (nla_put_s32(skb, NETCONFA_IFINDEX, ifindex) < 0)
>   		goto nla_put_failure;
>
>   	/* type -1 is used for ALL */
> -	if ((type =3D=3D -1 || type =3D=3D NETCONFA_FORWARDING) &&
> +	if (((type =3D=3D -1 && family =3D=3D AF_INET6) ||
> +	     type =3D=3D NETCONFA_FORWARDING) &&
>   	    nla_put_s32(skb, NETCONFA_FORWARDING, devconf->forwarding) < 0=
)
>   		goto nla_put_failure;
>   #ifdef CONFIG_IPV6_MROUTE
> -	if ((type =3D=3D -1 || type =3D=3D NETCONFA_MC_FORWARDING) &&
> +	if (((type =3D=3D -1 && family =3D=3D RTNL_FAMILY_IP6MR) ||
> +	     type =3D=3D NETCONFA_MC_FORWARDING) &&
>   	    nla_put_s32(skb, NETCONFA_MC_FORWARDING,
>   			devconf->mc_forwarding) < 0)
>   		goto nla_put_failure;
> @@ -520,12 +525,23 @@ void inet6_netconf_notify_devconf(struct
>   	struct sk_buff *skb;
>   	int err =3D -ENOBUFS;
>
> +	BUG_ON(type =3D=3D -1);
> +
>   	skb =3D nlmsg_new(inet6_netconf_msgsize_devconf(type), GFP_ATOMIC)=
;
>   	if (skb =3D=3D NULL)
>   		goto errout;
>
> +#ifdef CONFIG_IPV6_MROUTE
> +	if (type =3D=3D NETCONFA_MC_FORWARDING)
> +		err =3D inet6_netconf_fill_devconf(skb, ifindex, devconf, 0, 0,
> +						 RTM_NEWNETCONF, 0,
> +						 RTNL_FAMILY_IP6MR, type);
> +	else
> +#endif
>   	err =3D inet6_netconf_fill_devconf(skb, ifindex, devconf, 0, 0,
> -					 RTM_NEWNETCONF, 0, type);
> +					 RTM_NEWNETCONF, 0,
> +					 AF_INET6, type);
> +#endif
>   	if (err < 0) {
>   		/* -EMSGSIZE implies BUG in inet6_netconf_msgsize_devconf() */
>   		WARN_ON(err =3D=3D -EMSGSIZE);
> @@ -592,13 +608,25 @@ static int inet6_netconf_get_devconf(str
>   	err =3D inet6_netconf_fill_devconf(skb, ifindex, devconf,
>   					 NETLINK_CB(in_skb).portid,
>   					 nlh->nlmsg_seq, RTM_NEWNETCONF, 0,
> -					 -1);
> +					 AF_INET6, -1);
> +	if (err < 0) {
> +		/* -EMSGSIZE implies BUG in inet6_netconf_msgsize_devconf() */
> +		WARN_ON(err =3D=3D -EMSGSIZE);
> +		kfree_skb(skb);
> +		goto errout;
> +	}
> +#ifdef CONFIG_IPV6_MROUTE
> +	err =3D inet6_netconf_fill_devconf(skb, ifindex, devconf,
> +					 NETLINK_CB(in_skb).portid,
> +					 nlh->nlmsg_seq, RTM_NEWNETCONF, 0,
> +					 RTNL_FAMILY_IP6MR, -1);
>   	if (err < 0) {
>   		/* -EMSGSIZE implies BUG in inet6_netconf_msgsize_devconf() */
>   		WARN_ON(err =3D=3D -EMSGSIZE);
>   		kfree_skb(skb);
>   		goto errout;
>   	}
> +#endif
>   	err =3D rtnl_unicast(skb, net, NETLINK_CB(in_skb).portid);
>   errout:
>   	return err;
> @@ -636,10 +664,23 @@ static int inet6_netconf_dump_devconf(st
>   						       cb->nlh->nlmsg_seq,
>   						       RTM_NEWNETCONF,
>   						       NLM_F_MULTI,
> +						       AF_INET6, -1) <=3D 0) {
> +				rcu_read_unlock();
> +				goto done;
> +			}
> +#ifdef CONFIG_IPV6_MROUTE
> +			if (inet6_netconf_fill_devconf(skb, dev->ifindex,
> +						       &idev->cnf,
> +						       NETLINK_CB(cb->skb).portid,
> +						       cb->nlh->nlmsg_seq,
> +						       RTM_NEWNETCONF,
> +						       NLM_F_MULTI,
> +						       RTNL_FAMILY_IP6MR,
>   						       -1) <=3D 0) {
>   				rcu_read_unlock();
>   				goto done;
>   			}
> +#endif
>   			nl_dump_check_consistent(cb, nlmsg_hdr(skb));
>   cont:
>   			idx++;
> @@ -652,10 +693,18 @@ cont:
>   					       NETLINK_CB(cb->skb).portid,
>   					       cb->nlh->nlmsg_seq,
>   					       RTM_NEWNETCONF, NLM_F_MULTI,
> -					       -1) <=3D 0)
> +					       AF_INET6, -1) <=3D 0)
>   			goto done;
> -		else
> -			h++;
> +#ifdef CONFIG_IPV6_MROUTE
> +		if (inet6_netconf_fill_devconf(skb, NETCONFA_IFINDEX_ALL,
> +					       net->ipv6.devconf_all,
> +					       NETLINK_CB(cb->skb).portid,
> +					       cb->nlh->nlmsg_seq,
> +					       RTM_NEWNETCONF, NLM_F_MULTI,
> +					       RTNL_FAMILY_IP6MR, -1) <=3D 0)
> +			goto done;
> +#endif
> +		h++;
>   	}
>   	if (h =3D=3D NETDEV_HASHENTRIES + 1) {
>   		if (inet6_netconf_fill_devconf(skb, NETCONFA_IFINDEX_DEFAULT,
> @@ -663,9 +712,17 @@ cont:
>   					       NETLINK_CB(cb->skb).portid,
>   					       cb->nlh->nlmsg_seq,
>   					       RTM_NEWNETCONF, NLM_F_MULTI,
> -					       -1) <=3D 0)
> +					       AF_INET6, -1) <=3D 0)
> +			goto done;
> +#ifdef CONFIG_IPV6_MROUTE
> +		if (inet6_netconf_fill_devconf(skb, NETCONFA_IFINDEX_DEFAULT,
> +					       net->ipv6.devconf_dflt,
> +					       NETLINK_CB(cb->skb).portid,
> +					       cb->nlh->nlmsg_seq,
> +					       RTM_NEWNETCONF, NLM_F_MULTI,
> +					       RTNL_FAMILY_IP6MR, -1) <=3D 0)
>   			goto done;
> -		else
> +#endif
>   			h++;
This line should be reindent too.

>   	}
>   done:
>
