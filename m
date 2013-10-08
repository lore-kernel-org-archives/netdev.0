From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: bug in passing file descriptors
Date: Tue, 8 Oct 2013 09:02:38 -0700
Message-ID: <CALCETrVoUrcuzEx_TURoGE8_MJtZLOz-UDz6m69Vo6MCWG0zjg@mail.gmail.com>
References: <525308C4.1030007@nec-labs.com> <20131007.154226.533738557474978526.davem@davemloft.net>
 <5253199B.3000109@nec-labs.com> <20131007.173237.1669132001431607341.davem@davemloft.net>
 <87li24zo6x.fsf@tassilo.jf.intel.com> <52541769.1000306@nec-labs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Michael Kerrisk-manpages <mtk.manpages@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Steve Rago <sar@nec-labs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:57216 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755949Ab3JHQDA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 12:03:00 -0400
Received: by mail-la0-f45.google.com with SMTP id eh20so7195753lab.32
        for <netdev@vger.kernel.org>; Tue, 08 Oct 2013 09:02:58 -0700 (PDT)
In-Reply-To: <52541769.1000306@nec-labs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 8, 2013 at 7:32 AM, Steve Rago <sar@nec-labs.com> wrote:
> On 10/07/2013 06:55 PM, Andi Kleen wrote:
>>
>> David Miller <davem@davemloft.net> writes:
>>
>>> From: Steve Rago <sar@nec-labs.com>
>>> Date: Mon, 7 Oct 2013 16:29:15 -0400
>>>
>>>> On 10/07/2013 03:42 PM, David Miller wrote:
>>>>>
>>>>> There is no compatability issue.
>>>>>
>>>>> 32-bit tasks will always see the 4-byte align/length.
>>>>> 64-bit tasks will always see the 8-byte align/length.
>>>>>
>>>>
>>>> Really?  So when I compile my application on a 32-bit Linux box and
>>>> then try to run it on a 64-bit Linux box, you're not going to overrun
>>>> my buffer when CMSG_SPACE led me to allocate an insufficient amount of
>>>> memory needed to account for padding on the 64-bit platform?
>>>
>>>
>>> We have a compatability layer that gives 32-bit applications the
>>> same behavior as if they had run on a 32-bit machine.
>>>
>>> Search around for the MSG_MSG_COMPAT flag and how that is used in
>>> net/socket.c
>>
>>
>> But it seems the compat layer doesn't handle this correctly,
>> otherwise Steve's original test case would work.
>>
>> Must be a bug somewhere in the compat layer.
>>
>> -Andi
>>
>
> I did some research last night and I think the problem stems from an
> underspecified standard.  CMSG_LEN and CMSG_SPACE seem to have originated
> with RFC 2292, which has since been obsoleted by RFC 3542.  The difference
> is that CMSG_SPACE accounts for padding at the end, which is needed when you
> stuff multiple cmsghdr objects in the same buffer.  CMSG_LEN is required to
> be used to initialize the cmsg_len member of the structure.  When you only
> have one cmsghdr object in your call to recvmsg, it is unclear whether you
> need to have a buffer as large as CMSG_SPACE or CMSG_LEN.  Historically,
> BSD-based platforms never had these macros and didn't return the ancillary
> data if the space provided by the application wasn't big enough.  Linux,
> *which has a bug*, won't copy more bytes than cmsg_len specifies when the
> application uses CMSG_LEN instead of CMSG_SPACE, but then lies to the
> application by overwriting msg_controllen.  Look in put_cmsg() in
> net/core/scm.c: "cmlen" is calculated using CM_LEN, and then msg_controllen
> is checked against it to make sure you don't overwrite the user's buffer.
> However, in recvmsg(), msg_controllen is overwritten by "msg_sys.msg_control
> - cmsg_ptr".  msg_control was incremented by CMSG_SPACE at the end of
> scm_detach_fds().
>
> The Linux kernel code seems to copy the right amount of data, even in the
> compat case, as far as I can tell.  The only bug I see is that
> msg_controllen returns from recvmsg() with the wrong value.

I don't see how the other behavior would be any less surprising.
Suppose you had a control message with CMSG_LEN=12 and CMSG_SPACE=16.
Then, with the semantics you want, one of them takes 12 bytes, two of
them take 28 bytes, three take 44 bytes, etc.

That seems considerably more surprising than having then take 16, 32,
and 48 bytes respectively.

--Andy
