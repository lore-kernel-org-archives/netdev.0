From: "Neftin, Sasha" <sasha.neftin@intel.com>
Subject: Re: [net-next 6/9] e1000e: fix buffer overrun while the I219 is
 processing DMA transactions
Date: Mon, 16 Oct 2017 13:24:15 +0300
Message-ID: <b7d05918-8480-b8bf-fe1c-f9b6395e8293@intel.com>
References: <20171010172139.77914-1-jeffrey.t.kirsher@intel.com>
 <20171010172139.77914-7-jeffrey.t.kirsher@intel.com>
 <063D6719AE5E284EB5DD2968C1650D6DD0090E17@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>
To: David Laight <David.Laight@ACULAB.COM>,
        'Jeff Kirsher' <jeffrey.t.kirsher@intel.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:2172 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751410AbdJPKYT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Oct 2017 06:24:19 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD0090E17@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/11/2017 12:07, David Laight wrote:
> From: Jeff Kirsher
>> Sent: 10 October 2017 18:22
>> Intel 100/200 Series Chipset platforms reduced the round-trip
>> latency for the LAN Controller DMA accesses, causing in some high
>> performance cases a buffer overrun while the I219 LAN Connected
>> Device is processing the DMA transactions. I219LM and I219V devices
>> can fall into unrecovered Tx hang under very stressfully UDP traffic
>> and multiple reconnection of Ethernet cable. This Tx hang of the LAN
>> Controller is only recovered if the system is rebooted. Slightly slow
>> down DMA access by reducing the number of outstanding requests.
>> This workaround could have an impact on TCP traffic performance
>> on the platform. Disabling TSO eliminates performance loss for TCP
>> traffic without a noticeable impact on CPU performance.
>>
>> Please, refer to I218/I219 specification update:
>> https://www.intel.com/content/www/us/en/embedded/products/networking/
>> ethernet-connection-i218-family-documentation.html
>>
>> Signed-off-by: Sasha Neftin <sasha.neftin@intel.com>
>> Reviewed-by: Dima Ruinskiy <dima.ruinskiy@intel.com>
>> Reviewed-by: Raanan Avargil <raanan.avargil@intel.com>
>> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> ---
>>   drivers/net/ethernet/intel/e1000e/netdev.c | 8 +++++---
>>   1 file changed, 5 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
>> index ee9de3500331..14b096f3d1da 100644
>> --- a/drivers/net/ethernet/intel/e1000e/netdev.c
>> +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
>> @@ -3021,8 +3021,8 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
>>
>>   	hw->mac.ops.config_collision_dist(hw);
>>
>> -	/* SPT and CNP Si errata workaround to avoid data corruption */
>> -	if (hw->mac.type >= e1000_pch_spt) {
>> +	/* SPT and KBL Si errata workaround to avoid data corruption */
>> +	if (hw->mac.type == e1000_pch_spt) {
>>   		u32 reg_val;
>>
>>   		reg_val = er32(IOSFPC);
>> @@ -3030,7 +3030,9 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
>>   		ew32(IOSFPC, reg_val);
>>
>>   		reg_val = er32(TARC(0));
>> -		reg_val |= E1000_TARC0_CB_MULTIQ_3_REQ;
>> +		/* SPT and KBL Si errata workaround to avoid Tx hang */
>> +		reg_val &= ~BIT(28);
>> +		reg_val |= BIT(29);
> Shouldn't some more of the commit message about what this is doing
> be in the comment?
There is provided link on specification update: 
https://www.intel.com/content/dam/www/public/us/en/documents/specification-updates/i218-i219-ethernet-connection-spec-update.pdf?asset=9561. 
This is Intel's public edition.
> And shouldn't the 28 and 28 be named constants?
(28 and 29) you can easy understand from the code that value has been 
changed from 3 to 2. There is no point add flags here I thought.
>
>>   		ew32(TARC(0), reg_val);
> 	David
>
Thanks,

Sasha
