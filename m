From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net 1/4 v2] ipvlan: fix addr hash list corruption
Date: Fri, 27 Mar 2015 20:36:36 +0300
Message-ID: <55159524.8010104@cogentembedded.com>
References: <cover.1427476903.git.jbenc@redhat.com> <b5d7fb60399f0a09914ff6dd94787132f40f5c0f.1427476903.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mahesh Bandewar <maheshb@google.com>,
	Dan Williams <dcbw@redhat.com>
To: Jiri Benc <jbenc@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:34703 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753410AbbC0Rgk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2015 13:36:40 -0400
Received: by lagg8 with SMTP id g8so75963076lag.1
        for <netdev@vger.kernel.org>; Fri, 27 Mar 2015 10:36:38 -0700 (PDT)
In-Reply-To: <b5d7fb60399f0a09914ff6dd94787132f40f5c0f.1427476903.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/27/2015 08:30 PM, Jiri Benc wrote:

> When ipvlan interface with IP addresses attached is brought down and then
> deleted, the assigned addresses are deleted twice from the address hash
> list, first on the interface down and second on the link deletion.
> Similarly, when an address is added while the interface is down, it is added
> second time once the interface is brought up.

> When the interface is down, the addresses should be kept off the hash list
> for performance reasons. Ensure this is true, which also fixes the double add
> problem. To fix the double free, check whether the address is hashed before
> removing it.

> Reported-by: Dan Williams <dcbw@redhat.com>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---

> Changes since v1: check hlist_unhashed on deletion instead of depending on
> netif_running

[...]

> diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
> index 4f4099d5603d..dbaf67c722a0 100644
> --- a/drivers/net/ipvlan/ipvlan_main.c
> +++ b/drivers/net/ipvlan/ipvlan_main.c
> @@ -622,7 +622,10 @@ static int ipvlan_add_addr6(struct ipvl_dev *ipvlan, struct in6_addr *ip6_addr)
>   	addr->atype = IPVL_IPV6;
>   	list_add_tail_rcu(&addr->anode, &ipvlan->addrs);
>   	ipvlan->ipv6cnt++;
> -	ipvlan_ht_addr_add(ipvlan, addr);
> +	/* If the interface is not up, the address will be added to the hash
> +	 * list by ipvlan_open. */

    The preferred multi-line comment style in the networking code is:

/* Like
  * this.
  */

[...]
> @@ -690,7 +693,10 @@ static int ipvlan_add_addr4(struct ipvl_dev *ipvlan, struct in_addr *ip4_addr)
>   	addr->atype = IPVL_IPV4;
>   	list_add_tail_rcu(&addr->anode, &ipvlan->addrs);
>   	ipvlan->ipv4cnt++;
> -	ipvlan_ht_addr_add(ipvlan, addr);
> +	/* If the interface is not up, the address will be added to the hash
> +	 * list by ipvlan_open. */

    Likewise.

[...]

WBR, Sergei
