From: Dmitry Kravkov <dkravkov@gmail.com>
Subject: Re: [PATCH net 1/6] bnx2x: properly initialize statistic counters
Date: Tue, 16 Jul 2013 21:14:36 +0300
Message-ID: <CAM8tLiPqKWxO7w9kL2LjGxFNth6oRV7-JccU+LXiFk9Roass5w@mail.gmail.com>
References: <1373988107-305-1-git-send-email-dmitry@broadcom.com>
	<1373988107-305-2-git-send-email-dmitry@broadcom.com>
	<1373991870.1949.3.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Dmitry Kravkov <dmitry@broadcom.com>,
	Dave Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f177.google.com ([209.85.128.177]:38155 "EHLO
	mail-ve0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933334Ab3GPSOh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 14:14:37 -0400
Received: by mail-ve0-f177.google.com with SMTP id cz10so743470veb.22
        for <netdev@vger.kernel.org>; Tue, 16 Jul 2013 11:14:36 -0700 (PDT)
In-Reply-To: <1373991870.1949.3.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 16, 2013 at 7:24 PM, Joe Perches <joe@perches.com> wrote:
> On Tue, 2013-07-16 at 18:21 +0300, Dmitry Kravkov wrote:
>> This prevent second statistics query be sent before first one is complete.
>> This is required since two outstanding queries may cause FW assert.
>
> Please run sparse on your code before submitting patches.
>
>> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
> []
>> @@ -1591,10 +1591,16 @@ void bnx2x_stats_init(struct bnx2x *bp)
>>  {
>>       int /*abs*/port = BP_PORT(bp);
>>       int mb_idx = BP_FW_MB_IDX(bp);
>> +     __le16 init_fw_counter = le16_to_cpu(0xFFFF);
>
>         __le16 init_fw_counter = cpu_to_le16(0xffff);
>

Thanks Joe,  for catching this

>> +     struct stats_counter *counters = &bp->fw_stats_data->storm_counters;
>>
>>       bp->stats_pending = 0;
>>       bp->executer_idx = 0;
>>       bp->stats_counter = 0;
>> +     counters->xstats_counter = init_fw_counter;
>> +     counters->tstats_counter = init_fw_counter;
>> +     counters->ustats_counter = init_fw_counter;
>> +     counters->cstats_counter = init_fw_counter;
>
> It might be better to remove init_fw_counter from
> stack and use a #define or just use cpu_to_le16(0xffff)
> in each init.

I'm not feel well for using same value in each init, probably is better to use
multiple assignment like this:
    counters->xstats_counter =
        counters->tstats_counter =
        counters->ustats_counter =
        counters->cstats_counter = cpu_to_le16(0xffff);
