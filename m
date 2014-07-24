From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [net-next 14/14] i40e: always print aqtx answer
Date: Thu, 24 Jul 2014 19:20:48 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E418ACFCB94@fmsmsx115.amr.corp.intel.com>
References: <1406207604-31653-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1406207604-31653-15-git-send-email-jeffrey.t.kirsher@intel.com>
 <1406227350.27221.63.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Joe Perches <joe@perches.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:26962 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934312AbaGXTVE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 15:21:04 -0400
In-Reply-To: <1406227350.27221.63.camel@joe-AO725>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Joe Perches [mailto:joe@perches.com]
> Sent: Thursday, July 24, 2014 11:43 AM
> 
> On Thu, 2014-07-24 at 06:13 -0700, Jeff Kirsher wrote:
> > From: Shannon Nelson <shannon.nelson@intel.com>
> >
> > Sometimes the AQTX answer comes back with no data, but we still want
> to print
> > the descriptor that got written back.
> 
> Maybe this does some reads from buffer beyond its size
> in i40e_debug_aq?  Is that always safe?

This is safe because we'll only print the descriptor in this case, not the buffer.  There's a check in i40e_debug_aq() for NULL or zero-length buffer.

sln

> 
> > diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
> b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
> []
> > @@ -889,11 +889,9 @@ i40e_status i40e_asq_send_command(struct i40e_hw
> *hw,
> >  		hw->aq.asq_last_status = (enum i40e_admin_queue_err)retval;
> >  	}
> >
> > -	if (le16_to_cpu(desc->datalen) == buff_size) {
> > -		i40e_debug(hw, I40E_DEBUG_AQ_MESSAGE,
> > -			   "AQTX: desc and buffer writeback:\n");
> > -		i40e_debug_aq(hw, I40E_DEBUG_AQ_COMMAND, (void *)desc, buff);
> > -	}
> > +	i40e_debug(hw, I40E_DEBUG_AQ_MESSAGE,
> > +		   "AQTX: desc and buffer writeback:\n");
> > +	i40e_debug_aq(hw, I40E_DEBUG_AQ_COMMAND, (void *)desc, buff);
> 
> 
> void i40e_debug_aq(struct i40e_hw *hw, enum i40e_debug_mask mask, void
> *desc,
> 		   void *buffer)
> {
> 	struct i40e_aq_desc *aq_desc = (struct i40e_aq_desc *)desc;
> 	u8 *aq_buffer = (u8 *)buffer;
> []
> 		for (i = 0; i < le16_to_cpu(aq_desc->datalen); i++) {
> 			data[((i % 16) / 4)] |=
> 				((u32)aq_buffer[i]) << (8 * (i % 4));
> 			if ((i % 16) == 15) {
> 				i40e_debug(hw, mask,
> 					   "\t0x%04X  %08X %08X %08X %08X\n",
> 					   i - 15, data[0], data[1], data[2],
> 					   data[3]);
> 				memset(data, 0, sizeof(data));
> 			}
> 
