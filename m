From: Rick Jones <rick.jones2@hp.com>
Subject: Re: CC2420 (802.15.4) Speed Issue
Date: Mon, 22 Oct 2007 09:59:32 -0700
Message-ID: <471CD6F4.1030509@hp.com>
References: <177fe7690710211747p23156475m9e880da04e1574c2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Michael Whyte <m.whyte@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:55593 "EHLO palrel11.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751907AbXJVRAv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 13:00:51 -0400
In-Reply-To: <177fe7690710211747p23156475m9e880da04e1574c2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Whyte wrote:
> Hi Guys,
> 
> I'm currently writing my first bit of Linux kernel code so be gentle.
> It's a driver for TI CC2420 802.15.4 radio and I'm observing strange
> behavior. I am currently testing just by transferring a ~300kb file
> over HTTP between two of these devices.

Into which revision of the kernel are you inserting your driver?

> The strange thing is, when ever you start the transfer it starts
> humming along at 5k/s which is not far off what I'd expect these
> devices to achieve, then at some random point along the transfer or
> sometimes not at all... it suddenly drops fairly deterministically to
> 150byte/s and finishes the transfer at that speed, maybe rising to
> 170bytes/s by the end of the transfer is I'm lucky.
> 
> I don't really know where to start looking to solve the problem, it
> seems everything is functioning as it should at least some of the time
> as in some cases it will complete the whole transfer at the 5k/s
> speed. Is it just tcp throttling very harshly (i.e. 50x) when it loses
> a packet?

See below re packet traces and stats.

> Is it the Xscale chip scaling down the CPU frequency
> mid-transfer, I've got no idea how to check this? 

Knowing nothing about Xscale I'd wonder if there wasn't a regsiter on it 
somewhere you could query for its current CPU frequency.  Otherwise, if the CPU 
is slowing down, presumably that should show-up as a change in power consumption 
for the whole device which  you could in theory measure with a power meter.

> It is some sort of
> resonance affect happening with the two radios CCA although I'm not
> seeing any CCA timeouts.
> 
> Can any one give any hints what to play with or where to look to try
> find the cause and get the transfers to run reliabily without the
> sudden bottoming out of speeds? (if you stop the transfer and initiate
> a new one immediately it will start at full speed again)

Might also check the netstat statistics for TCP - netstat -s -t.  You might find 
that at the point where the performance drops there was a non-trivial packet 
loss event taking the congestion window down.  Should show-up in a packet trace 
as well.

If you want to eliminate any possibility of http server issues (as close to 
epsilon as they probably are) you could use a netperf TCP_CRR test:

netperf -H <server> -t TCP_CRR -l <time> -- -r 256,300K

You could also add some -s and -S options to the end of that to constrain the 
TCP windows which might be an interesting experiment.

rick jones
