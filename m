From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH 1/2] net: Remove ndo_xmit_flush netdev operation, use
 signalling instead.
Date: Tue, 1 Sep 2015 09:22:00 -0700
Message-ID: <55E5D0A8.1040802@gmail.com>
References: <20140825.163502.973913220915588977.davem@davemloft.net>
 <55E549CE.4010509@windriver.com>
 <20150901.000051.2053259950492309439.davem@davemloft.net>
 <55E54F5F.9040603@windriver.com> <55E56080.9020502@iogearbox.net>
 <55E56E0C.7060500@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, jhs@mojatatu.com,
	hannes@stressinduktion.org, edumazet@google.com,
	jeffrey.t.kirsher@intel.com, rusty@rustcorp.com.au,
	brouer@redhat.com
To: yzhu1 <Yanjun.Zhu@windriver.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35721 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752657AbbIAQWE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 12:22:04 -0400
Received: by pacfv12 with SMTP id fv12so485928pac.2
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 09:22:03 -0700 (PDT)
In-Reply-To: <55E56E0C.7060500@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/2015 02:21 AM, yzhu1 wrote:
> On 09/01/2015 04:23 PM, Daniel Borkmann wrote:
>> On 09/01/2015 09:10 AM, yzhu1 wrote:
>>> On 09/01/2015 03:00 PM, David Miller wrote:
>>>> From: yzhu1 <Yanjun.Zhu@windriver.com>
>>>> Date: Tue, 1 Sep 2015 14:46:38 +0800
>>>>
>>>>> After I applied this patch, the skb->xmit_more is not always zero.
>>>> There have been thousands upon thousands of commits since that
>>>> change.
>>>>
>>>> You should be testing the tree as it currently stands, to see
>>>> if xmit_more behaves correctly or not.
>>>>
>>>> If xmit_more were incorrectly set to 1 in the current tree, it
>>>> would stall the TX queue of the networking device and we would
>>>> be seeing lots of reports of this.
>>>>
>>> Thanks for your reply.
>>> Yes. After running for several days, the following messages will 
>>> appear.
>>
>> Your below trace says 3.14.29ltsi-WR7.0.0.0 ...
>>
>> As Dave said, please retest with something up to date, like 4.2 kernel,
>> or latest -net git tree.
>>
>> Besides, the *upstream* xmit_more changes first went into 3.18 ...
>> nearest git describe is at:
>>
>>   $ git describe 0b725a2ca61bedc33a2a63d0451d528b268cf975
>>   v3.17-rc1-251-g0b725a2
>>
>> So, that only tells me, that you are reporting a possible bug based on
>> some non-upstream kernel ... ? Thus, it's not even possible to verify
>> if the actual backport was correct ?
>
> Sorry. There is something wrong with backporting this patch.
>
> Thanks for your help.
>
> Zhu Yanjun

You may very well be missing the code that forced the tail to write if 
the Tx descriptor ring was full.  Double check your igb driver code and 
compare it to the upstream kernel.  You should double check and verify 
that you backported commit 6f19e12f62306 "igb: flush when in xmit_more 
mode and under descriptor pressure".

You need to have both checked before you skip writing the next 
descriptor to the ring.  The original code only checked one and this can 
result in Tx hangs if the ring fills without ever notifying the hardware.

- Alex
