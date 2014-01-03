From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: IrDA woes..
Date: Thu, 2 Jan 2014 17:00:06 -0800
Message-ID: <CA+55aFyte5bC4703QVruVL3y_DV3Y6CbRPpXo=OkyRiJKtoMTA@mail.gmail.com>
References: <CA+55aFyFAaHgoTe_ZVs3F0Giy4qDndKsE6GbB4DgcaK7QkXOkA@mail.gmail.com>
	<20140102.174136.1587468571877727139.davem@davemloft.net>
	<CA+55aFwBCATuEWKZTK7aueSyO4JAOBGvqq3FZnsqynmouGOQog@mail.gmail.com>
	<20140102.190511.837169616985438729.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Samuel Ortiz <samuel@sortiz.org>,
	Network Development <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:46691 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751528AbaACBAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 20:00:07 -0500
Received: by mail-ee0-f44.google.com with SMTP id b57so6483001eek.17
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 17:00:06 -0800 (PST)
In-Reply-To: <20140102.190511.837169616985438729.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 2, 2014 at 4:05 PM, David Miller <davem@davemloft.net> wrote:
>
> I'm worried that mixing hardIRQ locking (via the direct calls to
> skb_dequeue() et al.) with explicit softIRQ locking will make lockdep
> complain.

You're probably right. I don't see how to do it right, though. lockdep
(or maybe it's DEBUG_ATOMIC_SLEEP or whatever) definitely complains
about the "enable softirq's with hardirqs disabled" part, and the way
the queueing is set up in irda, I don't see how else to do it.

Unless it would be ok to only re-send the oldest packet, not all of
them. And thus get rid of the loop entirely. But with the obvious lack
of testing irda is getting, that kind of change sounds like a really
bad idea.

The warning is, in case you care:

  WARNING: CPU: 2 PID: 0 at kernel/softirq.c:156 local_bh_enable+0x62/0x90()
  Call Trace:
   dev_queue_xmit
   irlap_queue_xmit
   irlap_send_i_frame
   irlap_resend_rejected_frames
   irlap_state_nrm_s
   irlap_do_event
   irlap_driver_rcv
   __netif_receive_skb_core

and without the _irqsave() at least that part is fine. But no, I
didn't try it with lockdep, and I think you're right that it would
break.

Oh well. Since I can't seem to get my test-case to work anyway, I
guess it doesn't much matter..

              Linus
