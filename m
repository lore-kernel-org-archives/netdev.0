From: Jean-Louis Dupond <info@dupondje.be>
Subject: Re: tg3 driver not advertising 1000mbit
Date: Fri, 12 Jun 2009 23:51:37 +0200
Message-ID: <4A32CDE9.7020602@dupondje.be>
References: <7e14b58794647ea1b1b0a644e14a11f6@localhost> <1244831838.9225.71.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	mcarlson@broadcom.com, davidch@broadcom.com
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from apollo.dupie.be ([85.17.239.130]:54362 "EHLO apollo.dupie.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934338AbZFLVvg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Jun 2009 17:51:36 -0400
In-Reply-To: <1244831838.9225.71.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

Here is a mii-tool -vvv on a box that doesn't advertise gbit speeds! It 
just doesn't advertise gbit @ random, sometimes it does, sometimes not! 
Without any logic in it!

# mii-tool  -vvv
Using SIOCGMIIPHY=0x8947
eth0: link ok
    registers for MII PHY 1:
      1000 794d 0143 bed0 05e1 0000 0064 2001
      0000 0300 0000 0000 0000 0000 0000 3000
      0000 0101 0000 0000 0000 0000 0000 0000
      7477 0104 0000 ffff 2801 0000 8000 0000
    product info: vendor 00:50:ef, model 45 rev 0
    basic mode:   autonegotiation enabled
    basic status: link ok
    capabilities: 1000baseT-HD 1000baseT-FD 100baseTx-FD 100baseTx-HD
10baseT-FD 10baseT-HD
    advertising:  100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD flow-
control

# dmesg | grep tg3
[    3.331702] tg3.c:v3.92.1 (June 9, 2008)
[   18.238654] tg3: eth0: Link is up at 10 Mbps, half duplex.
[   18.238654] tg3: eth0: Flow control is off for TX and off for RX.


Sincerely,
Jean-Louis Dupond

Michael Chan schreef:
> On Fri, 2009-06-12 at 07:05 -0700, Jean-Louis Dupond wrote:
>> Hello,
>>
>> I'm experiencing a problem with my "Broadcom Corporation NetXtreme
>> BCM5722 Gigabit Ethernet PCI Express" network card in my Dell R300
>> servers. When booting the server, the network card sometimes doesn't
>> advertise gigabit speeds, and so it auto-negotiates @ 10mbit. The speed
>> can then be set to gigabit with mii-tool, but its not a good solution!
>> On the other hand, sometimes when it boots, it just works perfectly, and
>> advertises gigabit speeds & auto-negotiates on gigabit!
>>
>> I tried to debug the driver a bit, and found some strange behavior
>> :) Only 2 values were different in the writephy function when it booted
>> @ 10mbit & gigabit.
>>
>> I found something obvious in the tg3_readphy & tg3_writephy methods.
>>
>>> 807         while (loops != 0) {
>>> 808                 udelay(10);
>>> 809                 frame_val = tr32(MAC_MI_COM);
>>> 810                 if ((frame_val & MI_COM_BUSY) == 0) {
>>> 811                         udelay(5);
>>> 812                         frame_val = tr32(MAC_MI_COM);
>>> 813                         break;
>>> 814                 }
>>> 815                 loops -= 1;
>>> 816         }
> 
> This code was written like this to make sure we get the correct MDIO
> data.  The data is supposed to be valid when the MI_COM_BUSY bit is
> cleared.  But on some chips, the data may not be ready until some
> microseconds after the BUSY bit is cleared.
> 
> When you see the "wrong" speed being established, please provide the mii
> register dump using mii-tool -vvv eth0.  We'll then be able to see what
> we advertised and what the other side advertised.
> 
> Thanks.
> 
>> On line 809 frame_val is filled with a read (tr32) from the device.
>> On line 810 we check if its not 'MI_COM_BUSY'
>> If not then we have a delay of 5, and then we read it again ?!
>> I don't know why the value is read twice! I checked with some other
>> drivers (also broadcom) and there the read command was given some other
>> argument when reading the BUSY state, and then in the if, it was really
>> fetching the data. But in this case, we only have 2 times the same
>> argument!
>>
>> With the original code the server booted into 10mbit the half of the
>> boots! When I removed line 811 & 812, then it booted into 10mbit only
>> 1/20 times ! Which is way better ! But its still not fully fixed!
>>
>> ---------------------------------------------------------------------------
>>
>> Today I found the programmers documentation on the Broadcom website and it
>> mentions the following:
>>
>>> // Write value to MI communication register
>>> Mi_Communication_Register = Value32
>>> // Now read back MI Communication register until the start bit
>>> // has been cleared or we have timed out (>5000 reads)
>>> Loopcount = 5000
>>> While (LoopCount > 0)
>>> Begin
>>> Value32 = Mi_Communication_Register
>>> If (!(Value32 | 0x20000000)) then BREAK loop
>>> Else Loopcount--
>>> End
>> Here u can see its NOT needed to read the value twice.
>> Also there is no delay mentioned, so I removed it, and rebooted 20 times
>> without 1 time on 10mbit !
>>
>>
>> Feel free to give any other solutions / comments !
>>
>> Sincerely,
>> Jean-Louis Dupond
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
