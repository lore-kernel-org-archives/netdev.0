From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: 4.12-RC2 BUG: scheduling while atomic: irq/47-iwlwifi
Date: Tue, 23 May 2017 19:51:12 +0200
Message-ID: <e8b61883-1f23-c94c-1740-b121aae70a2c@eikelenboom.it>
References: <a54f3f4f-2365-2154-ad18-82e4cd572aac@eikelenboom.it>
 <1495450628.2653.14.camel@sipsolutions.net>
 <764a929c-ce8a-c859-a49e-2f20cb05ae44@broadcom.com>
 <532c257e-52a0-18c1-1afe-04d37c28e072@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
        netdev@vger.kernel.org
To: Arend Van Spriel <arend.vanspriel@broadcom.com>,
        Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server.eikelenboom.it ([91.121.65.215]:55930 "EHLO
        server.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966493AbdEWRvZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 13:51:25 -0400
In-Reply-To: <532c257e-52a0-18c1-1afe-04d37c28e072@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/05/17 23:02, Arend Van Spriel wrote:
> 
> 
> On 22-5-2017 14:09, Arend van Spriel wrote:
>> On 5/22/2017 12:57 PM, Johannes Berg wrote:
>>> On Mon, 2017-05-22 at 12:36 +0200, Sander Eikelenboom wrote:
>>>> Hi,
>>>>
>>>> I encountered this splat with 4.12-RC2.
>>>
>>> Ugh, yeah, I should've seen that in the review.
>>>
>>> Arend, please take a look at this. cfg80211_sched_scan_results() cannot
>>> sleep, so you can't rtnl_lock() in there. Looks like you can just rely
>>> on RCU though?
>>
>> I see. I think you are right on RCU. Don't have the code in front of me
>> now, but I think the lookup has an ASSERT_RTNL. Will look into it after
>> my monday meeting :-p
> 
> I realized I have a laptop lying around with intel 3160 wifi chip and
> tried to reproduce the issue. Did not run into the splat running
> 4.12-rc1 from wireless-drivers-next repo. I did not get the email from
> Sander so I don't know any details.
> 
> Here is what I changed based on the info Johannes provided. Can you
> please check if this get rid of the splat and let me know.

Hi Arend,

I ran your patch today, so far no issues.

--
Sander


> Regards,
> Arend
> ---
> diff --git a/net/wireless/scan.c b/net/wireless/scan.c
> index 14d5f0c..04833bb 100644
> --- a/net/wireless/scan.c
> +++ b/net/wireless/scan.c
> @@ -322,9 +322,7 @@ static void cfg80211_del_sched_scan_req(struct
> cfg80211_regi
>  {
>         struct cfg80211_sched_scan_request *pos;
> 
> -       ASSERT_RTNL();
> -
> -       list_for_each_entry(pos, &rdev->sched_scan_req_list, list) {
> +       list_for_each_entry_rcu(pos, &rdev->sched_scan_req_list, list) {
>                 if (pos->reqid == reqid)
>                         return pos;
>         }
> @@ -398,13 +396,13 @@ void cfg80211_sched_scan_results(struct wiphy
> *wiphy, u64
>         trace_cfg80211_sched_scan_results(wiphy, reqid);
>         /* ignore if we're not scanning */
> 
> -       rtnl_lock();
> +       rcu_read_lock();
>         request = cfg80211_find_sched_scan_req(rdev, reqid);
>         if (request) {
>                 request->report_results = true;
>                 queue_work(cfg80211_wq, &rdev->sched_scan_res_wk);
>         }
> -       rtnl_unlock();
> +       rcu_read_unlock();
>  }
>  EXPORT_SYMBOL(cfg80211_sched_scan_results);
> 
> 
