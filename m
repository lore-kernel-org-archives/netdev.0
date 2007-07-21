From: Al Viro <viro@ftp.linux.org.uk>
Subject: NET_DMA: where do we ever call dma_skb_copy_datagram_iovec() with NULL pinned_list?
Date: Sat, 21 Jul 2007 04:48:29 +0100
Message-ID: <20070721034829.GL21668@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: christopher.leech@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:37219 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761148AbXGUDsa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2007 23:48:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	AFAICS, all callers of dma_skb_copy_datagram_iovec()
are either
	* recursive for fragments, pass pinned_list unchanged or
	* called from tcp, with pinned_list coming from
tp->ucopy.pinned_list and only when tp->ucopy.dma_chan is non-NULL.

Now, all non-NULL assignments to ->dma_chan have the same form:
	if (!tp->ucopy.dma_chan && tp->ucopy.pinned_list)
		tp->ucopy.dma_chan = get_softnet_dma();
IOW, if ->ucopy.pinned_list stays NULL, ->ucopy.dma_chan will do the same.

Moreover, any place that resets ->ucopy.pinned_list will also reset
->ucopy.dma_chan.

IOW, we can't ever get non-NULL tp->ucopy.dma_chan while tp->ucopy.pinned_list
is NULL.  So how can we ever get to the dma_memcpy_to_kernel_iovec()?
