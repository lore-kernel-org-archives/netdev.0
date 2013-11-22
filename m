From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] net: sctp: set chunk->tsn_gap_acked at the end of cycle
Date: Fri, 22 Nov 2013 17:48:50 -0500
Message-ID: <528FDF52.4030500@gmail.com>
References: <1385106589-402-1-git-send-email-changxiangzhong@gmail.com> <528F69B7.7020902@gmail.com> <528FAF50.10100@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Chang <changxiangzhong@gmail.com>, nhorman@tuxdriver.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f54.google.com ([209.85.213.54]:63320 "EHLO
	mail-yh0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755876Ab3KVWsy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Nov 2013 17:48:54 -0500
In-Reply-To: <528FAF50.10100@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/22/2013 02:24 PM, Chang wrote:
> 
> On 11/22/2013 03:27 PM, Vlad Yasevich wrote:
>> On 11/22/2013 02:49 AM, Chang Xiangzhong wrote:
>>> tsn_gap_acked is an important state flag in chunk, which indicates if
>>> the
>>> chunk has been acked in gap reports before.
>> Actually, this bit indicates simply that the chunk has been acked.  It
>> doesn't state whether it's been acked in a gap report or via
>> cumulative tsn.
> Thanks for pointing this out. Sorry for not having made that clear.
>>
>>> SFR-CACC algorithm depends on this
>>> variable. So set this at the end of each iteration, otherwise the
>>> SFR-CACC
>>> algorithm would never be toggled.
>>>
>>> Signed-off-by: Chang Xiangzhong <changxiangzhong@gmail.com>
>>> ---
>>>   net/sctp/outqueue.c | 3 ++-
>>>   1 file changed, 2 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
>>> index 1b494fa..bff828c 100644
>>> --- a/net/sctp/outqueue.c
>>> +++ b/net/sctp/outqueue.c
>>> @@ -1396,7 +1396,6 @@ static void sctp_check_transmitted(struct
>>> sctp_outq *q,
>>>                * while DATA was outstanding).
>>>                */
>>>               if (!tchunk->tsn_gap_acked) {
>>> -                tchunk->tsn_gap_acked = 1;
>>>                   if (TSN_lt(*highest_new_tsn_in_sack, tsn))
>>>                       *highest_new_tsn_in_sack = tsn;
>>>                   bytes_acked += sctp_data_size(tchunk);
>>> @@ -1460,6 +1459,8 @@ static void sctp_check_transmitted(struct
>>> sctp_outq *q,
>>>                    */
>>>                   list_add_tail(lchunk, &tlist);
>>>               }
>>> +
>>> +            tchunk->tsn_gap_acked = 1;
>> The current code will set the state if it hasn't been set yet.  Why is
>> this needed?
> Because in line 1420 ~ 1440 The SFR-CACC algorithms use tsn_gap_acked.
> That "if block" would never be triggered because the varaiable's been
> set. That's why I move the "state changing sentence" to the end of the
> iteration.
>> Now there is an issue with tracking highest_new_tsn_in_sack.  The spec
>> is a little vague on this, but the highest_new_tsn_in_sack only supposed
>> to track tsns that have not been resent.  If a tsn has been reneged, and
>> then sent again, it is not considered 'new' thus should not count
>> toward highest_new_tsn_in_sack.  We currently do not track this right.
> I'll try to figure this out.

So the solution that's been proposed before is to move the CACC block up
and merge it with the !tsn_gap_acked block.  This requires additional
change though to only mark highest_new_tsn if the chunk has not been
retransmitted (which you've added in a prior patch).

-vlad

>> -vlad
>>
>> -vlad
>>
>>>           } else {
>>>               if (tchunk->tsn_gap_acked) {
>>>                   pr_debug("%s: receiver reneged on data TSN:0x%x\n",
>>>
> 
