From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH] bonding: Do not try to send packets over dead link in
 TLB mode.
Date: Wed, 9 Jul 2014 15:27:10 +0200
Message-ID: <20140709132709.GA11974@redhat.com>
References: <1404868198-24839-1-git-send-email-maheshb@google.com>
 <20140709102441.GB1227@redhat.com>
 <53BD18A7.6090109@redhat.com>
 <20140709120437.GC1227@redhat.com>
 <1404911849.3515.28.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Nikolay Aleksandrov <nikolay@redhat.com>,
	Mahesh Bandewar <maheshb@google.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62931 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751268AbaGINaQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jul 2014 09:30:16 -0400
Content-Disposition: inline
In-Reply-To: <1404911849.3515.28.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 09, 2014 at 03:17:29PM +0200, Eric Dumazet wrote:
>On Wed, 2014-07-09 at 14:04 +0200, Veaceslav Falico wrote:
>> On Wed, Jul 09, 2014 at 12:25:43PM +0200, Nikolay Aleksandrov wrote:
>> >On 07/09/2014 12:24 PM, Veaceslav Falico wrote:
>> >> On Tue, Jul 08, 2014 at 06:09:58PM -0700, Mahesh Bandewar wrote:
>> ...snip...
>> >>> +    spin_lock(&bond_info->slave_arr_lock);
>> >>
>> >> I don't think you can re-enter bond_alb_handle_link_change(), as it's
>> >> protected either by rtnl or write-lock curr_active_slave.
>> >>
>> >Actually a very good catch :-)
>> >Maybe the allocation above should be done with GFP_ATOMIC.
>>
>> For the record - it's indeed always under rtnl, so ASSERT_RTNL() (from your
>> other email) is a good idea.
>
>Strange. I basically suggested the ASSERT_RTNL() to Mahesh few days ago
>and he tried this. But the assert triggered with miimon, so Mahesh added
>back the spinlock.

That's indeed strange... From the code:

2103                 if (!rtnl_trylock()) {
2104                         delay = 1;
2105                         should_notify_peers = false;
2106                         goto re_arm;
2107                 }
2108
2109                 bond_miimon_commit(bond);
2110
2111                 rtnl_unlock();  /* might sleep, hold no other locks */

And we can get there only through bond_miimon_commit(), as part of the
miimon.

Maybe you've hit the kmalloc(GFP_KERNEL) warning?
