From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next v6 3/3] ipv6: tcp_ipv6 policy route issue
Date: Thu, 10 Apr 2014 18:23:35 +0900
Message-ID: <CAKD1Yr1Qkc6OP_6Oj7x1S0u9QWS5HP17rDAo=_kT8kHm_qPf5Q@mail.gmail.com>
References: <1396056451-5600-1-git-send-email-wangyufen@huawei.com> <1396056451-5600-4-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Wangyufen <wangyufen@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:63314 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933057AbaDJJX4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 05:23:56 -0400
Received: by mail-ie0-f173.google.com with SMTP id rl12so3674989iec.18
        for <netdev@vger.kernel.org>; Thu, 10 Apr 2014 02:23:56 -0700 (PDT)
In-Reply-To: <1396056451-5600-4-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 29, 2014 at 10:27 AM, Wangyufen <wangyufen@huawei.com> wrote:
> The issue raises when adding policy route, specify a particular
> NIC as oif, the policy route did not take effect. The reason is
> that fl6.oif is not set and route map failed. From the
> tcp_v6_send_response function, if the binding address is linklocal,
> fl6.oif is set, but not for global address.
>
> [...]
>
>         fl6.flowi6_proto = IPPROTO_TCP;
> -       if (ipv6_addr_type(&fl6.daddr) & IPV6_ADDR_LINKLOCAL)
> +       if (rt6_need_strict(&fl6.daddr) || !oif)
>                 fl6.flowi6_oif = inet6_iif(skb);

> +       else
> +               fl6.flowi6_oif = oif;

Shouldn't this be && !oif instead of || !oif? It seems to me that the
logic should be:

1. If sk->sk_bound_dev_if is set, use that interface.
2. Otherwise, if the connection came from a link-local address, use
the incoming interface.
3. Otherwise, use whatever route the system happens to have without
special regard to the incoming interface.

If so, then I think the code now does the wrong thing in two cases:

1. If the SYN comes from a global address, and sk->sk_bound_dev_if is
not set, the SYNACK is forced onto/prefers the interface the SYN came
in on instead of just doing a routing lookup with no interface.
2. If the SYN comes from a link-local address, and sk->sk_bound_dev_if
is set, then the SYNACK is forced onto/prefers the incoming interface
instead of the one specified by sk->sk_bound_dev_if.

If I am correct, then I'm happy to send out the trivial patch to fix
this. (Against what? net? net-next when the tree reopens?)
