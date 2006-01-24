From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: [Bugme-new] [Bug 5936] New: Openswan tunnels + netfilter
	problem
Date: Tue, 24 Jan 2006 18:25:43 +1100
Message-ID: <E1F1IYh-0001I3-00@gondolin.me.apana.org.au>
References: <43D3F186.6030206@trash.net>
Cc: akpm@osdl.org, netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	webmaster@elnportal.it
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: kaber@trash.net (Patrick McHardy)
In-Reply-To: <43D3F186.6030206@trash.net>
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

Patrick McHardy <kaber@trash.net> wrote:
> Andrew Morton wrote:
>> 
>> http://bugzilla.kernel.org/show_bug.cgi?id=5936
> 
> Please post your iptables rules and the full list of loaded modules.

The problem is caused by SNAT on a dst that already has an xfrm set.
When ip_route_me_harder processes the dst it will cause the dst to
lose its xfrm since it has IPSKB_XFRM_TRANSFORMED set.

Since xfrm4_output_finish does not expect dst's to lose their xfrm's
after POST_ROUTING, it crashes.

Obviously we could add a check in xfrm4_output_finish to prevent this
crash, however, I think we need to consider this a bit more since it
breaks a fairly common setup where people just stick a rule into the
NAT table that says

iptables -t nat -I POSTROUTING -i eth1 -j MASQUERADE

where eth1 is the outbound interface.  If this rule catches any IPsec
VPN traffic then it'll SNAT them even though the intention is obviously
to let them through without SNAT.

Perhaps it's best to have SNAT not touch packets with dst->xfrm set.
Unfortunately that leads to problems as well (albeit rarer) since you
may have catch-all IPsec policies that every packet matches, but you
want certain packets to be SNATed so that they match more specific
policies.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
