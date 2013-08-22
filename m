From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH 2/2] genl: Hold reference on correct module while netlink-dump.
Date: Thu, 22 Aug 2013 10:44:28 -0700
Message-ID: <CALnjE+oAO_1VQVPp1yq9UnHU0fyRAp7vBB0huaMVxRWMsPvK0w@mail.gmail.com>
References: <1377143892-20763-1-git-send-email-pshelar@nicira.com>
	<1377157242.14110.21.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog106.obsmtp.com ([74.125.149.77]:43293 "HELO
	na3sys009aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753827Ab3HVRo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 13:44:28 -0400
Received: by mail-qc0-f170.google.com with SMTP id i8so1180534qcq.15
        for <netdev@vger.kernel.org>; Thu, 22 Aug 2013 10:44:28 -0700 (PDT)
In-Reply-To: <1377157242.14110.21.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 22, 2013 at 12:40 AM, Johannes Berg
<johannes@sipsolutions.net> wrote:
> On Wed, 2013-08-21 at 20:58 -0700, Pravin B Shelar wrote:
>> netlink dump operations take module as parameter to hold
>> reference for entire netlink dump duration.
>> Currently it holds ref only on genl module which is not correct
>> when we use ops registered to genl from another module.
>> Following patch adds module pointer to genl_ops so that netlink
>> can hold ref count on it.
>>
>> CC: Jesse Gross <jesse@nicira.com>
>> CC: Johannes Berg <johannes.berg@intel.com>
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>> ---
>>  include/net/genetlink.h |   21 ++++++++++++++++++---
>>  net/netlink/genetlink.c |   39 ++++++++++++++++++++++++---------------
>>  2 files changed, 42 insertions(+), 18 deletions(-)
>>
>> diff --git a/include/net/genetlink.h b/include/net/genetlink.h
>> index 93024a4..7f57b2c 100644
>> --- a/include/net/genetlink.h
>> +++ b/include/net/genetlink.h
>> @@ -119,13 +119,28 @@ struct genl_ops {
>>                                        struct netlink_callback *cb);
>>       int                    (*done)(struct netlink_callback *cb);
>>       struct list_head        ops_list;
>> +     struct module           *module;
>>  };
>
> This may be more correct than my patch, but I'm not sure it's worth
> spending the memory. Is there going to be any generic netlink family
> that actually puts operations into a different module than the family
> itself? I doubt that.
>
I tried to do same, but I do not have access to ops in
genl_lock_done() function. therefore I decided to store direct pointer
to module in ops struct.

>> @@ -605,14 +610,18 @@ static int genl_family_rcv_msg(struct genl_family *family,
>>                       genl_unlock();
>>                       c.data = ops;
>>                       c.dump = genl_lock_dumpit;
>> -                     if (ops->done)
>> -                             c.done = genl_lock_done;
>> +                     c.done = genl_lock_done;
>> +                     c.module = THIS_MODULE;
>
> THIS_MODULE here is useless, this code is always built-in.
>
>> +                     if (!try_module_get(ops->module))
>> +                             return -EPROTONOSUPPORT;
>
> Why open-code it? You can just point c.module to the ops module here as
> well (because generic netlink is built-in) and save yourself the
> try_module_get stuff.
>

In locked genl case genl-dump operation has call graph as follows:
netlink_dump() -> genl_lock_dumpit() -> ops->dump()
Therefore I need to take ref on genl module and ops->module.

In case of parallel_ops been true, genl_lock_dumpit() is not used so I
have directly set c.module to ops->module.

I know this code is bit complicated, but I could not find way to simplify it.
