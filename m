From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH 2/2] e1000e: Fix msi-x interrupt automask
Date: Wed, 28 Oct 2015 16:08:16 -0700
Message-ID: <56315560.1070705@gmail.com>
References: <1445560348-29872-1-git-send-email-bpoirier@suse.com>
 <1445560348-29872-3-git-send-email-bpoirier@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Benjamin Poirier <bpoirier@suse.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445560348-29872-3-git-send-email-bpoirier@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/22/2015 05:32 PM, Benjamin Poirier wrote:
> Since the introduction of 82574 support in e1000e, the driver has worked on
> the assumption that msi-x interrupt generation is automatically disabled
> after each irq. As it turns out, this is not the case. Currently, rx
> interrupts can fire multiple times before and during napi processing. This
> can be a problem for users because frames that arrive in a certain window
> (after adapter->clean_rx() but before napi_complete_done() has cleared
> NAPI_STATE_SCHED) generate an interrupt which does not lead to
> napi_schedule(). These frames sit in the rx queue until another frame
> arrives (a tcp retransmit for example).
>
> While the EIAC and CTRL_EXT registers are properly configured for irq
> automask, the modification of IAM in e1000_configure_msix() is what
> prevents automask from working as intended.
>
> This patch removes that erroneous write and fixes interrupt rearming for tx
> and "other" interrupts. Since e1000_msix_other() reads ICR, all interrupts
> must be rearmed in that function.
>
> Reported-by: Frank Steiner <steiner-reg@bio.ifi.lmu.de>
> Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
> ---
>   drivers/net/ethernet/intel/e1000e/netdev.c | 12 ++++++------
>   1 file changed, 6 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
> index a228167..8881256 100644
> --- a/drivers/net/ethernet/intel/e1000e/netdev.c
> +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
> @@ -1921,7 +1921,8 @@ static irqreturn_t e1000_msix_other(int __always_unused irq, void *data)
>
>   no_link_interrupt:
>   	if (!test_bit(__E1000_DOWN, &adapter->state))
> -		ew32(IMS, E1000_IMS_LSC | E1000_IMS_OTHER);
> +		ew32(IMS, adapter->eiac_mask | E1000_IMS_OTHER |
> +		     E1000_IMS_LSC);
>
>   	return IRQ_HANDLED;
>   }

I would argue your first patch probably didn't go far enough to remove 
dead code.  Specifically you should only ever get into this function if 
LSC is set.  There are no other causes that should trigger this.  As 
such you could probably remove the ICR read, and instead replace it with 
an ICR write of the LSC bit since OTHER is already cleared via EIAC.

> @@ -1940,6 +1941,9 @@ static irqreturn_t e1000_intr_msix_tx(int __always_unused irq, void *data)
>   		/* Ring was not completely cleaned, so fire another interrupt */
>   		ew32(ICS, tx_ring->ims_val);
>
> +	if (!test_bit(__E1000_DOWN, &adapter->state))
> +		ew32(IMS, E1000_IMS_TXQ0);
> +
>   	return IRQ_HANDLED;
>   }
>

I think what you need to set here is tx_ring->ims_val, not E1000_IMS_TXQ0.

> @@ -2027,11 +2031,7 @@ static void e1000_configure_msix(struct e1000_adapter *adapter)
>
>   	/* enable MSI-X PBA support */
>   	ctrl_ext = er32(CTRL_EXT);
> -	ctrl_ext |= E1000_CTRL_EXT_PBA_CLR;
> -
> -	/* Auto-Mask Other interrupts upon ICR read */
> -	ew32(IAM, ~E1000_EIAC_MASK_82574 | E1000_IMS_OTHER);
> -	ctrl_ext |= E1000_CTRL_EXT_EIAME;
> +	ctrl_ext |= E1000_CTRL_EXT_PBA_CLR | E1000_CTRL_EXT_EIAME;
>   	ew32(CTRL_EXT, ctrl_ext);
>   	e1e_flush();
>   }
>
