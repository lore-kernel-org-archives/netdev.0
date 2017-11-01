From: Paul Moore <paul@paul-moore.com>
Subject: Re: [RFC PATCH] xfrm: fix regression introduced by xdst pcpu cache
Date: Wed, 1 Nov 2017 17:39:31 -0400
Message-ID: <CAHC9VhT7FOeoJgX=KmMPr_ACKSgJ8V9DEHNM=cnfV9-sdrHC2g@mail.gmail.com>
References: <20171030145843.13496-1-sds@tycho.nsa.gov> <CAHC9VhT6b1DJ0E65syC7XoVxfSTs3RUq9-HNLuzt2H-vrj69RA@mail.gmail.com>
 <20171031230809.GD7663@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Stephen Smalley <sds@tycho.nsa.gov>, netdev@vger.kernel.org,
        linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
        davem@davemloft.net, herbert@gondor.apana.org.au,
        steffen.klassert@secunet.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:57255 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933623AbdKAVjd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 17:39:33 -0400
Received: by mail-lf0-f68.google.com with SMTP id 90so4077876lfs.13
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 14:39:33 -0700 (PDT)
In-Reply-To: <20171031230809.GD7663@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 31, 2017 at 7:08 PM, Florian Westphal <fw@strlen.de> wrote:
> Paul Moore <paul@paul-moore.com> wrote:
>> On Mon, Oct 30, 2017 at 10:58 AM, Stephen Smalley <sds@tycho.nsa.gov> wrote:
>> > matching before (as in this patch) or after calling xfrm_bundle_ok()?
>>
>> I would probably make the LSM call the last check, as you've done; but
>> I have to say that is just so it is consistent with the "LSM last"
>> philosophy and not because of any performance related argument.
>>
>> > ... Also,
>> > do we need to test xfrm->sel.family before calling xfrm_selector_match
>> > (as in this patch) or not - xfrm_state_look_at() does so when the
>> > state is XFRM_STATE_VALID but not when it is _ERROR or _EXPIRED?
>>
>> Speaking purely from a SELinux perspective, I'm not sure it matters:
>> as long as the labels match we are happy.  However, from a general
>> IPsec perspective it does seem like a reasonable thing.
>>
>> Granted I'm probably missing something, but it seems a little odd that
>> the code isn't already checking that the selectors match (... what am
>> I missing?).  It does check the policies, maybe that is enough in the
>> normal IPsec case?
>
> The assumption was that identical policies would yield the same SAs,
> but thats not correct.

Well, to be fair, I think the assumption is valid for normal,
unlabeled IPsec.  The problem comes when SELinux starts labeling SAs
and now you have multiple SAs for a given policy, each differing only
in the SELinux/LSM label.

Considering that adding the SELinux/LSM label effectively adds an
additional selector, I'm wondering if we should simply add the
SELinux/LSM label matching to xfrm_selector_match()?  Looking quickly
at the code it seems as though we always follow xfrm_selector_match()
with a LSM check anyway, the one exception being in
__xfrm_policy_check() ... which *might* be a valid exception, as we
don't do our access checks for inbound traffic at that point in the
stack.

>> > diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
>> > index 2746b62..171818b 100644
>> > --- a/net/xfrm/xfrm_policy.c
>> > +++ b/net/xfrm/xfrm_policy.c
>> > @@ -1820,6 +1820,11 @@ xfrm_resolve_and_create_bundle(struct xfrm_policy **pols, int num_pols,
>> >             !xfrm_pol_dead(xdst) &&
>> >             memcmp(xdst->pols, pols,
>> >                    sizeof(struct xfrm_policy *) * num_pols) == 0 &&
>> > +           (!xdst->u.dst.xfrm->sel.family ||
>> > +            xfrm_selector_match(&xdst->u.dst.xfrm->sel, fl,
>> > +                                xdst->u.dst.xfrm->sel.family)) &&
>> > +           security_xfrm_state_pol_flow_match(xdst->u.dst.xfrm,
>> > +                                              xdst->pols[0], fl) &&
>
> ... so this needs to walk the bundle and validate each selector.
>
> Alternatively we could always do template resolution and then check
> that all states found match those of the old pcpu xdst:
>
> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -1786,19 +1786,23 @@ void xfrm_policy_cache_flush(void)
>         put_online_cpus();
>  }
>
> -static bool xfrm_pol_dead(struct xfrm_dst *xdst)
> +static bool xfrm_xdst_can_reuse(struct xfrm_dst *xdst,
> +                               struct xfrm_state * const xfrm[],
> +                               int num)
>  {
> -       unsigned int num_pols = xdst->num_pols;
> -       unsigned int pol_dead = 0, i;
> +       const struct dst_entry *dst = &xdst->u.dst;
> +       int i;
>
> -       for (i = 0; i < num_pols; i++)
> -               pol_dead |= xdst->pols[i]->walk.dead;
> +       if (xdst->num_xfrms != num)
> +               return false;
>
> -       /* Mark DST_OBSOLETE_DEAD to fail the next xfrm_dst_check() */
> -       if (pol_dead)
> -               xdst->u.dst.obsolete = DST_OBSOLETE_DEAD;
> +       for (i = 0; i < num; i++) {
> +               if (!dst || dst->xfrm != xfrm[i])
> +                       return false;
> +               dst = dst->child;
> +       }
>
> -       return pol_dead;
> +       return xfrm_bundle_ok(xdst);
>  }
>
>  static struct xfrm_dst *
> @@ -1812,26 +1816,28 @@ xfrm_resolve_and_create_bundle(struct xfrm_policy **pols, int num_pols,
>         struct dst_entry *dst;
>         int err;
>
> +       /* Try to instantiate a bundle */
> +       err = xfrm_tmpl_resolve(pols, num_pols, fl, xfrm, family);
> +       if (err <= 0) {
> +               if (err != 0 && err != -EAGAIN)
> +                       XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTPOLERROR);
> +               return ERR_PTR(err);
> +       }
> +
>         xdst = this_cpu_read(xfrm_last_dst);
>         if (xdst &&
>             xdst->u.dst.dev == dst_orig->dev &&
>             xdst->num_pols == num_pols &&
> -           !xfrm_pol_dead(xdst) &&
>             memcmp(xdst->pols, pols,
>                    sizeof(struct xfrm_policy *) * num_pols) == 0 &&
> -           xfrm_bundle_ok(xdst)) {
> +           xfrm_xdst_can_reuse(xdst, xfrm, err)) {
>                 dst_hold(&xdst->u.dst);
> +               while (err > 0)
> +                       xfrm_state_put(xfrm[--err]);
>                 return xdst;
>         }
>
>         old = xdst;
> -       /* Try to instantiate a bundle */
> -       err = xfrm_tmpl_resolve(pols, num_pols, fl, xfrm, family);
> -       if (err <= 0) {
> -               if (err != 0 && err != -EAGAIN)
> -                       XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTPOLERROR);
> -               return ERR_PTR(err);
> -       }
>
>         dst = xfrm_bundle_create(pols[0], xfrm, err, fl, dst_orig);
>         if (IS_ERR(dst)) {
> --
> 2.13.6

-- 
paul moore
www.paul-moore.com
