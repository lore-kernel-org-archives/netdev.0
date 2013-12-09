From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [patch net/stable v2] br: fix use of ->rx_handler_data in code
 executed on non-rx_handler path
Date: Sun, 08 Dec 2013 21:07:18 -0500
Message-ID: <52A525D6.7050409@gmail.com>
References: <1386257257-25258-1-git-send-email-jiri@resnulli.us> <20131206.154321.1673089712073824539.davem@davemloft.net> <20131206131028.41b5b8b1@nehalam.linuxnetplumber.net> <20131207085105.GA2496@minipsycho.orion> <52A372B5.8010602@gmail.com> <20131207200720.GB2516@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jtluka@redhat.com, zhiguohong@tencent.com,
	bridge@lists.linux-foundation.org, edumazet@google.com,
	laine@redhat.com, mst@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f54.google.com ([209.85.128.54]:58719 "EHLO
	mail-qe0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759080Ab3LICHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 21:07:24 -0500
Received: by mail-qe0-f54.google.com with SMTP id cy11so2314275qeb.13
        for <netdev@vger.kernel.org>; Sun, 08 Dec 2013 18:07:22 -0800 (PST)
In-Reply-To: <20131207200720.GB2516@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/07/2013 03:07 PM, Jiri Pirko wrote:
> Sat, Dec 07, 2013 at 08:10:45PM CET, vyasevich@gmail.com wrote:
>> On 12/07/2013 03:51 AM, Jiri Pirko wrote:
>>> Fri, Dec 06, 2013 at 10:10:28PM CET, stephen@networkplumber.org wrote:
>>>> On Fri, 06 Dec 2013 15:43:21 -0500 (EST)
>>>> David Miller <davem@davemloft.net> wrote:
>>>>
>>>>> From: Jiri Pirko <jiri@resnulli.us>
>>>>> Date: Thu,  5 Dec 2013 16:27:37 +0100
>>>>>
>>>>>> br_stp_rcv() is reached by non-rx_handler path. That means there is no
>>>>>> guarantee that dev is bridge port and therefore simple NULL check of
>>>>>> ->rx_handler_data is not enough. There is need to check if dev is really
>>>>>> bridge port and since only rcu read lock is held here, do it by checking
>>>>>> ->rx_handler pointer.
>>>>>>
>>>>>> Note that synchronize_net() in netdev_rx_handler_unregister() ensures
>>>>>> this approach as valid.
>>>>>>
>>>>>> Introduced originally by:
>>>>>> commit f350a0a87374418635689471606454abc7beaa3a
>>>>>>   "bridge: use rx_handler_data pointer to store net_bridge_port pointer"
>>>>>>
>>>>>> Fixed but not in the best way by:
>>>>>> commit b5ed54e94d324f17c97852296d61a143f01b227a
>>>>>>   "bridge: fix RCU races with bridge port"
>>>>>>
>>>>>> Reintroduced by:
>>>>>> commit 716ec052d2280d511e10e90ad54a86f5b5d4dcc2
>>>>>>   "bridge: fix NULL pointer deref of br_port_get_rcu"
>>>>>>
>>>>>> Please apply to stable trees as well. Thanks.
>>>>>>
>>>>>> RH bugzilla reference: https://bugzilla.redhat.com/show_bug.cgi?id=1025770
>>>>>>
>>>>>> Reported-by: Laine Stump <laine@redhat.com>
>>>>>> Debugged-by: Michael S. Tsirkin <mst@redhat.com>
>>>>>> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
>>>>>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>>>>> ---
>>>>>> v1->v2: moved br_port_get_check_rcu definition below br_handle_frame definition
>>>>>
>>>>> Applied and queued up for -stable, thanks Jiri.
>>>>
>>>> How come you ignored my simpler fix, that used the existing logic.
>>>> I don't like introducing this especially into the stable; much prefer
>>>> to go back to testing the flag as was being done before.
>>>
>>> Although your patch is technically sane, it depends on rtnl indirectly.
>>
>> Pardon my ignorance, but I've been staring at this and I can't for
>> the life of me see the dependency.
>>
>> The IFF_BRIDGE_PORT flag is set after the rx_handler is registered,
>> so we are safe there.  The rcu primitives will guarantee that the flag
>> will be set by the time rx_handler and rx_handler_data are set.
>>
>> The flag is cleared before rx_handler is unregistered, so it is
>> still valid to check for it in stp code.  Once the flag is cleared
>> we may still have a valid rx_handler during the rcu grace period, but
>> will still avoid doing processing.
>>
>> So, where is the dependency on the rtnl?
> 
> 
> Imagine br would release the netdev and some other rx_handler user would
> enslave the same netdev. This two events would happen between
> IFF_BRIDGE_PORT flag check and rx_handler_data get. That is what
> rtnl_lock prevents from happening.

I don't think this can happen.  Inside br_stp_rcv(), we are in an rcu
critical section.  The release of the netdev (rx_handler unregister)
forces us to to wait until synchronize_net() completes.  So, if under
rcu we checked the flag and it's on, the rx_handler will not change for
the duration of that rcu section and we can safely process the packet
even if the port is in the middle of going away.  Howe does the race
you describe happen?

The reason I ask, is that we check priv_flags under rcu in other
places to make sure that the device we are passing data to can handle
it.  If it's not safe, then those other places are vulnerable too.
It doesn't seem to me that it is unsafe.

Thanks
-vlad

> 
>>
>> Thanks
>> -vlad
>>
>>> My patch depends on rcu locking and synchronize_rcu which is direct.
>>> Therefore I think it is more appropriate.
>>>
>>> Jiri
>>>
>>>
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>
