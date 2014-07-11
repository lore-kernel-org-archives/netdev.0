From: Florian Westphal <fw@strlen.de>
Subject: Re: [Bug 79891] New: Router causes TCP retransmits for windows hosts
 after "ip_forward: fix inverted local_df test"
Date: Sat, 12 Jul 2014 00:07:31 +0200
Message-ID: <20140711220731.GA15184@breakpoint.cc>
References: <1405102310.26540.83.camel@deadeye.wl.decadent.org.uk>
 <CAHA+R7PDJ42Y1Wovtw=dzN-JqQjcamPtDPSmS_SyUK95JNp_aA@mail.gmail.com>
 <1405105272.26540.88.camel@deadeye.wl.decadent.org.uk>
 <20140711.121448.272840314486162433.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ben@decadent.org.uk, cwang@twopensource.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	stable@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:60484 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755297AbaGKWHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 18:07:40 -0400
Content-Disposition: inline
In-Reply-To: <20140711.121448.272840314486162433.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Fri, 11 Jul 2014 20:01:12 +0100
> 
> > On Fri, 2014-07-11 at 11:38 -0700, Cong Wang wrote:
[..]

> >> >> > http://marc.info/?l=linux-netdev&m=139949081418806&w=2
> >> >> >
> >> >>
> >> >> This commit should have been reverted for older kernels like 3.2.y.
> >> >
> >> > Really?  We already had fe6cc55f3a9 ("net: ip, ipv6: handle gso skbs in
> >> > forwarding path") backported in 3.2.57.
> >> 
> >> I haven't read the code, but according to a previous discussion it sounds
> >> like that should be reverted:
> >> 
> >> http://lists.openwall.net/netdev/2014/06/11/67
> > 
> > My reading of that is we need 895162b1101b ("netfilter: ipv4: defrag:
> > set local_df flag on defragmented skb") in 3.2.y and 3.4.y.  But there
> > seem to be many other places that local_df should be set, that have only
> > recently been fixed.  So maybe reverting is the safer option.
> 
> Reverting is indeed probably safer.

Right, I agree.  Reverting is safer.

IMO there are two possible options for 3.2 / 3.4:

1. Revert fe6cc55f3a9 ("net: ip, ipv6: handle gso skbs in forwarding
   path")
2. Backport 21d1196a3 ("ipv4: set transport header earlier") to 3.2/3.4 -stable

[ The problem is that transport header is not yet set in 3.2/3.4 in forward
  path so skb_gso_network_seglen() returns bogus length ]

There is a 3rd alternative (i mention this for completeness only).
You could sort-of 'soft-revert' to the old behaviour to not care
about GRO packets in the forward path.  The minium change is:

diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -50,7 +50,7 @@ static bool ip_exceeds_mtu(const struct sk_buff *skb, unsigned int mtu)
        if (skb->len <= mtu)
                return false;
 
-       if (skb_is_gso(skb) && skb_gso_network_seglen(skb) <= mtu)
+       if (skb_is_gso(skb))
                return false;
 
        return true;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index cb9df0e..f05d6ef 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -354,7 +354,7 @@ static bool ip6_pkt_too_big(const struct sk_buff *skb, unsigned int mtu)
        if (skb->ignore_df)
                return false;
 
-       if (skb_is_gso(skb) && skb_gso_network_seglen(skb) <= mtu)
+       if (skb_is_gso(skb))
                return false;
 
        return true;

Dave/Greg, if this is what you prefer just let me know and I can submit such patch for 3.2
and 3.4 stable series.
