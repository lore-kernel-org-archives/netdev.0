From: Debabrata Banerjee <dbavatar@gmail.com>
Subject: Re: [PATCH 1/2] ipv6: do not hold route table lock when send ndisc probe
Date: Fri, 17 Aug 2012 14:54:26 -0400
Message-ID: <CAATkVEzKuTeUbU75B6EoSfFvGVsz_eK47XNWmsP5KcCvjTDEDA@mail.gmail.com>
References: <1345187499-16929-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org,
	"Banerjee, Debabrata" <dbanerje@akamai.com>,
	"David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:61838 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932540Ab2HQSy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2012 14:54:26 -0400
Received: by obbuo13 with SMTP id uo13so5647957obb.19
        for <netdev@vger.kernel.org>; Fri, 17 Aug 2012 11:54:26 -0700 (PDT)
In-Reply-To: <1345187499-16929-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Well it get rids of the deadlock for sure, but I am not sure it
doesn't break something else, one would have to know all of this code
much better to tell. You'll notice read_unlock_bh(&table->tb6_lock)
for the first lock in ip6_pol_route() has more in the critical section
after the rt6_select() call, especially that rather scary BACKTRACK()
macro.

-Debabrata

On Fri, Aug 17, 2012 at 3:11 AM, Cong Wang <amwang@redhat.com> wrote:
> In rt6_probe(), we call ndisc_send_ns() with root->rwlock,
> but this is not necessary, so we can drop it before calling
> ndisc_send_ns().
>
> This could probably fix the deadlock reported by Debabrata:
> https://lkml.org/lkml/2012/8/16/432
>
> Reported-by: "Banerjee, Debabrata" <dbanerje@akamai.com>
> Cc: "Banerjee, Debabrata" <dbanerje@akamai.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> ---
>  net/ipv6/route.c |    7 ++++++-
>  1 files changed, 6 insertions(+), 1 deletions(-)
>
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 0ddf2d1..7a36df2 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -460,13 +460,18 @@ static void rt6_probe(struct rt6_info *rt)
>             time_after(jiffies, neigh->updated + rt->rt6i_idev->cnf.rtr_probe_interval)) {
>                 struct in6_addr mcaddr;
>                 struct in6_addr *target;
> +               struct net_device *dev = rt->dst.dev;
> +               struct fib6_table *table = rt->rt6i_table;
>
>                 neigh->updated = jiffies;
>                 read_unlock_bh(&neigh->lock);
> +               read_unlock_bh(&table->tb6_lock);
>
>                 target = (struct in6_addr *)&neigh->primary_key;
>                 addrconf_addr_solict_mult(target, &mcaddr);
> -               ndisc_send_ns(rt->dst.dev, NULL, target, &mcaddr, NULL);
> +               ndisc_send_ns(dev, NULL, target, &mcaddr, NULL);
> +
> +               read_lock_bh(&table->tb6_lock);
>         } else {
>                 read_unlock_bh(&neigh->lock);
>         }
> --
> 1.7.7.6
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
