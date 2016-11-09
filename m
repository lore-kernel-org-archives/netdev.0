From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH net] igb: re-assign hw address pointer
 on reset after PCI error
Date: Wed, 9 Nov 2016 09:12:37 -0800
Message-ID: <CAKgT0UdYrO14ytSgPfa6KgC0OPaydqtd2-j2+AQFgJMgz69d+w@mail.gmail.com>
References: <1477944749-22822-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Netdev <netdev@vger.kernel.org>,
        "Fujinaka, Todd" <todd.fujinaka@intel.com>
To: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35114 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754528AbcKIRMi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 12:12:38 -0500
Received: by mail-it0-f66.google.com with SMTP id b123so17949116itb.2
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2016 09:12:38 -0800 (PST)
In-Reply-To: <1477944749-22822-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 31, 2016 at 1:12 PM, Guilherme G. Piccoli
<gpiccoli@linux.vnet.ibm.com> wrote:
> Whenever the igb driver detects the result of a read operation returns
> a value composed only by F's (like 0xFFFFFFFF), it will detach the
> net_device, clear the hw_addr pointer and warn to the user that adapter's
> link is lost - those steps happen on igb_rd32().
>
> In case a PCI error happens on Power architecture, there's a recovery
> mechanism called EEH, that will reset the PCI slot and call driver's
> handlers to reset the adapter and network functionality as well.
>
> We observed that once hw_addr is NULL after the error is detected on
> igb_rd32(), it's never assigned back, so in the process of resetting
> the network functionality we got a NULL pointer dereference in both
> igb_configure_tx_ring() and igb_configure_rx_ring(). In order to avoid
> such bug, we re-assign the hw_addr value in the beginning of the
> function igb_reset(), in case the hw_addr is NULL when we reach that
> path.
>
> Reported-by: Anthony H. Thai <ahthai@us.ibm.com>
> Reported-by: Harsha Thyagaraja <hathyaga@in.ibm.com>
> Signed-off-by: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c | 7 +++++++
>  1 file changed, 7 insertions(+)
>
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
> index edc9a6a..c19119c 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -1873,6 +1873,13 @@ void igb_reset(struct igb_adapter *adapter)
>         struct e1000_fc_info *fc = &hw->fc;
>         u32 pba, hwm;
>
> +       /* In case of PCI error, adapter might have lost its HW
> +        * address; if we reached this point after an error scenario,
> +        * we should re-assign the hw_addr based on the saved io_addr.
> +        */
> +       if (!hw->hw_addr)
> +               hw->hw_addr = adapter->io_addr;
> +
>         /* Repartition Pba for greater than 9k mtu
>          * To take effect CTRL.RST is required.
>          */

It seems like this would have the potential to get noisy pretty
quickly since every reset would retrigger this.

It might make more sense to move this line into igb_io_slot_reset and
igb_resume where the device would have gone through a reset of some
sort and then had the state of the device restored and the device
memory access was re-enabled via pci_enable_device_mem.  Also there is
no point in really doing the "if" since you should always be okay to
overwrite hw->hw_addr with adapter->io_addr.

Thanks.

- Alex
