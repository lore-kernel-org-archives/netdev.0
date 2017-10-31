From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [RFC PATCH] xfrm: fix regression introduced by xdst pcpu cache
Date: Tue, 31 Oct 2017 10:00:00 -0400
Message-ID: <1509458400.20694.8.camel@tycho.nsa.gov>
References: <20171030145843.13496-1-sds@tycho.nsa.gov>
         <20171031111122.GB7663@breakpoint.cc>
         <1509457420.20694.4.camel@tycho.nsa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
        selinux@tycho.nsa.gov, davem@davemloft.net,
        herbert@gondor.apana.org.au, Paul Moore <paul@paul-moore.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from uphb19pa09.eemsg.mail.mil ([214.24.26.83]:28069 "EHLO
        USFB19PA12.eemsg.mail.mil" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751976AbdJaN7j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 09:59:39 -0400
In-Reply-To: <1509457420.20694.4.camel@tycho.nsa.gov>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-10-31 at 09:43 -0400, Stephen Smalley wrote:
> On Tue, 2017-10-31 at 12:11 +0100, Florian Westphal wrote:
> > Stephen Smalley <sds@tycho.nsa.gov> wrote:
> > > Since 4.14-rc1, the selinux-testsuite has been encountering
> > > sporadic
> > > failures during testing of labeled IPSEC. git bisect pointed to
> > > commit ec30d78c14a813db39a647b6a348b4286 ("xfrm: add xdst pcpu
> > > cache").
> > > The xdst pcpu cache is only checking that the policies are the
> > > same,
> > > but does not validate that the policy, state, and flow match with
> > > respect
> > > to security context labeling.  As a result, the wrong SA could be
> > > used
> > > and the receiver could end up performing permission checking and
> > > providing SO_PEERSEC or SCM_SECURITY values for the wrong
> > > security
> > > context.
> > > security_xfrm_state_pol_flow_match() exists for this purpose and
> > > is
> > > already called from xfrm_state_look_at() for matching purposes.
> > > Further, xfrm_state_look_at() also performs a
> > > xfrm_selector_match()
> > > test,
> > > which is also missing from the xdst pcpu cache logic.  Add calls
> > > to
> > > both
> > > of these functions when validating the cache entry.  With these
> > > changes,
> > > the selinux-testsuite passes all tests again.
> > > 
> > > Fixes: ec30d78c14a813db39a647b6a348b4286ba4abf5 ("xfrm: add xdst
> > > pcpu cache")
> > > Signed-off-by: Stephen Smalley <sds@tycho.nsa.gov>
> > > ---
> > > This is an RFC because I am not entirely confident in the fix,
> > > e.g.
> > > is it
> > > sufficient to perform this matching only on the first xfrm or do
> > > they all
> > > need to be walked as in xfrm_bundle_ok()?  Also, should we
> > > perform
> > > this
> > > matching before (as in this patch) or after calling
> > > xfrm_bundle_ok()? Also,
> > > do we need to test xfrm->sel.family before calling
> > > xfrm_selector_match
> > > (as in this patch) or not - xfrm_state_look_at() does so when the
> > > state is XFRM_STATE_VALID but not when it is _ERROR or _EXPIRED?
> > 
> > No idea.
> > 
> > I looked at the old flow cache but i don't see any of these extra
> > checks there either.
> > 
> > However, old flow cache stored flowi struct as key, and that
> > contains
> > a
> > flowi_secid,  populated by the decode_session hooks.
> > 
> > Was it enough to check for identical flowi_secid in the flowi
> > structs
> > to
> > avoid this problem or am i missing something?
> 
> I'm not sure, but security_xfrm_state_pol_flow_match() ->
> selinux_xfrm_state_pol_flow_match() does more than just compare flow
> secids.
> 
> Also, there is the separate issue of the missing
> xfrm_selector_match()
> call, which can also cause the wrong SA to be used independent of
> anything LSM/SELinux-related.
> 
> It is a regression; the correct SA was being used prior to the xdst
> pcpu cache commit.  Reproducible using the selinux-testsuite, most
> easily run on a Fedora VM,
> git clone https://github.com/SELinuxProject/selinux-testsuite/
> sudo dnf install perl-Test perl-Test-Harness perl-Test-Simple
> selinux-policy-devel gcc libselinux-devel net-tools netlabel_tools
> iptables

Actually, you should just run 'sudo make test' instead of the
individual commands below.  I was breaking out the individual commands
to avoid running the rest of the testsuite unrelated to networking, but
 that won't pick up all of the dependencies the first time.  Sorry.

> sudo make -C policy load
> cd tests/inet_socket
> while sudo ./test; do : ; done
