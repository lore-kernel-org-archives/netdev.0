From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: splice() giving unexpected EOF in 3.7.3 and 3.8-rc4+
Date: Fri, 18 Jan 2013 22:13:16 -0800
Message-ID: <1358575996.3464.447.camel@edumazet-glaptop>
References: <20130119044957.GA25395@dcvr.yhbt.net>
	 <1358574847.3464.422.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, Willy Tarreau <w@1wt.eu>
To: Eric Wong <normalperson@yhbt.net>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358574847.3464.422.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-01-18 at 21:54 -0800, Eric Dumazet wrote:

> 
> Hmm, this might be already fixed in net-next tree, could you try it ?
> 

Yes, running your program on net-next seems OK.

David, we need the two following commits.

They actually fixed a bug : current code in Linus tree
can push to the pipe a 0-length frag, because of the :

flen = min_t(unsigned int, flen, PAGE_SIZE - poff);

It can happen if poff == PAGE_SIZE, when one skb frag has this
particular starting offset.


commit 9ca1b22d6d228177e6f929f6818a1cd3d5e30c4a
Author: Eric Dumazet <edumazet@google.com>
Date:   Sat Jan 5 21:31:18 2013 +0000

    net: splice: avoid high order page splitting
    
    splice() can handle pages of any order, but network code tries hard to
    split them in PAGE_SIZE units. Not quite successfully anyway, as
    __splice_segment() assumed poff < PAGE_SIZE. This is true for
    the skb->data part, not necessarily for the fragments.
    
    This patch removes this logic to give the pages as they are in the skb.
    
    Signed-off-by: Eric Dumazet <edumazet@google.com>
    Cc: Willy Tarreau <w@1wt.eu>
    Signed-off-by: David S. Miller <davem@davemloft.net>


commit 18aafc622abf492809723d9c5a3c5dcea287169e
Author: Eric Dumazet <edumazet@google.com>
Date:   Fri Jan 11 14:46:37 2013 +0000

    net: splice: fix __splice_segment()
    
    commit 9ca1b22d6d2 (net: splice: avoid high order page splitting)
    forgot that skb->head could need a copy into several page frags.
    
    This could be the case for loopback traffic mostly.
    
    Also remove now useless skb argument from linear_to_page()
    and __splice_segment() prototypes.
    
    Signed-off-by: Eric Dumazet <edumazet@google.com>
    Cc: Willy Tarreau <w@1wt.eu>
    Signed-off-by: David S. Miller <davem@davemloft.net>
