From: Pavel Belous <pavel.belous@aquantia.com>
Subject: Re: [PATCH] aquantia: Fix "ethtool -S" crash when adapter down.
Date: Thu, 4 May 2017 21:37:04 +0300
Message-ID: <b039f869-2b3a-416f-2f52-f3efdf7b385a@aquantia.com>
References: <90666578f043b366313ddd90ffad86de42d890f2.1493914743.git.pavel.belous@aquantia.com>
 <0babf800-080c-96e0-4dbb-8d3fca3fb784@gmx.de>
 <20170504.125113.569969253752966231.davem@davemloft.net>
 <d20deac6-7010-c0e8-e4d8-7faa591e7306@aquantia.com>
 <0efef5aa-c73d-ff16-a2ec-e63ad298ffa2@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Arcari <darcari@redhat.com>,
        David Miller <davem@davemloft.net>, LinoSanfilippo@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0056.outbound.protection.outlook.com ([104.47.38.56]:23008
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752210AbdEDShT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 14:37:19 -0400
In-Reply-To: <0efef5aa-c73d-ff16-a2ec-e63ad298ffa2@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04.05.2017 21:27, David Arcari wrote:
> On 05/04/2017 01:09 PM, Pavel Belous wrote:
>>
>>
>> On 04.05.2017 19:51, David Miller wrote:
>>> From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
>>> Date: Thu, 4 May 2017 18:48:12 +0200
>>>
>>>> Hi Pavel,
>>>>
>>>> On 04.05.2017 18:33, Pavel Belous wrote:
>>>>> From: Pavel Belous <pavel.belous@aquantia.com>
>>>>>
>>>>> This patch fixes the crash that happens when driver tries to collect statistics
>>>>> from already released "aq_vec" object.
>>>>>
>>>>> Fixes: 97bde5c4f909 ("net: ethernet: aquantia: Support for NIC-specific code")
>>>>> Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
>>>>> ---
>>>>>  drivers/net/ethernet/aquantia/atlantic/aq_nic.c | 3 ++-
>>>>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>>>>
>>>>> diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
>>>>> b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
>>>>> index cdb0299..3a32573 100644
>>>>> --- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
>>>>> +++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
>>>>> @@ -755,7 +755,7 @@ void aq_nic_get_stats(struct aq_nic_s *self, u64 *data)
>>>>>      count = 0U;
>>>>>
>>>>>      for (i = 0U, aq_vec = self->aq_vec[0];
>>>>> -        self->aq_vecs > i; ++i, aq_vec = self->aq_vec[i]) {
>>>>> +        aq_vec && self->aq_vecs > i; ++i, aq_vec = self->aq_vec[i]) {
>>>>>          data += count;
>>>>>          aq_vec_get_sw_stats(aq_vec, data, &count);
>>>>>      }
>>>>> @@ -961,6 +961,7 @@ void aq_nic_free_hot_resources(struct aq_nic_s *self)
>>>>>      for (i = AQ_DIMOF(self->aq_vec); i--;) {
>>>>>          if (self->aq_vec[i])
>>>>>              aq_vec_free(self->aq_vec[i]);
>>>>> +            self->aq_vec[i] = NULL;
>>>>>      }
>>>>>
>>>>>  err_exit:;
>>>>>
>>>>
>>>> if the driver does not support statistics when the interface is down, would
>>>> not it be clearer
>>>> to check if netif_running() in get_stats() instead?
>>>
>>> Yes, much cleaner.
>>>
>>> Much better would be to have a cached software copy so that statistics
>>> can be reported regardless of whether the device is down or not.
>>>
>>
>> Thank you.
>> I will think about how to do it better.
>
> It appears that the adapter is still reporting the cumulative hardware stats
> even while its down.  The user is just losing the per queue stats.
>
> Although the loss of the per queue stats is not ideal, this patch still fixes a
> crash.
>
> It might be worthwhile to refactor this patch as a short term solution and then
> subsequently produce a version that contains cached statistics.  Assuming that
> is amenable to everyone of course.
>
> -DA
>

Yes, even adapter is in the down state user can still see statistics 
from the HW.
For example (adapter is down):

$ ethtool -S enp2s0
NIC statistics:
      InPackets: 3237727
      InUCast: 3237214
      InMCast: 391
      InBCast: 122
      InErrors: 0
      OutPackets: 14157898
      OutUCast: 14157089
      OutMCast: 304
      OutBCast: 505
      InUCastOctects: 226714406
      OutUCastOctects: 10463156
      InMCastOctects: 58046
      OutMCastOctects: 44817
      InBCastOctects: 12857
      OutBCastOctects: 41626
      InOctects: 226785309
      OutOctects: 10549599
      InPacketsDma: 0
      OutPacketsDma: 16
      InOctetsDma: 0
      OutOctetsDma: 2396
      InDroppedDma: 0
      Queue[0] InPackets: 0
      Queue[0] OutPackets: 0
      Queue[0] InJumboPackets: 0
      Queue[0] InLroPackets: 0
      Queue[0] InErrors: 0
      Queue[1] InPackets: 0
      Queue[1] OutPackets: 0
      Queue[1] InJumboPackets: 0
      Queue[1] InLroPackets: 0
      Queue[1] InErrors: 0
      Queue[2] InPackets: 0
      Queue[2] OutPackets: 0
      Queue[2] InJumboPackets: 0
      Queue[2] InLroPackets: 0
      Queue[2] InErrors: 0
      Queue[3] InPackets: 0
      Queue[3] OutPackets: 0
      Queue[3] InJumboPackets: 0
      Queue[3] InLroPackets: 0
      Queue[3] InErrors: 0

Lino, David what do you think?
If you agree I can re-submit the patch (with fixed braces).

Regards,
Pavel
