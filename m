From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][RFC] netfilter: Fix small leak in ipq_build_packet_message()
Date: Fri, 29 Jul 2011 16:39:47 +0200
Message-ID: <4E32C633.5000205@trash.net>
References: <alpine.LNX.2.00.1107171942400.32359@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	coreteam@netfilter.org, netfilter@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1107171942400.32359@swampdragon.chaosbits.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17.07.2011 19:46, Jesper Juhl wrote:
> ipq_build_packet_message() in net/ipv4/netfilter/ip_queue.c and
> net/ipv6/netfilter/ip6_queue.c contain a small potential mem leak as
> far as I can tell.
> 
> We allocate memory for 'skb' with alloc_skb() annd then call
>  nlh = NLMSG_PUT(skb, 0, 0, IPQM_PACKET, size - sizeof(*nlh));
> 
> NLMSG_PUT is a macro
>  NLMSG_PUT(skb, pid, seq, type, len) \
>   		NLMSG_NEW(skb, pid, seq, type, len, 0)
> 
> that expands to NLMSG_NEW, which is also a macro which expands to:
>  NLMSG_NEW(skb, pid, seq, type, len, flags) \
>   	({	if (unlikely(skb_tailroom(skb) < (int)NLMSG_SPACE(len))) \
>   			goto nlmsg_failure; \
>   		__nlmsg_put(skb, pid, seq, type, len, flags); })
> 
> If we take the true branch of the 'if' statement and 'goto
> nlmsg_failure', then we'll, at that point, return from
> ipq_build_packet_message() without having assigned 'skb' to anything
> and we'll leak the memory we allocated for it when it goes out of
> scope.
> 
> Fix this by placing a 'kfree(skb)' at 'nlmsg_failure'.
> 
> I admit that I do not know how likely this to actually happen or even
> if there's something that guarantees that it will never happen - I'm
> not that familiar with this code, but if that is so, I've not been
> able to spot it.
> 
> Please review and commit if you believe this is correct. Thanks.
> 

Looks correct, applied, thanks.
