From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: [PATCH] sky2: Use deferrable timer for watchdog
Date: Thu, 20 Dec 2007 20:11:57 +0100
Message-ID: <476ABE7D.60901@linux.intel.com>
References: <Pine.LNX.4.64.0712182008160.3616@mini.warudkars.net>	<20071220091603.0d69b045@deepthought>	<823114761-1198171803-cardhu_decombobulator_blackberry.rim.net-937108990-@bxe019.bisx.prod.on.blackberry> <20071220095121.7859c023@deepthought> <476ABDDF.8080607@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	parag.warudkar@gmail.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:4225 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754276AbXLTTNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 14:13:50 -0500
In-Reply-To: <476ABDDF.8080607@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>>> My interpretation of the api is:
>>>    * round_jiffies()  - timer wants to wakeup but isn't precise about when so schedule
>>>                         on next second when system will wake up anyway;
>>>                         e.g why meetings are usually scheduled on the hour
>>>
>>>    * deferrable       - timer doesn't have to really wakeup but wants to happen near
>>>                         a particular time. e.g. "I'll meet you at the pub around 8pm"

this is not correct.

deferrable means "if you're busy wake me up at this time. But if not, don't bother waking up for me, get to it
later".

The "later" can be a LONG time later, several seconds easily, if not more.
(timers are on a per cpu bases, and you may end up with a several-core system where the common timers are all on another cpu
than this one)



>> If this is the case then the whole usage of round_jiffies() is bogus. All users of round_jiffies()
>> should just be converted to deferrable??  I am a bit concerned that if deferrable gets used everywhere
>> then a strange situation would occur where all timers were waiting for some other timer to finally
>> happen, kind of a wierd timelock situation. Like the old chip/dale cartoon:
>>  "you first, no you first, after you mister chip, no after you mister dale,..."
> 
> 
> 
> that's a dangerous situation indeed and I'd really like to know what the limits
> are for deferring deferrable timers.... Arjan, do you know? Anyone?

there is NO limit to deferring a timer. Do NOT use a deferrable timer if you can't afford the timer to not happen
within.. 10 to 100 seconds! (or more)
They are really meant for things where you CAN afford for it to not happen when you're idle....


> 
> I don't see a danger just yet on normal systems - I get something like 10 wakeups
> per second from just the kernel (acpi, ahci, usb) on most my systems which
> guarantees that the watchdog runs often enough, but for embedded systems and
> critical timers in other drivers this may be an issue quickly

on my work desktop test box the average time between cpu wakeups is 1.4 seconds
(and that's single core). It would be higher if it wasn't for some hpet limit issues.


