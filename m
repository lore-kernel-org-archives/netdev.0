From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch net-next v5 4/4] igb/igbvf: implement
 ndo_get_phys_port_id
Date: Fri, 26 Jul 2013 16:09:47 +0100
Message-ID: <1374851387.1666.9.camel@bwh-desktop.uk.level5networks.com>
References: <1374840596-5748-1-git-send-email-jiri@resnulli.us>
	 <1374840596-5748-5-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<stephen@networkplumber.org>, <Narendra_K@Dell.com>,
	<john.r.fastabend@intel.com>, <or.gerlitz@gmail.com>,
	<jeffrey.t.kirsher@intel.com>, <jesse.brandeburg@intel.com>,
	<bruce.w.allan@intel.com>, <carolyn.wyborny@intel.com>,
	<donald.c.skidmore@intel.com>, <gregory.v.rose@intel.com>,
	<peter.p.waskiewicz.jr@intel.com>, <alexander.h.duyck@intel.com>,
	<john.ronciak@intel.com>, <tushar.n.dave@intel.com>,
	<matthew.vick@intel.com>, <mitch.a.williams@intel.com>,
	<vyasevic@redhat.com>, <amwang@redhat.com>,
	<johannes@sipsolutions.net>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:27697 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757386Ab3GZPJz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 11:09:55 -0400
In-Reply-To: <1374840596-5748-5-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-07-26 at 14:09 +0200, Jiri Pirko wrote:
> igb driver generated random number which will identify physical port.
> This id is available via ndo_get_phys_port_id directly on igb netdev.
> Also, id is passed to igbvf using mailbox. After that, it is available via
> ndo_get_phys_port_id on igbvf netdev as well.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  drivers/net/ethernet/intel/igb/e1000_mbx.h |  1 +
>  drivers/net/ethernet/intel/igb/igb.h       |  2 ++
>  drivers/net/ethernet/intel/igb/igb_main.c  | 29 +++++++++++++++++++++-
>  drivers/net/ethernet/intel/igbvf/igbvf.h   |  3 +++
>  drivers/net/ethernet/intel/igbvf/mbx.h     |  1 +
>  drivers/net/ethernet/intel/igbvf/netdev.c  | 40 ++++++++++++++++++++++++++++++
>  drivers/net/ethernet/intel/igbvf/vf.c      | 34 +++++++++++++++++++++++++
>  drivers/net/ethernet/intel/igbvf/vf.h      |  1 +
>  8 files changed, 110 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/intel/igb/e1000_mbx.h b/drivers/net/ethernet/intel/igb/e1000_mbx.h
> index de9bba4..1788480 100644
> --- a/drivers/net/ethernet/intel/igb/e1000_mbx.h
> +++ b/drivers/net/ethernet/intel/igb/e1000_mbx.h
> @@ -64,6 +64,7 @@
>  #define E1000_VF_SET_LPE	0x05 /* VF requests to set VMOLR.LPE */
>  #define E1000_VF_SET_PROMISC	0x06 /*VF requests to clear VMOLR.ROPE/MPME*/
>  #define E1000_VF_SET_PROMISC_MULTICAST	(0x02 << E1000_VT_MSGINFO_SHIFT)
> +#define E1000_VF_GET_PHYS_PORT_ID 0x07 /* VF requests to get physical port id */
>  
>  #define E1000_PF_CONTROL_MSG	0x0100 /* PF control message */
>  
> diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
> index 15ea8dc..12a25b1 100644
> --- a/drivers/net/ethernet/intel/igb/igb.h
> +++ b/drivers/net/ethernet/intel/igb/igb.h
> @@ -444,6 +444,8 @@ struct igb_adapter {
>  	struct i2c_algo_bit_data i2c_algo;
>  	struct i2c_adapter i2c_adap;
>  	struct i2c_client *i2c_client;
> +
> +	u32 phys_port_id;
[...]

If we're going to pick these IDs at random then 32 bits is fine for a
locally unique ID but not so much for a universally unique ID.  If we
want universal uniqueness (which is what you've specified) then I think
at least 64 bits are required.  Unless there's some constraint on length
then I would suggest using uuid_be_gen() in at least the single-PF case.

I had assumed that a stable ID was useful, but maybe it doesn't matter
(and I can see that it might sometimes be desirable to hide that from a
VM).

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
