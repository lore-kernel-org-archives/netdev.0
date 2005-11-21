From: Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
Subject: Re: [PATCH 06/13]: [IPV4/6]: Netfilter IPsec input hooks
Date: Mon, 21 Nov 2005 19:53:49 +0900 (JST)
Message-ID: <200511211053.jALAroPd022443@toshiba.co.jp>
References: <20051120163135.16666.76993.sendpatchset@localhost.localdomain>
	<200511210442.jAL4gPoO001846@toshiba.co.jp>
	<43816EB4.4080205@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	davem@davemloft.net, yasuyuki.kozakai@toshiba.co.jp
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: kaber@trash.net
In-Reply-To: <43816EB4.4080205@trash.net>
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


Hi,

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 21 Nov 2005 07:52:36 +0100

> I don't see why it is confusing. Plain text packets are visible before
> encapsulation (and they have to be because we don't necessarily know
> if packets will be encapsulated at the time the hooks are called in
> case the policy lookup after NAT returns a policy), plain text packets
> are visible after decapsulation. With different hooks we can't have
> symetrical behaviour because of the case I mentioned above, and that
> would be confusing IMO.

Well, what I worried about was just ease to use, not internal processing.
I suspected that users can correctly configure IPsec and packet filtering.
Just doing "iptables -P INPUT -j DROP; iptables -A INPUT -p esp -j ACCEPT"
will drop all input packets and this is different behavior with current
kernel, for example. So I just imagined many people would say "Why ?".

But as you said in other mail, probably this is my needles fear, isn't this ?
As you know, I'm basically worrier. :)

> > And this can be said about IPv6 input path. If packets have not been mangled
> > (this is ordinary case because ip6tables doesn't have neither NAT nor
> > target module to mangle addresses directly), they don't have to re-route
> > and don't have to re-visit ip6_input_finish().
> > 
> > In the other way, if their addresses have been mangled, it's necessary to
> > re-route. I agree re-visiting ip6_input_finish() in this case.
> 
> Same goes for ip6_input_finish as for ip_local_deliver_finish(),
> the packet would continue its path there anyway. Do you actually
> mean ip6_rcv_finish()?

No. I mean ip6_input_finish(). calling ip6_input_finish() twice causes
problem at processing of IPv6 extension headers. This is different point
between IPv4 and IPv6.

Please note that I don't mean IPv4 processing in your patch has problem.
I think it will work. What I wanted to do was just avoiding double processing
of extension headers and synchronizing IPv4/IPv6 behavior as possible.

> > Then, why don't we make xfrm{4,6}_rcv_spi() return 0 (1 if IPv6)
> > so that ip_local_deliver_finish()/ip6_input_finish() can continue to process
> > headers if packets have not been mangled ? Is this difficult or impossible to
> > implement ?
> 
> I'm not sure I understand. Do you propose to check if the packet was
> mangled after the PRE_ROUTING hook (if it was not stolen or queued)
> and if not return directly to ip6_input_finish()?

Yes.

>                                                    Where would the
> LOCAL_IN hook be called?

Ah, indeed. But we can add it just before return directly to
ip6_input_finish().

> > This can solve the issue about twice processing of statistics and IPv6
> > extension headers. Because ip_local_deliver_finish()/ip6_input_finish() can
> > continue to process extension headers after ESP/AH in ordinary case.
> 
> AFAICT statistics are not affected by my patches, except for the
> iptables counters. The double parsing of extension headers is indeed
> a problem I forgot about, it looks like we need to carry nhoff around
> if it can't be derived from the packet.

Of cause that is one solution.

-- Yasuyuki Kozakai
