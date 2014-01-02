From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: IrDA woes..
Date: Thu, 2 Jan 2014 13:07:05 -0800
Message-ID: <CA+55aFyFAaHgoTe_ZVs3F0Giy4qDndKsE6GbB4DgcaK7QkXOkA@mail.gmail.com>
References: <CA+55aFz2CQ4B1JSpQ75TuQrrd9sUnhV+u=T2dWZY2NTTT5OmpQ@mail.gmail.com>
	<20140102.034653.1968429090467668489.davem@davemloft.net>
	<CA+55aFz_qDYP_P0PLUNv0wotoy=5PcS+7Qtt=U6EzvL4h4E69A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Samuel Ortiz <samuel@sortiz.org>,
	Network Development <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:42888 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740AbaABVHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 16:07:07 -0500
Received: by mail-ee0-f44.google.com with SMTP id b57so6427589eek.17
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 13:07:05 -0800 (PST)
In-Reply-To: <CA+55aFz_qDYP_P0PLUNv0wotoy=5PcS+7Qtt=U6EzvL4h4E69A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 2, 2014 at 11:11 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> I get the feeling that the code was written back in the bad old days
> when we had the big kernel lock, and timers and network bottom half
> handling were all mutually exclusive.

Hmm. It even has a comment to that effect, see
irlap_resend_rejected_frames(), which does that skb_queue_walk()
without taking the queue lock. It says:

 *    Resend frames which has not been acknowledged. Should be safe to
 *    traverse the list without locking it since this function will only be
 *    called from interrupt context (BH)

and I don't *think* that is true any more.

Now, because it is in bottom half contect, I think it won't be
re-entered on the same CPU, but another cpu might be busy doing
irda_rcv(). No?

So I'd be inclined to take the queue lock (self->wx_list.lock) around
that skb_queue_walk(). Or am I just dazed and confused?

                    Linus
