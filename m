From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: Can I limit the number of active tx per TCP socket?
Date: Fri, 7 Mar 2014 10:17:54 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6D7226@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6D0F6D3B91@AcuExch.aculab.com>
 <5318ADB1.5050107@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Rick Jones' <rick.jones2@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:54648 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752290AbaCGKSb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 05:18:31 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 28177-08 for <netdev@vger.kernel.org>;
 Fri,  7 Mar 2014 10:18:29 +0000 (GMT)
In-Reply-To: <5318ADB1.5050107@hp.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones
> On 03/06/2014 04:28 AM, David Laight wrote:
> > Is it possible to stop a TCP connection having more than one
> > tx skb (in the ethernet tx ring) at any one time?
> > The idea is to allow time for short sends from the application
> > to accumulate so that the transmitted frames are longer.
> 
> That is precisely what Nagle is supposed to be doing - at least where
> the definition of "time" is the round-trip-time rather than "time it
> takes to get transmitted out the NIC."

No, enabling Nagle leads to unacceptable delays in sending packets.
Try sending one short message every 5ms (without any return data),
the 2nd message gets delayed until the remote ack timer, or Nagle
timer expire. Both these timers are far too long, and the Nagle
timeout isn't specifiable on a per socket basis.

> > Basically I have a TCP connection which carries a lot of separate
> > short 'user buffers'. These are not command-response so
> > TCP_NODELAY has to be set to avoid long delays.
> 
> When you are saturating the receiver and/or the 64K line, are you
> certain that not setting TCP_NODELAY means long delays?

Yes, because it delays data for at least 10s of milliseconds (100ms?)
(I can't remember the Nagle delay - I know it is visible if you
'page forward' when running 'vi' in a large xterm.)

We've had issues with 'slow start' being affected by 'delayed acks'.
IIRC 'slow start' will only send 4 frames without receiving an ack.
The 'delayed ack' code waits 50ms? before sending one out.
By that time we are discarding data received on the slow link!
I avoided that one by requesting an application level data ack
every 4 packets rather than every 8.

>  From a later message:
> 
> > The data is sent out on a 64k line so 1ms is only 8 byte times.
> 
> Are you still using a 1460 byte MSS on such a connection?

The 64k line isn't carrying TCP, the TCP connection is carrying
the data that will be sent over the 64k line.
(It is actually SS7 - telephony signalling data.)
The reason there are a lot of small packets on the TCP connection
is that the 'mtu' for those links it 273, and typical packets are
much shorter.

Also the traffic for multiple (max 64) 64k links is sent over the
same TCP connection, so the aggregate packet rate is considerable.
(Especially when I'm running performance tests!)

	David
