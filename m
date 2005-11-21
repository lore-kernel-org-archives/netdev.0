From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 06/13]: [IPV4/6]: Netfilter IPsec input hooks
Date: Mon, 21 Nov 2005 07:52:36 +0100
Message-ID: <43816EB4.4080205@trash.net>
References: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>	<20051120163135.16666.76993.sendpatchset@localhost.localdomain>
	<200511210442.jAL4gPoO001846@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	davem@davemloft.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
In-Reply-To: <200511210442.jAL4gPoO001846@toshiba.co.jp>
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

Yasuyuki KOZAKAI wrote:
> At first, now I could agree to use same name for hooks before/after xfrm
> processing, if it's important to keep compatibility than to avoid difficulty
> to use. Even now I think it's confusing to pass packets before/after xfrm to
> same hook, and believe it's ideal to use different name for them.
> But people can configure correctly according to you, then my concern might be
> needless fear.

I don't see why it is confusing. Plain text packets are visible before
encapsulation (and they have to be because we don't necessarily know
if packets will be encapsulated at the time the hooks are called in
case the policy lookup after NAT returns a policy), plain text packets
are visible after decapsulation. With different hooks we can't have
symetrical behaviour because of the case I mentioned above, and that
would be confusing IMO.

> Next is about re-visiting stack, I'm beginning to understand your patch.
> It looks natural to re-route after DNAT on input path of IPv4. That's really
> needed if packets have been mangled.
> 
> But is there any reason that we have to allow packets to re-visit
> ip_local_deliver_finish() in the case that they have not been mangled
> at PRE_ROUTING ? I think no. This situation is like ip_nat_out().

My patches don't change when and if packets will reach
ip_local_deliver_finish(), they just add a possibility for rerouting.
Currently the transforms are called from ip_local_deliver_finish() and
in transport mode the decapsulated packet continues its path in
ip_local_deliver_finish(), with my patches they will go through two
netfilter hooks and continue the exact same codepath, given that
they are not NATed to a foreign destination IP on their way.

> And this can be said about IPv6 input path. If packets have not been mangled
> (this is ordinary case because ip6tables doesn't have neither NAT nor
> target module to mangle addresses directly), they don't have to re-route
> and don't have to re-visit ip6_input_finish().
> 
> In the other way, if their addresses have been mangled, it's necessary to
> re-route. I agree re-visiting ip6_input_finish() in this case.

Same goes for ip6_input_finish as for ip_local_deliver_finish(),
the packet would continue its path there anyway. Do you actually
mean ip6_rcv_finish()?

> Then, why don't we make xfrm{4,6}_rcv_spi() return 0 (1 if IPv6)
> so that ip_local_deliver_finish()/ip6_input_finish() can continue to process
> headers if packets have not been mangled ? Is this difficult or impossible to
> implement ?

I'm not sure I understand. Do you propose to check if the packet was
mangled after the PRE_ROUTING hook (if it was not stolen or queued)
and if not return directly to ip6_input_finish()? Where would the
LOCAL_IN hook be called?

> This can solve the issue about twice processing of statistics and IPv6
> extension headers. Because ip_local_deliver_finish()/ip6_input_finish() can
> continue to process extension headers after ESP/AH in ordinary case.

AFAICT statistics are not affected by my patches, except for the
iptables counters. The double parsing of extension headers is indeed
a problem I forgot about, it looks like we need to carry nhoff around
if it can't be derived from the packet.

Regards
Patrick
