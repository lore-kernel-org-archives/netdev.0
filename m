From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: e1000: LED indicates trouble,
	and [PATCH] enable/disable of force-link-up
Date: Wed, 3 Dec 2008 00:12:00 -0800
Message-ID: <9929d2390812030012i4fb1a19emc19baaadbd0953e@mail.gmail.com>
References: <20081203163636ohashi-h@mail.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, bruce.w.allan@intel.com,
	jesse.brandeburg@intel.com, john.ronciak@intel.com, jgarzik@pobox.com
To: ohashi-h@mb.dnes.nec.co.jp
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20081203163636ohashi-h@mail.jp.nec.com>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, Dec 2, 2008 at 11:36 PM,  <ohashi-h@mb.dnes.nec.co.jp> wrote:
> From: Hiroki Ohashi  <ohashi-h@mb.dnes.nec.co.jp>
>
> Hi all,
>
> I faced the following situations.
> The LED of NIC was indicated, even when the system was not linked
> the network (auto-negotiation failed or link partner cannot
> auto-negotiate).
> LED should be indicate only when the network was linked.
> And so, it is a problem that LED indicates.
>
> I think the indicating the LED is a problem for maintenance.
> I cannot know the condition of the link, because I confirm
> to link up by LED's indication.
>
> We are using 82571EB ethernet controler and serdes interface.
>
> I think this problem is caused by the e1000 device driver
> setting LU and SLU bits in the interface and forcing the link
> to go up.
> I deleted this logic. (the following modification.)
> Then, LED was turned off.
>
> ================================
> --- e1000_hw.c.org
> +++ e1000_hw.c
> @@ -3069,6 +3069,7 @@I
>             hw->autoneg_failed = 1;
>             return 0;
>         }
> +#if 0
>         DEBUGOUT("NOT RXing /C/, disable AutoNeg and force link.\n");
>
>         /* Disable auto-negotiation in the TXCW register */
> @@ -3078,6 +3079,7 @@
>         ctrl = E1000_READ_REG(hw, CTRL);
>         ctrl |= (E1000_CTRL_SLU | E1000_CTRL_FD);
>         E1000_WRITE_REG(hw, CTRL, ctrl);
> +#endif
>
>         /* Configure Flow Control after forcing link up. */
>         ret_val = e1000_config_fc_after_link_up(hw);
> ================================
>
>
> I think the e1000 driver should enable/disable force-link-up
> depending on the condition of the link.
> But I don't know a good way to do this.
> If you have any good ideas, please let me know.
>
> As a temporary idea, I thought of a way of adding a module parameter
> to control enable/disable force-link-up.
> The patch is as follows.
>
> This patch adds "disable_force_link_up_when_autoneg_failed"
> as module parameter. When this is 0, force-link-up is disable.
>
> From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
>
> ================================
> --- drivers/net/e1000/e1000_hw.h.org
> +++ drivers/net/e1000/e1000_hw.h
> @@ -1469,6 +1469,7 @@ struct e1000_hw {
>        bool                    has_manc2h;
>        bool                    rx_needs_kicking;
>        bool                    has_smbus;
> +       bool                    disable_force_link_up_when_autoneg_failed;
>  };
> --- drivers/net/e1000/e1000_param.c.org
> +++ drivers/net/e1000/e1000_param.c
> @@ -196,6 +196,13 @@ E1000_PARAM(SmartPowerDownEnable, "Enabl
>  */
>  E1000_PARAM(KumeranLockLoss, "Enable Kumeran lock loss workaround");
>
> +/* Enable Force Link Up When AutoNeg Failed
> + *
> + * Valid Range: 0, 1
> + *
> + * Default Value: 1 (force link up enabled)  */
> +E1000_PARAM(EnableForceLinkOnSERDES, "Enable force link up when AutoNeg failed");
> +
>  struct e1000_option {
>        enum { enable_option, range_option, list_option } type;
>        const char *name;
> @@ -534,6 +541,23 @@ void __devinit e1000_check_options(struc
>                        adapter->hw.kmrn_lock_loss_workaround_disabled = !opt.def;
>                }
>        }
> +       { /* Enable Force Link Up When AutoNeg Failed */
> +               struct e1000_option opt = {
> +                       .type = enable_option,
> +                       .name = "Enable Force Link Up When AutoNeg Failed",
> +                       .err  = "defaulting to Enabled",
> +                       .def  = OPTION_ENABLED
> +               };
> +
> +               if (num_EnableForceLinkOnSERDES > bd) {
> +                       unsigned int force_link_up = EnableForceLinkOnSERDES [bd];
> +                       e1000_validate_option(&force_link_up, &opt, adapter);
> +                       adapter->hw.disable_force_link_up_when_autoneg_failed = !force_link_up;
> +
> +               } else {
> +                       adapter->hw.disable_force_link_up_when_autoneg_failed = !opt.def;
> +               }
> +       }
>
>        switch (adapter->hw.media_type) {
>        case e1000_media_type_fiber:
> --- drivers/net/e1000/e1000_hw.c.org
> +++ drivers/net/e1000/e1000_hw.c
> @@ -3062,6 +3062,12 @@ s32 e1000_check_for_link(struct e1000_hw
>             hw->autoneg_failed = 1;
>             return 0;
>         }
> +
> +        if (hw->disable_force_link_up_when_autoneg_failed) {
> +            DEBUGOUT("Force Link Up Disabled\n");
> +            return -E1000_ERR_PHY;
> +        }
> +
>         DEBUGOUT("NOT RXing /C/, disable AutoNeg and force link.\n");
>
>         /* Disable auto-negotiation in the TXCW register */
> ================================
> --
>

I am a little confused.  You state you are using an NIC (82571EB)
which is currently not supported by e1000, but is supported in the
e1000e driver.  Then you suggest a change to the e1000 driver to
resolve an issue you see with your 82571EB NIC.

So I would suggest you use the e1000e driver first.

Also the Link LED is supposed to indicated that there is a "physical"
link, in which case you can have a physical connection and still fail
auto-neg.  So I do not necessarily agree with your interpretation of
what a link LED is supposed to indicate.

NAK.

-- 
Cheers,
Jeff

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
