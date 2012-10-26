From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] sctp: Clean up type-punning in sctp_cmd_t union
Date: Thu, 25 Oct 2012 23:48:16 -0400
Message-ID: <508A0800.10404@gmail.com>
References: <1351198075-20385-1-git-send-email-nhorman@tuxdriver.com> <5089B237.6010902@gmail.com> <20121025235843.GA13809@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:57483 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755886Ab2JZDsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 23:48:19 -0400
In-Reply-To: <20121025235843.GA13809@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/25/2012 07:58 PM, Neil Horman wrote:
> On Thu, Oct 25, 2012 at 05:42:15PM -0400, Vlad Yasevich wrote:
>> On 10/25/2012 04:47 PM, Neil Horman wrote:
>>> Lots of points in the sctp_cmd_interpreter function treat the sctp_cmd_t arg as
>>> a void pointer, even though they are written as various other types.  Theres no
>>> need for this as doing so just leads to possible type-punning issues that could
>>> cause crashes, and if we remain type-consistent we can actually just remove the
>>> void * member of the union entirely.
>>>
>>> Signed-off-by: Neil Horman <nhorman@tuxdriver.com
>>> CC: Vlad Yasevich <vyasevich@gmail.com>
>>> CC: "David S. Miller" <davem@davemloft.net>
>>> CC: linux-sctp@vger.kernel.org
>>> ---
>>>   include/net/sctp/command.h  |  7 ++++---
>>>   include/net/sctp/ulpqueue.h |  2 +-
>>>   net/sctp/sm_sideeffect.c    | 45 ++++++++++++++++++++++-----------------------
>>>   net/sctp/ulpqueue.c         |  3 +--
>>>   4 files changed, 28 insertions(+), 29 deletions(-)
>>>
>>> diff --git a/include/net/sctp/command.h b/include/net/sctp/command.h
>>> index 712b3be..7f1b0f3 100644
>>> --- a/include/net/sctp/command.h
>>> +++ b/include/net/sctp/command.h
>>> @@ -131,7 +131,6 @@ typedef union {
>>>   	sctp_state_t state;
>>>   	sctp_event_timeout_t to;
>>>   	unsigned long zero;
>>> -	void *ptr;
>>>   	struct sctp_chunk *chunk;
>>>   	struct sctp_association *asoc;
>>>   	struct sctp_transport *transport;
>>> @@ -154,9 +153,12 @@ typedef union {
>>>    * which takes an __s32 and returns a sctp_arg_t containing the
>>>    * __s32.  So, after foo = SCTP_I32(arg), foo.i32 == arg.
>>>    */
>>> +#define SCTP_NULL_BYTE 0xAA
>>>   static inline sctp_arg_t SCTP_NULL(void)
>>>   {
>>> -	sctp_arg_t retval; retval.ptr = NULL; return retval;
>>> +	sctp_arg_t retval;
>>> +	memset(&retval, SCTP_NULL_BYTE, sizeof(sctp_arg_t));
>>> +	return retval;
>>
>> What's this for?  Can't we just use retval.zero?
>>
>> -vlad
>>
> My intent was to highlight any users of sctp_arg_t when SCTP_NULL was passed.
> My thinking was that the 0xAA byte patern would be a good indicator.  Although,
> admittedly I didn't see the zero argument there.  Looking at it though, the zero
> member of the union is effectively unused.  Strictly speaking its used for
> initalization of sctp_arg_t, but its done somewhat poorly, since theres no
> guarantee that an unsigned long will be the largest member of that union.  Doing
> the memset guarantees the whole instance is set to a predefined value.
>
> I could go either way with this, would you rather we just have SCTP_NULL return
> retval = { .zero = 0}; or would you rather remove the zero initialization from
> SCTP_[NO]FORCE, and SCTP_ARG_CONSTRUCTOR and do the memset.  I think the memset
> reduces to a single 64 bit assignment as long as the union doesn't exceed that
> size anyway, and it ensures that you initalize the whole union's storage if it
> does in the future.  And if we remove the initialization step (I don't see that
> its needed in the three macros above anyway), then we can remove the zero member
> as well.
>

You need the initialization step, otherwise things might fail (they did 
on IA64 a while back).  That's why the zero member was added.  You can 
go with memset if you want, but I was primarily wondering why the 0xAA 
pattern was there.

-vlad
> Let me know what you want to do here, and I can respin this.
> Best
> Neil
>
