From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 1/3] Fix for IPsec leakage with SELinux enabled - V.03
Date: Thu, 5 Oct 2006 16:54:38 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0610051651580.25705@d.namei>
References: <45256E33.8080205@trustedcs.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Eric Paris <eparis@redhat.com>, johnpol@2ka.mipt.ru,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sea5.speakeasy.net ([69.17.117.3]:57780 "EHLO
	mail1.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932192AbWJEUym (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 16:54:42 -0400
To: Venkat Yekkirala <vyekkirala@trustedcs.com>,
	"David S. Miller" <davem@davemloft.net>,
	Paul Moore <paul.moore@hp.com>
In-Reply-To: <45256E33.8080205@trustedcs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 5 Oct 2006, Venkat Yekkirala wrote:

> -		if (xfrm_policy_match(pol, fl, type, family, dir)) {
> +		err = xfrm_policy_match(pol, fl, type, family, dir);
> +		if (err) {
> +			if (err == -ESRCH)
> +				continue;
> +			else {
> +				ret = ERR_PTR(err);
> +				goto fail;
> +			}
> +		} else {

Semantics issue: if the exact policy match fails with -EACCESS, should we 
then try an inexact match before failing?

>  #ifdef CONFIG_XFRM_SUB_POLICY
>  	pol = xfrm_policy_lookup_bytype(XFRM_POLICY_TYPE_SUB, fl, family, dir);
> -	if (pol)
> +	if (IS_ERR(pol)) {
> +		err = PTR_ERR(pol);
> +		pol = NULL;
> +	}
> +	if (pol || err)
>  		goto end;

Similarly, if the sub-policy lookup returns -EACCESS, should we then try a 
main policy lookup before failing?

I would think yes to both.

Opinions?


- James
-- 
James Morris
<jmorris@namei.org>
