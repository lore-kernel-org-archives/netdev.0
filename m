From: "John Heffner" <johnwheffner@gmail.com>
Subject: Re: Socket buffer sizes with autotuning
Date: Wed, 23 Apr 2008 09:58:15 -0700
Message-ID: <1e41a3230804230958s4d7bb997pee2c7cbdd8448391@mail.gmail.com>
References: <480E8523.4030007@hp.com>
	 <1e41a3230804221917m4af32ed9ice8225c943d3ffa2@mail.gmail.com>
	 <20080422.205945.229828014.davem@davemloft.net>
	 <480F64B2.7060608@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Rick Jones" <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.188]:65044 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752066AbYDWQ60 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 12:58:26 -0400
Received: by rn-out-0910.google.com with SMTP id e11so1164453rng.17
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2008 09:58:25 -0700 (PDT)
In-Reply-To: <480F64B2.7060608@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 23, 2008 at 9:32 AM, Rick Jones <rick.jones2@hp.com> wrote:
>  I can see that for the sending side being willing to send into the
> receiver's ever increasing window, but is autotuning supposed to keep
> growing and growing the receive window the way it seems to be?

Receive-side autotuning by design will attempt to grow the rcvbuf
(adjusting for overhead) to twice the observed cwnd[1].  When the
sender keeps growing its window to fill up your interface queue, the
receiver will continue to grow its window to let the sender do what it
wants.  It's not the receiver's job to do congestion control.

One interesting observation is that when timestamps are turned off the
receiver autotuning actually has the property that if the RTT is
growing (in this case due to a queue filling), it will not grow the
window since it's not able to update its RTT estimate.  This property
was described as a feature of the Dynamic Right-Sizing algorithm
(http://public.lanl.gov/radiant/software/drs.html), and obviously in
some cases it is.  However, in general it has the same types of
problems that delay-based congestion control has.  And, it's not the
receiver's job to do congestion control. :-)

One thing you will note if you run many flows is that the aggregate
buffer space used should be much less than n*2MB, since each flow is
competing for the same queue space.  This has good scaling properties.

  -John


[1] It's not exactly accurate that it tries to set rcvbuf to 2*cwnd.
A subtle but important distinction is that it tries to set rcvbuf to
twice the data read by the application in any RTT.
