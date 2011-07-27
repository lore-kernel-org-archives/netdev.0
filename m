From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] vfs: avoid taking locks if inode not in lists
Date: Wed, 27 Jul 2011 16:44:15 -0400
Message-ID: <20110727204415.GA13308@infradead.org>
References: <1311294452.2576.18.camel@schen9-DESK>
 <20110723132411.GA22183@infradead.org>
 <1311633550.2576.33.camel@schen9-DESK>
 <20110725225154.GD22133@ZenIV.linux.org.uk>
 <1311636178.2576.34.camel@schen9-DESK>
 <1311660013.2996.6.camel@edumazet-laptop>
 <1311668466.2355.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20110726090357.GA13013@infradead.org>
 <1311672994.2355.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1311780065.2356.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	Tim Chen <tim.c.chen@linux.intel.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>,
	Andi Kleen <andi@firstfloor.org>,
	Matthew Wilcox <matthew@wil.cx>,
	Anton Blanchard <anton@samba.org>, npiggin@kernel.dk,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:38175
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751838Ab1G0Uoc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2011 16:44:32 -0400
Content-Disposition: inline
In-Reply-To: <1311780065.2356.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 27, 2011 at 05:21:05PM +0200, Eric Dumazet wrote:
> If I am not mistaken, we can add unlocked checks on the three hot spots.
> 
> After following patch, a close(socket(PF_INET, SOCK_DGRAM, 0)) pair on
> my dev machine takes ~3us instead of ~9us.
> 
> Maybe its better to split it in three patches, just let me know.

I think three patches would be a lot cleaner.

As for safety of the unlocked checks:

 - inode are either hashed when created or never, so that one looks
   fine.
 - same for the sb list.
 - the writeback list is a bit more dynamic as we move things around
   quite a bit.  But in additon to the inode_wb_list_del call from
   evict() it only ever gets remove in writeback_single_inode, which
   for a freeing inode can only be called from the callers of evict().

Btw, I wonder if you should micro-optimize things a bit further by
moving the unhashed checks from the deletion functions into the callers
and thus save a function call for each of them.

