From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: question: tg3 driver/nics and inconsistent RX ring count
Date: Tue, 26 Jul 2016 15:55:26 -0700
Message-ID: <CACKFLim9OToL6h0pR=-=dQaVwPgSRWzxZb+H4jYxfsDa08B26w@mail.gmail.com>
References: <01ffefd8-8191-b423-0ccf-feb2d769d8d2@ziu.info>
 <CAKgT0UekBsSbtv-jZ5qB29rAVBE_OnK=BEmavFu5DxuZX_7v-g@mail.gmail.com> <11f7cf93-7763-c0e1-85fb-49d47314d904@ziu.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	mcarlson@broadcom.com
To: Michal Soltys <soltys@ziu.info>,
	Siva Reddy Kallam <siva.kallam@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:36502 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755979AbcGZWz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 18:55:28 -0400
Received: by mail-io0-f169.google.com with SMTP id b62so48346518iod.3
        for <netdev@vger.kernel.org>; Tue, 26 Jul 2016 15:55:27 -0700 (PDT)
In-Reply-To: <11f7cf93-7763-c0e1-85fb-49d47314d904@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 26, 2016 at 1:32 PM, Michal Soltys <soltys@ziu.info> wrote:
> On 2016-07-26 22:06, Alexander Duyck wrote:
>> On Tue, Jul 26, 2016 at 12:52 PM, Michal Soltys <soltys@ziu.info> wrote:
>>> Hi,
>>>
>>> I have a few of BCM5720 and BCM5719 kinds sitting in Dell R320 and R520
>>> servers - and all of them have certain peculiarity: they claim to have
>>> up to 4 TX and RX rings (and this can be set/verified just fine through
>>> ethtool -l/-L, with driver defaulting to 4 rings), indirection table
>>> (ethtool -x) looks fine as well:
>>>
>>> RX flow hash indirection table for eth1b with 3 RX ring(s):
>>>     0:      0     1     2     3     0     1     2     3
>>>     8:      0     1     2     3     0     1     2     3
>>> ......
>>>
>>> But this "3 RX ring(s)" is actually a real limit if I try to adjust
>>> anything, for example all those commands would fail:
>>>
>>> ethtool -X eth1b equal 4
>>> ethtool -X eth1b weight 1 1 1 1
>>>
>>> But would work fine for 3 and less rings. This was quickly tested with
>>> different kernel/ethtool combinations, from old 3.16 to 4.6.y with same
>>> exact results. Nothing fancier (-N/-U) is supported either.
>>>
>>> Any hints/comments about the cause of this and/or possible workarounds ?
>>
>> Well a quick look at the driver code makes it seem the problem lies in
>> tg3_get_rxnfc.  I suspect the bug is related to the following lines:
>>
>>                 /* The first interrupt vector only
>>                  * handles link interrupts.
>>                  */
>>                 info->data -= 1;
>>
>> I'm not sure what the number of interrupt vectors has to do with the
>> number of rings.  Perhaps someone more familiar with the driver can
>> point out why you would subtract 1 from tp->rxq_cnt to get the number
>> of queues when it seems like it should be tp->rxq_cnt.
>>
>> Hope that helps.
>>
>> - Alex
>>
>
> Ah thanks, seems to be the case then. Quick git blame shows it's been
> since the very introduction of RSS indirection configurability (ca.
> 2011) in this driver, 90415477bf1356f72acc34063ff52441fc10a754.
>
> I've CCed the author, maybe he will be able to shed some light.

Matt is no longer working here.  The driver should support up to 5
MSIX vectors and 4 RSS rings.  It looks like the code to subtract 1 in
tg3_get_rxnfc() is not correct.  Siva will look further into this.
Thanks for reporting the issue.
