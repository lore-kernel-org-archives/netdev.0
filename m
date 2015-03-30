From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [net-next PATCH 1/2] fib_trie: Fix warning on fib4_rules_exit
Date: Mon, 30 Mar 2015 14:58:12 -0700
Message-ID: <5519C6F4.2050507@redhat.com>
References: <20150327211416.2465.23170.stgit@ahduyck-vm-fedora22>	<CAHA+R7McwZQ5PCWFvUh-wrktg3AP0tu7arkcp=+SFmiD5apRBQ@mail.gmail.com>	<5515E7CE.5050206@redhat.com>	<CAHA+R7NeYYmbyAuzNMtWQ4_T1Wq-mO42PmWfQp18ecOzYtX7wA@mail.gmail.com>	<5519B0E1.4040603@redhat.com> <CAHA+R7MMngzOrpPEG9zgbRfMzKxQLexqNGrtBYkoVQzn8p+ffw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53571 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932131AbbC3V6S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2015 17:58:18 -0400
In-Reply-To: <CAHA+R7MMngzOrpPEG9zgbRfMzKxQLexqNGrtBYkoVQzn8p+ffw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 03/30/2015 01:50 PM, Cong Wang wrote:
> On Mon, Mar 30, 2015 at 1:24 PM, Alexander Duyck
> <alexander.h.duyck@redhat.com> wrote:
>> On 03/30/2015 11:54 AM, Cong Wang wrote:
>>> On Fri, Mar 27, 2015 at 4:29 PM, Alexander Duyck
>>> <alexander.h.duyck@redhat.com> wrote:
>>>> On 03/27/2015 03:14 PM, Cong Wang wrote:
>>>>> On Fri, Mar 27, 2015 at 2:14 PM, Alexander Duyck
>>>>> <alexander.h.duyck@redhat.com> wrote:
>>>>>> The issue was that as a part of exiting the default rules were being
>>>>>> deleted which resulted in the local trie being unmerged.  By moving the
>>>>>> freeing of the FIB tables up we can avoid the unmerge since there is no
>>>>>> local table left when we call the fib4_rules_exit function.
>>>>>>
>>>>> This literally means we no longer need to call ops->delete()
>>>>> in netns unregister path.
>>>>
>>>> You are confusing table entries and rules.  The tables are cleared, the
>>>> rules still have to be deleted.  This patch breaks the reference counting
>>>> for fib_num_tclassid_users.
>>> It doesn't matter much here, the whole net is being unregistered,
>>> we are holding rtnl lock and existing readers don't mind to read an
>>> incorrect
>>> fib_num_tclassid_users.
>>
>> Still best not to mess with this.  For the sake of completeness if we have
>> delete implemented it should be called.
>>
>
> If it is to delete per-rule stuffs, of course yes. But it is to delete per-net
> stuffs, and this is the whole point.

The interface is much cleaner without duplicating code.  What you are 
proposing means we have to periodically check the delete function in 
case anything else gets added to it which is highly possible since 
switchdev and the fib_trie have been fairly active lately and there are 
likely to be more changes.  Please, just leave the delete function being 
called in fib_rules_cleanup_ops as is.

>
>>
>>>>> diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
>>>>> index 68ea695..27b6e04 100644
>>>>> --- a/net/core/fib_rules.c
>>>>> +++ b/net/core/fib_rules.c
>>>>> @@ -153,8 +153,6 @@ static void fib_rules_cleanup_ops(struct
>>>>> fib_rules_ops
>>>>> *ops)
>>>>>
>>>>>            list_for_each_entry_safe(rule, tmp, &ops->rules_list, list) {
>>>>>                    list_del_rcu(&rule->list);
>>>>> -               if (ops->delete)
>>>>> -                       ops->delete(rule);
>>>>>                    fib_rule_put(rule);
>>>>>            }
>>>>>     }
>>>>> diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
>>>>> index e5b6b05..1481b23 100644
>>>>> --- a/net/ipv4/fib_frontend.c
>>>>> +++ b/net/ipv4/fib_frontend.c
>>>>> @@ -1178,6 +1178,7 @@ static void ip_fib_net_exit(struct net *net)
>>>>>
>>>>>     #ifdef CONFIG_IP_MULTIPLE_TABLES
>>>>>            fib4_rules_exit(net);
>>>>> +       fib_flush_external(net); // <-------- Maybe not needed either.
>>>>>     #endif
>>>>>
>>>>>            for (i = 0; i < FIB_TABLE_HASHSZ; i++) {
>>>>
>>>> Take a look at fib4_rule_delete.  There is more there than just unmerge
>>>> and
>>>> flush external.
>>> I am not stupid, what otherwise do you think the above
>>> fib_flush_external()
>>> comes from?
>>
>> The fact is you are choosing to overlook things that will lead to issues, if
>> not now, then later, and as a result make the code more difficult to
>> maintain.  It isn't as if this is hot-path code so there isn't any need to
>> optimize it by dropping these calls.
>
> Who said it is for optimization?
>
> It is just _logically_ not needed, that is all, please don't interrupt
> me too far
> beyond the point.

The thing is it is doing something useful.  You don't agree, but it 
needs to be there for completeness and to reduce unnecessary duplication 
of code.

>
>>> Read fib4_rule_delete(), everything it cleans up is per net, you can argue
>>> ipv4.fib_num_tclassid_users is a refcount for rules, but still the whole
>>> net
>>> is being unregistered.
>>
>> Yes, the delete call will likely not do much more than update
>> ipv4.fib_num_tclassid_users, but having that value updated until we free the
>> net structure is useful for things like debugging.
>>
>> If anything it would be useful to go through and audit the other users to
>> make sure they are all following a similar pattern.  From what I can tell
>
> As you said, only ipv4 fib has ops->delete(), I don't understand why
> others should follow.

Because it is a necessary bit if there is any other objects that are 
added per rule.  Currently there aren't but there could be so please 
just leave it as is.  If nothing else at this point it is taking care of 
reference counting.

>> ip6mr_rules_exit is already in the same layout, and the same goes for
>> ipmr_rules_exit though each is dealing with the RTNL lock differently.  Your
>> efforts would be much better placed there than trying to alter code that
>> really should be left as-is for completeness.
>>
> They should be same with regarding to RTNL, I already sent a patch:
>
> http://permalink.gmane.org/gmane.linux.network/356700

The patch set is listed as "Changes Requested" in Dave's patchwork queue.
https://patchwork.ozlabs.org/patch/454744/

My advice for the patch would be to look at moving the rtnl_unlock down 
one line in ip6mr_rules_exit and your patch so that it includes the 
fib_rules_unregister call in the RTNL locked region.  While you are at 
it you could probably also wrap any other callers to 
fib_rules_unregister where it is called as a part of the exit path such 
as fib6_rules_net_exit and dn_fib_rules_cleanup.

- Alex
