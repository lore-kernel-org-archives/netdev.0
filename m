From: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Subject: RE: [E1000-devel] [PATCH 1/1] ixgbevf: avoid checking hang when
	performing hardware reset
Date: Mon, 18 Jul 2016 22:30:29 +0000
Message-ID: <F6FB0E698C9B3143BDF729DF2228664696ACAA19@ORSMSX116.amr.corp.intel.com>
References: <1468849489-8407-1-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "zyjzyj2000@gmail.com" <zyjzyj2000@gmail.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:57618 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751290AbcGRWab convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 18:30:31 -0400
In-Reply-To: <1468849489-8407-1-git-send-email-zyjzyj2000@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: zyjzyj2000@gmail.com [mailto:zyjzyj2000@gmail.com]
> Sent: Monday, July 18, 2016 6:45 AM
> To: e1000-devel@lists.sourceforge.net; netdev@vger.kernel.org; Kirsher,
> Jeffrey T <jeffrey.t.kirsher@intel.com>
> Subject: [E1000-devel] [PATCH 1/1] ixgbevf: avoid checking hang when
> performing hardware reset
> 
> From: Zhu Yanjun <zyjzyj2000@gmail.com>
> 
> When performing hardware reset, it is not necessary to check hang.
> Or else, the call trace will appear.
> 
> Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
> ---
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> index acc2401..d563d24 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> @@ -2792,9 +2792,14 @@ static void ixgbevf_reset_subtask(struct
> ixgbevf_adapter *adapter)  static void ixgbevf_check_hang_subtask(struct
> ixgbevf_adapter *adapter)  {
>  	struct ixgbe_hw *hw = &adapter->hw;
> +	struct ixgbe_mbx_info *mbx = &hw->mbx;
>  	u32 eics = 0;
>  	int i;
> 
> +	/* When performing hardware reset, unnecessary to check hang. */
> +	if (mbx->ops.check_for_rst(hw))
> +		return;
> +
>  	/* If we're down or resetting, just bail */
>  	if (test_bit(__IXGBEVF_DOWN, &adapter->state) ||
>  	    test_bit(__IXGBEVF_RESETTING, &adapter->state))
> --
> 2.7.4
> 
> 

My concern with this patch is that the check_for_rst does a read to clear on the RSTD and RSTI bits.  So reading it in the service task may mean we miss this transition in the mailbox protocol.  Likewise it is possible they may have already been cleared and you won't even catch the state your looking for.

-Don Skidmore <donald.c.skidmore@intel.com>
