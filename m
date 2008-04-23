From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Socket buffer sizes with autotuning
Date: Wed, 23 Apr 2008 10:24:25 -0700
Message-ID: <480F70C9.7010004@hp.com>
References: <480E8523.4030007@hp.com>	<1e41a3230804221917m4af32ed9ice8225c943d3ffa2@mail.gmail.com>	<20080422.205945.229828014.davem@davemloft.net>	<480F64B2.7060608@hp.com> <1e41a3230804230958s4d7bb997pee2c7cbdd8448391@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:27382 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751789AbYDWRY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 13:24:27 -0400
In-Reply-To: <1e41a3230804230958s4d7bb997pee2c7cbdd8448391@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Heffner wrote:
> On Wed, Apr 23, 2008 at 9:32 AM, Rick Jones <rick.jones2@hp.com> wrote:
> 
>> I can see that for the sending side being willing to send into the
>>receiver's ever increasing window, but is autotuning supposed to keep
>>growing and growing the receive window the way it seems to be?
> 
> 
> Receive-side autotuning by design will attempt to grow the rcvbuf
> (adjusting for overhead) to twice the observed cwnd[1].  When the
> sender keeps growing its window to fill up your interface queue, the
> receiver will continue to grow its window to let the sender do what it
> wants.  It's not the receiver's job to do congestion control.

Then why is it starting small and growing the advertised window?

> One interesting observation is that when timestamps are turned off the
> receiver autotuning actually has the property that if the RTT is
> growing (in this case due to a queue filling), it will not grow the
> window since it's not able to update its RTT estimate.  This property
> was described as a feature of the Dynamic Right-Sizing algorithm
> (http://public.lanl.gov/radiant/software/drs.html), and obviously in
> some cases it is.  However, in general it has the same types of
> problems that delay-based congestion control has.  And, it's not the
> receiver's job to do congestion control. :-)

Then why is it starting small and growing the advertised window?-)

> One thing you will note if you run many flows is that the aggregate
> buffer space used should be much less than n*2MB, since each flow is
> competing for the same queue space.  This has good scaling properties.

I'll see about getting another system on which to test (the one I got 
2.6.25 onto yesterday is being pulled-back for other things, grrr...) 
and see what happens when I run multiple netperfs.


> [1] It's not exactly accurate that it tries to set rcvbuf to 2*cwnd.
> A subtle but important distinction is that it tries to set rcvbuf to
> twice the data read by the application in any RTT.

I guess that explains why it grew but didn't keep growing when the 
sender's SO_SNDBUF was fixed.

What concerns me is that we tell folks to rely on autotuning because it 
will set their socket buffers to the size they need, but it seems to be 
setting their socket buffers to very much more than they need.  Given 
that netperf couldn't have been receiving any more data in an RTT if it 
was always going at ~940 Mbit/s I'm still perplexed unless there is a 
positive feedback here - allow a greater window, this allows more data 
to be queued, which increases the RTT, which allows more data to be 
recevied in an "RTT" which allows a greater window...

rick jones

