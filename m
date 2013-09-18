From: Francesco Ruggeri <fruggeri@aristanetworks.com>
Subject: Re: [CFT][PATCH] net: Delay default_device_exit_batch until no
 devices are unregistering
Date: Tue, 17 Sep 2013 20:50:41 -0700
Message-ID: <CA+HUmGgg3-0UNgfKS6Hpnczzi6PUeztk8TZ7p_97kcvtfMacJQ@mail.gmail.com>
References: <87mwncaz04.fsf_-_@xmission.com>
	<20130917.192158.941189471705765317.davem@davemloft.net>
	<e652a11e-b23d-4a83-aaac-00c469a416f1@email.android.com>
	<20130917.201515.1404443973169590392.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <edumazet@google.com>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f169.google.com ([209.85.220.169]:43914 "EHLO
	mail-vc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751609Ab3IRDul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 23:50:41 -0400
Received: by mail-vc0-f169.google.com with SMTP id ib11so4905066vcb.14
        for <netdev@vger.kernel.org>; Tue, 17 Sep 2013 20:50:41 -0700 (PDT)
In-Reply-To: <20130917.201515.1404443973169590392.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> List/count I don't much care but currently we don't have a list of
>> all of the devices that are unregistering.
>>
>> The problem with this is that netdev_run_todo moves all of the
>> devices to a local list, so they are only visible from a list_head
>> on the stack.  Which makes sense as we run this all in the context
>> of rtnl_unlock.
>
> And when that local list is processed (the while loop completes and
> has iterated over the entire list), either the global todo list is
> empty, or it is not empty.
>
> And the waked up code will check for this.
>
> I really don't see what the problem is.

I am not sure that would work.
list_empty(&net_todo_list) does not guarantee that there are no
unregistering devices still in flight.
Another process may have copied net_todo_run into its local list, left
net_todo_list empty and still be in the middle of processing
unregistering devices (without the rtnl lock) when
default_device_exit_batch starts executing.

> The count doesn't necessarily need to be atomic as it can be protected
> by the rtnl_lock.

If we use the rtnl_lock then we could have per-net wait queues. While
not strictly needed (since only one instance of
default_device_exit_batch can execute at a time) it would avoid
unnecessarily waking up the waiting code.

Francesco
