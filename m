From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH net 1/4 v3] ipvlan: fix addr hash list corruption
Date: Mon, 30 Mar 2015 13:24:25 -0700
Message-ID: <CAF2d9jikJZSX+8HGE7tn8FL8s9WSN9WCkQ-ZpPjw5pNkXjZ1eg@mail.gmail.com>
References: <cover.1427566140.git.jbenc@redhat.com> <7b41479bf40b6ea0714afc07e64ad39c531c273f.1427566140.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-netdev <netdev@vger.kernel.org>,
	Dan Williams <dcbw@redhat.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:32976 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752679AbbC3UYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 16:24:46 -0400
Received: by obvd1 with SMTP id d1so73363910obv.0
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 13:24:46 -0700 (PDT)
In-Reply-To: <7b41479bf40b6ea0714afc07e64ad39c531c273f.1427566140.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 28, 2015 at 11:13 AM, Jiri Benc <jbenc@redhat.com> wrote:
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
Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
>
> v2 -> v3: check hlist_unhashed also on addition; fixed comment coding style
>
> v1 -> v2: check hlist_unhashed on deletion instead of depending on
> netif_running
> ---
>  drivers/net/ipvlan/ipvlan_core.c |  5 +++--
>  drivers/net/ipvlan/ipvlan_main.c | 12 ++++++++++--
>  2 files changed, 13 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
> index 2a175006028b..8a542b9340c4 100644
> --- a/drivers/net/ipvlan/ipvlan_core.c
> +++ b/drivers/net/ipvlan/ipvlan_core.c
> @@ -81,12 +81,13 @@ void ipvlan_ht_addr_add(struct ipvl_dev *ipvlan, struct ipvl_addr *addr)
>         hash = (addr->atype == IPVL_IPV6) ?
>                ipvlan_get_v6_hash(&addr->ip6addr) :
>                ipvlan_get_v4_hash(&addr->ip4addr);
> -       hlist_add_head_rcu(&addr->hlnode, &port->hlhead[hash]);
> +       if (hlist_unhashed(&addr->hlnode))
> +               hlist_add_head_rcu(&addr->hlnode, &port->hlhead[hash]);
>  }
>
>  void ipvlan_ht_addr_del(struct ipvl_addr *addr, bool sync)
>  {
> -       hlist_del_rcu(&addr->hlnode);
> +       hlist_del_init_rcu(&addr->hlnode);
>         if (sync)
>                 synchronize_rcu();
>  }
> diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
> index 4f4099d5603d..1eb3f33e11cc 100644
> --- a/drivers/net/ipvlan/ipvlan_main.c
> +++ b/drivers/net/ipvlan/ipvlan_main.c
> @@ -622,7 +622,11 @@ static int ipvlan_add_addr6(struct ipvl_dev *ipvlan, struct in6_addr *ip6_addr)
>         addr->atype = IPVL_IPV6;
>         list_add_tail_rcu(&addr->anode, &ipvlan->addrs);
>         ipvlan->ipv6cnt++;
> -       ipvlan_ht_addr_add(ipvlan, addr);
> +       /* If the interface is not up, the address will be added to the hash
> +        * list by ipvlan_open.
> +        */
> +       if (netif_running(ipvlan->dev))
> +               ipvlan_ht_addr_add(ipvlan, addr);
>
>         return 0;
>  }
> @@ -690,7 +694,11 @@ static int ipvlan_add_addr4(struct ipvl_dev *ipvlan, struct in_addr *ip4_addr)
>         addr->atype = IPVL_IPV4;
>         list_add_tail_rcu(&addr->anode, &ipvlan->addrs);
>         ipvlan->ipv4cnt++;
> -       ipvlan_ht_addr_add(ipvlan, addr);
> +       /* If the interface is not up, the address will be added to the hash
> +        * list by ipvlan_open.
> +        */
> +       if (netif_running(ipvlan->dev))
> +               ipvlan_ht_addr_add(ipvlan, addr);
>         ipvlan_set_broadcast_mac_filter(ipvlan, true);
>
>         return 0;
> --
> 1.8.3.1
>
