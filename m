From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Fix for IPsec leakage with SELinux enabled - V.03
Date: Thu, 05 Oct 2006 14:04:23 -0700 (PDT)
Message-ID: <20061005.140423.48528368.davem@davemloft.net>
References: <45256E33.8080205@trustedcs.com>
	<Pine.LNX.4.64.0610051651580.25705@d.namei>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyekkirala@trustedcs.com, paul.moore@hp.com,
	netdev@vger.kernel.org, selinux@tycho.nsa.gov, sds@tycho.nsa.gov,
	eparis@redhat.com, johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:61098
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751340AbWJEVEW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 17:04:22 -0400
To: jmorris@namei.org
In-Reply-To: <Pine.LNX.4.64.0610051651580.25705@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Morris <jmorris@namei.org>
Date: Thu, 5 Oct 2006 16:54:38 -0400 (EDT)

> >  #ifdef CONFIG_XFRM_SUB_POLICY
> >  	pol = xfrm_policy_lookup_bytype(XFRM_POLICY_TYPE_SUB, fl, family, dir);
> > -	if (pol)
> > +	if (IS_ERR(pol)) {
> > +		err = PTR_ERR(pol);
> > +		pol = NULL;
> > +	}
> > +	if (pol || err)
> >  		goto end;
> 
> Similarly, if the sub-policy lookup returns -EACCESS, should we then try a 
> main policy lookup before failing?

We're trying to fill the flow cache here.  In the case where we'd
have a match in both the sub-policy and main table, I think the
sub-policy is supposed to take precedence, and if you fail to get
this sub-policy you should fail the entire lookup.

The way the sub-policied entries work is that you find the sub-policy
as the primary object in the flow cache, and once you notice you have
a sub-policy you do an explicit lookup in the main table to put the
whole thing together.
