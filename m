From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net-next 1/3] dcbnl: adding DCBX engine capability
Date: Tue, 28 Dec 2010 16:05:56 -0800
Message-ID: <4D1A7B64.5000402@intel.com>
References: <1292959963.7142.130.camel@lb-tlvb-shmulik.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"eilong@broadcom.com" <eilong@broadcom.com>,
	"Liu, Lucy" <lucy.liu@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Shmulik Ravid <shmulikr@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:25779 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751980Ab0L2AF7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Dec 2010 19:05:59 -0500
In-Reply-To: <1292959963.7142.130.camel@lb-tlvb-shmulik.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/21/2010 11:32 AM, Shmulik Ravid wrote:
> Adding an optional DCBX capability and a pair for get-set routines for
> setting the device DCBX mode. The DCBX capability is a bit field of
> supported attributes. The user is expected to set the DCBX mode with a
> subset of the advertised attributes.
> 
> 
> Signed-off-by: Shmulik Ravid <shmulikr@broadcom.com>
> ---
>  include/linux/dcbnl.h |   17 +++++++++++++++++
>  include/net/dcbnl.h   |    2 ++
>  net/dcb/dcbnl.c       |   42 ++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 61 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/dcbnl.h b/include/linux/dcbnl.h
> index 8723491..974fd1e 100644
> --- a/include/linux/dcbnl.h
> +++ b/include/linux/dcbnl.h
> @@ -50,6 +50,8 @@ struct dcbmsg {
>   * @DCB_CMD_SBCN: get backward congestion notification configration.
>   * @DCB_CMD_GAPP: get application protocol configuration
>   * @DCB_CMD_SAPP: set application protocol configuration
> + * @DCB_CMD_GDCBX: get DCBX engine configuration
> + * @DCB_CMD_SDCBX: set DCBX engine configuration
>   */
>  enum dcbnl_commands {
>  	DCB_CMD_UNDEFINED,
> @@ -83,6 +85,9 @@ enum dcbnl_commands {
>  	DCB_CMD_GAPP,
>  	DCB_CMD_SAPP,
>  
> +	DCB_CMD_GDCBX,
> +	DCB_CMD_SDCBX,
> +
>  	__DCB_CMD_ENUM_MAX,
>  	DCB_CMD_MAX = __DCB_CMD_ENUM_MAX - 1,
>  };
> @@ -102,6 +107,7 @@ enum dcbnl_commands {
>   * @DCB_ATTR_CAP: DCB capabilities of the device (NLA_NESTED)
>   * @DCB_ATTR_NUMTCS: number of traffic classes supported (NLA_NESTED)
>   * @DCB_ATTR_BCN: backward congestion notification configuration (NLA_NESTED)
> + * @DCB_ATTR_DCBX: DCBX engine configuration in the device (NLA_U8)
>   */
>  enum dcbnl_attrs {
>  	DCB_ATTR_UNDEFINED,
> @@ -118,6 +124,7 @@ enum dcbnl_attrs {
>  	DCB_ATTR_NUMTCS,
>  	DCB_ATTR_BCN,
>  	DCB_ATTR_APP,
> +	DCB_ATTR_DCBX,
>  
>  	__DCB_ATTR_ENUM_MAX,
>  	DCB_ATTR_MAX = __DCB_ATTR_ENUM_MAX - 1,
> @@ -262,6 +269,8 @@ enum dcbnl_tc_attrs {
>   * @DCB_CAP_ATTR_GSP: (NLA_U8) device supports group strict priority
>   * @DCB_CAP_ATTR_BCN: (NLA_U8) device supports Backwards Congestion
>   *                             Notification
> + * @DCB_CAP_ATTR_DCBX: (NLA_U8) device supports DCBX engine
> + *
>   */
>  enum dcbnl_cap_attrs {
>  	DCB_CAP_ATTR_UNDEFINED,
> @@ -273,11 +282,19 @@ enum dcbnl_cap_attrs {
>  	DCB_CAP_ATTR_PFC_TCS,
>  	DCB_CAP_ATTR_GSP,
>  	DCB_CAP_ATTR_BCN,
> +	DCB_CAP_ATTR_DCBX,
>  
>  	__DCB_CAP_ATTR_ENUM_MAX,
>  	DCB_CAP_ATTR_MAX = __DCB_CAP_ATTR_ENUM_MAX - 1,
>  };
>  
> +/* DCBX capabilities */
> +#define DCB_CAP_DCBX_HOST	0x01 /* host based DCBX engine support */
> +#define DCB_CAP_DCBX_HW		0x02 /* HW DCBX engine support */
> +#define DCB_CAP_DCBX_VER_CEE	0x04 /* HW DCBX supports CEE protocol */
> +#define DCB_CAP_DCBX_VER_IEEE	0x08 /* HW DCBX supports IEEE protocol */
> +#define DCB_CAP_DCBX_STATIC	0x10 /* HW DCBX supports static config */
> +

I would like to use these bits for guests using a VF as well. The problem is multiple lldp agents advertising dcbx tlvs on the same link is not spec compliant. In the VF case there may or may not be a hardware lldp engine all the VF driver (ie ixgbevf) should need to know is that some other entity is managing the DCB attributes.

To reflect this I would propose changing DCB_CAP_DCBX_HW and the comments by removing "HW". The two ideas I had were DCB_CAP_DCBX_READONLY or DCB_CAP_DCBX_LLD_MANAGED. Admittedly a bit of a nitpick but its a bit confusing to set the DCBX_HW bit when there really is no HW engine in the 82599 adapter case.

Otherwise this all looks good to me. I was hoping someone would get around to this. Thanks a lot!

-- John.
