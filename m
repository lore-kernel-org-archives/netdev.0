From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: PMTU discovery is broken on kernel 3.7.1 for UDP sockets
Date: Thu, 20 Dec 2012 13:35:35 +0100
Message-ID: <20121220123535.GN18940@secunet.com>
References: <50D1BCC0.2000208@oktetlabs.ru>
 <1355924119.2676.6.camel@bwh-desktop.uk.solarflarecom.com>
 <50D1CECE.7090706@oktetlabs.ru>
 <1355945864.2676.21.camel@bwh-desktop.uk.solarflarecom.com>
 <20121220073445.GM18940@secunet.com>
 <50D2F4E5.4050904@oktetlabs.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	"Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>
To: "Yurij M. Plotnikov" <Yurij.Plotnikov@oktetlabs.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:46395 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751359Ab2LTMfi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2012 07:35:38 -0500
Content-Disposition: inline
In-Reply-To: <50D2F4E5.4050904@oktetlabs.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 20, 2012 at 03:22:13PM +0400, Yurij M. Plotnikov wrote:
> On 12/20/12 11:34, Steffen Klassert wrote:
> >
> >diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
> >index 3c9d208..1049ce0 100644
> >--- a/net/ipv4/ip_sockglue.c
> >+++ b/net/ipv4/ip_sockglue.c
> >@@ -1198,7 +1198,7 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
> >  	{
> >  		struct dst_entry *dst;
> >  		val = 0;
> >-		dst = sk_dst_get(sk);
> >+		dst = sk_dst_check(sk, 0);
> >  		if (dst) {
> >  			val = dst_mtu(dst);
> >  			dst_release(dst);
> With this patch kernel 3.7.1 works perfect. All described problems
> are fixed.

Thanks for testing!

I'm not sure if we can't use this as a fix. I think with this patch it
could happen that we return -ENOTCONN instead of a pmtu value on a
connected socket. Perhaps it is better to update the cached dst_entry in
ipv4_sk_update_pmtu() when we receive the -EMSGSIZE. I'll do some
investigation.

Anyway, it is still odd that reverting my other patch 'fixes'
this issue too.
