From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: Cause of Large Latency Difference Between 1179-byte and 1180-byte
 UDP Frames?
Date: Thu, 21 May 2015 07:55:24 -0700
Message-ID: <555DF1DC.8020803@gmail.com>
References: <CAE1W6VpPJwKtFGmeLuStt-A8JjGj2xU8RitonBHBs3dH9pXYRA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Todd Bezenek <bezenek@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:35552 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755170AbbEUOz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 10:55:26 -0400
Received: by iesa3 with SMTP id a3so10089271ies.2
        for <netdev@vger.kernel.org>; Thu, 21 May 2015 07:55:26 -0700 (PDT)
In-Reply-To: <CAE1W6VpPJwKtFGmeLuStt-A8JjGj2xU8RitonBHBs3dH9pXYRA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/20/2015 09:50 PM, Todd Bezenek wrote:
> I'm pushing 10,000 frames per second of UDP traffic through a Linux
> system with a bridge configured between two 1GbE ports.
>
> Iptables is installed and running, but the default rule is ACCEPT with
> no other rules.
>
> When I make the packets 1179 bytes in size (total size includes
> Ethernet header, etc.), I see the latency of most packets between 60
> and 200 usec.  When I change the size to 1180 bytes, I start seeing
> about 1% of the packets with latencies larger than 300 usec, and some
> as high as 500+ usec.
>
> Any ideas what buffer size, cache line count, TLB reach, etc. might be
> causing this dramatic change?
>
> Cut-and-paste to my terminal is not working, so limited info here:
>
> Kernel:  3.12.20 x86-64
> Processor:  Intel E3845 (Atom, 4 cores)
> Network interface driver:  Intel igb
>
> Thank you for any helpful pointers.
>
> -Todd

The igb driver defaults to an adaptive interrupt moderation scheme. It 
is possible that what you are seeing could be due to that, or it could 
possibly be that the time between packets is becoming large enough that 
your CPU is starting to go into deeper sleep states.

My first suggestion would be to try disabling sleeps states beyond C1.  
To do that you could boot your kernel with the parameter 
"processor.max_cstate=1" or "idle=poll".  Either one should prevent the 
CPU from going into a sleep state but it will consume more power.

You also might try modifying the interrupt moderation to a fixed value 
of 10 or more via "ethtool -C <dev> rx-usecs <x>" to see if the behavior 
goes away after that.  If the device is the cause it might point to a 
possible glitch in the interrupt moderation scheme or possibly lost 
interrupts for the device or driver.

- Alex
