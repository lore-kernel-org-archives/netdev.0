From: Josef Bacik <jbacik@fb.com>
Subject: Re: [PATCH net][v2] bpf: fix range arithmetic for bpf map access
Date: Wed, 16 Nov 2016 15:25:01 -0500
Message-ID: <935e538a-1400-cad0-c933-d4a200e5e0ef@fb.com>
References: <1479156336-6211-1-git-send-email-jbacik@fb.com>
 <20161115031016.GA10323@ast-mbp.thefacebook.com>
 <CAG48ez1z8wJstz84-ekY5Ed8oNgpT73Xc18Or7RboOoBnTE03w@mail.gmail.com>
 <de657ab3-9d6c-a700-a593-53d5a4dcde75@fb.com>
 <CAG48ez2XnOQAc440ErNBATfL8uN1VOmV4M3BJKDW9s9PvWFOtg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Jann Horn <jannh@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:48701 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752605AbcKPUZa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 15:25:30 -0500
In-Reply-To: <CAG48ez2XnOQAc440ErNBATfL8uN1VOmV4M3BJKDW9s9PvWFOtg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/16/2016 01:41 PM, Jann Horn wrote:
> On Tue, Nov 15, 2016 at 3:20 PM, Josef Bacik <jbacik@fb.com> wrote:
>> On 11/15/2016 08:47 AM, Jann Horn wrote:
>>> In states_equal():
>>> if (rold->type == NOT_INIT ||
>>>    (rold->type == UNKNOWN_VALUE && rcur->type != NOT_INIT))
>>> <------------
>>> continue;
>>>
>>> I think this is broken in code like the following:
>>>
>>> int value;
>>> if (condition) {
>>>   value = 1; // visited first by verifier
>>> } else {
>>>   value = 1000000; // visited second by verifier
>>> }
>>> int dummy = 1; // states seem to converge here, but actually don't
>>> map[value] = 1234;
>>>
>>> `value` would be an UNKNOWN_VALUE for both paths, right? So
>>> states_equal() would decide that the states converge after the
>>> conditionally executed code?
>>>
>>
>> Value would be CONST_IMM for both paths, and wouldn't match so they wouldn't
>> converge.  I think I understood your question right, let me know if I'm
>> addressing the wrong part of it.
>
> Okay, true, but what if you load the values from a map and bounds-check them
> instead of hardcoding them? Then they will be of type UNKNOWN_VALUE, right?
> Like this:
>
> int value = map[0];
> if (condition) {
>   value &= 0x1; // visited first by verifier
> } else {
>   // nothing; visited second by verifier
> }
> int dummy = 1; // states seem to converge here, but actually don't
> map[value] = 1234;
>
> And then `rold->type == UNKNOWN_VALUE && rcur->type != NOT_INIT` will be
> true in the `dummy = 1` line, and the states converge. Am I missing something?
>

Ah ok yeah I see it now you are right.  This is slightly different from this 
particular problem so I'll send a second patch to address this, sound 
reasonable?  Thanks,

Josef
