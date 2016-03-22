From: Lance Richardson <lrichard@redhat.com>
Subject: Re: [PATCH net] ipv4: initialize flowi4_flags before calling
 fib_lookup()
Date: Tue, 22 Mar 2016 14:41:48 -0400 (EDT)
Message-ID: <950377980.72657238.1458672108040.JavaMail.zimbra@redhat.com>
References: <1458660679-7279-1-git-send-email-lrichard@redhat.com> <56F18EEE.4070000@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3-phx2.redhat.com ([209.132.183.24]:53449 "EHLO
	mx3-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750728AbcCVSlu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 14:41:50 -0400
In-Reply-To: <56F18EEE.4070000@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

----- Original Message -----
> From: "David Ahern" <dsa@cumulusnetworks.com>
> To: "Lance Richardson" <lrichard@redhat.com>, netdev@vger.kernel.org
> Sent: Tuesday, March 22, 2016 2:29:02 PM
> Subject: Re: [PATCH net] ipv4: initialize flowi4_flags before calling fib_lookup()
> 
> On 3/22/16 9:31 AM, Lance Richardson wrote:
> > Field fl4.flowi4_flags is not initialized in fib_compute_spec_dst()
> > before calling fib_lookup(), which means fib_table_lookup() is
> > using non-deterministic data at this line:
> >
> > 	if (!(flp->flowi4_flags & FLOWI_FLAG_SKIP_NH_OIF)) {
> >
> > Fix by initializing fl4.flowi4_flags to zero.
> >
> > Signed-off-by: Lance Richardson <lrichard@redhat.com>
> > ---
> >   net/ipv4/fib_frontend.c | 1 +
> >   1 file changed, 1 insertion(+)
> >
> > diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
> > index 21add55..896844a 100644
> > --- a/net/ipv4/fib_frontend.c
> > +++ b/net/ipv4/fib_frontend.c
> > @@ -304,6 +304,7 @@ __be32 fib_compute_spec_dst(struct sk_buff *skb)
> >   		fl4.flowi4_scope = scope;
> >   		fl4.flowi4_mark = IN_DEV_SRC_VMARK(in_dev) ? skb->mark : 0;
> >   		fl4.flowi4_tun_key.tun_id = 0;
> > +		fl4.flowi4_flags = 0;
> >   		if (!fib_lookup(net, &fl4, &res, 0))
> >   			return FIB_RES_PREFSRC(net, res);
> >   	} else {
> >
> 
> Fixes: 58189ca7b2741 ("net: Fix vti use case with oif in dst lookups")
> 
> I think a more robust solution is to move fl4 to this if case and init
> when it is declared:
> 
> 	struct flowi4 fl4 = {
> 		.flowi4_iif = LOOPBACK_IFINDEX,
> 		.daddr = ip_hdr(skb)->saddr,
> 		.flowi4_tos = RT_TOS(ip_hdr(skb)->tos),
> 		.flowi4_scope = scope,
> 		.flowi4_mark = IN_DEV_SRC_VMARK(in_dev) ? skb->mark : 0,
> 	};
> 

Agreed... I actually debated doing something similar but opted for the
smaller delta.

v2 coming up.

Thanks for the review,

   Lance
