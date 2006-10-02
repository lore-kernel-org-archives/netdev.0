From: James Morris <jmorris@namei.org>
Subject: RE: [PATCH] Fix for IPsec leakage with SELinux enabled
Date: Sun, 1 Oct 2006 21:44:03 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0610012117110.4789@d.namei>
References: <36282A1733C57546BE392885C0618592015CF3C7@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Paul Moore <paul.moore@hp.com>,
	Chad Hanson <chanson@TrustedCS.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.sea5.speakeasy.net ([69.17.117.4]:62660 "EHLO
	mail2.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932241AbWJBBoH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Oct 2006 21:44:07 -0400
To: Venkat Yekkirala <vyekkirala@TrustedCS.com>
In-Reply-To: <36282A1733C57546BE392885C0618592015CF3C7@chaos.tcs.tcs-sec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 1 Oct 2006, Venkat Yekkirala wrote:

> > The way I was seeing the problem was when connecting via IPsec to a 
> > confined service on an SELinux box (vsftpd), which did not have the 
> > appropriate SELinux policy permissions to send packets via IPsec.
> > 
> > The first SYNACK would be blocked,
> 
> Given that the resolver fails to find a policy here, I am trying to
> understand what exactly is blocking it (the first SYNACK) from
> proceeding without IPSec.

You're right.  My explanation there was for the case where I'd modified 
the code to propagate the SELinux denial back to xfrm_lookup(), and not 
for the original issue (sorry, it's been a long week).

In the original case, all packets originating from a confined domain will 
bypass ipsec.  During xfrm_lookup, flow_cache_lookup() returns NULL 
policy:

xfrm_lookup()
{
	...

	if (!policy) {
                /* To accelerate a bit...  */
                if ((dst_orig->flags & DST_NOXFRM) ||
                    !xfrm_policy_count[XFRM_POLICY_OUT])
                        return 0;

                policy = flow_cache_lookup(fl, dst_orig->ops->family,
                                           dir, xfrm_policy_lookup);
        }

        if (!policy)
                return 0;  <- bad
	...
}

The call chain is:

flow_cache_lookup()
  xfrm_policy_lookup()
   xfrm_policy_lookup_bytype()
     xfrm_policy_match() {
       xfrm_selector_match => returns true, then
         security_xfrm_policy_lookup => returns -EACCESS
     }

then
     
xfrm_policy_match() => returns 0
xfrm_policy_lookup_bytype => returns 0
xfrm_policy_lookup() => sets obj to NULL w/ void return
flow_cache_lookup() => returns NULL
xfrm_lookup => returns 0

and the packet proceeds without error and with no transform applied (i.e. 
leaked as cleartext).

The first component of the fix is to propagate errors back up to callers 
via the flow cache resolver, and handle them correctly, as this is where 
we can experience security module denials.

The second component is to then ensure that, on failure, we kill the new 
flow cache entry created during lookup, so that it is not subsequently 
looked up with a null policy (i.e. allowing future packets to leak) and to 
force the security hook to be called again in case the policy has changed.  

Hope that clarifies.
    

- James
-- 
James Morris
<jmorris@namei.org>
