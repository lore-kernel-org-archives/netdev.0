From: Ethan Zhao <ethan.kernel@gmail.com>
Subject: Re: [PATCH] i40e: don't enable and init FCOE by default when do PF reset
Date: Tue, 13 Jan 2015 10:56:28 +0800
Message-ID: <CABawtvN_afL4B=fwtRJF_YJpe7tv6yf-OHJipWkGd-AiAjtckg@mail.gmail.com>
References: <1420821466-5747-1-git-send-email-ethan.zhao@oracle.com>
	<D38E8E86660E514AB505863C19C9287C741097AF@ORSMSX102.amr.corp.intel.com>
	<933BEC2E04D6A5458F4B0239FB547F9A34CC3608@fmsmsx118.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: "Ronciak, John" <john.ronciak@intel.com>,
	Ethan Zhao <ethan.zhao@oracle.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"Parikh, Neerav" <neerav.parikh@intel.com>,
	Linux NICS <Linux-nics@isotope.jf.intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"brian.maly@oracle.com" <brian.maly@oracle.com>
To: "Dev, Vasu" <vasu.dev@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <933BEC2E04D6A5458F4B0239FB547F9A34CC3608@fmsmsx118.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vasu,

On Sat, Jan 10, 2015 at 2:18 AM, Dev, Vasu <vasu.dev@intel.com> wrote:
>> -----Original Message-----
>> From: Ronciak, John
>> Sent: Friday, January 09, 2015 8:42 AM
>> To: Ethan Zhao; Kirsher, Jeffrey T; Brandeburg, Jesse; Allan, Bruce W;
>> Wyborny, Carolyn; Skidmore, Donald C; Rose, Gregory V; Vick, Matthew;
>> Williams, Mitch A; Dev, Vasu; Parikh, Neerav
>> Cc: Linux NICS; e1000-devel@lists.sourceforge.net; netdev@vger.kernel.org;
>> linux-kernel@vger.kernel.org; ethan.kernel@gmail.com;
>> brian.maly@oracle.com
>> Subject: RE: [PATCH] i40e: don't enable and init FCOE by default when do PF
>> reset
>>
>> Adding Vasu and Neerav
>>
>> Cheers,
>> John
>>
>> > -----Original Message-----
>> > From: Ethan Zhao [mailto:ethan.zhao@oracle.com]
>> > Sent: Friday, January 9, 2015 8:38 AM
>> > To: Kirsher, Jeffrey T; Brandeburg, Jesse; Allan, Bruce W; Wyborny,
>> > Carolyn; Skidmore, Donald C; Rose, Gregory V; Vick, Matthew; Ronciak,
>> > John; Williams, Mitch A
>> > Cc: Linux NICS; e1000-devel@lists.sourceforge.net;
>> > netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
>> > ethan.kernel@gmail.com; brian.maly@oracle.com; Ethan Zhao
>> > Subject: [PATCH] i40e: don't enable and init FCOE by default when do
>> > PF reset
>> >
>> > While do PF reset with function i40e_reset_and_rebuild(), it will call
>> > i40e_init_pf_fcoe() by default if FCOE is defined, thus if the PF is
>> > resetted, FCOE will be enabled whatever it was - enabled or not.
>> >
>> > Such bug might be hit when PF resumes from suspend, run diagnostic
>> > test with ethtool, setup VLAN etc.
>> >
>> > Passed building with v3.19-rc3.
>> >
>> > Signed-off-by: Ethan Zhao <ethan.zhao@oracle.com>
>> > ---
>> >  drivers/net/ethernet/intel/i40e/i40e_main.c | 9 ++++++---
>> >  1 file changed, 6 insertions(+), 3 deletions(-)
>> >
>> > diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c
>> > b/drivers/net/ethernet/intel/i40e/i40e_main.c
>> > index a5f2660..a2572cc 100644
>> > --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
>> > +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
>> > @@ -6180,9 +6180,12 @@ static void i40e_reset_and_rebuild(struct
>> > i40e_pf *pf, bool reinit)
>> >     }
>> >  #endif /* CONFIG_I40E_DCB */
>> >  #ifdef I40E_FCOE
>> > -   ret = i40e_init_pf_fcoe(pf);
>> > -   if (ret)
>> > -           dev_info(&pf->pdev->dev, "init_pf_fcoe failed: %d\n", ret);
>> > +   if (pf->flags & I40E_FLAG_FCOE_ENABLED) {
>> > +           ret = i40e_init_pf_fcoe(pf);
>
> Calling i40e_init_pf_fcoe() here conflicts with its I40E_FLAG_FCOE_ENABLED pre-condition since I40E_FLAG_FCOE_ENABLED is set by very same i40e_init_pf_fcoe(), in turn i40e_init_pf_fcoe() will never get called.

I don't think so,  here ,i40e_reset_and_rebuild()  is not the only and
the first place that  i40e_init_pf_fcoe() is called,
see i40e_probe(), that is the first chance.

i40e_probe()
-->i40e_sw_init()
     -->i40e_init_pf_fcoe()

And the I40E_FLAG_FCOE_ENABLED is possible be set by
i40e_fcoe_enable() or i40e_fcoe_disable() interface before the reset
action is to be done.

BTW, the reason I post this patch is that we hit a bug, after setup
vlan, the PF is enabled to FCOE.

>
> Jeff Kirsher should be getting out a patch queued by me which adds I40E_FCoE Kbuild option, in that FCoE is disabled by default and  user could enable FCoE only if needed, that patch would do same of skipping i40e_init_pf_fcoe() whether FCoE capability in device enabled or not in default config.
>

The following patch will not fix the above issue -- configuration of
PF will be changed via reset.
How about the FCOE is configured and disabled by  i40e_fcoe_disable()
, then reset happens ?

> From patchwork Wed Oct  2 23:26:08 2013
> Content-Type: text/plain; charset="utf-8"
> MIME-Version: 1.0
> Content-Transfer-Encoding: 7bit
> Subject: [net] i40e: adds FCoE configure option
> Date: Thu, 03 Oct 2013 07:26:08 -0000
> From: Vasu Dev <vasu.dev@intel.com>
> X-Patchwork-Id: 11797
>
> Adds FCoE config option I40E_FCOE, so that FCoE can be enabled
> as needed but otherwise have it disabled by default.
>
> This also eliminate multiple FCoE config checks, instead now just
> one config check for CONFIG_I40E_FCOE.
>
> The I40E FCoE was added with 3.17 kernel and therefore this patch
> shall be applied to stable 3.17 kernel also.
>
> CC: <stable@vger.kernel.org>
> Signed-off-by: Vasu Dev <vasu.dev@intel.com>
> Tested-by: Jim Young <jamesx.m.young@intel.com>
>
> ---
> drivers/net/ethernet/intel/Kconfig           |   11 +++++++++++
>  drivers/net/ethernet/intel/i40e/Makefile     |    2 +-
>  drivers/net/ethernet/intel/i40e/i40e_osdep.h |    4 ++--
>  3 files changed, 14 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
> index 5b8300a..4d61ef5 100644
> --- a/drivers/net/ethernet/intel/Kconfig
> +++ b/drivers/net/ethernet/intel/Kconfig
> @@ -281,6 +281,17 @@ config I40E_DCB
>
>           If unsure, say N.
>
> +config I40E_FCOE
> +       bool "Fibre Channel over Ethernet (FCoE)"
> +       default n
> +       depends on I40E && DCB && FCOE
> +       ---help---
> +         Say Y here if you want to use Fibre Channel over Ethernet (FCoE)
> +         in the driver. This will create new netdev for exclusive FCoE
> +         use with XL710 FCoE offloads enabled.
> +
> +         If unsure, say N.
> +
>  config I40EVF
>         tristate "Intel(R) XL710 X710 Virtual Function Ethernet support"
>         depends on PCI_MSI
> diff --git a/drivers/net/ethernet/intel/i40e/Makefile b/drivers/net/ethernet/intel/i40e/Makefile
> index 4b94ddb..c405819 100644
> --- a/drivers/net/ethernet/intel/i40e/Makefile
> +++ b/drivers/net/ethernet/intel/i40e/Makefile
> @@ -44,4 +44,4 @@ i40e-objs := i40e_main.o \
>         i40e_virtchnl_pf.o
>
>  i40e-$(CONFIG_I40E_DCB) += i40e_dcb.o i40e_dcb_nl.o
> -i40e-$(CONFIG_FCOE:m=y) += i40e_fcoe.o
> +i40e-$(CONFIG_I40E_FCOE) += i40e_fcoe.o
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_osdep.h b/drivers/net/ethernet/intel/i40e/i40e_osdep.h
> index 045b5c4..ad802dd 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_osdep.h
> +++ b/drivers/net/ethernet/intel/i40e/i40e_osdep.h
> @@ -78,7 +78,7 @@ do {                                                            \
>  } while (0)
>
>  typedef enum i40e_status_code i40e_status;
> -#if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
> +#ifdef CONFIG_I40E_FCOE
>  #define I40E_FCOE
> -#endif /* CONFIG_FCOE or CONFIG_FCOE_MODULE */
> +#endif
>  #endif /* _I40E_OSDEP_H_ */
>
>> > +           if (ret)
>> > +                   dev_info(&pf->pdev->dev,
>> > +                            "init_pf_fcoe failed: %d\n", ret);
>> > +   }
>> >
>> >  #endif
>> >     /* do basic switch setup */
>> > --
>> > 1.8.3.1
>

Thanks,
Ethan
