From: "John Heffner" <johnwheffner@gmail.com>
Subject: Re: setsockopt()
Date: Tue, 8 Jul 2008 12:10:26 -0700
Message-ID: <1e41a3230807081210m7b2816eeyb83ba0ab1937b50b@mail.gmail.com>
References: <48725DFE.6000504@citi.umich.edu> <20080707142408.43aa2a2e@extreme>
	 <48728B09.1050801@citi.umich.edu> <48729DAD.8010400@hp.com>
	 <1e41a3230807072033n2f5519e4m42003e191b44cefe@mail.gmail.com>
	 <4873AF0A.3020705@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Rick Jones" <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.246]:12593 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754755AbYGHTK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 15:10:27 -0400
Received: by an-out-0708.google.com with SMTP id d40so536725and.103
        for <netdev@vger.kernel.org>; Tue, 08 Jul 2008 12:10:26 -0700 (PDT)
In-Reply-To: <4873AF0A.3020705@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 8, 2008 at 11:16 AM, Rick Jones <rick.jones2@hp.com> wrote:
> John Heffner wrote:
>> Jerry's optimization is a sender-side change.  The fact that the
>> receiver announces enough window is almost certainly the right thing
>> for it to do, and (I hope) this will not change.
>
> It just seems to be so, well, trusting of the sender.


Really, it's not trusting the sender at all.  The way it works is that
a receiver sizes its buffer based strictly on *how much its
application has read in an RTT*.  It the application reads slowly, it
uses a small buffer.  If it reads quickly, it increases the size so
that the TCP buffer is big enough to not be the limiting factor (if
system limits allow).  That's about all there is to it.

The only effect the sender has is that it it sends slowly, it bounds
the rate at which the receiver can read, and consequently results in
an appropriately small receive buffer.

The issue you're talking about is when the RTT gets inflated by
filling a buffer somewhere in that path -- in your case specifically
in the sender's interface queue.  When the RTT gets inflated, the
receiver will continue to track it, and continue announcing a window
large enough that it doesn't limit the sender's window.  In this case,
it is not really paying a penalty, since it's keeping up and it
doesn't actually have to buffer any data.  It will happily let the
sender continue to fill its own buffers, and the sender will pay the
penalty.

The receiver *can* try to do something about this situation, basically
by seeing that the RTT is increasing, and not using the higher RTT
values in its calculation.  However, this is a very dangerous game,
and comes with all the issues of delay-based congestion control.
(Basically, you can't tell if your flow is the one causing the queuing
or if it's cross/reverse-path traffic.  Or if increased delay is
caused by a routing change.  Or wireless link layer games.)  If you're
going to try to solve this problem, the sender is the better place to
do it, because it has better information, and because it pays the
higher cost.

  -John
