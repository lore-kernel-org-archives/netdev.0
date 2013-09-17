From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: Re: [CFT][PATCH] net: Delay default_device_exit_batch until no devices are unregistering
Date: Tue, 17 Sep 2013 16:41:37 -0700
Message-ID: <e652a11e-b23d-4a83-aaac-00c469a416f1@email.android.com>
References: <87six5kpu5.fsf@xmission.com> <CA+HUmGih9akzhpRrb_0WEapi4jGcuSV8qO==QeRWHoqnxzFyng@mail.gmail.com> <87mwncaz04.fsf_-_@xmission.com> <20130917.192158.941189471705765317.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: fruggeri@aristanetworks.com, edumazet@google.com, jiri@resnulli.us,
	alexander.h.duyck@intel.com, amwang@redhat.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:47004 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753371Ab3IQXl6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 19:41:58 -0400
In-Reply-To: <20130917.192158.941189471705765317.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
>From: ebiederm@xmission.com (Eric W. Biederman)
>Date: Mon, 16 Sep 2013 20:49:31 -0700
>
>>  /* Delayed registration/unregisteration */
>>  static LIST_HEAD(net_todo_list);
>> +static atomic_t netdev_unregistering = ATOMIC_INIT(0);
>> +static DECLARE_WAIT_QUEUE_HEAD(netdev_unregistering_wait);
>
>I think you don't need this atomic.
>
>Something like this should work and seems much simpler:
>
>1) Still use the netdev_unregistering_wait queue, that's fine.
>
>2) In netdev_run_todo(), unconditionally wake it up at the end of
>   the while() loop.
>
>3) In default_device_exit_batch() use the same retry logic but
>   your tests are on list_empty(&net_todo_list() rather than the
>   new atomic count.

List/count I don't much care but currently we don't have a list of all of the devices that are unregistering.

The problem with this is that netdev_run_todo moves all of the devices to a local list, so they are only visible from a list_head on the stack.  Which makes sense as we run this all in the context of rtnl_unlock.

>I think with this simplification I'm fine to apply this patch after
>it has been tested properly.

I wish we could make that simplication.

>Long term I'd like to see a per-namespace todo list, as seems to
>have been suggested and discussed already.

Eric
