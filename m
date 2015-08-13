From: Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH] mm: make page pfmemalloc check more robust
Date: Thu, 13 Aug 2015 11:13:04 +0200
Message-ID: <55CC5FA0.300@suse.cz>
References: <1439456364-4530-1-git-send-email-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mel Gorman <mgorman@suse.de>, Jiri Bohac <jbohac@suse.cz>,
 Andrew Morton <akpm@linux-foundation.org>,
 "David S. Miller" <davem@davemloft.net>,
 Eric Dumazet <eric.dumazet@gmail.com>, LKML <linux-kernel@vger.kernel.org>,
 netdev@vger.kernel.org, Michal Hocko <mhocko@suse.com>
To: mhocko@kernel.org, linux-mm@kvack.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1439456364-4530-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 08/13/2015 10:58 AM, mhocko@kernel.org wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> The patch c48a11c7ad26 ("netvm: propagate page->pfmemalloc to skb")
> added the checks for page->pfmemalloc to __skb_fill_page_desc():
>
>          if (page->pfmemalloc && !page->mapping)
>                  skb->pfmemalloc = true;
>
> It assumes page->mapping == NULL implies that page->pfmemalloc can be
> trusted.  However, __delete_from_page_cache() can set set page->mapping
> to NULL and leave page->index value alone. Due to being in union, a
> non-zero page->index will be interpreted as true page->pfmemalloc.
>
> So the assumption is invalid if the networking code can see such a
> page. And it seems it can. We have encountered this with a NFS over
> loopback setup when such a page is attached to a new skbuf. There is no
> copying going on in this case so the page confuses __skb_fill_page_desc
> which interprets the index as pfmemalloc flag and the network stack
> drops packets that have been allocated using the reserves unless they
> are to be queued on sockets handling the swapping which is the case here

                                                             ^ not ?

The full story (according to Jiri Bohac and my understanding, I don't 
know much about netdev) is that the __skb_fill_page_desc() is invoked 
here during *sending* and normally the skb->pfmemalloc would be ignored 
in the end. But because it is a localhost connection, the receiving code 
will think it was a memalloc allocation during receive, and then do the 
socket restriction.

Given that this apparently isn't the first case of this localhost issue, 
I wonder if network code should just clear skb->pfmemalloc during send 
(or maybe just send over localhost). That would be probably easier than 
distinguish the __skb_fill_page_desc() callers for send vs receive.

> and that leads to hangs when the nfs client waits for a response from
> the server which has been dropped and thus never arrive.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
