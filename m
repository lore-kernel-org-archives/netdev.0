From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] xfrm: Fix double dst_release() in xfrm_lookup() -EREMOTE
 case
Date: Thu, 08 Apr 2010 15:39:38 +0300
Message-ID: <4BBDCE8A.7040106@iki.fi>
References: <1270729773-1758-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f222.google.com ([209.85.219.222]:38635 "EHLO
	mail-ew0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758634Ab0DHMjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 08:39:41 -0400
Received: by ewy22 with SMTP id 22so971487ewy.37
        for <netdev@vger.kernel.org>; Thu, 08 Apr 2010 05:39:40 -0700 (PDT)
In-Reply-To: <1270729773-1758-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark Brown wrote:
> Commit 80c802 ("xfrm: cache bundles instead of policies for outgoing
> flows") changed __xfrm_policy() to call dst_release() when returning
> -EREMOTE. In the case where this is called from xfrm_lookup() a double
> call to dst_release() would result due to the existing dst_release()
> there. Remove the dst_release() in xfrm_lookup().
> 
> Signed-off-by: Mark Brown <broonie@opensource.wolfsonmicro.com>
> ---
> 
> I'm not sure if this is correct or not - there may a reference been
> taken earlier in __xfrm_lookup() that's being dropped but I didn't spot
> it.

This is not correct.

The only case we return -EREMOTE from __xfrm_policy() is at:
                if (net->xfrm.sysctl_larval_drop) {
                        /* EREMOTE tells the caller to generate
                         * a one-shot blackhole route. */
                        dst_release(dst);
                        xfrm_pols_put(pols, num_pols);
                        XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTNOSTATES);
                        return -EREMOTE;
                }

It drops the inner xfrm_dst returned from flow cache lookup / resolver.
xfrm_lookup() will drop the original dst (which is not xfrm_dst).

This semantics is important because __xfrm_lookup() is also called
from other places, that do other things when they get -EREMOTE.

- TImo
