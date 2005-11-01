From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NF+IPsec 4/6]: Make IPsec input processing symetrical to output
Date: Tue, 01 Nov 2005 19:23:22 +0100
Message-ID: <4367B29A.8050809@trash.net>
References: <20051026003954.GA14068@gondor.apana.org.au>	<4360E75A.10405@trash.net>	<43655428.3040904@trash.net>
	<200510310319.j9V3JHNl019752@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	herbert@gondor.apana.org.au
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
In-Reply-To: <200510310319.j9V3JHNl019752@toshiba.co.jp>
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
>>Patrick McHardy wrote:
>>
>>>Herbert Xu wrote:
>>>
>>>>I presume that you will be changing the output path so that LOCAL_OUT
>>>>does not see the plain-text packet.  Otherwise it'll be asymmetric with
>>>>repsect to the inbound side which does not see plain-text packets for
>>>>transport mode SAs.
> 
> I support this way.

Hiding the packets from the hooks dependant on the xfrm_state is always
a problem with NAT, because when we do a second xfrm lookup after NAT
it is already to late to hide the packets.

>>>Yes, that was the idea. But since people seem to consider this an
>>>important case to handle I'm going to try the per-SA flag you
>>>proposed. I'll send new patches in the next days.
> 
> I think pure transport mode is important, too. For example, for users of
> L2TP over IPsec.
> 
> But I'm not sure that how many people wants to use netfilter hook together.
> At least, I don't need that. Because I can use IPsec policy instead of
> iptables rule and that's enough for me.
> 
> I also think that it's the work for IPsec policy check to decide to
> accept or drop decrypted packets on input path of transport mode, that is
> not netfilter work.

I agree that its the job of policy checks, but its often simpler to
add a policy which includes just IP addresses and use iptables for
filtering. Connection state, TCP flags, ..., can't be handled using
policy checks, and netfilter might also be used for marking, TCP MSS
rewriting, proxy redirection, ...

> On the other hand, for the users who want to use local NAT and IPsec
> transport mode together, we might have to add netfilter hook to input
> path. But I'm not sure how many such users are. If nobody want, hooks
> we need are only LOCAL_OUT and POST_ROUTING on output path per tunnel.

Yes, we could add new hooks and duplicate the relevant code from the
IP input path. But I think just sending the packets through the stack
again is cleaner.

>>Unfortunately hiding the plain-text packets on output when transport
>>mode SAs are used and the flag is not set adds a new inconsistency
>>with NAT. In my last patchsets NAT was handled by redoing the policy
>>lookup when a packet was NATed at LOCAL_OUT or POST_ROUTING and wasn't
>>already transformed. If the new lookup yielded a policy
>>ip_dst_output/__ip_dst_output was called again. The hooks were always
>>called in the normal order. With a per-SA flag however we don't know
>>if the packet should be hidden before the second lookup is done, so
>>with NAT a packet that would usually be hidden might be visible
>>on LOCAL_OUT and POST_ROUTING, or just LOCAL_OUT. This also affects
>>ip_queue.
> 
> Sorry, maybe I don't understand. per-SA flag means that packets go through
> netfilter hook before handling of its SA on output path ? Why it isn't
> 'after' ?

The idea was to usually hide transport mode packets on the output path
from netfilter hooks, unless a special flag in the xfrm_state is set.
On input the flag would make a packet decapsulated from a transport mode
SA through the stack again. But it has the same problem wrt. NAT I
described above as hiding unconditionally.
