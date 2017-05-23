From: Arend Van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: 4.12-RC2 BUG: scheduling while atomic: irq/47-iwlwifi
Date: Tue, 23 May 2017 09:19:26 +0200
Message-ID: <09ddb018-7093-2e2a-c84b-148889f7f06d@broadcom.com>
References: <a54f3f4f-2365-2154-ad18-82e4cd572aac@eikelenboom.it>
 <1495450628.2653.14.camel@sipsolutions.net>
 <764a929c-ce8a-c859-a49e-2f20cb05ae44@broadcom.com>
 <532c257e-52a0-18c1-1afe-04d37c28e072@broadcom.com>
 <1495487095.26008.7.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
        netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>,
        Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:37326 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761956AbdEWHT3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 03:19:29 -0400
Received: by mail-wm0-f44.google.com with SMTP id d127so15148566wmf.0
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 00:19:28 -0700 (PDT)
In-Reply-To: <1495487095.26008.7.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22-5-2017 23:04, Johannes Berg wrote:
> Hi Arend,
> 
> Sorry, I forgot that the original message wasn't Cc'ed to the wireless
> list, only netdev.

That explains. Not subscribed to that.

>> +++ b/net/wireless/scan.c
>> @@ -322,9 +322,7 @@ static void cfg80211_del_sched_scan_req(struct
>> cfg80211_regi
>>  {
>>         struct cfg80211_sched_scan_request *pos;
>>
>> -       ASSERT_RTNL();
>> -
>> -       list_for_each_entry(pos, &rdev->sched_scan_req_list, list) {
>> +       list_for_each_entry_rcu(pos, &rdev->sched_scan_req_list,
>> list) {
> 
> [snip]
> 
> This looks fine, but perhaps in the above we should have some kind of
> locking assertion, e.g.
> 
> 	WARN_ON_ONCE(!rcu_read_lock_held() && !lockdep_rtnl_is_held());

Thought about something like this after sending the email. So there are
two call sites. One for scheduled scan results notification and one in
scheduled scan stop scenario. So for the latter it is not needed to use
the rcu_read_lock() as it should have RTNL lock hence the two checks above?

Will create a formal patch.

Regards,
Arend
