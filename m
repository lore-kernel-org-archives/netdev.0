From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: [PATCH 1/1] ixgbe: add fiber tranceiver
	plug/unplug notifier
Date: Thu, 16 Jun 2016 18:43:22 +0800
Message-ID: <CAD=hENffbs-mWH7yTN2B7vimO+UNa7jYg0raK1NYoaVp42L+-w@mail.gmail.com>
References: <F6FB0E698C9B3143BDF729DF2228664696AC171C@ORSMSX116.amr.corp.intel.com>
	<1465997798-3261-1-git-send-email-zyjzyj2000@gmail.com>
	<1465997798-3261-2-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1256517615092987371=="
To: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1465997798-3261-2-git-send-email-zyjzyj2000@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

--===============1256517615092987371==
Content-Type: multipart/alternative; boundary=94eb2c046b1c3b1972053562e894

--94eb2c046b1c3b1972053562e894
Content-Type: text/plain; charset=UTF-8

Sorry, Maybe last_tranceiver_status and tranceiver_polltime should not be
in ixgbe_hw struct. It is better in ixgbe struct. I will change it soon.

Zhu Yanjun

On Wed, Jun 15, 2016 at 9:36 PM, <zyjzyj2000@gmail.com> wrote:

> From: Zhu Yanjun <zyjzyj2000@gmail.com>
>
> When the fiber tranceiver is plugged/unplugged, a netdev notifier is
>  sent. The userspace tools or kernel can receive this notifier.
>
> Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   24
> +++++++++++++++++++++++-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_type.h |    2 ++
>  2 files changed, 25 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index 088c47c..1d8c1ff 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -5635,6 +5635,8 @@ static int ixgbe_sw_init(struct ixgbe_adapter
> *adapter)
>         hw->revision_id = pdev->revision;
>         hw->subsystem_vendor_id = pdev->subsystem_vendor;
>         hw->subsystem_device_id = pdev->subsystem_device;
> +       hw->last_tranceiver_status = IXGBE_NOT_IMPLEMENTED;
> +       hw->tranceiver_polltime = 0;
>
>         /* Set common capability flags and settings */
>         rss = min_t(int, ixgbe_max_rss_indices(adapter),
> num_online_cpus());
> @@ -7067,7 +7069,27 @@ static void ixgbe_watchdog_subtask(struct
> ixgbe_adapter *adapter)
>  static void ixgbe_sfp_detection_subtask(struct ixgbe_adapter *adapter)
>  {
>         struct ixgbe_hw *hw = &adapter->hw;
> -       s32 err;
> +       s32 err, status;
> +
> +       if ((hw->mac.ops.get_media_type(hw) == ixgbe_media_type_fiber) &&
> +           time_after(jiffies, hw->tranceiver_polltime)) {
> +               status = IXGBE_READ_REG(hw, IXGBE_ESDP) & IXGBE_ESDP_SDP2;
> +               if (status != hw->last_tranceiver_status) {
> +                       unsigned long val;
> +
> +                       if (!status) {
> +                               hw->phy.sfp_type =
> ixgbe_sfp_type_not_present;
> +                               val = NETDEV_FIBER_TRANCEIVER_UNPLUG;
> +                       } else {
> +                               val = NETDEV_FIBER_TRANCEIVER_PLUG;
> +                       }
> +                       rtnl_lock();
> +                       call_netdevice_notifiers(val, adapter->netdev);
> +                       rtnl_unlock();
> +               }
> +               hw->last_tranceiver_status = status;
> +               hw->tranceiver_polltime = jiffies + 3 * HZ;
> +       }
>
>         /* If crosstalk fix enabled verify the SFP+ cage is full */
>         if (adapter->need_crosstalk_fix) {
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
> b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
> index da3d835..fe19899 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
> @@ -3525,6 +3525,8 @@ struct ixgbe_hw {
>         bool                            force_full_reset;
>         bool                            allow_unsupported_sfp;
>         bool                            wol_enabled;
> +       s32                             last_tranceiver_status;
> +       unsigned long                   tranceiver_polltime;
>  };
>
>  struct ixgbe_info {
> --
> 1.7.9.5
>
>

--94eb2c046b1c3b1972053562e894--


--===============1256517615092987371==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
What NetFlow Analyzer can do for you? Monitors network bandwidth and traffic
patterns at an interface-level. Reveals which users, apps, and protocols are 
consuming the most bandwidth. Provides multi-vendor support for NetFlow, 
J-Flow, sFlow and other flows. Make informed decisions using capacity planning
reports. http://pubads.g.doubleclick.net/gampad/clk?id=1444514421&iu=/41014381
--===============1256517615092987371==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============1256517615092987371==--
