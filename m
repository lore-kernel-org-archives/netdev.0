From: David Miller <davem@davemloft.net>
Subject: Re: [CFT][PATCH] net: Delay default_device_exit_batch until no
 devices are unregistering
Date: Tue, 17 Sep 2013 19:21:58 -0400 (EDT)
Message-ID: <20130917.192158.941189471705765317.davem@davemloft.net>
References: <87six5kpu5.fsf@xmission.com>
	<CA+HUmGih9akzhpRrb_0WEapi4jGcuSV8qO==QeRWHoqnxzFyng@mail.gmail.com>
	<87mwncaz04.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fruggeri@aristanetworks.com, edumazet@google.com, jiri@resnulli.us,
	alexander.h.duyck@intel.com, amwang@redhat.com,
	netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43691 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753371Ab3IQXWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 19:22:00 -0400
In-Reply-To: <87mwncaz04.fsf_-_@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 16 Sep 2013 20:49:31 -0700

>  /* Delayed registration/unregisteration */
>  static LIST_HEAD(net_todo_list);
> +static atomic_t netdev_unregistering = ATOMIC_INIT(0);
> +static DECLARE_WAIT_QUEUE_HEAD(netdev_unregistering_wait);

I think you don't need this atomic.

Something like this should work and seems much simpler:

1) Still use the netdev_unregistering_wait queue, that's fine.

2) In netdev_run_todo(), unconditionally wake it up at the end of
   the while() loop.

3) In default_device_exit_batch() use the same retry logic but
   your tests are on list_empty(&net_todo_list() rather than the
   new atomic count.

I think with this simplification I'm fine to apply this patch after
it has been tested properly.

Long term I'd like to see a per-namespace todo list, as seems to
have been suggested and discussed already.

Thanks.
