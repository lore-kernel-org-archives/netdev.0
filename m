From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink, mmap: fix edge-case leakages in nf queue
 zero-copy
Date: Wed, 09 Sep 2015 21:43:49 -0700 (PDT)
Message-ID: <20150909.214349.1837841017864345220.davem@davemloft.net>
References: <c973763474a5ecfd97f8733a111545f919949408.1441840987.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chamaken@gmail.com, tgraf@suug.ch, fw@strlen.de, kaber@trash.net,
	netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37256 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751446AbbIJEnu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 00:43:50 -0400
In-Reply-To: <c973763474a5ecfd97f8733a111545f919949408.1441840987.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 10 Sep 2015 02:10:57 +0200

> When netlink mmap on receive side is the consumer of nf queue data,
> it can happen that in some edge cases, we write skb shared info into
> the user space mmap buffer:
> 
> Assume a possible rx ring frame size of only 4096, and the network skb,
> which is being zero-copied into the netlink skb, contains page frags
> with an overall skb->len larger than the linear part of the netlink
> skb.
> 
> skb_zerocopy(), which is generic and thus not aware of the fact that
> shared info cannot be accessed for such skbs then tries to write and
> fill frags, thus leaking kernel data/pointers and in some corner cases
> possibly writing out of bounds of the mmap area (when filling the
> last slot in the ring buffer this way).
> 
> I.e. the ring buffer slot is then of status NL_MMAP_STATUS_VALID, has
> an advertised length larger than 4096, where the linear part is visible
> at the slot beginning, and the leaked sizeof(struct skb_shared_info)
> has been written to the beginning of the next slot (also corrupting
> the struct nl_mmap_hdr slot header incl. status etc), since skb->end
> points to skb->data + ring->frame_size - NL_MMAP_HDRLEN.
> 
> The fix adds and lets __netlink_alloc_skb() take the actual needed
> linear room for the network skb + meta data into account. It's completely
> irrelevant for non-mmaped netlink sockets, but in case mmap sockets
> are used, it can be decided whether the available skb_tailroom() is
> really large enough for the buffer, or whether it needs to internally
> fallback to a normal alloc_skb().
> 
> From nf queue side, the information whether the destination port is
> an mmap RX ring is not really available without extra port-to-socket
> lookup, thus it can only be determined in lower layers i.e. when
> __netlink_alloc_skb() is called that checks internally for this. I
> chose to add the extra ldiff parameter as mmap will then still work:
> We have data_len and hlen in nfqnl_build_packet_message(), data_len
> is the full length (capped at queue->copy_range) for skb_zerocopy()
> and hlen some possible part of data_len that needs to be copied; the
> rem_len variable indicates the needed remaining linear mmap space.
> 
> The only other workaround in nf queue internally would be after
> allocation time by f.e. cap'ing the data_len to the skb_tailroom()
> iff we deal with an mmap skb, but that would 1) expose the fact that
> we use a mmap skb to upper layers, and 2) trim the skb where we
> otherwise could just have moved the full skb into the normal receive
> queue.
> 
> After the patch, in my test case the ring slot doesn't fit and therefore
> shows NL_MMAP_STATUS_COPY, where a full skb carries all the data and
> thus needs to be picked up via recv().
> 
> Fixes: 3ab1f683bf8b ("nfnetlink: add support for memory mapped netlink")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied.
