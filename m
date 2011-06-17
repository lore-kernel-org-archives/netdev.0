From: Scott Goldman <scottjg@vmware.com>
Subject: RE: [PATCH] vmxnet3: fix starving rx ring when alloc_skb fails
Date: Thu, 16 Jun 2011 21:40:15 -0700
Message-ID: <03E840D17E263A48A5766AD576E0423A012911782E@exch-mbx-111.vmware.com>
References: <1308261747-17702-1-git-send-email-scottjg@vmware.com>,<20110617.001610.2160676566738613200.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.115.85.69]:5797 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751979Ab1FQEkQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2011 00:40:16 -0400
In-Reply-To: <20110617.001610.2160676566738613200.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David. 

> This is why other drivers allocate the replacement skb _first_ before
> handing the current receive packet to the stack.
> 
> And if the replacement allocation fails, they elide passing the packet
> to the stack, and instead recycle it back onto the RX ring.
> 
> Please implement your RX policy in this manner, as we advise all Linux
> networking drivers to, and you simply won't have this problem.

I'm sorry if my patch description was unclear, but as I understand it, what you are describing is what this patch implements. The patched rx handler does something like:
1) poll the rx ring, peel off a pending skb (don't pass the packet up the stack yet)
2) if the ring needs to be repopulated, we do that
3) if the ring was repopulated successfully, then that's great, and we pass up the pending skb to the network stack.
4) if not and there are no skbs left on the ring, we reuse the pending skb and recycle it back on the ring (effectively dropping the packet we were about to pass up to the network stack)

Maybe the code structure is a bit unclear? Since we don't always repopulate the ring every iteration (only when we hit a low watermark), it's true that we don't strictly always allocate a new skb before passing up the old one, but since this is only a problem when there are no skbs on the ring, and we do elide passing up the pending skb in this case, is that not ok?

thanks,
-sjg