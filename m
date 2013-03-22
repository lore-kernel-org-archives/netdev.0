From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 2/2] ipv6: provide addr and netconf dump consistency
 info
Date: Fri, 22 Mar 2013 17:22:49 +0100
Message-ID: <514C8559.5030301@6wind.com>
References: <1363963360-3603-1-git-send-email-nicolas.dichtel@6wind.com> <1363963360-3603-2-git-send-email-nicolas.dichtel@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	junwei.zhang@6wind.com, hongjun.li@6wind.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:59993 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933862Ab3CVQWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 12:22:55 -0400
Received: by mail-we0-f176.google.com with SMTP id s10so268784wey.7
        for <netdev@vger.kernel.org>; Fri, 22 Mar 2013 09:22:53 -0700 (PDT)
In-Reply-To: <1363963360-3603-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please, drop both patches. If we dump addresses via rtnl_dump_all(), se=
q is not=20
reset and thus NLM_F_DUMP_INTR is always set when switching from ipv4 t=
o ipv6=20
family.

I will send a new patch.

Nicolas

Le 22/03/2013 15:42, Nicolas Dichtel a =C3=A9crit :
> This patch adds a dev_addr_genid for IPv6. The goal is to use it, com=
bined with
> dev_base_seq to check if a change occurs during a netlink dump.
> If a change is detected, the flag NLM_F_DUMP_INTR is set in the first=
 message
> after the dump was interrupted.
>
> Note that only dump of unicast addresses is checked (multicast and an=
ycast are
> not checked).
>
> Reported-by: Junwei Zhang <junwei.zhang@6wind.com>
> Reported-by: Hongjun Li <hongjun.li@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>   include/net/netns/ipv6.h | 1 +
>   net/ipv6/addrconf.c      | 8 ++++++++
>   2 files changed, 9 insertions(+)
>
> diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
> index 1242f37..005e2c2 100644
> --- a/include/net/netns/ipv6.h
> +++ b/include/net/netns/ipv6.h
> @@ -71,6 +71,7 @@ struct netns_ipv6 {
>   	struct fib_rules_ops	*mr6_rules_ops;
>   #endif
>   #endif
> +	atomic_t		dev_addr_genid;
>   };
>
>   #if IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index fa36a67..d0e40d4 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -622,6 +622,8 @@ static int inet6_netconf_dump_devconf(struct sk_b=
uff *skb,
>   		idx =3D 0;
>   		head =3D &net->dev_index_head[h];
>   		rcu_read_lock();
> +		cb->seq =3D atomic_read(&net->ipv6.dev_addr_genid) ^
> +			  net->dev_base_seq;
>   		hlist_for_each_entry_rcu(dev, head, index_hlist) {
>   			if (idx < s_idx)
>   				goto cont;
> @@ -639,6 +641,7 @@ static int inet6_netconf_dump_devconf(struct sk_b=
uff *skb,
>   				rcu_read_unlock();
>   				goto done;
>   			}
> +			nl_dump_check_consistent(cb, nlmsg_hdr(skb));
>   cont:
>   			idx++;
>   		}
> @@ -3875,6 +3878,7 @@ static int in6_dump_addrs(struct inet6_dev *ide=
v, struct sk_buff *skb,
>   						NLM_F_MULTI);
>   			if (err <=3D 0)
>   				break;
> +			nl_dump_check_consistent(cb, nlmsg_hdr(skb));
>   		}
>   		break;
>   	}
> @@ -3932,6 +3936,7 @@ static int inet6_dump_addr(struct sk_buff *skb,=
 struct netlink_callback *cb,
>   	s_ip_idx =3D ip_idx =3D cb->args[2];
>
>   	rcu_read_lock();
> +	cb->seq =3D atomic_read(&net->ipv6.dev_addr_genid) ^ net->dev_base_=
seq;
>   	for (h =3D s_h; h < NETDEV_HASHENTRIES; h++, s_idx =3D 0) {
>   		idx =3D 0;
>   		head =3D &net->dev_index_head[h];
> @@ -4409,6 +4414,8 @@ errout:
>
>   static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
>   {
> +	struct net *net =3D dev_net(ifp->idev->dev);
> +
>   	inet6_ifa_notify(event ? : RTM_NEWADDR, ifp);
>
>   	switch (event) {
> @@ -4434,6 +4441,7 @@ static void __ipv6_ifa_notify(int event, struct=
 inet6_ifaddr *ifp)
>   			dst_free(&ifp->rt->dst);
>   		break;
>   	}
> +	atomic_inc(&net->ipv6.dev_addr_genid);
>   }
>
>   static void ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
>

--=20
Nicolas DICHTEL
6WIND
R&D Engineer

Tel: +33 1 39 30 92 41
=46ax: +33 1 39 30 92 11
nicolas.dichtel@6wind.com
www.6wind.com
www.6windblog.com
Twitter: http://twitter.com/6windsoftware

Ce courriel ainsi que toutes les pi=C3=A8ces jointes, est uniquement de=
stin=C3=A9 =C3=A0 son ou=20
ses destinataires. Il contient des informations confidentielles qui son=
t la=20
propri=C3=A9t=C3=A9 de 6WIND. Toute r=C3=A9v=C3=A9lation, distribution =
ou copie des informations=20
qu'il contient est strictement interdite. Si vous avez re=C3=A7u ce mes=
sage par=20
erreur, veuillez imm=C3=A9diatement le signaler =C3=A0 l'=C3=A9metteur =
et d=C3=A9truire toutes les=20
donn=C3=A9es re=C3=A7ues.

This e-mail message, including any attachments, is for the sole use of =
the=20
intended recipient(s) and contains information that is confidential and=
=20
proprietary to 6WIND. All unauthorized review, use, disclosure or distr=
ibution=20
is prohibited. If you are not the intended recipient, please contact th=
e sender=20
by reply e-mail and destroy all copies of the original message.
