From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Re: Error handling corner case found during audits
Date: Tue, 06 May 2008 12:40:27 -0400
Message-ID: <482089FB.3050104@garzik.org>
References: <20080429143119.4ef252d6@core> <4817668F.8050404@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34577 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755022AbYEFQkl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 12:40:41 -0400
In-Reply-To: <4817668F.8050404@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kok, Auke wrote:
> Alan Cox wrote:
>> Not sure what should happen here.
>>
>>
>> diff -u --new-file --recursive --exclude-from /usr/src/exclude linux.vanilla-2.6.25-mm1/drivers/net/e1000e/ethtool.c linux-2.6.25-mm1/drivers/net/e1000e/ethtool.c
>> --- linux.vanilla-2.6.25-mm1/drivers/net/e1000e/ethtool.c	2008-04-28 11:36:49.000000000 +0100
>> +++ linux-2.6.25-mm1/drivers/net/e1000e/ethtool.c	2008-04-18 16:42:41.000000000 +0100
>> @@ -494,6 +494,8 @@
>>  		for (i = 0; i < last_word - first_word + 1; i++) {
>>  			ret_val = e1000_read_nvm(hw, first_word + i, 1,
>>  						      &eeprom_buff[i]);
>> +			/* ERROR: This path leaves eeprom_buf containing
>> +			   old kernel bytes we then byteswap/return */
>>  			if (ret_val)
>>  				break;
>>  		}
> 
> either we fill the buffer with 0xff (the determined value for "empty eeprom"), or
> just kzalloc the buffer instead. This should be enough of a warning for the user
> that something is really wrong.
> 
> Auke
> 
> ---
> 
> e1000e: don't return half-read eeprom on error
> 
> On a read error, e1000e might have returned uninitialized block of eeprom data
> back to userspace. The convention is that 0xff is "empty", so mark the entire
> eeprom as empty in case of an error.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> 
> ---
> diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
> index b1b784a..8b04a42 100644
> --- a/drivers/net/e1000e/ethtool.c
> +++ b/drivers/net/e1000e/ethtool.c
> @@ -510,8 +510,12 @@ static int e1000_get_eeprom(struct net_device *netdev,
>  		for (i = 0; i < last_word - first_word + 1; i++) {
>  			ret_val = e1000_read_nvm(hw, first_word + i, 1,
>  						      &eeprom_buff[i]);
> -			if (ret_val)
> +			if (ret_val) {
> +				/* a read error occurred, throw away the
> +				 * result */
> +				memset(eeprom_buff, 0xff, sizeof(eeprom_buff));
>  				break;
> +			}
>  		}
>  	}

applied


