From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Patch net] rtnetlink: call rtnl_lock_unregistering() in rtnl_link_unregister()
Date: Mon, 12 May 2014 02:18:45 -0700
Message-ID: <87mwenjqx6.fsf@x220.int.ebiederm.org>
References: <1399657653-4909-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140509110345.417d2b90@nehalam.linuxnetplumber.net>
	<CAM_iQpUJ7q_RgFzJ7yu5F0aYSSCVAEu64UpwN=md0OyRGHBFAg@mail.gmail.com>
	<20140509120241.3b628dc1@nehalam.linuxnetplumber.net>
	<CAM_iQpWsbvC8nZd31n+akt2tQfCKvsHW6WAfjFdsgKNc5iiVig@mail.gmail.com>
	<87bnv6lfig.fsf@x220.int.ebiederm.org>
	<CAM_iQpVYwx175-qbo4g80nHKbJ3XPYD5Py409Tmyt=zaJqgZ-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:52428 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750791AbaELJTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 05:19:32 -0400
In-Reply-To: <CAM_iQpVYwx175-qbo4g80nHKbJ3XPYD5Py409Tmyt=zaJqgZ-Q@mail.gmail.com>
	(Cong Wang's message of "Sun, 11 May 2014 22:17:11 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <xiyou.wangcong@gmail.com> writes:

> On Fri, May 9, 2014 at 4:05 PM, Eric W. Biederman <ebiederm@xmission.com> wrote:
>> Cong Wang <xiyou.wangcong@gmail.com> writes:
>>
>>> On Fri, May 9, 2014 at 12:02 PM, Stephen Hemminger
>>> <stephen@networkplumber.org> wrote:
>>>> On Fri, 9 May 2014 11:10:36 -0700
>>>> Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>>>
>>>>>
>>>>> This can't be done without a macro (at least for me). Or
>>>>> we have to duplicate the code.
>>>>
>>>> macro method is too ugly, figure out a better way.
>>>
>>> That's what I am going to do for -net-next. This patch is for -net,
>>> it's an ugly but minimum change I can find.
>>>
>>> Of course, if you insist we should clean up it for -net as well,
>>> I can do that.
>>
>> It would be no worse to rename the existing function
>> rtnl_lock_unregistering_list
>>
>> And add a second function rtnl_lock_unregistering that does
>> the same thing but uses the global list.
>>
>> Of course this begs the question what happens if the network
>> device we want to destroy is a network namespace that is currently
>> exiting and not on the global list.
>>
>
> OK, so we have to duplicate the code.
>
>> It looks like we need to grab the net_mutex to get a state where network
>> namespaces are not exiting...
>>
>
> Hmm, for me it looks like we need net_mutex only we change pernet ops,
> here rtnl lock is enough. No?

Look at net/core/net_namespace.c:cleanup_net

While namespaces are being torn down the net_mutex is held.  At the same
time the rtnl_mutex is not held, and those namespaces are not on the
net_namespace_list.

So while holding the rtnl_lock is enough to traverse the net_namespace
list without it changing.  You need the net_mutex to make certain there
are not network namespaces in the final stages of being cleaned up
that are not on the net_namespaces list.

Those namespaces in the final stages of being cleaned up are as
problematic as network devices that are being cleaned up that live
on the netdev todo list.  for_each_net in rtnl_link_unregister
can not see them.

Eric
