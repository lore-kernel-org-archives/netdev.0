From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP regression with packets rates < 10k per sec
Date: Wed, 9 Sep 2009 12:47:13 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0909091234360.15538@V090114053VZO-1>
References: <alpine.DEB.1.10.0909081820030.7733@V090114053VZO-1> <4AA6E039.4000907@gmail.com> <alpine.DEB.1.10.0909091000200.28070@V090114053VZO-1> <4AA7C512.6040100@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:55253 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753751AbZIIQsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 12:48:18 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 923B382C36D
	for <netdev@vger.kernel.org>; Wed,  9 Sep 2009 12:49:17 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id P7qpIDtdEnOw for <netdev@vger.kernel.org>;
	Wed,  9 Sep 2009 12:49:12 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E8D5382C36F
	for <netdev@vger.kernel.org>; Wed,  9 Sep 2009 12:49:12 -0400 (EDT)
In-Reply-To: <4AA7C512.6040100@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 9 Sep 2009, Eric Dumazet wrote:

> Christoph Lameter a ?crit :
> > On Wed, 9 Sep 2009, Eric Dumazet wrote:
> >
> >> In order to reproduce this here, could you tell me if you use
> >>
> >> Producer linux-2.6.22 -> Receiver 2.6.22
> >> Producer linux-2.6.31 -> Receiver 2.6.31
> >
> > I use the above setup.
>
> Then frames are sent on wire but not received
>
> (they are received via  mc loop, internal stack magic)

We are talking about two machines running 2.6.22 or 2.6.31. There is no
magic mc loop between the two machines. -L was not used.

> # ./mcast -L -n1 -r 10000
> WARNING: Multiple active ethernet devices. Using local address 192.168.0.1
> Receiver: Listening to control channel 239.0.192.1
> Receiver: Subscribing to 1 MC addresses 239.0.192-254.2-254 offset 0 origin 192.168.0.1
> Sender: Sending 10000 msgs/ch/sec on 1 channels. Probe interval=0.001-1 sec.
>
> TotalMsg   Lost SeqErr TXDrop Msg/Sec  KB/Sec  Min/us  Avg/us  Max/us StdDv
> 100000      0      0      0   10000  3000.0    7.84    8.89   10.51  0.66

These are loopback latencies... Dont use -L

> # uname -a
> Linux erd 2.6.30.5 #2 SMP Mon Sep 7 17:15:43 CEST 2009 i686 i686 i386 GNU/Linux
>
>
>
> I tried an old kernel on same hardware :
>
> # ./mcast -L -n1 -r 10000
> WARNING: Multiple active ethernet devices. Using local address 55.225.18.6
> Receiver: Listening to control channel 239.0.192.1
> Receiver: Subscribing to 1 MC addresses 239.0.192-254.2-254 offset 0 origin 55.225.18.6
> Sender: Sending 10000 msgs/ch/sec on 1 channels. Probe interval=0.001-1 sec.
>
> TotalMsg   Lost SeqErr TXDrop Msg/Sec  KB/Sec  Min/us  Avg/us  Max/us StdDv
>    99999      0      0      0    9998     0.0    9.00    9.95   14.50  1.56
>
> Linux erd 2.6.9-55.ELsmp #1 SMP Fri Apr 20 17:03:35 EDT 2007 i686 i686 i386 GNU/Linux
>
> So my numbers seem much better than yours...

These are loopback numbers. Why is 2.6.9 so high? The regression show at
less than 10k.

Could you use real NICs? With multiple TX queues and all the other cool
stuff? And run at lower packet rates?

My loopback numbers also show the same trends.

2.6.22:

mcast -Ln1
TotalMsg   Lost SeqErr TXDrop Msg/Sec  KB/Sec  Min/us  Avg/us  Max/us StdDv
     101      0      0      0      10     3.0    5.47    5.74    7.00  0.43

mcast -Ln1 -r10000
TotalMsg   Lost SeqErr TXDrop Msg/Sec  KB/Sec  Min/us  Avg/us  Max/us StdDv
  100000      0      0      0   10000  3000.0    5.97    6.11    6.40 0.13


2.6.31-rc9

mcast -Ln1
TotalMsg   Lost SeqErr TXDrop Msg/Sec  KB/Sec  Min/us  Avg/us  Max/us StdDv
     100      0      0      0      10     3.0   13.26   13.45   13.56  0.09

mcast -Ln1 -r10000
TotalMsg   Lost SeqErr TXDrop Msg/Sec  KB/Sec  Min/us  Avg/us  Max/us StdDv
  100000      0      0      0   10000  3000.0    5.70    5.82    5.91  0.07


So 2.6.22 is better at 10 msgs per second. 2.6.31 is slightly better at
10k.
