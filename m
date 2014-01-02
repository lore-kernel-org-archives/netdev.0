From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: IrDA woes..
Date: Thu, 2 Jan 2014 14:47:44 -0800
Message-ID: <CA+55aFwBCATuEWKZTK7aueSyO4JAOBGvqq3FZnsqynmouGOQog@mail.gmail.com>
References: <20140102.034653.1968429090467668489.davem@davemloft.net>
	<CA+55aFz_qDYP_P0PLUNv0wotoy=5PcS+7Qtt=U6EzvL4h4E69A@mail.gmail.com>
	<CA+55aFyFAaHgoTe_ZVs3F0Giy4qDndKsE6GbB4DgcaK7QkXOkA@mail.gmail.com>
	<20140102.174136.1587468571877727139.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Samuel Ortiz <samuel@sortiz.org>,
	Network Development <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f53.google.com ([74.125.83.53]:48403 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752550AbaABWrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 17:47:45 -0500
Received: by mail-ee0-f53.google.com with SMTP id b57so6488659eek.40
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 14:47:44 -0800 (PST)
In-Reply-To: <20140102.174136.1587468571877727139.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 2, 2014 at 2:41 PM, David Miller <davem@davemloft.net> wrote:
>
> Yes, something like the following untested patch.

I did that initially too, but that doesn't work, because the code
inside the skb_queue_walk() loop ends up calling irlap_send_i_frame()
which calls irlap_queue_xmit(), which does dev_queue_xmit().

Which will do a bh_disable/bh_enable() (as part of spin_[un]lock_bh(), iirc).

So you can't use "spin_lock_irqsave()", because it doesn't nest around
a softirq-disable.

You could use spin_lock_bh(), but if it's true that it's all in a
softirq context, I think it should be safe to just do "spin_lock()".
Afaik, there is nothing that actually does anything in real hardirq
context in there. I *think* all the network _rcv() functions are
called from softirqs, right?

             Linus
