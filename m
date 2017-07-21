From: Lisong Xu <xu@unl.edu>
Subject: Re: A buggy behavior for Linux TCP Reno and HTCP
Date: Fri, 21 Jul 2017 15:27:09 -0500
Message-ID: <dc5db0ec-0746-d42e-5418-f621e1840bc0@unl.edu>
References: <CANdGJ5Qp1MoGfeSyAnEqYeSeEyoiH8e1j_Ut3F4PnLRBnqNNZg@mail.gmail.com>
 <CAK6E8=eP3jwTD5t7Cj3h_m4JTJ61p=roqsr02WiSHUANse1ynw@mail.gmail.com>
 <CANdGJ5SOUV1OoonC-3i=5MLUWvoHPBZgp19c3mJTTYbNr2yLeQ@mail.gmail.com>
 <CAK6E8=eWYybZZxkjjVXC_K7DfYayEg7gx0bPqKpwi6iuE+bh8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>, Wei Sun <unlcsewsun@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03lp0016.outbound.protection.outlook.com ([216.32.181.16]:62624
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752811AbdGUU1O (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Jul 2017 16:27:14 -0400
In-Reply-To: <CAK6E8=eWYybZZxkjjVXC_K7DfYayEg7gx0bPqKpwi6iuE+bh8Q@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Yuchung,

This test scenario is only one example to trigger this bug. In general, 
as long as cwnd <4, the undo function has this bug.

This would not be a problem for a normal network. But might be an issue, 
if the network is highly congested (e.g., many many TCP flows with small 
cwnd <4). In this case, the bug may possibly mistakenly double the 
sending rate of each flow, and make a highly congested network even more 
congested .... similar to congestion collapse. This is actually why we 
need the congestion control algorithms in the first place.

Thanks
Lisong

On 7/21/2017 12:59 PM, Yuchung Cheng wrote:
> On Thu, Jul 20, 2017 at 2:28 PM, Wei Sun <unlcsewsun@gmail.com> wrote:
>> Hi Yuchung,
>>
>> Sorry for the confusion.  The test case was adapted from an old DSACK
>> test case (i.e., forget to remove something).
>>
>> Attached is a new and simple one. Thanks
> Note that the test scenario is fairly rare IMO: the connection first
> experience timeouts, then its retransmission got acked, then the
> original packets get Acked (ack w/ val 1400 ecr 130). It can be really
> long reordering, or reordering plus packet loss.
>
> The Linux undo state machines may not handle this perfectly, but it's
> probably not worth extra state for such rare events.
>
>>
>>
>> On Wed, Jul 19, 2017 at 2:31 PM, Yuchung Cheng <ycheng@google.com> wrote:
>>> On Tue, Jul 18, 2017 at 2:36 PM, Wei Sun <unlcsewsun@gmail.com> wrote:
>>>> Hi there,
>>>>
>>>> We find a buggy behavior when using Linux TCP Reno and HTCP in low
>>>> bandwidth or highly congested network environments.
>>>>
>>>> In a simple word, their undo functions may mistakenly double the cwnd,
>>>> leading to a more aggressive behavior in a highly congested scenario.
>>>>
>>>>
>>>> The detailed reason:
>>>>
>>>> The current reno undo function assumes cwnd halving (and thus doubles
>>>> the cwnd), but it doesn't consider a corner case condition that
>>>> ssthresh is at least 2.
>>>>
>>>> e.g.,
>>>>                           cwnd              ssth
>>>> An initial state:     2                    5
>>>> A spurious loss:   1                    2
>>>> Undo:                   4                    5
>>>>
>>>> Here the cwnd after undo is two times as that before undo. Attached is
>>>> a simple script to reproduce it.
>>> the packetdrill script is a bit confusing: it disables SACK but then
>>> the client returns ACK w/ SACKs, also 3 dupacks happen after RTO so
>>> the sender isn't technically going through a fast recovery...
>>>
>>> could you provide a better test?
>>>
>>>> A similar reason for HTCP, so we recommend to store the cwnd on loss
>>>> in .ssthresh implementation and restore it again in .undo_cwnd for TCP
>>>> Reno and HTCP implementations.
>>>>
>>>> Thanks
