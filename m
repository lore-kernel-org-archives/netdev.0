From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fw: [Bugme-new] [Bug 5936] New: Openswan tunnels + netfilter
 problem
Date: Wed, 25 Jan 2006 10:25:27 +0100
Message-ID: <43D74407.5040705@trash.net>
References: <E1F1IYh-0001I3-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	webmaster@elnportal.it
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1F1IYh-0001I3-00@gondolin.me.apana.org.au>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Patrick McHardy <kaber@trash.net> wrote:
> 
>>Andrew Morton wrote:
>>
>>>http://bugzilla.kernel.org/show_bug.cgi?id=5936
>>
>>Please post your iptables rules and the full list of loaded modules.
> 
> 
> The problem is caused by SNAT on a dst that already has an xfrm set.
> When ip_route_me_harder processes the dst it will cause the dst to
> lose its xfrm since it has IPSKB_XFRM_TRANSFORMED set.
> 
> Since xfrm4_output_finish does not expect dst's to lose their xfrm's
> after POST_ROUTING, it crashes.
> 
> Obviously we could add a check in xfrm4_output_finish to prevent this
> crash, however, I think we need to consider this a bit more since it
> breaks a fairly common setup where people just stick a rule into the
> NAT table that says
> 
> iptables -t nat -I POSTROUTING -i eth1 -j MASQUERADE
> 
> where eth1 is the outbound interface.  If this rule catches any IPsec
> VPN traffic then it'll SNAT them even though the intention is obviously
> to let them through without SNAT.
> 
> Perhaps it's best to have SNAT not touch packets with dst->xfrm set.
> Unfortunately that leads to problems as well (albeit rarer) since you
> may have catch-all IPsec policies that every packet matches, but you
> want certain packets to be SNATed so that they match more specific
> policies.

I don't like adding this special behaviour for NAT, people need
to adjust their rulesets for filtering etc. anyway. We could stop
rerouting packets in between transforms (when both dst->xfrm and
IPSKB_XFRM_TRANSFORMED are set), but this is inconsistent with what
happens on input, when a packet is DNATed in PRE_ROUTING it does
affect the SA lookup. So I think I'd prefer handling this case in
xfrm[46]_output_finish, but I need to think about it a bit more.
