From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH] s2io: add PCI error recovery support
Date: Mon, 5 Mar 2007 17:33:39 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7701481EE3@nekter>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Wen Xiong" <wenxiong@us.ibm.com>, <linux-kernel@vger.kernel.org>,
	<linux-pci@atrey.karlin.mff.cuni.cz>, <netdev@vger.kernel.org>,
	"Jeff Garzik" <jgarzik@pobox.com>, "Andrew Morton" <akpm@osdl.org>
To: "Linas Vepstas" <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:42450 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751625AbXCEWr6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2007 17:47:58 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Comments on this patch -

1. device_close_flag is unused and is not required.
> +static pci_ers_result_t s2io_io_error_detected(struct pci_dev *pdev,
> +                                               pci_channel_state_t
state)
> +{
		...
> +		do_s2io_card_down(sp, 0);
> +		sp->device_close_flag = TRUE;	/* Device is shut down.
*/

2. s2io_reset can fail to reset the device. Ideally s2io_reset should
return a failure in this case (return is void now) and in this case
could s2io_io_slot_reset() be called again, maybe try thrice, in total,
before failing to reset the slot?

Ram
> -----Original Message-----
> From: Linas Vepstas [mailto:linas@austin.ibm.com]
> Sent: Thursday, February 15, 2007 3:09 PM
> To: Ramkrishna Vepa; Raghavendra Koushik; Ananda Raju
> Cc: Wen Xiong; linux-kernel@vger.kernel.org; linux-
> pci@atrey.karlin.mff.cuni.cz; netdev@vger.kernel.org; Jeff Garzik;
Andrew
> Morton
> Subject: [PATCH] s2io: add PCI error recovery support
> 
> 
> Koushik, Raju,
> 
> Please review, comment, and if you find this acceptable,
> please forward upstream. This patch incorporates all of
> fixes resulting from the last set of discussions, circa
> November 2006.
> 
> --linas
> 
> This patch adds PCI error recovery support to the
> s2io 10-Gigabit ethernet device driver. Fourth revision,
> blocks interrupts and the watchdog. Adds a flag to
> s2io_down(), to avoid doing I/O when PCI bus is offline.
> 
> Tested, seems to work well.
> 
> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> Acked-by: Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>
> Cc: Raghavendra Koushik <raghavendra.koushik@neterion.com>
> Cc: Ananda Raju <Ananda.Raju@neterion.com>
> Cc: Wen Xiong <wenxiong@us.ibm.com>
> 
> ----
>  drivers/net/s2io.c |  116
> ++++++++++++++++++++++++++++++++++++++++++++++++++---
>  drivers/net/s2io.h |    5 ++
>  2 files changed, 116 insertions(+), 5 deletions(-)
> 
> Index: linux-2.6.20-git4/drivers/net/s2io.c
> ===================================================================
> --- linux-2.6.20-git4.orig/drivers/net/s2io.c	2007-02-15
> 15:39:35.000000000 -0600
> +++ linux-2.6.20-git4/drivers/net/s2io.c	2007-02-15
16:15:10.000000000 -
> 0600
> @@ -435,11 +435,18 @@ static struct pci_device_id s2io_tbl[] _
> 
>  MODULE_DEVICE_TABLE(pci, s2io_tbl);
> 
> +static struct pci_error_handlers s2io_err_handler = {
> +	.error_detected = s2io_io_error_detected,
> +	.slot_reset = s2io_io_slot_reset,
> +	.resume = s2io_io_resume,
> +};
> +
>  static struct pci_driver s2io_driver = {
>        .name = "S2IO",
>        .id_table = s2io_tbl,
>        .probe = s2io_init_nic,
>        .remove = __devexit_p(s2io_rem_nic),
> +      .err_handler = &s2io_err_handler,
>  };
> 
>  /* A simplifier macro used both by init and free shared_mem Fns(). */
> @@ -2577,6 +2584,9 @@ static void s2io_netpoll(struct net_devi
>  	u64 val64 = 0xFFFFFFFFFFFFFFFFULL;
>  	int i;
> 
> +	if (pci_channel_offline(nic->pdev))
> +		return;
> +
>  	disable_irq(dev->irq);
> 
>  	atomic_inc(&nic->isr_cnt);
> @@ -3079,6 +3089,8 @@ static void alarm_intr_handler(struct s2
>  	int i;
>  	if (atomic_read(&nic->card_state) == CARD_DOWN)
>  		return;
> +	if (pci_channel_offline(nic->pdev))
> +		return;
>  	nic->mac_control.stats_info->sw_stat.ring_full_cnt = 0;
>  	/* Handling the XPAK counters update */
>  	if(nic->mac_control.stats_info->xpak_stat.xpak_timer_count <
72000)
> {
> @@ -4117,6 +4129,10 @@ static irqreturn_t s2io_isr(int irq, voi
>  	struct mac_info *mac_control;
>  	struct config_param *config;
> 
> +	/* Pretend we handled any irq's from a disconnected card */
> +	if (pci_channel_offline(sp->pdev))
> +		return IRQ_NONE;
> +
>  	atomic_inc(&sp->isr_cnt);
>  	mac_control = &sp->mac_control;
>  	config = &sp->config;
> @@ -6188,7 +6204,7 @@ static void s2io_rem_isr(struct s2io_nic
>  	} while(cnt < 5);
>  }
> 
> -static void s2io_card_down(struct s2io_nic * sp)
> +static void do_s2io_card_down(struct s2io_nic * sp, int do_io)
>  {
>  	int cnt = 0;
>  	struct XENA_dev_config __iomem *bar0 = sp->bar0;
> @@ -6203,7 +6219,8 @@ static void s2io_card_down(struct s2io_n
>  	atomic_set(&sp->card_state, CARD_DOWN);
> 
>  	/* disable Tx and Rx traffic on the NIC */
> -	stop_nic(sp);
> +	if (do_io)
> +		stop_nic(sp);
> 
>  	s2io_rem_isr(sp);
> 
> @@ -6211,7 +6228,7 @@ static void s2io_card_down(struct s2io_n
>  	tasklet_kill(&sp->task);
> 
>  	/* Check if the device is Quiescent and then Reset the NIC */
> -	do {
> +	while(do_io) {
>  		/* As per the HW requirement we need to replenish the
>  		 * receive buffer to avoid the ring bump. Since there is
>  		 * no intention of processing the Rx frame at this
pointwe are
> @@ -6236,8 +6253,9 @@ static void s2io_card_down(struct s2io_n
>  				  (unsigned long long) val64);
>  			break;
>  		}
> -	} while (1);
> -	s2io_reset(sp);
> +	}
> +	if (do_io)
> +		s2io_reset(sp);
> 
>  	spin_lock_irqsave(&sp->tx_lock, flags);
>  	/* Free all Tx buffers */
> @@ -6252,6 +6270,11 @@ static void s2io_card_down(struct s2io_n
>  	clear_bit(0, &(sp->link_state));
>  }
> 
> +static void s2io_card_down(struct s2io_nic * sp)
> +{
> +	do_s2io_card_down(sp, 1);
> +}
> +
>  static int s2io_card_up(struct s2io_nic * sp)
>  {
>  	int i, ret = 0;
> @@ -7536,3 +7559,86 @@ static void lro_append_pkt(struct s2io_n
>  	sp->mac_control.stats_info->sw_stat.clubbed_frms_cnt++;
>  	return;
>  }
> +
> +/**
> + * s2io_io_error_detected - called when PCI error is detected
> + * @pdev: Pointer to PCI device
> + * @state: The current pci conneection state
> + *
> + * This function is called after a PCI bus error affecting
> + * this device has been detected.
> + */
> +static pci_ers_result_t s2io_io_error_detected(struct pci_dev *pdev,
> +                                               pci_channel_state_t
state)
> +{
> +	struct net_device *netdev = pci_get_drvdata(pdev);
> +	struct s2io_nic *sp = netdev->priv;
> +
> +	netif_device_detach(netdev);
> +
> +	if (netif_running(netdev)) {
> +		/* Bring down the card, while avoiding PCI I/O */
> +		do_s2io_card_down(sp, 0);
> +		sp->device_close_flag = TRUE;	/* Device is shut down.
*/
> +	}
> +	pci_disable_device(pdev);
> +
> +	return PCI_ERS_RESULT_NEED_RESET;
> +}
> +
> +/**
> + * s2io_io_slot_reset - called after the pci bus has been reset.
> + * @pdev: Pointer to PCI device
> + *
> + * Restart the card from scratch, as if from a cold-boot.
> + * At this point, the card has exprienced a hard reset,
> + * followed by fixups by BIOS, and has its config space
> + * set up identically to what it was at cold boot.
> + */
> +static pci_ers_result_t s2io_io_slot_reset(struct pci_dev *pdev)
> +{
> +	struct net_device *netdev = pci_get_drvdata(pdev);
> +	struct s2io_nic *sp = netdev->priv;
> +
> +	if (pci_enable_device(pdev)) {
> +		printk(KERN_ERR "s2io: "
> +		       "Cannot re-enable PCI device after reset.\n");
> +		return PCI_ERS_RESULT_DISCONNECT;
> +	}
> +
> +	pci_set_master(pdev);
> +	s2io_reset(sp);
> +
> +	return PCI_ERS_RESULT_RECOVERED;
> +}
> +
> +/**
> + * s2io_io_resume - called when traffic can start flowing again.
> + * @pdev: Pointer to PCI device
> + *
> + * This callback is called when the error recovery driver tells
> + * us that its OK to resume normal operation.
> + */
> +static void s2io_io_resume(struct pci_dev *pdev)
> +{
> +	struct net_device *netdev = pci_get_drvdata(pdev);
> +	struct s2io_nic *sp = netdev->priv;
> +
> +	if (netif_running(netdev)) {
> +		if (s2io_card_up(sp)) {
> +			printk(KERN_ERR "s2io: "
> +			       "Can't bring device back up after
reset.\n");
> +			return;
> +		}
> +
> +		if (s2io_set_mac_addr(netdev, netdev->dev_addr) ==
FAILURE) {
> +			s2io_card_down(sp);
> +			printk(KERN_ERR "s2io: "
> +			       "Can't resetore mac addr after
reset.\n");
> +			return;
> +		}
> +	}
> +
> +	netif_device_attach(netdev);
> +	netif_wake_queue(netdev);
> +}
> Index: linux-2.6.20-git4/drivers/net/s2io.h
> ===================================================================
> --- linux-2.6.20-git4.orig/drivers/net/s2io.h	2007-02-15
> 15:39:35.000000000 -0600
> +++ linux-2.6.20-git4/drivers/net/s2io.h	2007-02-15
16:59:40.000000000 -
> 0600
> @@ -1020,6 +1020,11 @@ static void update_L3L4_header(struct s2
>  static void lro_append_pkt(struct s2io_nic *sp, struct lro *lro,
>  			   struct sk_buff *skb, u32 tcp_len);
> 
> +static pci_ers_result_t s2io_io_error_detected(struct pci_dev *pdev,
> +			                      pci_channel_state_t
state);
> +static pci_ers_result_t s2io_io_slot_reset(struct pci_dev *pdev);
> +static void s2io_io_resume(struct pci_dev *pdev);
> +
>  #define s2io_tcp_mss(skb) skb_shinfo(skb)->gso_size
>  #define s2io_udp_mss(skb) skb_shinfo(skb)->gso_size
>  #define s2io_offload_type(skb) skb_shinfo(skb)->gso_type
