From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH] net/wireless/nl80211.c: fix endless Netlink callback loop.
Date: Tue, 8 Jul 2008 14:23:53 +0200
Message-ID: <f4845fc0807080523o7e773de2u94c10a8739f4ddf4@mail.gmail.com>
References: <1215518539-19587-1-git-send-email-juliusv@google.com>
	 <1215518799.9610.33.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Johannes Berg" <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:27637 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752132AbYGHMYC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 08:24:02 -0400
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id m68CNts0008418
	for <netdev@vger.kernel.org>; Tue, 8 Jul 2008 13:23:55 +0100
Received: from yx-out-1718.google.com (yxp4.prod.google.com [10.190.4.196])
	by wpaz1.hot.corp.google.com with ESMTP id m68CNsKX017320
	for <netdev@vger.kernel.org>; Tue, 8 Jul 2008 05:23:54 -0700
Received: by yx-out-1718.google.com with SMTP id 4so583427yxp.44
        for <netdev@vger.kernel.org>; Tue, 08 Jul 2008 05:23:54 -0700 (PDT)
In-Reply-To: <1215518799.9610.33.camel@johannes.berg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 8, 2008, Johannes Berg wrote:
>> Also, iterations where the filling of an element fails should not be counted as
>> completed, so idx should not be incremented in this case.
>
> Seems to be the case on both points, however,
>
>> --- a/net/wireless/nl80211.c
>> +++ b/net/wireless/nl80211.c
>> @@ -194,22 +194,24 @@ static int nl80211_send_wiphy(struct sk_buff *msg, u32 pid, u32 seq, int flags,
>>  static int nl80211_dump_wiphy(struct sk_buff *skb, struct netlink_callback *cb)
>>  {
>>       int idx = 0;
>>       int start = cb->args[0];
>>       struct cfg80211_registered_device *dev;
>>
>>       mutex_lock(&cfg80211_drv_mutex);
>>       list_for_each_entry(dev, &cfg80211_drv_list, list) {
>> -             if (++idx < start)
>> +             if (++idx <= start)
>>                       continue;
>>               if (nl80211_send_wiphy(skb, NETLINK_CB(cb->skb).pid,
>>                                      cb->nlh->nlmsg_seq, NLM_F_MULTI,
>> -                                    dev) < 0)
>> +                                    dev) < 0) {
>> +                     idx--;
>>                       break;
>> +             }
>
> I see much of the problem stemming from incrementing 'idx' at the
> beginning of the loop, can't we just move it to the end?

idx still needs to be incremented in the 'continue' case, so that
alone wouldn't help. I'm not sure if there is a way to make this look
more intuitive?

Julius

-- 
Google Switzerland GmbH
