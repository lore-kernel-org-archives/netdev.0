From: Arend Van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: 4.12-RC2 BUG: scheduling while atomic: irq/47-iwlwifi
Date: Mon, 22 May 2017 23:02:34 +0200
Message-ID: <532c257e-52a0-18c1-1afe-04d37c28e072@broadcom.com>
References: <a54f3f4f-2365-2154-ad18-82e4cd572aac@eikelenboom.it>
 <1495450628.2653.14.camel@sipsolutions.net>
 <764a929c-ce8a-c859-a49e-2f20cb05ae44@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
        Sander Eikelenboom <linux-6SM94LqRVpn6gRhOQ7JHfg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <764a929c-ce8a-c859-a49e-2f20cb05ae44-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 22-5-2017 14:09, Arend van Spriel wrote:
> On 5/22/2017 12:57 PM, Johannes Berg wrote:
>> On Mon, 2017-05-22 at 12:36 +0200, Sander Eikelenboom wrote:
>>> Hi,
>>>
>>> I encountered this splat with 4.12-RC2.
>>
>> Ugh, yeah, I should've seen that in the review.
>>
>> Arend, please take a look at this. cfg80211_sched_scan_results() cannot
>> sleep, so you can't rtnl_lock() in there. Looks like you can just rely
>> on RCU though?
> 
> I see. I think you are right on RCU. Don't have the code in front of me
> now, but I think the lookup has an ASSERT_RTNL. Will look into it after
> my monday meeting :-p

I realized I have a laptop lying around with intel 3160 wifi chip and
tried to reproduce the issue. Did not run into the splat running
4.12-rc1 from wireless-drivers-next repo. I did not get the email from
Sander so I don't know any details.

Here is what I changed based on the info Johannes provided. Can you
please check if this get rid of the splat and let me know.

Regards,
Arend
---
diff --git a/net/wireless/scan.c b/net/wireless/scan.c
index 14d5f0c..04833bb 100644
--- a/net/wireless/scan.c
+++ b/net/wireless/scan.c
@@ -322,9 +322,7 @@ static void cfg80211_del_sched_scan_req(struct
cfg80211_regi
 {
        struct cfg80211_sched_scan_request *pos;

-       ASSERT_RTNL();
