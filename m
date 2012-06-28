From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH v2] sctp: be more restrictive in transport selection on
 bundled sacks
Date: Thu, 28 Jun 2012 11:58:56 -0400
Message-ID: <4FEC7F40.8070707@gmail.com>
References: <1340742704-2192-1-git-send-email-nhorman@tuxdriver.com> <1340807003-23139-1-git-send-email-nhorman@tuxdriver.com> <4FEB2262.1030803@gmail.com> <20120627172802.GA9250@neilslaptop.think-freely.org> <4FEB6296.5050603@gmail.com> <20120628153308.GB29277@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:53795 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753824Ab2F1P67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 11:58:59 -0400
In-Reply-To: <20120628153308.GB29277@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/28/2012 11:33 AM, Neil Horman wrote:
> On Wed, Jun 27, 2012 at 03:44:22PM -0400, Vlad Yasevich wrote:
>> On 06/27/2012 01:28 PM, Neil Horman wrote:
>>> On Wed, Jun 27, 2012 at 11:10:26AM -0400, Vlad Yasevich wrote:
>>>>
>>>> I didn't think of this yesterday, but I think it would be much
>>>> better to use pkt->transport here since you are adding the chunk to
>>>> the packet and it will go out on the transport of the packet.  You
>>>> are also guaranteed that pkt->transport is set.
>>>>
>>> I don't think it really matters, as the chunk transport is used to lookup the
>>> packet that we append to, and if the chunk transport is unset, its somewhat
>>> questionable as to weather we should bundle, but if packet->transport is set,
>>> its probably worth it to avoid the extra conditional.
>>>
>>
>> Just looked at the code flow.  chunk->transport may not be set until
>> the end of sctp_packet_append_chunk.  For new data, transport may
>> not be set.  For retransmitted data, transport is set to last
>> transport data was sent on.  So, we could be looking at the wrong
>> transport.  What you are trying to decided is if the current
>> transport we will be used can take the SACK, but you may not be
>> looking at the current transport. Looking at packet->transport is
>> the correct thing to do.
>>
>> -vlad
>>
> So, I agree after what you said above, that this is the right thing to do.  That
> said, I just tested the change with the SCTP_RR test in netperf, and it wound up
> giving me horrid performance (Its reporting about 5 transactions per second).
> It appears that whats happening is that, because the test alternates which
> transports it sends out, and because it waits for a sack of teh prior packet
> before it sends out the next transaction, we're always missing the bundle
> opportunity, and always waiting for the 200ms timeout for the sack to occur.
> While I know this is a pessimal case, it really seems bad to me.  It seems that
> because I was using chunk->transport previously, I luckily got the transport
> wrong sometimes, and it managed to bundle more often.
>
> So I'm not sure what to do here.  I had really wanted to avoid adding a sysctl
> here, but given that this is likely a corner cases, it seems that might be the
> best approach.  Do you have any thoughts?
>
> Neil
>

that's strange.  did you modify the SCTP_RR to alternate transports? 
Seems like responses in the RR test need to go the address of the sender 
so that we don't see things like:
Request (t) --->
             <--- Response (t2)

Should be:
Request (t1) --->
              <--- Response (t1)


-vlad
