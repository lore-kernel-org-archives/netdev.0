From: Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
Subject: Re: [RFC PATCH] xfrm: fix regression introduced by xdst pcpu cache
Date: Tue, 31 Oct 2017 09:43:40 -0400
Message-ID: <1509457420.20694.4.camel@tycho.nsa.gov>
References: <20171030145843.13496-1-sds@tycho.nsa.gov>
 <20171031111122.GB7663@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org
To: Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>
Return-path: <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
In-Reply-To: <20171031111122.GB7663-E0PNVn5OA6ohrxcnuTQ+TQ@public.gmane.org>
List-Post: <mailto:selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Help: <mailto:selinux-request-+05T5uksL2qpZYMLLGbcSA@public.gmane.org?subject=help>
Errors-To: selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
Sender: "Selinux" <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Tue, 2017-10-31 at 12:11 +0100, Florian Westphal wrote:
> Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org> wrote:
> > Since 4.14-rc1, the selinux-testsuite has been encountering
> > sporadic
> > failures during testing of labeled IPSEC. git bisect pointed to
> > commit ec30d78c14a813db39a647b6a348b4286 ("xfrm: add xdst pcpu
> > cache").
> > The xdst pcpu cache is only checking that the policies are the
> > same,
> > but does not validate that the policy, state, and flow match with
> > respect
> > to security context labeling.  As a result, the wrong SA could be
> > used
> > and the receiver could end up performing permission checking and
> > providing SO_PEERSEC or SCM_SECURITY values for the wrong security
> > context.
> > security_xfrm_state_pol_flow_match() exists for this purpose and is
> > already called from xfrm_state_look_at() for matching purposes.
> > Further, xfrm_state_look_at() also performs a xfrm_selector_match()
> > test,
> > which is also missing from the xdst pcpu cache logic.  Add calls to
> > both
> > of these functions when validating the cache entry.  With these
> > changes,
> > the selinux-testsuite passes all tests again.
> > 
> > Fixes: ec30d78c14a813db39a647b6a348b4286ba4abf5 ("xfrm: add xdst
> > pcpu cache")
> > Signed-off-by: Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
> > ---
> > This is an RFC because I am not entirely confident in the fix, e.g.
> > is it
> > sufficient to perform this matching only on the first xfrm or do
> > they all
> > need to be walked as in xfrm_bundle_ok()?  Also, should we perform
> > this
> > matching before (as in this patch) or after calling
> > xfrm_bundle_ok()? Also,
> > do we need to test xfrm->sel.family before calling
> > xfrm_selector_match
> > (as in this patch) or not - xfrm_state_look_at() does so when the
> > state is XFRM_STATE_VALID but not when it is _ERROR or _EXPIRED?
> 
> No idea.
> 
> I looked at the old flow cache but i don't see any of these extra
> checks there either.
> 
> However, old flow cache stored flowi struct as key, and that contains
> a
> flowi_secid,  populated by the decode_session hooks.
> 
> Was it enough to check for identical flowi_secid in the flowi structs
> to
> avoid this problem or am i missing something?

I'm not sure, but security_xfrm_state_pol_flow_match() ->
selinux_xfrm_state_pol_flow_match() does more than just compare flow
secids.

Also, there is the separate issue of the missing xfrm_selector_match()
call, which can also cause the wrong SA to be used independent of
anything LSM/SELinux-related.

It is a regression; the correct SA was being used prior to the xdst
pcpu cache commit.  Reproducible using the selinux-testsuite, most
easily run on a Fedora VM,
git clone https://github.com/SELinuxProject/selinux-testsuite/
sudo dnf install perl-Test perl-Test-Harness perl-Test-Simple selinux-policy-devel gcc libselinux-devel net-tools netlabel_tools iptables
sudo make -C policy load
cd tests/inet_socket
while sudo ./test; do : ; done
