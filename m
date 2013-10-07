From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next] xen-netback: fix	xenvif_count_skb_slots()
Date: Mon, 7 Oct 2013 10:50:12 +0100
Message-ID: <525283D4.7010504@citrix.com>
References: <1380903983-27429-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Annie Li <annie.li@oracle.com>, Matt Wilson <msw@amazon.com>,
	Xi Xiong <xixiong@amazon.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:59199 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754093Ab3JGJuP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 05:50:15 -0400
In-Reply-To: <1380903983-27429-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/10/13 17:26, Paul Durrant wrote:
> Commit 4f0581d25827d5e864bcf07b05d73d0d12a20a5c introduced an error into
> xenvif_count_skb_slots() for skbs with a linear area spanning a page
> boundary. The alignment of skb->data needs to be taken into account, not
> just the head length. This patch fixes the issue by dry-running the code
> from xenvif_gop_skb() (and adjusting the comment above the function to note
> that).

If 4f0581d2582 is causing the skb->data to be fully packed into a
minimal number of slots then the simple DIV_ROUND_UP(skb_headlen(skb))
is correct.

I think this change will miscount in the number of slots,
over-estimating the count which I think will eventually cause netback to
think the ring has no space when it has some.

Is the problem here not the miscounting of slots but running out of
space in the grant table op array because we know use more copy ops?

I didn't think there was any real merit in the problematic commit (or at
least there was no evidence that it was better) so I would suggest just
reverting it instead of trying to fix it up.

If we do want to change how netback fills the ring then netback needs
some redesign (i.e., change it so it doesn't have to this counting in
advance) to make it much less fragile to changes in this area.

David
