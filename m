From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [net-intel-e1000e] question about value overwrite
Date: Thu, 18 May 2017 17:22:23 -0500
Message-ID: <20170518172223.Horde.5kLLwxMJWThQKv0bAxTsk4D@gator4166.hostgator.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hello everybody,

While looking into Coverity ID 1226905 I ran into the following piece  
of code at drivers/net/ethernet/intel/e1000e/ich8lan.c:2400

2400/**
2401 *  e1000_hv_phy_workarounds_ich8lan - A series of Phy workarounds to be
2402 *  done after every PHY reset.
2403 **/
2404static s32 e1000_hv_phy_workarounds_ich8lan(struct e1000_hw *hw)
2405{
2406        s32 ret_val = 0;
2407        u16 phy_data;
2408
2409        if (hw->mac.type != e1000_pchlan)
2410                return 0;
2411
2412        /* Set MDIO slow mode before any other MDIO access */
2413        if (hw->phy.type == e1000_phy_82577) {
2414                ret_val = e1000_set_mdio_slow_mode_hv(hw);
2415                if (ret_val)
2416                        return ret_val;
2417        }
2418
2419        if (((hw->phy.type == e1000_phy_82577) &&
2420             ((hw->phy.revision == 1) || (hw->phy.revision == 2))) ||
2421            ((hw->phy.type == e1000_phy_82578) &&  
(hw->phy.revision == 1))) {
2422                /* Disable generation of early preamble */
2423                ret_val = e1e_wphy(hw, PHY_REG(769, 25), 0x4431);
2424                if (ret_val)
2425                        return ret_val;
2426
2427                /* Preamble tuning for SSC */
2428                ret_val = e1e_wphy(hw, HV_KMRN_FIFO_CTRLSTA, 0xA204);
2429                if (ret_val)
2430                        return ret_val;
2431        }
2432
2433        if (hw->phy.type == e1000_phy_82578) {
2434                /* Return registers to default by doing a soft reset then
2435                 * writing 0x3140 to the control register.
2436                 */
2437                if (hw->phy.revision < 2) {
2438                        e1000e_phy_sw_reset(hw);
2439                        ret_val = e1e_wphy(hw, MII_BMCR, 0x3140);
2440                }
2441        }
2442
2443        /* Select page 0 */
2444        ret_val = hw->phy.ops.acquire(hw);
2445        if (ret_val)
2446                return ret_val;
2447
2448        hw->phy.addr = 1;
2449        ret_val = e1000e_write_phy_reg_mdic(hw,  
IGP01E1000_PHY_PAGE_SELECT, 0);
2450        hw->phy.ops.release(hw);
2451        if (ret_val)
2452                return ret_val;
2453
2454        /* Configure the K1 Si workaround during phy reset  
assuming there is
2455         * link so that it disables K1 if link is in 1Gbps.
2456         */
2457        ret_val = e1000_k1_gig_workaround_hv(hw, true);
2458        if (ret_val)
2459                return ret_val;
2460
2461        /* Workaround for link disconnects on a busy hub in half duplex */
2462        ret_val = hw->phy.ops.acquire(hw);
2463        if (ret_val)
2464                return ret_val;
2465        ret_val = e1e_rphy_locked(hw, BM_PORT_GEN_CFG, &phy_data);
2466        if (ret_val)
2467                goto release;
2468        ret_val = e1e_wphy_locked(hw, BM_PORT_GEN_CFG, phy_data & 0x00FF);
2469        if (ret_val)
2470                goto release;
2471
2472        /* set MSE higher to enable link to stay up when noise is high */
2473        ret_val = e1000_write_emi_reg_locked(hw,  
I82577_MSE_THRESHOLD, 0x0034);
2474release:
2475        hw->phy.ops.release(hw);
2476
2477        return ret_val;
2478}

The issue is that the value stored in variable _ret_val_ at line 2439  
is overwritten by the one stored at line 2444, before it can be used.

My question is if the original intention was to return this value  
immediately after the assignment at line 2439, something like in the  
following patch:

index 68ea8b4..d6d4ed7 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -2437,6 +2437,8 @@ static s32  
e1000_hv_phy_workarounds_ich8lan(struct e1000_hw *hw)
                 if (hw->phy.revision < 2) {
                         e1000e_phy_sw_reset(hw);
                         ret_val = e1e_wphy(hw, MII_BMCR, 0x3140);
+                       if (ret_val)
+                               return ret_val;
                 }
         }

What do you think?

I'd really appreciate any comment on this.

Thank you!
--
Gustavo A. R. Silva
