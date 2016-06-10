From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 4/7] ixgbe: protect vxlan_get_rx_port in
 ixgbe_service_task with rtnl_lock
Date: Fri, 10 Jun 2016 14:33:57 -0700
Message-ID: <CAKgT0UfHEDOu_qPwUX9Jc087JGGWgk9K8JKFDY-AGA-kZ=p71g@mail.gmail.com>
References: <1461007188-1603-1-git-send-email-hannes@stressinduktion.org>
 <1461007188-1603-5-git-send-email-hannes@stressinduktion.org> <1465593442.7945.68.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:32907 "EHLO
	mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752016AbcFJVd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 17:33:58 -0400
Received: by mail-it0-f67.google.com with SMTP id i6so848751ith.0
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2016 14:33:58 -0700 (PDT)
In-Reply-To: <1465593442.7945.68.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 10, 2016 at 2:17 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2016-04-18 at 21:19 +0200, Hannes Frederic Sowa wrote:
>> vxlan_get_rx_port requires rtnl_lock to be held.
>>
>> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
>> Cc: Shannon Nelson <shannon.nelson@intel.com>
>> Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
>> Cc: Don Skidmore <donald.c.skidmore@intel.com>
>> Cc: Bruce Allan <bruce.w.allan@intel.com>
>> Cc: John Ronciak <john.ronciak@intel.com>
>> Cc: Mitch Williams <mitch.a.williams@intel.com>
>> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> ---
>>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> index 2976df77bf14f5..b2f2cf40f06a87 100644
>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> @@ -7192,10 +7192,12 @@ static void ixgbe_service_task(struct work_struct *work)
>>               return;
>>       }
>>  #ifdef CONFIG_IXGBE_VXLAN
>> +     rtnl_lock();
>>       if (adapter->flags2 & IXGBE_FLAG2_VXLAN_REREG_NEEDED) {
>>               adapter->flags2 &= ~IXGBE_FLAG2_VXLAN_REREG_NEEDED;
>>               vxlan_get_rx_port(adapter->netdev);
>>       }
>> +     rtnl_unlock();
>>  #endif /* CONFIG_IXGBE_VXLAN */
>>       ixgbe_reset_subtask(adapter);
>>       ixgbe_phy_interrupt_subtask(adapter);
>
> Although there might be a deadlock with a concurrent
> cancel_work_sync(&adapter->service_task);  from ixgbe_remove()

I don't think we are holding the rtnl_lock when that is called.  The
ixgbe_remove function is a PCI function.  The ixgbe_close routine is
the one called with the rtnl_lock held.

- Alex
