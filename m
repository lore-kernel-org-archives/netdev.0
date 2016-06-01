From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH v2] qed: fix qed_fill_link() error handling
Date: Wed, 1 Jun 2016 13:36:38 +0000
Message-ID: <CO2PR11MB0088CD4139A272FEB3947EF897470@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1464623197-2084229-1-git-send-email-arnd@arndb.de>
 <8209894.K472MDjuEr@wuerfel>
 <CO2PR11MB00885CC1028BFEAD9CD85E8397470@CO2PR11MB0088.namprd11.prod.outlook.com>
 <11393820.LSE4DkNrNd@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Manish Chopra <manish.chopra@qlogic.com>,
	Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: Arnd Bergmann <arnd@arndb.de>, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <11393820.LSE4DkNrNd@wuerfel>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> gcc warns about qed_fill_link possibly accessing uninitialized data:
> 
> drivers/net/ethernet/qlogic/qed/qed_main.c: In function 'qed_fill_link':
> drivers/net/ethernet/qlogic/qed/qed_main.c:1170:35: error: 'link_caps' may be
> used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> While this warning is only about the specific case of CONFIG_QED_SRIOV being
> disabled but the function getting called for a VF (which should never happen),
> another possibility is that qed_mcp_get_*() fails without returning data.
> 
> This rearranges the code so we bail out in either of the two cases and print a
> warning instead of accessing the uninitialized data.
> 
> The qed_link_output structure remains untouched in this case, but all callers first
> call memset() on it, so at least we are not leaking stack data then.
> 
> As discussed, we also use a compile-time check to ensure we never use any of
> the VF code if CONFIG_QED_SRIOV is disabled, and the PCI device table is
> updated to no longer bind to virtual functions in that configuration.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> 
> ---
> On Wednesday, June 1, 2016 11:10:30 AM CEST Yuval Mintz wrote:
> > Actually, I think VF probe should gracefully fail in that case, as
> > qed_vf_hw_prepare() would simply return -EINVAL.
> > But I can honestly say I've never tested this flow, and I agree
> > there's no reason to allow VF probe in case we're not supporting SRIOV.
> 
> ok
> 
> > So I guess removing the PCI ID and defining IS_PF to be true in case
> > CONFIG_QED_SRIOV isn't set is the right way to go.
> > Do you want to revise your patch, or do you want me to do it?
> 
> I've done the patch below now, please either Ack or modify it the way you like
> and forward it.
> 
> Thanks,
> 
> 	Arnd

Perhaps it would have made more sense as a 2-part series; But I'm content with
the changes themselves. I'd let Dave decide whether he wants it split.

Thanks for taking the time fixing this.

Acked-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
