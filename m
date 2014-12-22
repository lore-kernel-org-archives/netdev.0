From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH for 3.19] rtlwifi: Fix error when accessing unmapped
 memory in skb
Date: Mon, 22 Dec 2014 17:33:05 -0600
Message-ID: <20141222233305.GA11280@zzz>
References: <1419269826-12552-1-git-send-email-Larry.Finger@lwfinger.net>
 <20141222194843.GA7575@zzz>
 <54989E12.6050808@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvalo@codeaurora.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:40355 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751162AbaLVXdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 18:33:08 -0500
Content-Disposition: inline
In-Reply-To: <54989E12.6050808@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 22, 2014 at 04:41:22PM -0600, Larry Finger wrote:
> Please look at the attached patch. I think it handles the skb allocations
> correctly. The critical point is that _rtl_pci_init_one_rxdesc() cannot be
> allowed to fail to allocate an skb while in the interrupt path. Now, I have
> already allocated the skb before the call and bypassed this routine if the
> allocation fails. After a couple of crashes, this one now works for the case
> when the allocation wouldn't fail anyway. I will likely pull the allocation
> out of _rtl_pci_init_one_rxdesc() in all cases for the final patch.

Well, it's looking better.  But what seems strange to me is that
_rtl_pci_init_one_rxdesc() will map the skb for DMA, even though in the error
path it was never unmapped from the previous use.  The 3.17 version will neither
unmap nor map the skb in the error path.

I also suspect that trying to share _rtl_pci_init_one_rxdesc() between the
driver initialization and the interrupt handler is just confusing matters.
Perhaps only the ->set_desc() calls should be shared?

In any case, I assume it would be a good idea to, for testing, inject some
random skb allocation failures and make sure the driver still works smoothly
except for some dropped packets.
