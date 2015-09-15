From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 2/2] bonding: use l4 hash if available
Date: Tue, 15 Sep 2015 16:45:50 -0700
Message-ID: <CALx6S36gs8qC5UXjowoDShZif=81BMJQjUyR_mn4JTaH6xE43w@mail.gmail.com>
References: <1442355868.4116.14.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:33177 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751532AbbIOXpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 19:45:51 -0400
Received: by iofh134 with SMTP id h134so215405004iof.0
        for <netdev@vger.kernel.org>; Tue, 15 Sep 2015 16:45:50 -0700 (PDT)
In-Reply-To: <1442355868.4116.14.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 15, 2015 at 3:24 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> If skb carries a l4 hash, no need to perform a flow dissection.
>
> Performance is slightly better :
>
> lpaa5:~# ./super_netperf 200 -H lpaa6 -t TCP_RR -l 100
> 2.39012e+06
> lpaa5:~# ./super_netperf 200 -H lpaa6 -t TCP_RR -l 100
> 2.39393e+06
> lpaa5:~# ./super_netperf 200 -H lpaa6 -t TCP_RR -l 100
> 2.39988e+06
>
> After patch :
>
> lpaa5:~# ./super_netperf 200 -H lpaa6 -t TCP_RR -l 100
> 2.43579e+06
> lpaa5:~# ./super_netperf 200 -H lpaa6 -t TCP_RR -l 100
> 2.44304e+06
> lpaa5:~# ./super_netperf 200 -H lpaa6 -t TCP_RR -l 100
> 2.44312e+06
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Tom Herbert <tom@herbertland.com>
> Cc: Mahesh Bandewar <maheshb@google.com>
> ---
>  drivers/net/bonding/bond_main.c |    4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 771a449..9250d1e 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -3136,6 +3136,10 @@ u32 bond_xmit_hash(struct bonding *bond, struct sk_buff *skb)
>         struct flow_keys flow;
>         u32 hash;
>
> +       if (bond->params.xmit_policy == BOND_XMIT_POLICY_ENCAP34 &&
> +           skb->l4_hash)
> +                       return skb->hash;
> +
>         if (bond->params.xmit_policy == BOND_XMIT_POLICY_LAYER2 ||
>             !bond_flow_dissect(bond, skb, &flow))
>                 return bond_eth_hash(skb);
>
>
Ugh, bond_flow_dissect is yet another instance of customized flow
dissection! We should really clean this up. I suggest that in cases
were we want L4 hash a call to skb_get_hash should suffice. We can
create skb_get_l3hash when caller explicitly wants an L3 hash-- this
would return skb->hash if it's valid and skb->l4_hash is not set, else
call flow dissector with FLOW_DISSECTOR_F_STOP_AT_L3 and then do the
normal hash over flow keys (don't save result in skb->hash in this
case).

Tom
