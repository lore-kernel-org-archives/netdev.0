From: "John Heffner" <johnwheffner@gmail.com>
Subject: Re: Socket buffer sizes with autotuning
Date: Wed, 23 Apr 2008 10:41:45 -0700
Message-ID: <1e41a3230804231041x6fc7cba7pd73447201faf555d@mail.gmail.com>
References: <480E8523.4030007@hp.com>
	 <1e41a3230804221917m4af32ed9ice8225c943d3ffa2@mail.gmail.com>
	 <20080422.205945.229828014.davem@davemloft.net>
	 <480F64B2.7060608@hp.com>
	 <1e41a3230804230958s4d7bb997pee2c7cbdd8448391@mail.gmail.com>
	 <480F70C9.7010004@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Rick Jones" <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.183]:55512 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751204AbYDWRlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 13:41:45 -0400
Received: by wa-out-1112.google.com with SMTP id m16so4771461waf.23
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2008 10:41:45 -0700 (PDT)
In-Reply-To: <480F70C9.7010004@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 23, 2008 at 10:24 AM, Rick Jones <rick.jones2@hp.com> wrote:
> John Heffner wrote:
> > Receive-side autotuning by design will attempt to grow the rcvbuf
> > (adjusting for overhead) to twice the observed cwnd[1].  When the
> > sender keeps growing its window to fill up your interface queue, the
> > receiver will continue to grow its window to let the sender do what it
> > wants.  It's not the receiver's job to do congestion control.
> >
>
>  Then why is it starting small and growing the advertised window?

Because the receiver tracks the sender's behavior.  (Also because of
the algorithm for figuring out the buffer overhead ratio, but that's a
different story.)


>  What concerns me is that we tell folks to rely on autotuning because it
> will set their socket buffers to the size they need, but it seems to be
> setting their socket buffers to very much more than they need.  Given that
> netperf couldn't have been receiving any more data in an RTT if it was
> always going at ~940 Mbit/s I'm still perplexed unless there is a positive
> feedback here - allow a greater window, this allows more data to be queued,
> which increases the RTT, which allows more data to be recevied in an "RTT"
> which allows a greater window...

It's true that careful hand-tuning can do better than autotuning in
some cases, due to the sub-optimality of congestion control.  This is
one such case, where you have an overbuffered bottleneck.  Another
case is where you have an underbuffered bottleneck, especially with a
large BDP.  You can calculate exactly the window size you need to fill
the bottleneck and set your send or receive buffer to throttle you to
exactly that window, so that you will get 100% utilization.  If you
let autotuning work, it will keep increasing your buffer as congestion
control asks for more until you overflow the buffer and take a loss.
Then, congestion control will have to back off, likely resulting in
under-utilization.

In these cases, hand-tuning can do better because you have out-of-band
knowledge of the path.  Also, smarter congestion control algorithms
can do better than traditional AIMD, but it's a very hard problem to
do this well in general.  Autotuning's job is mainly just to grow the
buffer sizes to as much as congestion control needs to do its thing.

  -John
