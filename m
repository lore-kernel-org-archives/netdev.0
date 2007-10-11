From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: Re: [PATCH net-2.6.23-rc5] ipsec interfamily route handling fix
Date: Thu, 11 Oct 2007 11:53:45 +0300
Message-ID: <200710111153.45530.joakim.koskela@hiit.fi>
References: <200709061900.10508.joakim.koskela@hiit.fi> <20070914.134252.112612041.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from creon.otaverkko.fi ([212.68.0.5]:59151 "EHLO creon.otaverkko.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753356AbXJKJN1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Oct 2007 05:13:27 -0400
In-Reply-To: <20070914.134252.112612041.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 14 September 2007 23:42:52 David Miller wrote:
> From: Joakim Koskela <joakim.koskela@hiit.fi>
> Date: Thu, 6 Sep 2007 19:00:10 +0300
>
> > This patch addresses a couple of issues related to interfamily ipsec
> > modes. The problem is that the structure of the routing info changes
> > with the family during the __xfrmX_bundle_create, which hasn't been
> > taken properly into account. Seems that by coincidence it hasn't
>
> Since nobody else found time to review this, I did :-)
>

Thanks for taking the time, and sorry for not getting back on this until
now..

> It sets encap_type in the inner loop, but what if we find multiple
> entries some ipv4 and some ipv6?  This logic can't be right.
>
> Instead, we need to treat these objects on an individual basis, I
> think, and that requires a bit more changes.

Yes, this is what I was worried about. But as I'm not that familiar with 
how these dst_entries are used down the line or with subpolicy 
transformations I didn't feel comfortable rewriting that completely.
I'm trying to get this thing solved (any help is of course appreciated :),
but in the meantime I think the following bit could actually be separated as,
although related, fixes an issue not directly tied to the original problem
(..and would be great to get applied as it makes interfamily work quite ok
for a number of setups). What do you think?

..and for a short description:

This patch resets the ipv4-related flags in the new flow as their content
will otherwise depend on the bits of the ipv6 addresses the struct was 
previously used for. For example, fl4_tos might have RTO_ONLINK set, which
usually prevents the right route from being found.

--
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 15aa4c5..b4a0b54 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -185,6 +185,8 @@ __xfrm6_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 			case AF_INET:
 				fl_tunnel.fl4_dst = xfrm[i]->id.daddr.a4;
 				fl_tunnel.fl4_src = xfrm[i]->props.saddr.a4;
+				fl_tunnel.fl4_tos = 0;
+				fl_tunnel.fl4_scope = 0;
 				break;
 			case AF_INET6:
 				ipv6_addr_copy(&fl_tunnel.fl6_dst, __xfrm6_bundle_addr_remote(xfrm[i], &fl->fl6_dst));
