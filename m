From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH RFC] sctp: Update HEARTBEAT timer immediately after user
 changed HB.interval
Date: Tue, 18 Feb 2014 11:14:55 -0500
Message-ID: <530386FF.6090903@gmail.com>
References: <1392703010-6128-1-git-send-email-xufeng.zhang@windriver.com> <5303731C.8020308@gmail.com> <063D6719AE5E284EB5DD2968C1650D6D0F6C2AEE@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
	Xufeng Zhang <xufeng.zhang@windriver.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6C2AEE@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/18/2014 10:39 AM, David Laight wrote:
>>> +
>>> +				/* Update the heartbeat timer immediately. */
>>> +				if (!mod_timer(&trans->hb_timer,
>>> +					    sctp_transport_timeout(trans)))
>>> +					sctp_transport_hold(trans);
>>
>> This is causes a rather inconsistent behavior in that it doesn't
>> account of the amount of time left on the hb timer.  Thus it doesn't
>> always do what commit log implies.  If the remaining time is shorter
>> then the new timeout value, it will take longer till the next HB
>> the application expects.
> 
> Being able to stop heartbeats being sent by repeatedly configuring
> the interval is certainly not a good idea!
> 
>> If the application has very strict timing requirement on the HBs, it
>> should trigger the HB manually.
>>
>> We could rework the code to allow the combination of
>> SPP_HB_DEMAND | SPP_HB_ENABLE to work as follows:
>>   1) update the timer to the new value
>>   2) Send an immediate HB
>>      a) Update the hb timeout.
>>
>> 2a should probably be done regardless since it can cause 2 HB to be
>> outstanding at the same time.
> 
> Sending a heartbeat 'on demand' might be problematic if one
> has also just been sent (from the timer).

Yes, you are right.  This will trigger an rto doubling since we'll
be in a state where we have an outstanding HB without an ack.

> 
> I'd have thought that you wouldn't want to send a heartbeat while
> still expecting a response from the previous one (this might require
> splitting the time interval in two).

This one is interesting.  Technically, a user can request an immediate
HB any time, and if the user requests it, we should honor the request.
Also, the user may not know that there is an outstanding HB.  I'll need
to think about this a bit.

Thanks for bringing this up.
-vlad
> 
> 	David
> 
> 
> 
