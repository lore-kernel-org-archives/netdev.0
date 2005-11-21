From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 06/13]: [IPV4/6]: Netfilter IPsec input hooks
Date: Mon, 21 Nov 2005 17:34:51 +0100
Message-ID: <4381F72B.3090007@trash.net>
References: <20051120163135.16666.76993.sendpatchset@localhost.localdomain>	<200511210442.jAL4gPoO001846@toshiba.co.jp>	<43816EB4.4080205@trash.net>
	<200511211053.jALAro04019574@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	davem@davemloft.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
In-Reply-To: <200511211053.jALAro04019574@toshiba.co.jp>
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
>>I don't see why it is confusing. Plain text packets are visible before
>>encapsulation (and they have to be because we don't necessarily know
>>if packets will be encapsulated at the time the hooks are called in
>>case the policy lookup after NAT returns a policy), plain text packets
>>are visible after decapsulation. With different hooks we can't have
>>symetrical behaviour because of the case I mentioned above, and that
>>would be confusing IMO.
> 
> Well, what I worried about was just ease to use, not internal processing.
> I suspected that users can correctly configure IPsec and packet filtering.
> Just doing "iptables -P INPUT -j DROP; iptables -A INPUT -p esp -j ACCEPT"
> will drop all input packets and this is different behavior with current
> kernel, for example. So I just imagined many people would say "Why ?".
> 
> But as you said in other mail, probably this is my needles fear, isn't this ?
> As you know, I'm basically worrier. :)

:) I think its OK since in tunnel mode the decapsulated packets already
need to be allowed by the ruleset, so I think its not too confusing to
expect the same in transport mode.

>>>Then, why don't we make xfrm{4,6}_rcv_spi() return 0 (1 if IPv6)
>>>so that ip_local_deliver_finish()/ip6_input_finish() can continue to process
>>>headers if packets have not been mangled ? Is this difficult or impossible to
>>>implement ?
>>
>>I'm not sure I understand. Do you propose to check if the packet was
>>mangled after the PRE_ROUTING hook (if it was not stolen or queued)
>>and if not return directly to ip6_input_finish()?
> 
> Yes.
> 
>> Where would the LOCAL_IN hook be called?
> 
> Ah, indeed. But we can add it just before return directly to
> ip6_input_finish().

Please see my mail to Kazunori. The hooks take ownership of the
skb, changing this would become pretty ugly because of queued
or stolen packets. And it would still leave one path where packets
are not directly returned, so I think the double-parsing should
be handled otherwise.

>>AFAICT statistics are not affected by my patches, except for the
>>iptables counters. The double parsing of extension headers is indeed
>>a problem I forgot about, it looks like we need to carry nhoff around
>>if it can't be derived from the packet.
> 
> Of cause that is one solution.

I'm going to try that if I can't come up with something better.
