From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: Crashes in xfrm_lookup
Date: Thu, 08 Apr 2010 14:24:41 +0300
Message-ID: <4BBDBCF9.5060906@iki.fi>
References: <20100408111441.GA14241@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f222.google.com ([209.85.219.222]:55092 "EHLO
	mail-ew0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758552Ab0DHLYo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 07:24:44 -0400
Received: by ewy22 with SMTP id 22so948403ewy.37
        for <netdev@vger.kernel.org>; Thu, 08 Apr 2010 04:24:43 -0700 (PDT)
In-Reply-To: <20100408111441.GA14241@sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark Brown wrote:
> With -next as of today I'm experiencing crashes in the xfrm_lookup code
> when attempting to boot from an NFS root on a SMDK6410 (an ARM based
> development board).  I'm currently investigating what's gone wrong, but
> thought it was better to report early in case it's obvious to someone
> familiar with the code or there's a fix already.

Probably the same as http://marc.info/?t=127071006600005&r=1&w=2

Happens because CONFIG_XFRM_SUB_POLICY is not enabled, and one of
the helper functions I used did unexpected things in that case.

Try the following:

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 625dd61..cccb049 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -735,19 +735,12 @@ static inline void xfrm_pol_put(struct xfrm_policy *policy)
 		xfrm_policy_destroy(policy);
 }
 
-#ifdef CONFIG_XFRM_SUB_POLICY
 static inline void xfrm_pols_put(struct xfrm_policy **pols, int npols)
 {
 	int i;
 	for (i = npols - 1; i >= 0; --i)
 		xfrm_pol_put(pols[i]);
 }
-#else
-static inline void xfrm_pols_put(struct xfrm_policy **pols, int npols)
-{
-	xfrm_pol_put(pols[0]);
-}
-#endif
 
 extern void __xfrm_state_destroy(struct xfrm_state *);
 

