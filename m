From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH ipsec-next 6/8] xfrm: policy: only use rcu in
 xfrm_sk_policy_lookup
Date: Wed, 16 Nov 2016 18:30:28 +0100
Message-ID: <20161116173028.GI30581@breakpoint.cc>
References: <1470921479-25592-1-git-send-email-fw@strlen.de>
 <1470921479-25592-7-git-send-email-fw@strlen.de>
 <0e235471-cb63-2376-c42d-5872e78e4c98@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 8bit
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
        Steffen Klassert <steffen.klassert@secunet.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:50402 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932201AbcKPRcv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 12:32:51 -0500
Content-Disposition: inline
In-Reply-To: <0e235471-cb63-2376-c42d-5872e78e4c98@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
> Le 11/08/2016 à 15:17, Florian Westphal a écrit :
> > Don't acquire the readlock anymore and rely on rcu alone.
> > 
> > In case writer on other CPU changed policy at the wrong moment (after we
> > obtained sk policy pointer but before we could obtain the reference)
> > just repeat the lookup.
> > 
> > Signed-off-by: Florian Westphal <fw@strlen.de>
> Since this patch, our IKEv1 Transport tests (using charon) fail to establish the
> connection. If I revert it, the IKE negociation is ok again.
> charon logs are enclosed.
> 
> I didn't had time to investigate now, but any idea is welcomed ;-)

I'm an idiot.  Thanks for figuring out the faulty commit!

This should fix it (if we succeed grabbing the refcount, then if (err && !xfrm_pol_hold_rcu
evaluates to false and we hit last else branch and set pol to ERR_PTR(0)...

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index fd6986634e6f..5bf7e1bfeac7 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1268,12 +1268,14 @@ static struct xfrm_policy *xfrm_sk_policy_lookup(const struct sock *sk, int dir,
                        err = security_xfrm_policy_lookup(pol->security,
                                                      fl->flowi_secid,
                                                      policy_to_flow_dir(dir));
-                       if (!err && !xfrm_pol_hold_rcu(pol))
-                               goto again;
-                       else if (err == -ESRCH)
+                       if (!err) {
+                               if (!xfrm_pol_hold_rcu(pol))
+                                       goto again;
+                       } else if (err == -ESRCH) {
                                pol = NULL;
-                       else
+                       } else {
                                pol = ERR_PTR(err);
+                       }
                } else
