From: Patrick McHardy <kaber@trash.net>
Subject: Re: Broken commit: [NETFILTER]: ipt_REJECT: remove largely duplicate
 route_reverse function
Date: Tue, 28 Nov 2006 22:45:49 +0100
Message-ID: <456CAE0D.2080209@trash.net>
References: <m3fyc3e84s.fsf@defiant.localdomain> <456C94D2.9000602@trash.net> <m3wt5fb8lz.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020901050501040105090504"
Cc: David Miller <davem@davemloft.net>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@lists.netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39084 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1756985AbWK1Vpy
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Nov 2006 16:45:54 -0500
To: Krzysztof Halasa <khc@pm.waw.pl>
In-Reply-To: <m3wt5fb8lz.fsf@defiant.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020901050501040105090504
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Krzysztof Halasa wrote:
> Patrick McHardy <kaber@trash.net> writes:
> 
>>How sure are you about this? I can see nothing wrong with that
>>commit and can't reproduce the slab corruption. Please post
>>the rule that triggers this.
> 
> 
> 99% sure. Past this commit I get corruptions after 5 minutes at most
> (that's ADSL with USB Thomson/Alcatel Speedtouch -> PPP over ATM,
> with a GRE tunnel over that PPP).

It might be the case that your network device has a
hard_header_len > LL_MAX_HEADER, which could trigger
a corruption.

> I'm now running 901eaf6c8f997f18ebc8fcbb85411c79161ab3b2 (i.e. the
> last commit before the one in question) for 4 hours and nothing like
> that.
> 
> Not sure about the exact rule, but the most probable candidates are:
> -A INPUT -p tcp --tcp-flags SYN,RST,ACK SYN -j REJECT --reject-with tcp-reset
> -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable
> 
> Other "REJECT" rules haven't fired yet.
> 
> Could be some obscure problem with GRE/Speedtouch/PPP over ATM,
> triggered by this patch, though.
> 
> Perhaps I can do some experiments - just say a word.

Please try this patch on top of the REJECT patch (ideally after
verifying that the REJECT patch is really introducing the
corruption).


--------------020901050501040105090504
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJECT.c
index ad0312d..264763a 100644
--- a/net/ipv4/netfilter/ipt_REJECT.c
+++ b/net/ipv4/netfilter/ipt_REJECT.c
@@ -114,6 +114,14 @@ static void send_reset(struct sk_buff *o
 	tcph->window = 0;
 	tcph->urg_ptr = 0;
 
+	/* Adjust TCP checksum */
+	tcph->check = 0;
+	tcph->check = tcp_v4_check(tcph, sizeof(struct tcphdr),
+				   nskb->nh.iph->saddr,
+				   nskb->nh.iph->daddr,
+				   csum_partial((char *)tcph,
+						sizeof(struct tcphdr), 0));
+
 	/* Set DF, id = 0 */
 	nskb->nh.iph->frag_off = htons(IP_DF);
 	nskb->nh.iph->id = 0;
@@ -129,14 +137,8 @@ #endif
 	if (ip_route_me_harder(&nskb, addr_type))
 		goto free_nskb;
 
-	/* Adjust TCP checksum */
 	nskb->ip_summed = CHECKSUM_NONE;
-	tcph->check = 0;
-	tcph->check = tcp_v4_check(tcph, sizeof(struct tcphdr),
-				   nskb->nh.iph->saddr,
-				   nskb->nh.iph->daddr,
-				   csum_partial((char *)tcph,
-						sizeof(struct tcphdr), 0));
+
 	/* Adjust IP TTL */
 	nskb->nh.iph->ttl = dst_metric(nskb->dst, RTAX_HOPLIMIT);
 

--------------020901050501040105090504--
