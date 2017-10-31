From: Florian Westphal <fw@strlen.de>
Subject: Re: [RFC PATCH] xfrm: fix regression introduced by xdst pcpu cache
Date: Tue, 31 Oct 2017 12:11:22 +0100
Message-ID: <20171031111122.GB7663@breakpoint.cc>
References: <20171030145843.13496-1-sds@tycho.nsa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
        selinux@tycho.nsa.gov, fw@strlen.de, davem@davemloft.net,
        herbert@gondor.apana.org.au, steffen.klassert@secunet.com,
        paul@paul-moore.com
To: Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171030145843.13496-1-sds@tycho.nsa.gov>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Smalley <sds@tycho.nsa.gov> wrote:
> Since 4.14-rc1, the selinux-testsuite has been encountering sporadic
> failures during testing of labeled IPSEC. git bisect pointed to
> commit ec30d78c14a813db39a647b6a348b4286 ("xfrm: add xdst pcpu cache").
> The xdst pcpu cache is only checking that the policies are the same,
> but does not validate that the policy, state, and flow match with respect
> to security context labeling.  As a result, the wrong SA could be used
> and the receiver could end up performing permission checking and
> providing SO_PEERSEC or SCM_SECURITY values for the wrong security context.
> security_xfrm_state_pol_flow_match() exists for this purpose and is
> already called from xfrm_state_look_at() for matching purposes.
> Further, xfrm_state_look_at() also performs a xfrm_selector_match() test,
> which is also missing from the xdst pcpu cache logic.  Add calls to both
> of these functions when validating the cache entry.  With these changes,
> the selinux-testsuite passes all tests again.
> 
> Fixes: ec30d78c14a813db39a647b6a348b4286ba4abf5 ("xfrm: add xdst pcpu cache")
> Signed-off-by: Stephen Smalley <sds@tycho.nsa.gov>
> ---
> This is an RFC because I am not entirely confident in the fix, e.g. is it
> sufficient to perform this matching only on the first xfrm or do they all
> need to be walked as in xfrm_bundle_ok()?  Also, should we perform this
> matching before (as in this patch) or after calling xfrm_bundle_ok()? Also,
> do we need to test xfrm->sel.family before calling xfrm_selector_match
> (as in this patch) or not - xfrm_state_look_at() does so when the
> state is XFRM_STATE_VALID but not when it is _ERROR or _EXPIRED?

No idea.

I looked at the old flow cache but i don't see any of these extra
checks there either.

However, old flow cache stored flowi struct as key, and that contains a
flowi_secid,  populated by the decode_session hooks.

Was it enough to check for identical flowi_secid in the flowi structs to
avoid this problem or am i missing something?
