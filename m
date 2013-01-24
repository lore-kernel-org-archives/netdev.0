From: Xufeng Zhang <xufengzhang.main@gmail.com>
Subject: Re: [PATCH] sctp: set association state to established in dupcook_a handler
Date: Thu, 24 Jan 2013 09:36:32 +0800
Message-ID: <CA+=dFziSL35Y3+Y=3BWnX5ChfLHDrm5Kr-mU6KP=yNR7vOwwbg@mail.gmail.com>
References: <1358926720-25557-1-git-send-email-xufengzhang.main@gmail.com>
	<20130123134650.GA3512@hmsreliant.think-freely.org>
	<50FFF218.1010204@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Neil Horman <nhorman@tuxdriver.com>, sri@us.ibm.com,
	davem@davemloft.net, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f49.google.com ([209.85.214.49]:39285 "EHLO
	mail-bk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752727Ab3AXBge (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 20:36:34 -0500
In-Reply-To: <50FFF218.1010204@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/23/13, Vlad Yasevich <vyasevich@gmail.com> wrote:
> On 01/23/2013 08:46 AM, Neil Horman wrote:
>> On Wed, Jan 23, 2013 at 03:38:40PM +0800, xufengzhang.main@gmail.com
>> wrote:
>>> From: Xufeng Zhang <xufeng.zhang@windriver.com>
>>>
>>> While sctp handling a duplicate COOKIE-ECHO and the action is
>>> 'Association restart', sctp_sf_do_dupcook_a() will processing
>>> the unexpected COOKIE-ECHO for peer restart, but it does not set
>>> the association state to SCTP_STATE_ESTABLISHED, so the association
>>> could stuck in SCTP_STATE_SHUTDOWN_PENDING state forever.
>>> This violates the sctp specification:
>>>    RFC 4960 5.2.4. Handle a COOKIE ECHO when a TCB Exists
>>>    Action
>>>    A) In this case, the peer may have restarted. .....
>>>       After this, the endpoint shall enter the ESTABLISHED state.
>>>
>>> Fix this problem by adding a SCTP_CMD_NEW_STATE cmd to the command
>>> list so as to set the restart association to SCTP_STATE_ESTABLISHED
>>> state properly.
>>>
>>> Signed-off-by: Xufeng Zhang <xufeng.zhang@windriver.com>
>>> ---
>>>   net/sctp/sm_statefuns.c |    2 ++
>>>   1 files changed, 2 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
>>> index 618ec7e..528f1c8 100644
>>> --- a/net/sctp/sm_statefuns.c
>>> +++ b/net/sctp/sm_statefuns.c
>>> @@ -1779,6 +1779,8 @@ static sctp_disposition_t
>>> sctp_sf_do_dupcook_a(struct net *net,
>>>
>>>   	/* Update the content of current association. */
>>>   	sctp_add_cmd_sf(commands, SCTP_CMD_UPDATE_ASSOC,
>>> SCTP_ASOC(new_asoc));
>>> +	sctp_add_cmd_sf(commands, SCTP_CMD_NEW_STATE,
>>> +			SCTP_STATE(SCTP_STATE_ESTABLISHED));
>>>   	sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(repl));
>>>   	sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP, SCTP_ULPEVENT(ev));
>>>   	return SCTP_DISPOSITION_CONSUME;
>>> --
>>> 1.7.0.2
>>>
>>>
>>
>> Looks reasonable to me, thanks
>>
>> nit: The RFC indicate the association should enter the ESTABLISHED state
>> after
>> preforming all other actions, so it seems that the state change should
>> occur
>> after the ULP event is sent
>>
>
> I have a slight concern here that if we change state last, then any data
> that may have been bundled with COOKIE-ACK as part of CMD_REPLY will get
> the SACK_IMMEDIATE flag set since we are still in the SHUTDOWN_PENDING
> state.
>
> I would be more correct (and would match sctp_sf_do_5_1D_ce) to
> do it in this order:
>    UPDATE_ASSOC  - resets all the congestion/association variables
>    EVENT_UP  - send RESTART to USER
>    NEW_STATE  - set ESTABLISHED state (as per spec)
>    REPLY	- Send cookie-ack along with any pending data.

Yep, I agree with you, I'll send V2 patch based on your suggestion.
Thanks for your review!


Thanks,
Xufeng

>
> -vlad
>> Neil
>>
>
>
