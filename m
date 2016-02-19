From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: [PATCH v1 3/4] net: netcp: rename {get/set}pad_info to
 {get/set}_sw_data
Date: Fri, 19 Feb 2016 12:22:20 -0500
Message-ID: <56C74F4C.8060005@ti.com>
References: <1455824777-15571-1-git-send-email-m-karicheri2@ti.com>
 <1455824777-15571-3-git-send-email-m-karicheri2@ti.com>
 <3448016.8sm2r4rFcb@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:43099 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964982AbcBSRWZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2016 12:22:25 -0500
In-Reply-To: <3448016.8sm2r4rFcb@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/19/2016 09:37 AM, Arnd Bergmann wrote:
> On Thursday 18 February 2016 14:46:16 Murali Karicheri wrote:
>> Rename the helpers to match with the updated dma desc field sw_data.
>>
>> Cc: Wingman Kwok <w-kwok2@ti.com>
>> Cc: Mugunthan V N <mugunthanvnm@ti.com>
>> CC: Arnd Bergmann <arnd@arndb.de>
>> CC: Grygorii Strashko <grygorii.strashko@ti.com>
>> CC: David Laight <David.Laight@ACULAB.COM>
>> Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
>> ---
>>  v1 - new patch to based on discussion at
>> 	https://patchwork.ozlabs.org/patch/580860/
>>  drivers/net/ethernet/ti/netcp_core.c | 40 +++++++++++++++++++-----------------
>>  1 file changed, 21 insertions(+), 19 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
>> index 0b26e52..1d07cca 100644
>> --- a/drivers/net/ethernet/ti/netcp_core.c
>> +++ b/drivers/net/ethernet/ti/netcp_core.c
>> @@ -117,10 +117,11 @@ static void get_pkt_info(dma_addr_t *buff, u32 *buff_len, dma_addr_t *ndesc,
>>  	*ndesc = le32_to_cpu(desc->next_desc);
>>  }
>>  
>> -static void get_pad_info(u32 *pad0, u32 *pad1, struct knav_dma_desc *desc)
>> +static void get_sw_data(u32 *data0, u32 *data1, struct knav_dma_desc *desc)
>>  {
>> -	*pad0 = le32_to_cpu(desc->pad[0]);
>> -	*pad1 = le32_to_cpu(desc->pad[1]);
>> +	/* No Endian conversion needed as this data is untouched by hw */
>> +	*data0 = desc->sw_data[0];
>> +	*data1 = desc->sw_data[1];
>>  }
> 
> Actually this needs to be done together with patch 2, or you
> get a build failure if this one is not yet applied.
> 
>> @@ -1174,7 +1176,7 @@ static int netcp_tx_submit_skb(struct netcp_intf *netcp,
>>  	}
>>  
>>  	set_words(&tmp, 1, &desc->packet_info);
>> -	set_words((u32 *)&skb, 1, &desc->pad[0]);
>> +	set_words((u32 *)&skb, 1, &desc->sw_data[0]);
>>  
>>  	if (tx_pipe->flags & SWITCH_TO_PORT_IN_TAGINFO) {
>>  		tmp = tx_pipe->switch_to_port;
>>
> 
> This seems to introduce a bug, and should produce an "sparse" warning
> about a u32 being passed into a function expecting a __le32.
> 
The fix is to use set_sw_data() instead. I could reproduce the sparse
warning you mentioned and fixed using the above. Will be part of v2.

> The other bug I originally tried to address here is the way an indirect
> pointer is converted to a 'u32' pointer, which won't work on 64-bit
> architectures when pointers are wider than u32. Maybe at least put a
> comment here that this is a known deficiency.

Will add a comment here and other possible places we do similar things as
much as I can.

Murali

> 
> 	Arnd
> 


-- 
Murali Karicheri
Linux Kernel, Keystone
