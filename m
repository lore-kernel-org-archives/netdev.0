From: James Morris <jmorris@namei.org>
Subject: Re: Is TCP over IPsec broken in 2.6.18?
Date: Sat, 30 Sep 2006 03:41:01 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0609300244280.17297@d.namei>
References: <Pine.LNX.4.64.0609241029410.14827@d.namei>
 <E1GRdnS-0003kd-00@gondolin.me.apana.org.au> <20060925103836.GA13966@2ka.mipt.ru>
 <20060925112754.GA18228@gondor.apana.org.au> <20060925120519.GA19010@2ka.mipt.ru>
 <Pine.LNX.4.64.0609300037460.12011@d.namei> <Pine.LNX.4.64.0609300110190.12422@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:3011 "EHLO
	mail8.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751114AbWI3HlE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Sep 2006 03:41:04 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Venkat Yekkirala <vyekkirala@TrustedCS.com>
In-Reply-To: <Pine.LNX.4.64.0609300110190.12422@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 30 Sep 2006, James Morris wrote:

> SELinux enabled is changed to permissive mode.


Ok, in the case where unencrypted packets are leaking, the problem is that 
xfrm_lookup() is returning a false zero on a polmatch denial like:

  avc:  denied  { polmatch } for  scontext=system_u:system_r:ftpd_t:s0 
  tcontext=system_u:object_r:unlabeled_t:s0 tclass=association


Follow the call back up from selinux_xfrm_policy_lookup(), when:

{
	rc = avc_has_perm(fl_secid, sel_sid, SECCLASS_ASSOCIATION,
                          ASSOCIATION__POLMATCH,
                          NULL);

	return rc;  <----  -EACCESS
}


Which is propagated back via 

   xfrm_policy_match()
   xfrm_policy_lookup_bytype()
   xfrm_policy_lookup()
   
to

int xfrm_lookup() 
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
		return 0;   <---- returns

	...
}

and the callers then allow the packet to proceed unencrypted.

It seems that some logic needs to be reworked to ensure that the real 
error value is propagated back and returned via xfrm_lookup().

I was also seeing these AVCs when receiving ping requests:

  avc:  denied { sendto } for scontext=system_u:object_r:unlabeled_t:s0 
  tcontext=system_u :object_r:unlabeled_t:s0 tclass=association

Not sure if there are any deeper issues in this case: the callers need to 
be audited.




- James
-- 
James Morris <jmorris@namei.org>
