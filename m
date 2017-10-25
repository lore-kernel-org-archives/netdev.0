From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net] net/sched: cls_flower: Avoid attempt to delete from
 hw a flow which was not offloaded
Date: Wed, 25 Oct 2017 17:07:26 +0300
Message-ID: <8e6bb07f-7967-941b-cb67-a9c9af56fc6d@mellanox.com>
References: <1508939080-22317-1-git-send-email-ogerlitz@mellanox.com>
 <20171025135820.GB1976@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>, mlxsw@mellanox.com,
        Roi Dayan <roid@mellanox.com>, Paul Blakey <paulb@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0044.outbound.protection.outlook.com ([104.47.1.44]:64880
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751162AbdJYOHe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Oct 2017 10:07:34 -0400
In-Reply-To: <20171025135820.GB1976@nanopsycho.orion>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/25/2017 4:58 PM, Jiri Pirko wrote:
> Wed, Oct 25, 2017 at 03:44:40PM CEST, ogerlitz@mellanox.com wrote:
>> If we failed to offload a flow to HW, we should not be attempting to delete
>> it from the HW. Also, on this case, we should be err-ing only if the flow is
>> not is SW, fix both issues.
>>
>> Fixes: 717503b9cf57 ('net: sched: convert cls_flower->egress_dev users to tc_setup_cb_egdev infra')
>> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
>> ---
>> net/sched/cls_flower.c | 11 ++++-------
>> 1 file changed, 4 insertions(+), 7 deletions(-)
>>
>> diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
>> index 16f58ab..b98e0cb 100644
>> --- a/net/sched/cls_flower.c
>> +++ b/net/sched/cls_flower.c
>> @@ -230,15 +230,12 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
>>
>> 	err = tc_setup_cb_call(block, &f->exts, TC_SETUP_CLSFLOWER,
>> 			       &cls_flower, skip_sw);
>> -	if (err < 0) {
>> -		fl_hw_destroy_filter(tp, f);
>> -		return err;
>
> As I wrote in the other thread: Yes, that is intentional. The thing is, there might be multiple block callbacks registered and to be called. If there is a fail with one, we need to cleanup all. So in your case you have 1 cb registered, that means that in case of an error during insertion, you will get cb called to remove. Driver has to take care of that. I was checking that and was under impression that mlx5 deals with that.

I see, what about the other line I deleted of blankly returning err no 
matter regardless if we' re on skip_sw or not, do you agree this fix is 
needed, also see below
>> -	} else if (err > 0) {
>> +
>> +	if (err > 0)
>> 		f->flags |= TCA_CLS_FLAGS_IN_HW;
>> -	}
>>
>> -	if (skip_sw && !(f->flags & TCA_CLS_FLAGS_IN_HW))
>> -		return -EINVAL;
>> +	if (skip_sw)
>> +		return err;
>>
>> 	return 0;
>> }

here's too, I don't see why we should return -EINVAL etc, and what's 
wrong with the code as it wad before your patch, I just returned it to 
how it was before which I think is correct

Or.
