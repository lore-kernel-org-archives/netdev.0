From: Stefan Assmann <sassmann@kpanic.de>
Subject: Re: [PATCH net-next] igbvf: do not force carrier off in igbvf_msix_other()
Date: Fri, 09 Aug 2013 09:02:46 +0200
Message-ID: <52049416.2030201@kpanic.de>
References: <1375963002-1624-1-git-send-email-sassmann@kpanic.de> <5203C2C3.3030205@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	davem@davemloft.net, carolyn.wyborny@intel.com,
	jeffrey.t.kirsher@intel.com, gregory.v.rose@intel.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.xlhost.de ([213.202.242.118]:36097 "EHLO app1b.xlhost.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S967344Ab3HIHK4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Aug 2013 03:10:56 -0400
In-Reply-To: <5203C2C3.3030205@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08.08.2013 18:09, Alexander Duyck wrote:
> On 08/08/2013 04:56 AM, Stefan Assmann wrote:
>> Currently carrier is forced off in igbvf_msix_other(). This seems
>> unnecessary and causes multiple calls to igbvf_watchdog_task(), resulting
>> in multiple link up messages when calling dhclient for example.
>> [  111.818106] igbvf 0000:00:04.0: Link is Up 1000 Mbps Full Duplex
>> [  111.819347] IPv6: ADDRCONF(NETDEV_UP): eth5: link is not ready
>> [  111.820509] IPv6: ADDRCONF(NETDEV_CHANGE): eth5: link becomes ready
>> [  111.822983] igbvf 0000:00:04.0: Link is Up 1000 Mbps Full Duplex
>> [  115.152421] igbvf 0000:00:04.0: Link is Up 1000 Mbps Full Duplex
>> compared to
>> [ 1040.422161] igbvf 0000:00:04.0: Link is Up 1000 Mbps Full Duplex
>> [ 1040.423447] IPv6: ADDRCONF(NETDEV_UP): eth5: link is not ready
>> [ 1040.424622] IPv6: ADDRCONF(NETDEV_CHANGE): eth5: link becomes ready
>> when this patch is applied.
>>
>> Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
>> ---
>>  drivers/net/ethernet/intel/igbvf/netdev.c | 2 --
>>  1 file changed, 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
>> index 93eb7ee..f041586 100644
>> --- a/drivers/net/ethernet/intel/igbvf/netdev.c
>> +++ b/drivers/net/ethernet/intel/igbvf/netdev.c
>> @@ -876,8 +876,6 @@ static irqreturn_t igbvf_msix_other(int irq, void *data)
>>  
>>  	adapter->int_counter1++;
>>  
>> -	netif_carrier_off(netdev);
>> -	hw->mac.get_link_status = 1;
>>  	if (!test_bit(__IGBVF_DOWN, &adapter->state))
>>  		mod_timer(&adapter->watchdog_timer, jiffies + 1);
>>  
> 
> While this patch helps to squelch the messages, did you test to see what
> happens if for example you bring the PF interface down while the VFs are
> trying to function?  The reason for switching the carrier off is because
> most interrupts on the mailbox indicate that something has been changed
> in the underlying interface.  If for example the PF is about to disable
> the interfaces it should be triggering this interrupt.  Otherwise you
> are just setting up the VF to dump out a number of Tx hang and watchdog
> messages.

Yes, I downed the PF while the VF is up, also tried unloading/reloading
igb. I didn't see any unwanted behaviour while doing this but I'd sure
appreciate it if you could run this through Intel testing.

The reason why this shouldn't be an issue is that on PF down link
will be lost and the igbvf watchdog calls netif_carrier_off().

Thanks!

  Stefan
