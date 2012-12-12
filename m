From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH 6/6] netfilter: nf_nat: Handle routing changes in MASQUERADE
 target
Date: Wed, 12 Dec 2012 19:37:16 +0100 (CET)
Message-ID: <alpine.DEB.2.00.1212121934240.32075@blackhole.kfki.hu>
References: <1354642293-4114-1-git-send-email-pablo@netfilter.org> <1354642293-4114-7-git-send-email-pablo@netfilter.org> <CAKTPYJQn_vVg+f1Nvbe=hU7Xzw7mX6Xw7ZR4Tz2Bpd49792-rg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Collins <bsderandrew@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CAKTPYJQn_vVg+f1Nvbe=hU7Xzw7mX6Xw7ZR4Tz2Bpd49792-rg@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 11 Dec 2012, Andrew Collins wrote:

> On Tue, Dec 4, 2012 at 10:31 AM, <pablo@netfilter.org> wrote:
> >
> > From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
> >
> > When the route changes (backup default route, VPNs) which affect a
> > masqueraded target, the packets were sent out with the outdated source
> > address. The patch addresses the issue by comparing the outgoing interface
> > directly with the masqueraded interface in the nat table.
> >
> > Events are inefficient in this case, because it'd require adding route
> > events to the network core and then scanning the whole conntrack table
> > and re-checking the route for all entry.
> >
> > Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
> > Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> 
> Jozsef, a small question about this change.  Should this same check
> not exist here:
> 
>         case IP_CT_NEW:
>                 /* Seen it before?  This can happen for loopback, retrans,
>                  * or local packets.
>                  */
>                 if (!nf_nat_initialized(ct, maniptype)) {
>                         unsigned int ret;
> 
>                         ret = nf_nat_rule_find(skb, hooknum, in, out, ct);
>                         if (ret != NF_ACCEPT)
>                                 return ret;
> -               } else
> +               } else {
>                         pr_debug("Already setup manip %s for ct %p\n",
>                                  maniptype == NF_NAT_MANIP_SRC ? "SRC" : "DST",
>                                  ct);
> +                       if (nf_nat_oif_changed(hooknum, ctinfo, nat, out)) {
> +                               nf_ct_kill_acct(ct, ctinfo, skb);
> +                               return NF_DROP;
> +                       }
> +               }
>                 break;
> 
> as well?  It's *significantly* less common than the case you fixed,
> and perhaps just letting the state time out is acceptable, but I've
> seen TCP connections get stuck with the wrong source address if we
> haven't hit ESTABLISHED at the point when the routing change occurs
> (most reproducible on high latency links).

It is a less common case, but I think you are right: the timeout can take 
several minutes. But instead of repeating the code segment, a "goto" case 
handling were better. Are you going to submit a patch?

Best regards,
Jozsef

-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
