From: Shmulik Hen <shmulik@trego.co.il>
Subject: Re: System blocks (hangs) on ifconfig up
Date: Mon, 13 Dec 2010 11:14:40 +0200
Message-ID: <4D05E400.7080409@trego.co.il>
References: <4D04E38A.1040605@trego.co.il> <1292194983.3136.294.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Shmulik Hen <shmulik.hen@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	eric.dumazet@gmail.com, shemminger@vyatta.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f45.google.com ([209.85.214.45]:64682 "EHLO
	mail-bw0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753227Ab0LMJOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 04:14:46 -0500
Received: by bwz16 with SMTP id 16so6362403bwz.4
        for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 01:14:45 -0800 (PST)
In-Reply-To: <1292194983.3136.294.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/13/2010 01:03 AM, Ben Hutchings wrote:
> On Sun, 2010-12-12 at 17:00 +0200, Shmulik Hen wrote:
>> Hello,
>>
>> My system is Ubuntu 10.04, running kernel 2.6.32-26-generic.
>>
>> Whenever I try to bring up a specific ethernet interface for the second
>> time, my
>> system becomes unresponsive for 60 seconds - i.e. no mouse, no keyboard, no
>> screen refresh. etc.
>>
>> Looking at the driver's code, I could see that it's dev->open() method calls
>> wait_event_interruptible_timeout() with a timeout of 60 seconds - exactly
>> the delay I'm seeing.
> That seems like a stupid thing for it to do.
I agree...
>> I have narrowed the code to a bare minimum (see below - loosely based on
>> dummy.c), which only calls mdelay(10000) in it's dev->open() method, and
>> still, my system blocks for exactly 10 seconds when I run the following
>> sequence:
>>
>>   >  sudo ifconfig shmulik0 up
>>   >  sudo ifconfig shmulik0 down
>>   >  sudo ifconfig shmulik0 up
>>
>> At this point - the system is stuck for 10 seconds.
> Bringing an interface up or down is a synchronous operation and is
> serialised with most other network configuration operations.  So this is
> the expected behaviour.
>
> Ben.
But why does this happen only the second time I run ifconfig up?
How come the entire system is totally frozen?
I can't even switch to other applications running. If I run 'top' in another
console, it stops refreshing for the entire period.

I'll try to explain better;
The driver I'm referring to is part of an embedded system development kit.
It runs on the controlling side, which may be a PC or some Linux embedded
system. It exposes a virtual interface that allows to communicate via
ethernet connection to a remote board, and performs the firmware download
to that board.
Unfortunately, the firmware download stage is  done during dev->open() of
this virtual interface. The call to wait_event_interruptible_timeout()
is there to make sure the boot process of the remote board is complete via a
message. If all goes well the first time, there is no delay, but if the 
operation
fails for any reason the first time, and a second attempt is made (another
ifconfig up), we see the freezing.

Since this driver is (mostly) closed source, I had to try and reproduce 
the situation
in an all open-source driver - this is the sample code I attached to my 
original
message. The call to mdelay() there is meant to simulate the delay of 
the original
driver - it schedules.

Obviously, the correct way to fix this is to separate the firmware 
download part
from the dev->open() method, but this is not as simple as it may sound - I'm
currently working on this. In the mean time I'm looking for a simpler 
solution
(or answer) to our problem.

I'll appreciate any insight on this matter.

     Thanks in advance,
     Shmulik Hen.
