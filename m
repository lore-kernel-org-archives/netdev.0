From: Patrick McHardy <kaber@trash.net>
Subject: Re: ip6tables: accept of IPv6 transport esp packages not possible
 - no rule matches
Date: Sun, 02 Jan 2005 12:42:54 +0100
Message-ID: <41D7DE3E.2090304@trash.net>
References: <019064D0423CE6C823CBF476@t1mobil.muc.aerasec.de>
	<5F6ACA5CEF52DBFBF11FBF94@t1mobil.muc.aerasec.de>
	<41CD8B4F.6010402@trash.net>
	<85346B5DA83795C08812E782@worker.muc.bieringer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Maillist netdev <netdev@oss.sgi.com>,
	Netfilter development mailing list <netfilter-devel@lists.netfilter.org>,
	USAGI core <usagi-core@linux-ipv6.org>, Harald Welte <laforge@gnumonks.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Peter Bieringer <pb@bieringer.de>
In-Reply-To: <85346B5DA83795C08812E782@worker.muc.bieringer.de>
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

Peter Bieringer wrote:
>>Does this patch fix the problem ?
>>
> Yes, this patch fix the problem on the incoming side:

Thanks.

> 
> I ping6 to a remote host via IPsec in transport mode:
> 
> IPv6 INPUT chain:
> 
>     0     0 ACCEPT     icmpv6    *      *       ::/0                 ::/0
> ipv6-icmp type 128
>     0     0 ACCEPT     icmpv6    *      *       ::/0                 ::/0
> ipv6-icmp type 129
>     1   156 ACCEPT     esp      *      *       remote/128  local/128
>     0     0 ACCEPT     all      *      *       remote/128  local/128
> 
> 
> So the proper chain matches.
> 
> 
> But I wonder a little bit because of the result of the OUTPUT chain:
> 
>     0     0 ACCEPT     icmpv6    *      *       ::/0                 ::/0
> ipv6-icmp type 129
>     1   104 ACCEPT     icmpv6    *      *       ::/0                 ::/0
> ipv6-icmp type 128
>     0     0 ACCEPT     esp      *      *       local/128  remote/128
>     0     0 ACCEPT     all      *      *       local/128  remote/128
> 
> 
> Here, the ICMPv6 rule matches.
> 
> This means for me that the traffic goes like this:
> 
> OUTPUT: ping6 -> netfilter -> encryption -> ESP
> INPUT : ESP -> netfilter -> decryption -> ping6

More specific, with transport mode it goes:

OUTPUT: ping6 -> LOCAL_OUT -> encryption -> POST_ROUTING
INPUT: ESP -> PRE_ROUTING -> LOCAL_IN -> decryption -> ping6

Filtering for IPv6 happens on LOCAL_IN/LOCAL_OUT (and FORWARD).

> Is this logical?

Not very. Patches to improve this for IPv4 will be submitted
next week, but IPv6 still needs some work.

> 
> BTW: how to filter incoming traffic after decryption?

Use tunnel-mode. The decrypted packets will hit PRE_ROUTING
and LOCAL_IN again.

Regards
Patrick
