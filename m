From: Michael Ma <make0818@gmail.com>
Subject: Re: Why do we need tasklet in IFB?
Date: Tue, 1 Nov 2016 11:49:48 -0700
Message-ID: <CAAmHdhw0O7z-T_vtZjMXvXU43DvdiHDXQWzgcp0qacmTJZ2KZQ@mail.gmail.com>
References: <20161028144803.4d3f5a2a@xeon-e3> <CAAmHdhwWGygKtcNR2Bazh-TMoAahEaAf6N5CPWjnvun0BfUdLA@mail.gmail.com>
 <CAAmHdhyC4DT+Ch2jAhAeCXKoUBH+_q-j96VcZFMO=oBhikN6cg@mail.gmail.com>
 <20161031.141047.1551501937019100403.davem@davemloft.net> <dc98e4d7-b076-66ca-a22f-5199b6d13ea9@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f43.google.com ([209.85.214.43]:37037 "EHLO
        mail-it0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751152AbcKAStt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 14:49:49 -0400
Received: by mail-it0-f43.google.com with SMTP id u205so67169258itc.0
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 11:49:49 -0700 (PDT)
In-Reply-To: <dc98e4d7-b076-66ca-a22f-5199b6d13ea9@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-11-01 4:38 GMT-07:00 Jamal Hadi Salim <jhs@mojatatu.com>:
> On 16-10-31 02:10 PM, David Miller wrote:
>>
>> From: Michael Ma <make0818@gmail.com>
>> Date: Mon, 31 Oct 2016 11:02:28 -0700
>>
>>> 2016-10-28 14:52 GMT-07:00 Michael Ma <make0818@gmail.com>:
>>>>
>>>> 2016-10-28 14:48 GMT-07:00 Stephen Hemminger
>>>> <stephen@networkplumber.org>:
>>>>>
>>>>> On Fri, 28 Oct 2016 14:45:07 -0700
>>>>> Michael Ma <make0818@gmail.com> wrote:
>>>>>
>>>>>> 2016-10-28 14:38 GMT-07:00 Stephen Hemminger
>>>>>> <stephen@networkplumber.org>:
>>>>>>>
>>>>>>> On Fri, 28 Oct 2016 14:36:27 -0700
>>>>>>> Michael Ma <make0818@gmail.com> wrote:
>>>>>>>
>>>>>>>> Hi -
>>>>>>>>
>>>>>>>> Currently IFB uses tasklet to process tx/rx on the interface that
>>>>>>>> forwarded the packet to IFB. My understanding on why we're doing
>>>>>>>> this
>>>>>>>> is that since dev_queue_xmit() can be invoked in interrupt, we want
>>>>>>>> to
>>>>>>>> defer the processing of original tx/rx in case ifb_xmit() is called
>>>>>>>> from interrupt.
>>>>>>>
>>>>>>>
>>>>>>> dev_queue_xmit is only called from interrupt if doing netconsole.
>>>>>>
>>>>>>
>>>
>>> In fact this doesn't seem to explain since if the original path is tx
>>> and the context is interrupt, IFB will call dev_queue_xmit as well so
>>> the context can be interrupt in that case.
>>>
>>> Then tasklet is still unnecessary.
>>
>>
>> Perhaps it's necessary to deal with potential recursion, that's my only
>> guess at this point.
>>
>> Jamal, do you remember what went through your mind back in 2005? :-)
>>
>
> Certainly recursions (which were a huge issue in the original
> implementations) as well as the need to have qdisc which shape traffic
> (which implies they will sit on the queue for some period of time and
> where accuracy of timing is important; therefore low latency of
> scheduling was  needed).
>
Thanks for the explanation - I can get the point of avoiding
recursion. However latency wise if we don't have queue/tasklet in IFB
and rely on the upstream/downstream part (either qdisc or tx/rx) to do
the queueing, latency wouldn't be a problem anyway, or did I miss
anything here?

> I didnt follow the context of "tasklets are unnecessary":
> Are tasklets bad or is the OP interested in replacing them with
> something s/he thinks is better? IIRC, at some point the idea was to
> infact use a softirq but it became obvious it was overkill.

I was thinking of directly forwarding the packet in the thread context
of IFB since it's really an intermediate forwarding component and
additional queueing/tasklet doesn't seem to be necessary (let's put
the consideration of too deep call stack/recursion problem aside).

The problem that I have found is that queue selection on NIC will
actually be inherited in IFB and that affects how packets are handled
in tasklet since the tasklet is associated with each queue. We don't
really have a strict one to one mapping of cpu core to queue in NIC,
whereas in IFB case the queue is strictly mapped to tasklet/cpu core
which can cause undesirable contention.

The question here was raised mostly because I wanted to adopt the
thread context of packet in IFB.

>
> cheers,
> jamal
