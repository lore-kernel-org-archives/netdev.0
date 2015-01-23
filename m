From: Michael Tuexen <tuexen@fh-muenster.de>
Subject: Re: Question on SCTP ABORT chunk is generated when the association_max_retrans is reached
Date: Fri, 23 Jan 2015 19:36:38 +0100
Message-ID: <628C9A19-FFC7-4D98-9FBB-D59F45BF6915@fh-muenster.de>
References: <CAFXGftKp3=OfjkCVBuR-zM3+uZ42Sk_9i2UjAHBNnbX=hQJwpA@mail.gmail.com> <CAFXGft+fwo=8LJEG7h6uOpGciSo5f_dXjSx3sn67RZZp7jsYHw@mail.gmail.com> <54C23581.9060809@redhat.com> <54C27137.5010405@gmail.com> <54C2807E.8080607@redhat.com> <54C2935F.2000105@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 8.1 \(1993\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Sun Paul <paulrbk@gmail.com>, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54C2935F.2000105@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> On 23 Jan 2015, at 19:30, Vlad Yasevich <vyasevich@gmail.com> wrote:
> 
> On 01/23/2015 12:10 PM, Daniel Borkmann wrote:
>> On 01/23/2015 05:05 PM, Vlad Yasevich wrote:
>>> On 01/23/2015 06:50 AM, Daniel Borkmann wrote:
>>>> On 01/23/2015 11:25 AM, Sun Paul wrote:
>>>> ...
>>>>> I would like to check the behave in LKSCTP.
>>>>> 
>>>>> we are running DIAMETER message over SCTP, and we have set the
>>>>> parameter "net.sctp.association_max_retrans = 4" in the LinuxOS.
>>>>> 
>>>>> We noticed that when remote peer have retry to send the same request
>>>>> for 4 times, the LKSCTP will initiate an ABORT chunk with reason
>>>>> "association exceeded its max_retrans count".
>>>>> 
>>>>> We would like to know whether this is the correct behavior? is there
>>>>> any other option that we can alter in order to avoid the ABORT chunk
>>>>> being sent?
>>>> 
>>>> I don't recall the RFC saying to send an ABORT, but let me double
>>>> check in the mean time.
>>> 
>>> The RFC is silent on the matter.  The abort got added in 3.8 so
>>> it's been there for a while.
>> 
>> I see, commit de4594a51c90 ("sctp: send abort chunk when max_retrans
>> exceeded") added the behaviour.
>> 
>>>> Hmm, untested, but could you try something like that?
>>>> 
>>>> diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
>>>> index fef2acd..5ce198d 100644
>>>> --- a/net/sctp/sm_sideeffect.c
>>>> +++ b/net/sctp/sm_sideeffect.c
>>>> @@ -584,7 +584,8 @@ static void sctp_cmd_assoc_failed(sctp_cmd_seq_t *commands,
>>>>          sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP,
>>>>                  SCTP_ULPEVENT(event));
>>>> 
>>>> -    if (asoc->overall_error_count >= asoc->max_retrans) {
>>>> +    if (asoc->overall_error_count >= asoc->max_retrans &&
>>>> +        error != SCTP_ERROR_NO_ERROR) {
>>>>          abort = sctp_make_violation_max_retrans(asoc, chunk);
>>>>          if (abort)
>>>>              sctp_add_cmd_sf(commands, SCTP_CMD_REPLY,
>>> 
>>> This would pretty much stop all ABORTs due to excessive rtx.  Might
>>> as well take the code out :).
>>> 
>>> I was a bit concerned about this ABORT when it went in.
>> 
>> So effectively, if I understand the argument from the commit, the
>> assumption is that the ABORT would never reach the peer anyway, but
>> is a way for tcpdump users to see on the wire that rtx limit has
>> been exceeded and since there's not mentioned anything in the RFC
>> about this, it doesn't break it. Hm.
>> 
> 
> Additionally I seem to recall BSD sending this type of ABORT for pretty
> much the same reason.
Yepp.

Best regards
Michael
> 
> -vlad
> 
>> Sun Paul, what exactly broke in your scenario? Can you be more explicit?
>> 
>> Thanks,
>> Daniel
> 
> 
