From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Conntrack leak with raw sockets
Date: Fri, 25 Mar 2005 21:37:01 +0100
Message-ID: <4244766D.2020001@trash.net>
References: <20050325201127.GA3400@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
To: Phil Oester <kernel@linuxace.com>
In-Reply-To: <20050325201127.GA3400@linuxace.com>
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

Phil Oester wrote:
> In the event a raw socket is created for sending purposes only, the creator
> never bothers to check the socket's receive queue.  But we continue to
> add skbs to its queue until it fills up.
> 
> Unfortunately, if ip_conntrack is loaded on the box, each skb we add to the
> queue potentially holds a reference to a conntrack.  If the user attempts
> to unload ip_conntrack, we will spin around forever since the queued skbs
> are pinned.

Great work tracking this down. But I fear the problem will come back
haunt us with this patch. The are more places where a packet can be
queued indefinitely, for example stopped qdiscs. IMO the best fix
is to drop the conntrack reference once the packet leaves IP, so we
don't have to make any assumptions about what will happen to the
packet - this would be in ip_finish_output2(). Could you send a patch
that does this? While you're at it, you could also remove this part
from ip_conntrack_standalone:

#if !defined(CONFIG_IP_NF_NAT) && !defined(CONFIG_IP_NF_NAT_MODULE)
         /* Previously seen (loopback)?  Ignore.  Do this before
            fragment check. */
         if ((*pskb)->nfct)
                 return NF_ACCEPT;
#endif

Regards
Patrick
