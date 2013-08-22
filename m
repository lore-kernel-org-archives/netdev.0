From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH 2/2] genl: Hold reference on correct module while netlink-dump.
Date: Thu, 22 Aug 2013 11:04:38 -0700
Message-ID: <CALnjE+rUOz2tafyR0QzvwL3R1gxrpe71cM1Z4DedD=ak4RcKoA@mail.gmail.com>
References: <1377143892-20763-1-git-send-email-pshelar@nicira.com>
	<1377157242.14110.21.camel@jlt4.sipsolutions.net>
	<CALnjE+oAO_1VQVPp1yq9UnHU0fyRAp7vBB0huaMVxRWMsPvK0w@mail.gmail.com>
	<1377193772.14110.25.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog110.obsmtp.com ([74.125.149.203]:60628 "HELO
	na3sys009aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753138Ab3HVSEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 14:04:38 -0400
Received: by mail-qc0-f170.google.com with SMTP id i8so1198545qcq.1
        for <netdev@vger.kernel.org>; Thu, 22 Aug 2013 11:04:38 -0700 (PDT)
In-Reply-To: <1377193772.14110.25.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 22, 2013 at 10:49 AM, Johannes Berg
<johannes@sipsolutions.net> wrote:
> On Thu, 2013-08-22 at 10:44 -0700, Pravin Shelar wrote:
>
>> > This may be more correct than my patch, but I'm not sure it's worth
>> > spending the memory. Is there going to be any generic netlink family
>> > that actually puts operations into a different module than the family
>> > itself? I doubt that.
>> >
>> I tried to do same, but I do not have access to ops in
>> genl_lock_done() function. therefore I decided to store direct pointer
>> to module in ops struct.
>
> You mean the family? I still don't like this, it'll be a massive
> increase in memory for something like nl80211 that has a lot of
> operations. In fact I think we should get rid of being allowed to
> register single ops and just force a single array to remove the linked
> list as well.
>
Sorry, I meant I do not have access to genl-family in genl_lock_done().
I am using c.data to store ops pointer. Thats why module pointer was
store in ops.

But considering we do not need to hold ref on genl, I can move module
pointer to family.

>> >> +                     c.module = THIS_MODULE;
>> >
>> > THIS_MODULE here is useless, this code is always built-in.
>> >
>> >> +                     if (!try_module_get(ops->module))
>> >> +                             return -EPROTONOSUPPORT;
>> >
>> > Why open-code it? You can just point c.module to the ops module here as
>> > well (because generic netlink is built-in) and save yourself the
>> > try_module_get stuff.
>> >
>>
>> In locked genl case genl-dump operation has call graph as follows:
>> netlink_dump() -> genl_lock_dumpit() -> ops->dump()
>> Therefore I need to take ref on genl module and ops->module.
>
> There's no "genl module", generic netlink is always built in. That was
> my point, you don't need to hold any reference to the "genl module"
> since it doesn't exist, so you can just point to the ops (family)
> module.
>
ok, this make sense.
I will send updated patch.
