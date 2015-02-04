From: Siva Mannem <siva.mannem.lnx@gmail.com>
Subject: Re: [PATCH net-next] bridge: Let bridge not age 'externally' learnt
 FDB entries, they are removed when 'external' entity notifies the aging
Date: Wed, 4 Feb 2015 13:32:53 +0530
Message-ID: <CA+CtxLSziWmx94_V9S-uW9=6VYg4WXsU4CERx-uovvrFOtO1dA@mail.gmail.com>
References: <1422897714-5956-1-git-send-email-siva.mannem.lnx@gmail.com>
	<54D0E521.6070100@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:54820 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716AbbBDICy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 03:02:54 -0500
Received: by mail-wi0-f172.google.com with SMTP id h11so29804741wiw.5
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 00:02:53 -0800 (PST)
In-Reply-To: <54D0E521.6070100@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 3, 2015 at 8:41 PM, roopa <roopa@cumulusnetworks.com> wrote:
> On 2/2/15, 9:21 AM, Siva Mannem wrote:
>>
>>   When 'learned_sync' flag is turned on, the offloaded switch
>>   port syncs learned MAC addresses to bridge's FDB via switchdev notifier
>>   (NETDEV_SWITCH_FDB_ADD). Currently, FDB entries learnt via this
>> mechanism are
>>   wrongly being deleted by bridge aging logic. This patch ensures that FDB
>>   entries synced from offloaded switch ports are not deleted by bridging
>> logic.
>>   Such entries can only be deleted via switchdev notifier
>>   (NETDEV_SWITCH_FDB_DEL).
>
>
> Your patch seems right and maintains symmetry for fdb add/del of externally
> learnt entries.
> However, this could be made configurable. I think some drivers may rely on
> bridge driver aging these entries (The default setting needs more thought).
> I am not sure what rocker does (CC'ed rocker maintainers). But, our driver
> does rely on the bridge driver aging these entries by default.

added_by_external_learn flag is only set for entries learned via
switchdev notifier
(NETDEV_SWITCH_FDB_ADD) and rocker is the only driver using these notifiers.
 I see that rocker is deleting the entries via switchdev notifier
(NETDEV_SWITCH_FDB_DEL).
This mechanism is only used by drivers when learned_sync is turned on by user.

$ sudo bridge link set dev swp1 learning_sync on self

Am I missing something here?

>
>>
>> Signed-off-by: Siva Mannem <siva.mannem.lnx@gmail.com>
>> ---
>>   net/bridge/br_fdb.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
>> index 08bf04b..6eb94b5 100644
>> --- a/net/bridge/br_fdb.c
>> +++ b/net/bridge/br_fdb.c
>> @@ -280,7 +280,7 @@ void br_fdb_cleanup(unsigned long _data)
>>                 hlist_for_each_entry_safe(f, n, &br->hash[i], hlist) {
>>                         unsigned long this_timer;
>> -                       if (f->is_static)
>> +                       if (f->is_static || f->added_by_external_learn)
>>                                 continue;
>>                         this_timer = f->updated + delay;
>>                         if (time_before_eq(this_timer, jiffies))
>
>



-- 
Regards,
Siva Mannem.
