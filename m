From: David Daney <ddaney.cavm@gmail.com>
Subject: Re: [PATCH 1/2] netdev: octeon_mgmt: Correct tx IFG workaround.
Date: Wed, 19 Jun 2013 18:28:42 -0700
Message-ID: <51C25ACA.1070907@gmail.com>
References: <1371688820-4585-1-git-send-email-ddaney.cavm@gmail.com>  <1371688820-4585-2-git-send-email-ddaney.cavm@gmail.com> <1371690487.2146.5.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-mips@linux-mips.org, David Daney <david.daney@cavium.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:48733 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935191Ab3FTB2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 21:28:46 -0400
Received: by mail-pd0-f175.google.com with SMTP id 4so5661767pdd.20
        for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 18:28:45 -0700 (PDT)
In-Reply-To: <1371690487.2146.5.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/19/2013 06:08 PM, Joe Perches wrote:
> On Wed, 2013-06-19 at 17:40 -0700, David Daney wrote:
>> From: David Daney <david.daney@cavium.com>
>>
>> The previous fix was still too agressive to meet ieee specs.  Increase
>> to (14, 10).
> []
>> diff --git a/drivers/net/ethernet/octeon/octeon_mgmt.c b/drivers/net/ethernet/octeon/octeon_mgmt.c
> []
>> @@ -1141,10 +1141,13 @@ static int octeon_mgmt_open(struct net_device *netdev)
>>   		/* For compensation state to lock. */
>>   		ndelay(1040 * NS_PER_PHY_CLK);
>>
>> -		/* Some Ethernet switches cannot handle standard
>> -		 * Interframe Gap, increase to 16 bytes.
>> +		/* Default Interframe Gaps are too small.  Recommended
>> +		 * workaround is.
>> +		 *
>> +		 * AGL_GMX_TX_IFG[IFG1]=14
>> +		 * AGL_GMX_TX_IFG[IFG2]=10
>
> Why isn't the TX IFG just 96 bit times?

I don't have a full understanding of how the transistors are wired up on 
the chip, so I cannot accurately answer your question.  But I can say 
that after I empirically found the previous values to get the thing to 
work, the hardware designers independently found that the values 
supplied in this patch are required to achieve industry standard IFGs 
with this hardware.


>
> I'm also confused a bit here by the difference between the
> bsd implementation and yours.
>
> http://fxr.watson.org/fxr/source/contrib/octeon-sdk/cvmx-csr-typedefs.h?v=FREEBSD8
>
>   2628  * * Programming IFG1 and IFG2.
>   2629  *
>   2630  *   For half-duplex systems that require IEEE 802.3 compatibility, IFG1 must
>   2631  *   be in the range of 1-8, IFG2 must be in the range of 4-12, and the
>   2632  *   IFG1+IFG2 sum must be 12.
>   2633  *
>   2634  *   For full-duplex systems that require IEEE 802.3 compatibility, IFG1 must
>   2635  *   be in the range of 1-11, IFG2 must be in the range of 1-11, and the
>   2636  *   IFG1+IFG2 sum must be 12.
>   2637  *
>   2638  *   For all other systems, IFG1 and IFG2 can be any value in the range of
>   2639  *   1-15.  Allowing for a total possible IFG sum of 2-30.
>   2640  *
>   2641  * Additionally reset when both MIX0/1_CTL[RESET] are set to 1.
>

The advice in that particular comment in the BSD source code has been 
found to be incorrect, that is why we are overriding the default value 
of this register in the first place.

>>   		 */
>> -		cvmx_write_csr(CVMX_AGL_GMX_TX_IFG, 0x88);
>> +		cvmx_write_csr(CVMX_AGL_GMX_TX_IFG, 0xae);
>>   	}
>>
>>   	octeon_mgmt_rx_fill_ring(netdev);
>
> I don't have a datasheet.  Is one available?
>

I don't believe the datasheets are publicly available, but they do 
exist.  If you feel you have a compelling reason to have one, and don't 
mind jumping through hoops, you could contact me privately.

David Daney
