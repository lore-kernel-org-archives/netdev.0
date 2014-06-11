From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 5/5] net: sctp: fix incorrect type in gfp initializer
Date: Wed, 11 Jun 2014 10:18:39 -0700
Message-ID: <CAADnVQLyNCUU0+onEHbygVE-M3WK59uB=NoKWi1V4Rh+6AZkVA@mail.gmail.com>
References: <1402497297-27100-1-git-send-email-dborkman@redhat.com>
	<1402497297-27100-6-git-send-email-dborkman@redhat.com>
	<063D6719AE5E284EB5DD2968C1650D6D1725AF78@AcuExch.aculab.com>
	<5398712C.3000801@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Laight <David.Laight@aculab.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	Tejun Heo <tj@kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f182.google.com ([209.85.216.182]:34938 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220AbaFKRSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 13:18:40 -0400
In-Reply-To: <5398712C.3000801@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 11, 2014 at 8:09 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> On 06/11/2014 04:55 PM, David Laight wrote:
>>
>> From: Daniel Borkmann
>>>
>>> This fixes the following sparse warning:
>>>
>>>    net/sctp/associola.c:1556:29: warning: incorrect type in initializer
>>> (different base types)
>>>    net/sctp/associola.c:1556:29:    expected bool [unsigned] [usertype]
>>> preload
>>>    net/sctp/associola.c:1556:29:    got restricted gfp_t
>>
>> ...
>>>
>>> --- a/net/sctp/associola.c
>>> +++ b/net/sctp/associola.c
>>> @@ -1591,7 +1591,7 @@ int sctp_assoc_lookup_laddr(struct sctp_association
>>> *asoc,
>>>   /* Set an association id for a given association */
>>>   int sctp_assoc_set_id(struct sctp_association *asoc, gfp_t gfp)
>>>   {
>>> -       bool preload = gfp & __GFP_WAIT;
>>> +       bool preload = !!(gfp & __GFP_WAIT);
>>>         int ret;
>>>
>>>         /* If the id is already assigned, keep it. */
>>> --
>>
>>
>> I was wondering if the compiler still manages to optimise this in a
>> manner that avoids actually calculating the boolean value...
>>
>> So I disassembled the compilation I just did of the old code (gcc 4.7.3).
>> The object code looks strange.

I'm not sure where you see this.
Just tried with gcc 4.7.2 on x64 and assembler code is exactly the
same before/after this change.

>> I think that idr_preload_end() must be an empty inline function.
>
>
> Cc'ing Tejun. ;-)
>
>
>> The compiler has duplicated the code between the two 'if (preload)'
>> clauses (to avoid the conditional test), and the failed to tail
>> merge everything in the latter stages.
>> I suspect that an empty '#define' would generate smaller code.
>>
>>         David
>>
>>
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
