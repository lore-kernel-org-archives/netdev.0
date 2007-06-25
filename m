From: Patrick McHardy <kaber@trash.net>
Subject: Re: [E1000 05/05]: Secondary unicast address support
Date: Mon, 25 Jun 2007 21:05:54 +0200
Message-ID: <46801212.6040002@trash.net>
References: <20070622122330.15215.47821.sendpatchset@localhost.localdomain> <20070622122338.15215.41966.sendpatchset@localhost.localdomain> <468010F9.6060406@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44767 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751343AbXFYTGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 15:06:41 -0400
In-Reply-To: <468010F9.6060406@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Patrick McHardy wrote:
>> @@ -2449,9 +2450,16 @@ e1000_set_multi(struct net_device *netdev)
>>          rctl |= (E1000_RCTL_UPE | E1000_RCTL_MPE);
>>      } else if (netdev->flags & IFF_ALLMULTI) {
>>          rctl |= E1000_RCTL_MPE;
>> -        rctl &= ~E1000_RCTL_UPE;
>>      } else {
>> -        rctl &= ~(E1000_RCTL_UPE | E1000_RCTL_MPE);
>> +        rctl &= ~E1000_RCTL_MPE;
>> +    }
>> +
>> +    uc_ptr = NULL;
>> +    if (netdev->uc_count > rar_entries - 1) {
>> +        rctl |= E1000_RCTL_UPE;
>> +    } else if (!(netdev->flags & IFF_PROMISC)) {
>> +        rctl &= ~E1000_RCTL_UPE;
>> +        uc_ptr = netdev->uc_list;
>>      }
>>  
>>      E1000_WRITE_REG(hw, RCTL, rctl);
>> @@ -2461,7 +2469,10 @@ e1000_set_multi(struct net_device *netdev)
>>      if (hw->mac_type == e1000_82542_rev2_0)
>>          e1000_enter_82542_rst(adapter);
>>  
>> -    /* load the first 14 multicast address into the exact filters 1-14
>> +    /* load the first 14 addresses into the exact filters 1-14. Unicast
>> +     * addresses take precedence to avoid disabling unicast filtering
>> +     * when possible.
>> +     *
>>       * RAR 0 is used for the station MAC adddress
>>       * if there are not 14 addresses, go ahead and clear the filters
>>       * -- with 82571 controllers only 0-13 entries are filled here
>> @@ -2469,8 +2480,11 @@ e1000_set_multi(struct net_device *netdev)
>>      mc_ptr = netdev->mc_list;
>>  
>>      for (i = 1; i < rar_entries; i++) {
>> -        if (mc_ptr) {
>> -            e1000_rar_set(hw, mc_ptr->dmi_addr, i);
>> +        if (uc_ptr) {
>> +            e1000_rar_set(hw, uc_ptr->da_addr, i);
>> +            uc_ptr = uc_ptr->next;
>> +        } else if (mc_ptr) {
>> +            e1000_rar_set(hw, mc_ptr->da_addr, i);
>>              mc_ptr = mc_ptr->next;
>>          } else {
>>              E1000_WRITE_REG_ARRAY(hw, RA, i << 1, 0);
>> @@ -2479,6 +2493,7 @@ e1000_set_multi(struct net_device *netdev)
>>              E1000_WRITE_FLUSH(hw);
>>          }
>>      }
>> +    WARN_ON(uc_ptr != NULL);
>>   
>
> noted. I'm (like a lot of people) on the road and still need to dig 
> into this deeper.

Please take your time, this was mainly an example and for testing.
If its OK I wouldn't object to you applying it of course :)

> I think it's OK for as far as I can see, except the WARN_ON, can't we 
> pre-check to see if we have enough room in the rar_entries first?


It does, the WARN_ON would only trigger if I made a mistake:

+    if (netdev->uc_count > rar_entries - 1) {


