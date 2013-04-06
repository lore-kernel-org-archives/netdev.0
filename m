From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH] bonding: remove sysfs before removing devices
Date: Sat, 06 Apr 2013 09:38:00 +0200
Message-ID: <515FD0D8.2080104@redhat.com>
References: <1365003993-13181-1-git-send-email-vfalico@redhat.com> <515F4CEF.3030207@redhat.com> <20130405232133.GA19437@redhat.com> <515F5E6C.2030009@redhat.com> <20130406014924.GA8023@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	davem@davemloft.net
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60425 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756019Ab3DFHkv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Apr 2013 03:40:51 -0400
In-Reply-To: <20130406014924.GA8023@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/06/2013 03:49 AM, Veaceslav Falico wrote:
> On Sat, Apr 06, 2013 at 01:29:48AM +0200, Nikolay Aleksandrov wrote:
>> On 04/06/2013 01:21 AM, Veaceslav Falico wrote:
>>> On Sat, Apr 06, 2013 at 12:15:11AM +0200, Nikolay Aleksandrov wrote:
>>>> Hi,
>>>> Sorry for the late reply but I was travelling this week. In my
>>>> opinion this
>>>> fix is wrong because in bond_uninit() (called by rtnl_link_unregister)
>>>> you have:
>>>> list_del(&bond->bond_list);
>>>> which is linked in the bond_net dev_list which is freed by
>>>> unregister_pernet_subsys.
>>>
>>> Yep, you're right, I've hit it recently with the patch applied, and now
>>> working on it. However, I still think that the idea of the patch is
>>> correct
>>> - i.e. to first disable sysfs (especially bonding_masters) and only
>>>  afterwards to start removing everything else. Or, obviously, to
>>> finally
>>> add normal locking to sysfs functions.
>>>
>>> Anyway, this corruption is really rare, so I'll wait for your fix next
>>> week.
>>>
>> Well, there's no need for that because you'll have to iterate over all
>> "net"s to do it properly. Since we already have code that does it
>> (unregister_pernet_subsys), my fix is to kill off any "left" bond
>> devices in bond_net_exit() _after_ destroying the bonding_masters
>> sysfs entry for that net. This way we preserve the code structure and
>> avoid
>> duplicating a loop over all nets.
>
> Yep, that was one approach that I wanted to do, however I didn't like the
> idea to duplicate the device destruction - i.e. the
> rtnl_link_unregister()
> already does that, and to re-delete them after sysfs gets out of the way
> feeled wrong. However, I've also missed the net->dev_list part, so seems
> like both approaches have drawbacks... Or did I miss something?
>
Bridge code does it this way. See br_deinit() (br_netlink_fini() followed
by unregister pernet_subsys which again deletes anything left).
>> This is the fix we discussed a week ago.
>
> Not with me :). I didn't know of this bug by that time...
>
>> I'd be happy to hear any comments on it before posting :-)
>>
>> Of course stopping the whole bonding sysfs handling is also an
>> alternative.
>
> I think it'd be the best way to do that.
>
> 1) We can't remove the net_ns before removing the devices cause they
> depend
> on it (and I think it's quite a hack anyway now that I'm aware of
> dev_list).
> 2) We can't re-remove devices after sysfs deactivation, it's also a hack,
> cause rtnl does the same thing.
As I mentioned earlier see the bridge code for example.
> 3) We can't hold rtnl_mutex to do both rtnl and net_ns removal cause
> we can
> deadlock in sysfs code (when it gets removed).
> 4) We can't remove the b_masters before all the logic cause it'll
> duplicate
> the code for unregister_pernet_operations(), and will also look like a
> hack (with looping through net_ns).
>
Agreed.
> Out of all these, #2 (your option) looks the best - the least
> intrusive and
> the easiest to read. However, I still think that it's the lesser evil,
> and
> there must exist a way to do it correctly (like with #3, and avoid the
> deadlock by restart_syscall() technique in bond_store_bonds() - however I
> don't really know if it'll work.).
>
> Anyway, I'd really like your feedback on these thoughts, and if nothing
> better comes up - your patch :).
>
One more way would be to make a mechanism that prevents sysfs
bond handling while doing loading/unloading, it can also later be
used to fix other bugs that are present, but it might be tricky with
the loading case.
> Thank you!
Thank you for the input.
