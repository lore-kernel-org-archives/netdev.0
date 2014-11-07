From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next 1/9] i40e: poll firmware slower
Date: Fri, 7 Nov 2014 09:40:08 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1C9EAE27@AcuExch.aculab.com>
References: <1415350670-15333-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1415350670-15333-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Kamil Krawczyk <kamil.krawczyk@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: 'Jeff Kirsher' <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:49944 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751229AbaKGJnH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 04:43:07 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 15630-06 for <netdev@vger.kernel.org>;
 Fri,  7 Nov 2014 09:42:55 +0000 (GMT)
In-Reply-To: <1415350670-15333-2-git-send-email-jeffrey.t.kirsher@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher
> From: Kamil Krawczyk <kamil.krawczyk@intel.com>
> 
> The code was polling the firmware tail register for completion every
> 10 microseconds, which is way faster than the firmware can respond.
> This changes the poll interval to 1ms, which reduces polling CPU
> utilization, and the number of times we loop.

Are you sure the code path is allowed to sleep?

> The maximum delay is still 100ms.

Actually it is now likely to be up to 200ms or more.
You could convert the maximum delay check to one that
looks at jiffies - but maybe it doesn't matter.

> Change-ID: I4bbfa6b66d802890baf8b4154061e55942b90958
> Signed-off-by: Kamil Krawczyk <kamil.krawczyk@intel.com>
> Acked-by: Shannon Nelson <shannon.nelson@intel.com>
> Tested-by: Jim Young <jamesx.m.young@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_adminq.c   | 5 ++---
>  drivers/net/ethernet/intel/i40e/i40e_adminq.h   | 2 +-
>  drivers/net/ethernet/intel/i40evf/i40e_adminq.c | 5 ++---
>  drivers/net/ethernet/intel/i40evf/i40e_adminq.h | 2 +-
>  4 files changed, 6 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
> b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
> index 72f5d25..057b7bf 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
> @@ -853,7 +853,6 @@ i40e_status i40e_asq_send_command(struct i40e_hw *hw,
>  	 */
>  	if (!details->async && !details->postpone) {
>  		u32 total_delay = 0;
> -		u32 delay_len = 10;
> 
>  		do {
>  			/* AQ designers suggest use of head for better
> @@ -862,8 +861,8 @@ i40e_status i40e_asq_send_command(struct i40e_hw *hw,
>  			if (i40e_asq_done(hw))
>  				break;
>  			/* ugh! delay while spin_lock */

The comment is not right any more.

> -			udelay(delay_len);
> -			total_delay += delay_len;
> +			usleep_range(1000, 2000);
> +			total_delay++;
>  		} while (total_delay < hw->aq.asq_cmd_timeout);
>  	}
> 
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.h
> b/drivers/net/ethernet/intel/i40e/i40e_adminq.h
> index ba38a89..df0bd09 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_adminq.h
> +++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.h
> @@ -141,7 +141,7 @@ static inline int i40e_aq_rc_to_posix(u16 aq_rc)
> 
>  /* general information */
>  #define I40E_AQ_LARGE_BUF	512
> -#define I40E_ASQ_CMD_TIMEOUT	100000  /* usecs */
> +#define I40E_ASQ_CMD_TIMEOUT	100  /* msecs */

It looks like this value is written to asq_cmd_timeout, that makes
be wonder whether anything else can change it - otherwise the compile
time constant would be used.
Changing the units has broken anything else that modifies the value.

> 
>  void i40e_fill_default_direct_cmd_desc(struct i40e_aq_desc *desc,
>  				       u16 opcode);
> diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
> b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
> index f206be9..25c846b 100644
> --- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
> +++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
> @@ -801,7 +801,6 @@ i40e_status i40evf_asq_send_command(struct i40e_hw *hw,
>  	 */
>  	if (!details->async && !details->postpone) {
>  		u32 total_delay = 0;
> -		u32 delay_len = 10;
> 
>  		do {
>  			/* AQ designers suggest use of head for better
> @@ -810,8 +809,8 @@ i40e_status i40evf_asq_send_command(struct i40e_hw *hw,
>  			if (i40evf_asq_done(hw))
>  				break;
>  			/* ugh! delay while spin_lock */
> -			udelay(delay_len);
> -			total_delay += delay_len;
> +			usleep_range(1000, 2000);
> +			total_delay++;
>  		} while (total_delay < hw->aq.asq_cmd_timeout);
>  	}
> 
> diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
> b/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
> index 91a5c5b..f40cfac 100644
> --- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
> +++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
> @@ -141,7 +141,7 @@ static inline int i40e_aq_rc_to_posix(u16 aq_rc)
> 
>  /* general information */
>  #define I40E_AQ_LARGE_BUF	512
> -#define I40E_ASQ_CMD_TIMEOUT	100000  /* usecs */
> +#define I40E_ASQ_CMD_TIMEOUT	100  /* msecs */
> 
>  void i40evf_fill_default_direct_cmd_desc(struct i40e_aq_desc *desc,
>  				       u16 opcode);
> --
> 1.9.3

Hmmm.... two drivers containing the same code....

	David
