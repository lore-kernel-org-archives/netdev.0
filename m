From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [CFT][PATCH] net: Delay default_device_exit_batch until no devices are unregistering
Date: Wed, 18 Sep 2013 01:19:58 -0700
Message-ID: <871u4mh781.fsf@tw-ebiederman.twitter.com>
References: <e652a11e-b23d-4a83-aaac-00c469a416f1@email.android.com>
	<20130917.201515.1404443973169590392.davem@davemloft.net>
	<CA+HUmGgg3-0UNgfKS6Hpnczzi6PUeztk8TZ7p_97kcvtfMacJQ@mail.gmail.com>
	<20130917.235247.344101545141336143.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: fruggeri@aristanetworks.com, edumazet@google.com, jiri@resnulli.us,
	alexander.h.duyck@intel.com, amwang@redhat.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:59245 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751582Ab3IRIW3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 04:22:29 -0400
In-Reply-To: <20130917.235247.344101545141336143.davem@davemloft.net> (David
	Miller's message of "Tue, 17 Sep 2013 23:52:47 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Francesco Ruggeri <fruggeri@aristanetworks.com>
> Date: Tue, 17 Sep 2013 20:50:41 -0700

>> I am not sure that would work.
>> list_empty(&net_todo_list) does not guarantee that there are no
>> unregistering devices still in flight.
>> Another process may have copied net_todo_run into its local list, left
>> net_todo_list empty and still be in the middle of processing
>> unregistering devices (without the rtnl lock) when
>> default_device_exit_batch starts executing.
>
> Ok, now I understand.
>
> Eric B., when you get a chance can you resubmit your patch and perhaps
> elaborate on the situation in the commit message.

The code is on my computer at home so I won't be able to get back to
this until Sunday or Monday.  This should give Francesco time to verify
I really have closed the holes he is seeing.

> If I was confused I'm sure other people will be if they look into
> this in the future.

Agreed.  It is easy to get confused with this issue.  And I was in a
rush so I expect my wording could be improved.



There is still the other part of this issue that dev_close reorders
devices in default_device_exit_batch.

With that reordering we can get the call chain:
  netdev_run_todo
    call_netdevice_notifiers(NETDEV_UNREGISTER_FINAL,...)
      dst_dev_event
        dst_ifdown(..., unregister == 1)
          dst->dev = dev_net(dst->dev)->loopback_dev;
	  dev_hold(dst->dev);

With dev_net(dst->dev)->loopback_dev == NULL;

So my patch to split the close_list out of the unreg_list is also needed
(or something else to address that issue). 

Hopefully my exaspearation with dev_close_many didn't obscure what is
happening there.

Eric
