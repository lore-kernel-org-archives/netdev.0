From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [PATCH] Fix for IPsec leakage with SELinux enabled
Date: Mon, 2 Oct 2006 13:09:15 -0400
Message-ID: <36282A1733C57546BE392885C0618592015CF4DE@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Paul Moore <paul.moore@hp.com>,
	Chad Hanson <chanson@TrustedCS.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:60497 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S965147AbWJBRRT
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Oct 2006 13:17:19 -0400
To: James Morris <jmorris@namei.org>,
	Venkat Yekkirala <vyekkirala@TrustedCS.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Sun, 1 Oct 2006, Venkat Yekkirala wrote:
> 
> > > The way I was seeing the problem was when connecting via 
> IPsec to a 
> > > confined service on an SELinux box (vsftpd), which did 
> not have the 
> > > appropriate SELinux policy permissions to send packets via IPsec.
> > > 
> > > The first SYNACK would be blocked,
> > 
> > Given that the resolver fails to find a policy here, I am trying to
> > understand what exactly is blocking it (the first SYNACK) from
> > proceeding without IPSec.
> 
> You're right.  My explanation there was for the case where 
> I'd modified 
> the code to propagate the SELinux denial back to 
> xfrm_lookup(), and not 
> for the original issue (sorry, it's been a long week).
> 
> In the original case, all packets originating from a confined 
> domain will 
> bypass ipsec.  During xfrm_lookup, flow_cache_lookup() returns NULL 
> policy:
> 
> xfrm_lookup()
> {
> 	...
> 
> 	if (!policy) {
>                 /* To accelerate a bit...  */
>                 if ((dst_orig->flags & DST_NOXFRM) ||
>                     !xfrm_policy_count[XFRM_POLICY_OUT])
>                         return 0;
> 
>                 policy = flow_cache_lookup(fl, dst_orig->ops->family,
>                                            dir, xfrm_policy_lookup);
>         }
> 
>         if (!policy)
>                 return 0;  <- bad
> 	...
> }
> 
> The call chain is:
> 
> flow_cache_lookup()
>   xfrm_policy_lookup()
>    xfrm_policy_lookup_bytype()
>      xfrm_policy_match() {
>        xfrm_selector_match => returns true, then
>          security_xfrm_policy_lookup => returns -EACCESS
>      }
> 
> then
>      
> xfrm_policy_match() => returns 0
> xfrm_policy_lookup_bytype => returns 0
> xfrm_policy_lookup() => sets obj to NULL w/ void return
> flow_cache_lookup() => returns NULL
> xfrm_lookup => returns 0
> 
> and the packet proceeds without error and with no transform 
> applied (i.e. 
> leaked as cleartext).

This is indeed the "designed" and expected (for me) behavior. But I am
beginning to see where this is perhaps NOT in line with the user
expectation when the users have an IPSec policy rule that does NOT use
labels.

IOW, if they have their policy like (NO LABELS):

spdadd 192.168.4.79 192.168.4.78 any -P out ipsec
        esp/transport//require;

spdadd 192.168.4.78 192.168.4.79 any -P in ipsec
        esp/transport//require;

currently, EACH flow needing to use this rule MUST
have SELinux policy "polmatch"ing the flow context (ftpd_t)
to unlabeled_t (the implied in the absence of an explicit
context on the IPSec policy rule) or the traffic would flow
in clear text ("leaks" in user perception).

What I propose we do is to do the polmatch check ONLY when
there's an explicit label associated with the spd rule. Does
this sound reasonable and correct in the larger SELinux context?

In cases where there's an explicit label on an spd rule like:

spdadd 192.168.4.79 192.168.4.78 any -ctx 1 1
"system_u:object_r:labeled_ipsec_t:s2-s4"
	-P out ipsec
        esp/transport//require;

spdadd 192.168.4.78 192.168.4.79 any -ctx 1 1
"system_u:object_r:labeled_ipsec_t:s2-s4"
	-P in ipsec
        esp/transport//require;

then the current behavior (prior to this proposed patch) would be the
desired behavior, i.e., a polmatch denial in the SELinux module just
means that the flow isn't expected to undergo IPSec xfrms. IOW, there's
no need to propagate -EACCES all the way back up. We could still propagate
errors other than -EACCES if we like.

> 
> The first component of the fix is to propagate errors back up 
> to callers 
> via the flow cache resolver, and handle them correctly, as 
> this is where 
> we can experience security module denials.

This will cause problems with the case where we may have multiple
"labeled" spd rules, each of which should be attempted to be polmatched
against before letting the flow out in clear text, as would be expected
by the user as well.

> 
> The second component is to then ensure that, on failure,

-EACCES in this case is perceived as a failure since the
designed behavior doesn't seem to be in line with the user
expectation. Otherwise, with the above proposed change to
the design, there won't be a polmatch check in this case and
hence no failure.

It's probably still a good idea to propagate non-EACCES failures
back up the chain though.

> we 
> kill the new 
> flow cache entry created during lookup, so that it is not 
> subsequently 
> looked up with a null policy (i.e. allowing future packets to 
> leak) and to 
> force the security hook to be called again in case the policy 
> has changed.  
> 
> Hope that clarifies.
>     
> 
> - James
> -- 
> James Morris
> <jmorris@namei.org>
> 
