From: Takashi Hibi <hibi665@oki.com>
Subject: Re: MLD problems (again)
Date: Wed, 07 Jan 2004 10:53:47 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040107105347.52d6dc1d%hibi665@oki.com>
References: <OFB92352E7.7549AEDC-ON88256E13.0074177C@us.ibm.com>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: (Your message of "Tue, 6 Jan 2004 13:44:40 -0800")
  <OFB92352E7.7549AEDC-ON88256E13.0074177C@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stevens,

> 
> Takashi,
>       I am looking at this-- I just haven't been in the office for the last
> two weeks. I haven't looked at it in detail, but I believe there are
> problems
> with your patch.
> 
> Offhand:
> 1) you added a check "if (skb) skb = addgrec(skb...)"
>       "skb == NULL" is a perfectly valid argument for addgrec(), and
> there aren't any circumstances I know of where you'd want to only add
> the record when no others had been added yet (which appears to be
> what this code is doing). So, this looks completely wrong to me. Either
> you want the record or not and it doesn't depend on whether you have
> other records in the report or not.
> 

OK, I missed that there may be other records.

> 2) your patch adds a set of crcount within ip_mc_add1_src(), which if
> necessary would mean the other code is completely broken (which it
> isn't). I think this is likely either redundant or it may break other
> assumptions
> about crcount handling. There are potential races I avoided in this code,
> so I'm wary of why you put that in there, but I'm pretty sure it's at best
> unnecessary.
> 

It may be unnecessary, I think.

> 3) it is not correct to always automatically join a group if it's listed in
> a
> setsockopt(). I think the result of your patch to fix your problem would
> also automatically join groups in cases where it should return an error.
> 
I don't know what kind of error can be occurred.
I think that error check is done in other parts.

> General comment-- the code is set up with the assumption that an
> ordinary join has a filter of "EXCLUDE, empty-set". That's because
> the protocol makes that assumption, and reports for includes of new
> groups are CHANGE_TO_INCLUDE. It looks like you're trying to
> bypass that and set the filter directly to INCLUDE, which I expect would
> result in incorrect reports for some cases.

In some cases, both CHANGE_TO_INCLUDE and ALLOW_NEW_SOURCES can be included.
It is redundant. (That is why I added the code mentioned in 1) )
When to join SSM (without previous join), is it OK to use CHANGE_TO_INCLUDE?
ALLOW_NEW_SOURCES seems ordinary (and Implementation of FreeBSD is so).
I couldn't judge which should be used (or both OK) from MLDv2 draft.

> Again, I have only looked at the patch context in your mail, so some of
> the things I think are problems probably aren't. I suspect, though, that
> the
> original cause of your problem is simply a missing "mld_ifc_event" call,
> though I'm not sure. Those are also carefully constructed to try to avoid
> multiple reports for complex transitions, when only one report will do, so
> some care is needed. I will look at this further and try to have an
> alternative
> patch by the end of the week.

No, mld_ifc_event() is called when the problem occurrs.
But because of the wrong mca_sfmode value, mld_send_cr() doen't
send MLD listner report.
In the following code in mld_send_cr(), all add_grec() returns NULL.

Regards,
Takashi Hibi

        /* change recs */
        for (pmc=idev->mc_list; pmc; pmc=pmc->next) {
                spin_lock_bh(&pmc->mca_lock);
                if (pmc->mca_sfcount[MCAST_EXCLUDE]) {
                        type = MLD2_BLOCK_OLD_SOURCES;
                        dtype = MLD2_ALLOW_NEW_SOURCES;
                } else {
                        type = MLD2_ALLOW_NEW_SOURCES;
                        dtype = MLD2_BLOCK_OLD_SOURCES;
                }
                skb = add_grec(skb, pmc, type, 0, 0);
                skb = add_grec(skb, pmc, dtype, 0, 1);  /* deleted sources */

                /* filter mode changes */
                if (pmc->mca_crcount) {
                        pmc->mca_crcount--;
                        if (pmc->mca_sfmode == MCAST_EXCLUDE)
                                type = MLD2_CHANGE_TO_EXCLUDE;
                        else
                                type = MLD2_CHANGE_TO_INCLUDE;
                        skb = add_grec(skb, pmc, type, 0, 0);
                }
                spin_unlock_bh(&pmc->mca_lock);
        }



> 
>                               +-DLS
> 
> 
> Takashi Hibi <hibi665@oki.com>@oss.sgi.com on 01/06/2004 04:15:42 AM
> 
> Sent by:    netdev-bounce@oss.sgi.com
> 
> 
> To:    netdev@oss.sgi.com
> cc:
> Subject:    MLD problems (again)
> 
> 
> 
> A Happy new year.
> 
> Let me discuss about the problems of MLD again.
> As I pointed out, there are two problems in current MLD code.
> 
> 1. In MLDv1 compatibility mode, Older Version Querier Present timer expires
>    prematurely.
> 2. After join SSM using setsockopt(MCAST_JOIN_SOURCE_GROUP),
>    MLDv2 listener report isn't issued immediately.
> 
> The cause of 1 is the wrong computation of timeout value.
> The cause of 2 is difficult to find. After tracing the code,
> I figured out that the mode of ifmcaddr6 isn't correctly set after
> setsockopt.
> 
> After join by setsockopt, pmc->mca_sfmode should be MCAST_INCLUDE,
> but it remains MCAST_EXCLUDE. Eventually is_in() call returns false,
> and MLDv2 packet isn't composed.
> I don't know the right way to fix it, since the code is too complicated
> by a lot of flags.
> At least the following patch(diff from 2.6.0) works for me.
> 
> Regards,
> Takashi Hibi
> 
> --- mcast.c 2003-12-18 11:59:28.000000000 +0900
> +++ new/mcast.c   2004-01-06 16:30:05.546174486 +0900
> @@ -1050,7 +1050,7 @@ int igmp6_event_query(struct sk_buff *sk
>    /* Translate milliseconds to jiffies */
>    max_delay = (ntohs(hdr->icmp6_maxdelay)*HZ)/1000;
> 
> -           switchback = (idev->mc_qrv + 1) * max_delay;
> +           switchback = MLD_QRV_DEFAULT * 125*HZ + max_delay;
>    idev->mc_v1_seen = jiffies + switchback;
> 
>    /* cancel the interface change timer */
> @@ -1541,7 +1541,8 @@ static void mld_send_cr(struct inet6_dev
>      type = MLD2_CHANGE_TO_EXCLUDE;
>     else
>      type = MLD2_CHANGE_TO_INCLUDE;
> -                 skb = add_grec(skb, pmc, type, 0, 0);
> +                 if (!skb)
> +                       skb = add_grec(skb, pmc, type, 0, 0);
>    }
>    spin_unlock_bh(&pmc->mca_lock);
>   }
> @@ -1745,6 +1746,7 @@ static int ip6_mc_add1_src(struct ifmcad
>     return -ENOBUFS;
>    memset(psf, 0, sizeof(*psf));
>    psf->sf_addr = *psfsrc;
> +     psf->sf_crcount = pmc->idev->mc_qrv;
>    if (psf_prev) {
>     psf_prev->sf_next = psf;
>    } else
> @@ -1799,6 +1801,7 @@ int ip6_mc_add_src(struct inet6_dev *ide
>   struct ifmcaddr6 *pmc;
>   int isexclude;
>   int i, err;
> +     int     first_join_src_grp;
> 
>   if (!idev)
>    return -ENODEV;
> @@ -1816,6 +1819,8 @@ int ip6_mc_add_src(struct inet6_dev *ide
> 
>   sf_markstate(pmc);
>   isexclude = pmc->mca_sfmode == MCAST_EXCLUDE;
> +     first_join_src_grp = (!pmc->sources && sfmode == MCAST_INCLUDE &&
> +           sfcount == 1 && delta);
>   if (!delta)
>    pmc->mca_sfcount[sfmode]++;
>   err = 0;
> @@ -1827,10 +1832,19 @@ int ip6_mc_add_src(struct inet6_dev *ide
>   if (err) {
>    int j;
> 
> -           pmc->mca_sfcount[sfmode]--;
> +           if (!delta)
> +                 pmc->mca_sfcount[sfmode]--;
>    for (j=0; j<i; j++)
>     (void) ip6_mc_del1_src(pmc, sfmode, &psfsrc[i]);
> -     } else if (isexclude != (pmc->mca_sfcount[MCAST_EXCLUDE] != 0)) {
> +           goto done;
> +     }
> +     if (first_join_src_grp) {
> +           pmc->mca_sfmode = MCAST_INCLUDE;
> +           if (sf_setstate(pmc))
> +                 mld_ifc_event(idev);
> +           goto done;
> +     }
> +     if (isexclude != (pmc->mca_sfcount[MCAST_EXCLUDE] != 0)) {
>    struct inet6_dev *idev = pmc->idev;
>    struct ip6_sf_list *psf;
> 
> @@ -1848,6 +1862,7 @@ int ip6_mc_add_src(struct inet6_dev *ide
>    mld_ifc_event(idev);
>   } else if (sf_setstate(pmc))
>    mld_ifc_event(idev);
> +done:
>   spin_unlock_bh(&pmc->mca_lock);
>   read_unlock_bh(&idev->lock);
>   return err;
> 
> 
