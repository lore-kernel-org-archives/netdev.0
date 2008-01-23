From: "Chatre, Reinette" <reinette.chatre@intel.com>
Subject: Re: [PATCH 1/5] iwlwifi: iwl3945 flush interrupt
	mask
Date: Wed, 23 Jan 2008 10:50:05 -0800
Message-ID: <D936D925018D154694D8A362EEB0892003780156@orsmsx416.amr.corp.intel.com>
References: <11998765342443-git-send-email-joonwpark81@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>,
	ipw3945-devel@lists.sourceforge.net
To: "Joonwoo Park" <joonwpark81@gmail.com>,
	"Zhu, Yi" <yi.zhu@intel.com>, <netdev@vger.kernel.org>
Return-path: <ipw3945-devel-bounces@lists.sourceforge.net>
Content-class: urn:content-classes:message
In-Reply-To: <11998765342443-git-send-email-joonwpark81@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ipw3945-devel>,
	<mailto:ipw3945-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=ipw3945-devel>
List-Post: <mailto:ipw3945-devel@lists.sourceforge.net>
List-Help: <mailto:ipw3945-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ipw3945-devel>,
	<mailto:ipw3945-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: ipw3945-devel-bounces@lists.sourceforge.net
Errors-To: ipw3945-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Joonwoo Park <joonwpark81@gmail.com> wrote:

> interrupt mask
> 
> After enabling/disabling interrupts flushing is required
> 

I have been looking at this patch and I would like to get some more
feedback from the experts in the group.

First off, the register used for the read in order to flush has to be
safe. We have to make sure that the register has no side effects. To do
this we could use CSR_INT_MASK, as in "#define iwl_flush32(iwl)
iwl_read32(iwl, CSR_INT_MASK)" This also enables us to flush at the end
of a sequence of writes instead of after every write.

Digging deeper it is not 100% clear to me when we should do flushing to
handle write posting. I understand that it should be done in time
sensitive code, but that could on a high level mean any write operation
in the driver. How should it be decided which writes to the device need
to be flushed? 

Patch is kept below fyi.

Reinette

> Signed-off-by: Joonwoo Park <joonwpark81@gmail.com> ---
> drivers/net/wireless/iwlwifi/iwl-io.h       |    2 ++
> drivers/net/wireless/iwlwifi/iwl3945-base.c |    6 ++++++
> 2 files changed, 8 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/wireless/iwlwifi/iwl-io.h
> b/drivers/net/wireless/iwlwifi/iwl-io.h
> index 8a8b96f..f2bc30e 100644
> --- a/drivers/net/wireless/iwlwifi/iwl-io.h
> +++ b/drivers/net/wireless/iwlwifi/iwl-io.h
> @@ -87,6 +87,8 @@ static inline u32 __iwl_read32(char *f, u32
> l, struct iwl_priv *iwl, u32 ofs)
> #define iwl_read32(p, o) _iwl_read32(p, o)
> #endif
> 
> +#define iwl_flush32(iwl, ofs) iwl_read32(iwl, ofs) +
> static inline int _iwl_poll_bit(struct iwl_priv *priv, u32 addr,
> 				u32 bits, u32 mask, int timeout)
> {
> diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c
> b/drivers/net/wireless/iwlwifi/iwl3945-base.c
> index 8ed898d..85f1112 100644
> --- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
> +++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
> @@ -4410,6 +4410,7 @@ static void iwl_enable_interrupts(struct
> 	iwl_priv *priv) IWL_DEBUG_ISR("Enabling interrupts\n");
> 	set_bit(STATUS_INT_ENABLED, &priv->status);
> 	iwl_write32(priv, CSR_INT_MASK, CSR_INI_SET_MASK);
> +	iwl_flush32(priv, CSR_INT_MASK);
> }
> 
> static inline void iwl_disable_interrupts(struct iwl_priv *priv)
> @@ -4418,11 +4419,15 @@ static inline void
> iwl_disable_interrupts(struct iwl_priv *priv)
> 
> 	/* disable interrupts from uCode/NIC to host */
> 	iwl_write32(priv, CSR_INT_MASK, 0x00000000);
> +	iwl_flush32(priv, CSR_INT_MASK);
> 
> 	/* acknowledge/clear/reset any interrupts still pending
> 	 * from uCode or flow handler (Rx/Tx DMA) */
> 	iwl_write32(priv, CSR_INT, 0xffffffff);
> +	iwl_flush32(priv, CSR_INT);
> 	iwl_write32(priv, CSR_FH_INT_STATUS, 0xffffffff);
> +	iwl_flush32(priv, CSR_FH_INT_STATUS);
> +
> 	IWL_DEBUG_ISR("Disabled interrupts\n");
> }
> 
> @@ -4840,6 +4845,7 @@ static irqreturn_t iwl_isr(int irq, void *data)
> 	 * If we *don't* have something, we'll re-enable before
> leaving here. */
> 	inta_mask = iwl_read32(priv, CSR_INT_MASK);  /* just
> for debug */
> 	iwl_write32(priv, CSR_INT_MASK, 0x00000000);
> +	iwl_flush32(priv, CSR_INT_MASK);
> 
> 	/* Discover which interrupts are active/pending */
> 	inta = iwl_read32(priv, CSR_INT);
> --
> 1.5.3.rc5
> 
> 
> ---------------------------------------------------------------
> ----------
> Check out the new SourceForge.net Marketplace.
> It's the best place to buy or sell services for
> just about anything Open Source.
> http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.ne
> t/marketplace _______________________________________________
> Ipw3945-devel mailing list
> Ipw3945-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/ipw3945-devel


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
