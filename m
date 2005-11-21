From: Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
Subject: Re: [PATCH 06/13]: [IPV4/6]: Netfilter IPsec input hooks
Date: Mon, 21 Nov 2005 13:42:24 +0900 (JST)
Message-ID: <200511210442.jAL4gP5c001845@toshiba.co.jp>
References: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
	<20051120163135.16666.76993.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	davem@davemloft.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: kaber@trash.net
In-Reply-To: <20051120163135.16666.76993.sendpatchset@localhost.localdomain>
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


Hi, Patrick,

From: Patrick McHardy <kaber@trash.net>
Date: Sun, 20 Nov 2005 17:31:36 +0100

> [IPV4/6]: Netfilter IPsec input hooks
> 
> When the innermost transform uses transport mode the decapsulated packet
> is not visible to netfilter. Pass the packet through the PRE_ROUTING and
> LOCAL_IN hooks again before handing it to upper layer protocols to make
> netfilter-visibility symetrical to the output path.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

At first, now I could agree to use same name for hooks before/after xfrm
processing, if it's important to keep compatibility than to avoid difficulty
to use. Even now I think it's confusing to pass packets before/after xfrm to
same hook, and believe it's ideal to use different name for them.
But people can configure correctly according to you, then my concern might be
needless fear.

Next is about re-visiting stack, I'm beginning to understand your patch.
It looks natural to re-route after DNAT on input path of IPv4. That's really
needed if packets have been mangled.

But is there any reason that we have to allow packets to re-visit
ip_local_deliver_finish() in the case that they have not been mangled
at PRE_ROUTING ? I think no. This situation is like ip_nat_out().

And this can be said about IPv6 input path. If packets have not been mangled
(this is ordinary case because ip6tables doesn't have neither NAT nor
target module to mangle addresses directly), they don't have to re-route
and don't have to re-visit ip6_input_finish().

In the other way, if their addresses have been mangled, it's necessary to
re-route. I agree re-visiting ip6_input_finish() in this case.

Then, why don't we make xfrm{4,6}_rcv_spi() return 0 (1 if IPv6)
so that ip_local_deliver_finish()/ip6_input_finish() can continue to process
headers if packets have not been mangled ? Is this difficult or impossible to
implement ?

This can solve the issue about twice processing of statistics and IPv6
extension headers. Because ip_local_deliver_finish()/ip6_input_finish() can
continue to process extension headers after ESP/AH in ordinary case.

In special case, if some codes mangle IPv6 addresses, that's the codes
to take care of the possibility of re-visiting ip6_input_finish().

What do you think ?

# Please note that these are just my opinions and other USAGI guys might have
# other opinions.

Regards,

-- Yasuyuki Kozakai
