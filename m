From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH net 1/4 v2] ipvlan: fix addr hash list corruption
Date: Fri, 27 Mar 2015 17:16:49 -0700
Message-ID: <CAF2d9jj-kkmwwJvVe8EjZcnGiy5roEUYh2AqX1Ov3FRNbtXNEw@mail.gmail.com>
References: <cover.1427476903.git.jbenc@redhat.com> <b5d7fb60399f0a09914ff6dd94787132f40f5c0f.1427476903.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-netdev <netdev@vger.kernel.org>,
	Dan Williams <dcbw@redhat.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:33783 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752201AbbC1ARK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2015 20:17:10 -0400
Received: by oifl3 with SMTP id l3so89353008oif.0
        for <netdev@vger.kernel.org>; Fri, 27 Mar 2015 17:17:09 -0700 (PDT)
In-Reply-To: <b5d7fb60399f0a09914ff6dd94787132f40f5c0f.1427476903.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 27, 2015 at 10:30 AM, Jiri Benc <jbenc@redhat.com> wrote:
> When ipvlan interface with IP addresses attached is brought down and then
> deleted, the assigned addresses are deleted twice from the address hash
> list, first on the interface down and second on the link deletion.
> Similarly, when an address is added while the interface is down, it is added
> second time once the interface is brought up.
>
> When the interface is down, the addresses should be kept off the hash list
> for performance reasons. Ensure this is true, which also fixes the double add
> problem. To fix the double free, check whether the address is hashed before
> removing it.
>
> Reported-by: Dan Williams <dcbw@redhat.com>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
>
> Changes since v1: check hlist_unhashed on deletion instead of depending on
> netif_running
>
> ---
>  drivers/net/ipvlan/ipvlan_core.c |  2 +-
>  drivers/net/ipvlan/ipvlan_main.c | 10 ++++++++--
>  2 files changed, 9 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
> index 2a175006028b..9f705fc9e0ef 100644
> --- a/drivers/net/ipvlan/ipvlan_core.c
> +++ b/drivers/net/ipvlan/ipvlan_core.c
> @@ -86,7 +86,7 @@ void ipvlan_ht_addr_add(struct ipvl_dev *ipvlan, struct ipvl_addr *addr)
>
>  void ipvlan_ht_addr_del(struct ipvl_addr *addr, bool sync)
>  {
> -       hlist_del_rcu(&addr->hlnode);
> +       hlist_del_init_rcu(&addr->hlnode);
Though this fixes the current crash problem; the duplicate addition in
the hash-table is still open. I would still prefer it to be protected
by hlist_unhashed() check.
>         if (sync)
>                 synchronize_rcu();
>  }
> diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
> index 4f4099d5603d..dbaf67c722a0 100644
> --- a/drivers/net/ipvlan/ipvlan_main.c
> +++ b/drivers/net/ipvlan/ipvlan_main.c
> @@ -622,7 +622,10 @@ static int ipvlan_add_addr6(struct ipvl_dev *ipvlan, struct in6_addr *ip6_addr)
>         addr->atype = IPVL_IPV6;
>         list_add_tail_rcu(&addr->anode, &ipvlan->addrs);
>         ipvlan->ipv6cnt++;
> -       ipvlan_ht_addr_add(ipvlan, addr);
> +       /* If the interface is not up, the address will be added to the hash
> +        * list by ipvlan_open. */
> +       if (netif_running(ipvlan->dev))
> +               ipvlan_ht_addr_add(ipvlan, addr);
>
>         return 0;
>  }
> @@ -690,7 +693,10 @@ static int ipvlan_add_addr4(struct ipvl_dev *ipvlan, struct in_addr *ip4_addr)
>         addr->atype = IPVL_IPV4;
>         list_add_tail_rcu(&addr->anode, &ipvlan->addrs);
>         ipvlan->ipv4cnt++;
> -       ipvlan_ht_addr_add(ipvlan, addr);
> +       /* If the interface is not up, the address will be added to the hash
> +        * list by ipvlan_open. */
> +       if (netif_running(ipvlan->dev))
> +               ipvlan_ht_addr_add(ipvlan, addr);
>         ipvlan_set_broadcast_mac_filter(ipvlan, true);
>
>         return 0;
> --
> 1.8.3.1
>
