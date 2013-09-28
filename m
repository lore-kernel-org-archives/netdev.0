From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Delay default_device_exit_batch until no devices
 are unregistering v2
Date: Sat, 28 Sep 2013 15:14:28 -0700 (PDT)
Message-ID: <20130928.151428.1911890333600618537.davem@davemloft.net>
References: <CA+HUmGgg3-0UNgfKS6Hpnczzi6PUeztk8TZ7p_97kcvtfMacJQ@mail.gmail.com>
	<20130917.235247.344101545141336143.davem@davemloft.net>
	<87a9j26eca.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fruggeri@aristanetworks.com, edumazet@google.com, jiri@resnulli.us,
	alexander.h.duyck@intel.com, amwang@redhat.com,
	netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33413 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755080Ab3I1WHd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Sep 2013 18:07:33 -0400
In-Reply-To: <87a9j26eca.fsf_-_@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 23 Sep 2013 21:19:49 -0700

> 
> There is currently serialization network namespaces exiting and
> network devices exiting as the final part of netdev_run_todo does not
> happen under the rtnl_lock.  This is compounded by the fact that the
> only list of devices unregistering in netdev_run_todo is local to the
> netdev_run_todo.
> 
> This lack of serialization in extreme cases results in network devices
> unregistering in netdev_run_todo after the loopback device of their
> network namespace has been freed (making dst_ifdown unsafe), and after
> the their network namespace has exited (making the NETDEV_UNREGISTER,
> and NETDEV_UNREGISTER_FINAL callbacks unsafe).
> 
> Add the missing serialization by a per network namespace count of how
> many network devices are unregistering and having a wait queue that is
> woken up whenever the count is decreased.  The count and wait queue
> allow default_device_exit_batch to wait until all of the unregistration
> activity for a network namespace has finished before proceeding to
> unregister the loopback device and then allowing the network namespace
> to exit.
> 
> Only a single global wait queue is used because there is a single global
> lock, and there is a single waiter, per network namespace wait queues
> would be a waste of resources.
> 
> The per network namespace count of unregistering devices gives a
> progress guarantee because the number of network devices unregistering
> in an exiting network namespace must ultimately drop to zero (assuming
> network device unregistration completes).
> 
> The basic logic remains the same as in v1.  This patch is now half
> comment and half rtnl_lock_unregistering an expanded version of
> wait_event performs no extra work in the common case where no network
> devices are unregistering when we get to default_device_exit_batch.
> 
> Reported-by: Francesco Ruggeri <fruggeri@aristanetworks.com>
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Applied, thanks for following up on this Eric.
