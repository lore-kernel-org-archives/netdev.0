From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 6/9] ixgbe: fix X540 Completion timeout
Date: Fri, 07 Nov 2014 17:35:04 +0300
Message-ID: <545CD898.7060403@cogentembedded.com>
References: <1415350670-15333-1-git-send-email-jeffrey.t.kirsher@intel.com> <1415350670-15333-7-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:62629 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752555AbaKGOfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 09:35:07 -0500
Received: by mail-la0-f50.google.com with SMTP id hz20so4498488lab.37
        for <netdev@vger.kernel.org>; Fri, 07 Nov 2014 06:35:06 -0800 (PST)
In-Reply-To: <1415350670-15333-7-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11/7/2014 11:57 AM, Jeff Kirsher wrote:

> From: Don Skidmore <donald.c.skidmore@intel.com>

> On topologies including few levels of PCIe switching X540 can run into an
> unexpected completion error.  We get around this by waiting after enabling
> loopback a sufficient amount of time until Tx Data Fetch is sent.  We then
> poll the pending transaction bit to ensure we received the completion.  Only
> then do we go on to clear the buffers.

> Signed-of-by: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

> ---
>   drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 21 ++++++++++++++++++++-
>   1 file changed, 20 insertions(+), 1 deletion(-)

> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
> index b5f484b..e314b53 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
[...]
> @@ -3600,6 +3601,24 @@ void ixgbe_clear_tx_pending(struct ixgbe_hw *hw)
>   	hlreg0 = IXGBE_READ_REG(hw, IXGBE_HLREG0);
>   	IXGBE_WRITE_REG(hw, IXGBE_HLREG0, hlreg0 | IXGBE_HLREG0_LPBK);
>
> +	/* wait for a last completion before clearing buffers */
> +	IXGBE_WRITE_FLUSH(hw);
> +	usleep_range(3000, 6000);
> +
> +	/* Before proceeding, make sure that the PCIe block does not have
> +	 * transactions pending.
> +	 */
> +	poll = ixgbe_pcie_timeout_poll(hw);
> +	for (i = 0; i < poll; i++) {
> +		usleep_range(100, 200);
> +		value = ixgbe_read_pci_cfg_word(hw, IXGBE_PCI_DEVICE_STATUS);
> +		if (ixgbe_removed(hw->hw_addr))
> +			goto out;

    Why not just *break*?

> +		if (!(value & IXGBE_PCI_DEVICE_STATUS_TRANSACTION_PENDING))
> +			goto out;

    Likewise.

> +	}
> +
> +out:
>   	/* initiate cleaning flow for buffers in the PCIe transaction layer */
>   	gcr_ext = IXGBE_READ_REG(hw, IXGBE_GCR_EXT);
>   	IXGBE_WRITE_REG(hw, IXGBE_GCR_EXT,

WBR, Sergei
