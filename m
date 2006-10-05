From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [PATCH 1/3] Fix for IPsec leakage with SELinux enabled - V.03
Date: Thu, 5 Oct 2006 17:17:47 -0400
Message-ID: <36282A1733C57546BE392885C0618592015CFB62@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Eric Paris <eparis@redhat.com>, johnpol@2ka.mipt.ru,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:41552 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1751318AbWJEVSC
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 17:18:02 -0400
To: James Morris <jmorris@namei.org>,
	Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	"David S. Miller" <davem@davemloft.net>,
	Paul Moore <paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > -		if (xfrm_policy_match(pol, fl, type, family, dir)) {
> > +		err = xfrm_policy_match(pol, fl, type, family, dir);
> > +		if (err) {
> > +			if (err == -ESRCH)
> > +				continue;
> > +			else {
> > +				ret = ERR_PTR(err);
> > +				goto fail;
> > +			}
> > +		} else {
> 
> Semantics issue: if the exact policy match fails with 
> -EACCESS, should we 
> then try an inexact match before failing?

I wonder what you mean by an inexact match here.

> 
> >  #ifdef CONFIG_XFRM_SUB_POLICY
> >  	pol = xfrm_policy_lookup_bytype(XFRM_POLICY_TYPE_SUB, 
> fl, family, dir);
> > -	if (pol)
> > +	if (IS_ERR(pol)) {
> > +		err = PTR_ERR(pol);
> > +		pol = NULL;
> > +	}
> > +	if (pol || err)
> >  		goto end;
> 
> Similarly, if the sub-policy lookup returns -EACCESS, should 
> we then try a 
> main policy lookup before failing?

I would think not since we are already handling the more usual
"failure" of EACCES properly, and any other error would usually
have to be a near-fatal error concerning the whole LSM policy or
temporary memory pressure, for example. Usually the latter is auto
handled when the callers reattempt the llokup.

While it is theoretically possible
that the LSM might generate an error for the sub but not for the main,
we would have to first redefine the LSM hook to communicate this
differentiation. And at least in the case of the current user of LSM
(SELinux)
I don't currently see the need for this differentiation.

> 
> I would think yes to both.
> 
> Opinions?
> 
> 
> - James
> -- 
> James Morris
> <jmorris@namei.org>
> 
