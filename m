From: Robin Humble <rjh@cita.utoronto.ca>
Subject: Re: [RFC] e1000 performance patch
Date: Thu, 27 Apr 2006 16:49:45 -0400
Message-ID: <20060427204945.GA25722@lemming.cita.utoronto.ca>
References: <20060426221353.GA22143@lemming.cita.utoronto.ca> <444FF389.2090002@hp.com> <20060427024326.GA6318@lemming.cita.utoronto.ca> <4450EC48.5060304@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from quail.cita.utoronto.ca ([128.100.76.6]:55773 "EHLO
	quail.cita.utoronto.ca") by vger.kernel.org with ESMTP
	id S1751649AbWD0Uu0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Apr 2006 16:50:26 -0400
To: Rick Jones <rick.jones2@hp.com>
Content-Disposition: inline
In-Reply-To: <4450EC48.5060304@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 27, 2006 at 09:07:36AM -0700, Rick Jones wrote:
>There should be three basic measures there - one is the single-instance 
>request-response test. The idea is to see minimum latency.  That test 
>likes to see the interrupt throttle rate made very high, or disabled 
>completely.
>
>The aggregate TCP_RR's and the TCP_STREAM tests are there to show what 
>effect that has on the ability to do aggregate request/response and a 
>bulk transfer.

I guess the whole point of my patch is to try to handle all these cases
efficiently without user intervention by making the driver self-tune
the InterruptThrottleRate depending on what traffic it's seeing.

I think it's doing the right things so far - at least it's a good
compromise - it probably won't ever be ideal in all workloads.

>>can netperf (or some other tool) mix up big and small message sizes
>>like 'the real world' perhaps does?
>>that might help me find a good frequency at which to try to adapt the
>>ITR... (eg. 1, 10, 100 or 1000 times a second)
>
>There is the "vst" (variable size test IIRC) in netperf4:
>
>http://www.netperf.org/svn/netperf4/branches/glib_migration
>
>The docs for netperf4 are presently pathetic.  Feel free to email me for 
>bootstrapping information.  Basically, you'll need pkg-config, libxml2 
>and glib-2.0 on the system.

thanks. I'll check it out.

actually, thinking about it more, the worst case for the patched driver
is a quiescent system (where ITR will be maximum) which then sees a
stream of large messages - say 500MB (~=5s at 1Gbit). so until the
watchdog kicks in (every 2s at the moment) and lowers the ITR then the
load on the cpu will be high.
The only solution for this is to run the ITR resetting watchdog as
often as possible. ie. times per second.

And then test it on real codes that do some sort of large message
bursty communication and see if they run faster or slower.

The patched driver will actually deal fairly well with a mixed size
workload as some of the workload will be large messages and that will
(on average) lower the ITR automatically.

cheers,
robin
