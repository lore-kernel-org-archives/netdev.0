From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NF+IPsec 4/6]: Make IPsec input processing symetrical to output
Date: Mon, 31 Oct 2005 00:15:52 +0100
Message-ID: <43655428.3040904@trash.net>
References: <4352EEC8.9000602@trash.net>
	<20051017.094919.56989341.yoshfuji@linux-ipv6.org>
	<4352FD49.4090201@trash.net>
	<20051017014629.GB32661@gondor.apana.org.au>
	<435EBB18.50701@trash.net>
	<20051025231049.GA13679@gondor.apana.org.au>
	<435EBC57.7090000@trash.net>
	<20051026003954.GA14068@gondor.apana.org.au>
	<4360E75A.10405@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <4360E75A.10405@trash.net>
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

Patrick McHardy wrote:
> Herbert Xu wrote:
> 
>>I presume that you will be changing the output path so that LOCAL_OUT
>>does not see the plain-text packet.  Otherwise it'll be asymmetric with
>>repsect to the inbound side which does not see plain-text packets for
>>transport mode SAs.
> 
> Yes, that was the idea. But since people seem to consider this an
> important case to handle I'm going to try the per-SA flag you
> proposed. I'll send new patches in the next days.

Unfortunately hiding the plain-text packets on output when transport
mode SAs are used and the flag is not set adds a new inconsistency
with NAT. In my last patchsets NAT was handled by redoing the policy
lookup when a packet was NATed at LOCAL_OUT or POST_ROUTING and wasn't
already transformed. If the new lookup yielded a policy
ip_dst_output/__ip_dst_output was called again. The hooks were always
called in the normal order. With a per-SA flag however we don't know
if the packet should be hidden before the second lookup is done, so
with NAT a packet that would usually be hidden might be visible
on LOCAL_OUT and POST_ROUTING, or just LOCAL_OUT. This also affects
ip_queue.

So far the by far cleanest solution from a netfilter point of view
was to ignore transport mode unless its the innermost transform on
output and to always send the decapsulated packets through the stack
again on input. Since Yoshifuji disagrees with this approach we seem
to be deadlocked ..
