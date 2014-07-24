From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 14/14] i40e: always print aqtx answer
Date: Thu, 24 Jul 2014 11:42:30 -0700
Message-ID: <1406227350.27221.63.camel@joe-AO725>
References: <1406207604-31653-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1406207604-31653-15-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Shannon Nelson <shannon.nelson@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0012.hostedemail.com ([216.40.44.12]:54932 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933349AbaGXSmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 14:42:35 -0400
In-Reply-To: <1406207604-31653-15-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-07-24 at 06:13 -0700, Jeff Kirsher wrote:
> From: Shannon Nelson <shannon.nelson@intel.com>
> 
> Sometimes the AQTX answer comes back with no data, but we still want to print
> the descriptor that got written back.

Maybe this does some reads from buffer beyond its size
in i40e_debug_aq?  Is that always safe?

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
[]
> @@ -889,11 +889,9 @@ i40e_status i40e_asq_send_command(struct i40e_hw *hw,
>  		hw->aq.asq_last_status = (enum i40e_admin_queue_err)retval;
>  	}
>  
> -	if (le16_to_cpu(desc->datalen) == buff_size) {
> -		i40e_debug(hw, I40E_DEBUG_AQ_MESSAGE,
> -			   "AQTX: desc and buffer writeback:\n");
> -		i40e_debug_aq(hw, I40E_DEBUG_AQ_COMMAND, (void *)desc, buff);
> -	}
> +	i40e_debug(hw, I40E_DEBUG_AQ_MESSAGE,
> +		   "AQTX: desc and buffer writeback:\n");
> +	i40e_debug_aq(hw, I40E_DEBUG_AQ_COMMAND, (void *)desc, buff);


void i40e_debug_aq(struct i40e_hw *hw, enum i40e_debug_mask mask, void *desc,
		   void *buffer)
{
	struct i40e_aq_desc *aq_desc = (struct i40e_aq_desc *)desc;
	u8 *aq_buffer = (u8 *)buffer;
[]
		for (i = 0; i < le16_to_cpu(aq_desc->datalen); i++) {
			data[((i % 16) / 4)] |=
				((u32)aq_buffer[i]) << (8 * (i % 4));
			if ((i % 16) == 15) {
				i40e_debug(hw, mask,
					   "\t0x%04X  %08X %08X %08X %08X\n",
					   i - 15, data[0], data[1], data[2],
					   data[3]);
				memset(data, 0, sizeof(data));
			}
