From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [E1000-devel] [PATCH 1/1] ixgbe: add fiber tranceiver
 plug/unplug notifier
Date: Tue, 14 Jun 2016 08:54:54 -0700
Message-ID: <20160614085454.36c6290d@xeon-e3>
References: <1465911805-27528-1-git-send-email-zyjzyj2000@gmail.com>
	<1465911805-27528-2-git-send-email-zyjzyj2000@gmail.com>
	<CAD=hENdq=NfePHCQEmS-msQfcDfWbZp7O+W68ci8pA2=5whfFw@mail.gmail.com>
	<F6FB0E698C9B3143BDF729DF2228664696AC171C@ORSMSX116.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: zhuyj <zyjzyj2000@gmail.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>
To: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33629 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750794AbcFNPyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 11:54:52 -0400
Received: by mail-pa0-f51.google.com with SMTP id b13so35270407pat.0
        for <netdev@vger.kernel.org>; Tue, 14 Jun 2016 08:54:52 -0700 (PDT)
In-Reply-To: <F6FB0E698C9B3143BDF729DF2228664696AC171C@ORSMSX116.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 14 Jun 2016 15:20:07 +0000
"Skidmore, Donald C" <donald.c.skidmore@intel.com> wrote:

> > -----Original Message-----
> > From: zhuyj [mailto:zyjzyj2000@gmail.com]
> > Sent: Tuesday, June 14, 2016 6:55 AM
> > To: e1000-devel@lists.sourceforge.net; netdev <netdev@vger.kernel.org>
> > Subject: Re: [E1000-devel] [PATCH 1/1] ixgbe: add fiber tranceiver
> > plug/unplug notifier
> > 
> > Hi, all
> > 
> > When the fiber tranceiver is plugged/unplugged from the nic, there is no any
> > notifier to indicate this event now.
> > This event sometimes is needed by the userspace tools or kernel.
> > 
> > So,
> > 
> > Is there any interrupt to indicate this event?
> > If no interrupt, is there any method to notify this event to the netdev notifier
> > chain?
> > 
> > I made a new patch to send the notifier when the fiber tranceiver is
> > plugged/unplugged.
> > 
> > This patch is based on the function ixgbe_sfp_detection_subtask.
> > 
> > When the fiber tranceiver is plugged/unplugged, the value in the register is
> > changed, then
> > NETDEV_FIBER_TRANCEIVER_UNPLUG/NETDEV_FIBER_TRANCEIVER_PLUG
> > notifier is sent.
> > 
> > This patch can work well with the following steps:
> > 
> > 1. boot the host
> > 2. ip link set eth0 up
> > 3. unplug the fiber tranceiver
> > 4. a message NETDEV_FIBER_TRANCEIVER_UNPLUG is sent 5. plug the fiber
> > tranceiver 6. a notifier NETDEV_FIBER_TRANCEIVER_PLUG is sent
> > 
> > Please comment on it.
> > 
> > On Tue, Jun 14, 2016 at 9:43 PM, <zyjzyj2000@gmail.com> wrote:
> > 
> > > From: Zhu Yanjun <zyjzyj2000@gmail.com>
> > >
> > > When the fiber tranceiver is plugged/unplugged, a netdev notifier is
> > > sent. The userspace tools or kernel can receive this notifier.
> > >
> > > Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
> > > ---
> > >  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   26
> > > ++++++++++++++++++++++++-
> > >  drivers/net/ethernet/intel/ixgbe/ixgbe_type.h |    3 +++
> > >  include/linux/netdevice.h                     |    2 ++
> > >  3 files changed, 30 insertions(+), 1 deletion(-)
> > >
> > > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > > b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > > index cb19cbc..df0eed3 100644
> > > --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > > +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > > @@ -5635,6 +5635,8 @@ static int ixgbe_sw_init(struct ixgbe_adapter
> > > *adapter)
> > >         hw->revision_id = pdev->revision;
> > >         hw->subsystem_vendor_id = pdev->subsystem_vendor;
> > >         hw->subsystem_device_id = pdev->subsystem_device;
> > > +       hw->last_tranceiver_status = IXGBE_NOT_IMPLEMENTED;
> > > +       hw->tranceiver_polltime = 0;
> > >
> > >         /* Set common capability flags and settings */
> > >         rss = min_t(int, ixgbe_max_rss_indices(adapter),
> > > num_online_cpus()); @@ -7067,7 +7069,25 @@ static void
> > > ixgbe_watchdog_subtask(struct ixgbe_adapter *adapter)  static void
> > > ixgbe_sfp_detection_subtask(struct ixgbe_adapter *adapter)  {
> > >         struct ixgbe_hw *hw = &adapter->hw;
> > > -       s32 err;
> > > +       s32 err, status;
> > > +
> > > +       if ((hw->mac.ops.get_media_type(hw) == ixgbe_media_type_fiber)
> > &&
> > > +           time_after(jiffies, hw->tranceiver_polltime)) {
> > > +               u8 identifier;
> > > +
> > > +               status = hw->phy.ops.read_i2c_eeprom(hw,
> > > +                                                    0x0,
> > > +                                                    &identifier);
> > > +               if ((status != hw->last_tranceiver_status) && status) {
> > > +                       hw->phy.sfp_type = ixgbe_sfp_type_not_present;
> > > +                       rtnl_lock();
> > > +
> > >  call_netdevice_notifiers(NETDEV_FIBER_TRANCEIVER_UNPLUG,
> > > +                                                adapter->netdev);
> > > +                       rtnl_unlock();
> > > +               }
> > > +               hw->last_tranceiver_status = status;
> > > +               hw->tranceiver_polltime = jiffies + 3 * HZ;
> > > +       }
> > >
> > >         /* If crosstalk fix enabled verify the SFP+ cage is full */
> > >         if (adapter->need_crosstalk_fix) { @@ -7130,6 +7150,10 @@
> > > static void ixgbe_sfp_detection_subtask(struct
> > > ixgbe_adapter *adapter)
> > >         adapter->flags |= IXGBE_FLAG_NEED_LINK_CONFIG;
> > >         e_info(probe, "detected SFP+: %d\n", hw->phy.sfp_type);
> > >
> > > +       rtnl_lock();
> > > +       call_netdevice_notifiers(NETDEV_FIBER_TRANCEIVER_PLUG,
> > > adapter->netdev);
> > > +       rtnl_unlock();
> > > +
> > >  sfp_out:
> > >         clear_bit(__IXGBE_IN_SFP_INIT, &adapter->state);
> > >
> > > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
> > > b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
> > > index da3d835..0dde95c 100644
> > > --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
> > > +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
> > > @@ -3525,6 +3525,8 @@ struct ixgbe_hw {
> > >         bool                            force_full_reset;
> > >         bool                            allow_unsupported_sfp;
> > >         bool                            wol_enabled;
> > > +       s32                             last_tranceiver_status;
> > > +       unsigned long                   tranceiver_polltime;
> > >  };
> > >
> > >  struct ixgbe_info {
> > > @@ -3574,6 +3576,7 @@ struct ixgbe_info {
> > >  #define IXGBE_ERR_FDIR_CMD_INCOMPLETE          -38
> > >  #define IXGBE_ERR_FW_RESP_INVALID              -39
> > >  #define IXGBE_ERR_TOKEN_RETRY                  -40
> > > +#define IXGBE_ERR_TRANCEIVER_NOT_PRESENT       -41
> > >  #define IXGBE_NOT_IMPLEMENTED                   0x7FFFFFFF
> > >
> > >  #define IXGBE_FUSES0_GROUP(_i)         (0x11158 + ((_i) * 4))
> > > diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> > > index d101e4d..693ba92 100644
> > > --- a/include/linux/netdevice.h
> > > +++ b/include/linux/netdevice.h
> > > @@ -2253,6 +2253,8 @@ struct netdev_lag_lower_state_info {
> > >  #define NETDEV_CHANGELOWERSTATE        0x001B
> > >  #define NETDEV_OFFLOAD_PUSH_VXLAN      0x001C
> > >  #define NETDEV_OFFLOAD_PUSH_GENEVE     0x001D
> > > +#define NETDEV_FIBER_TRANCEIVER_PLUG   0x001E
> > > +#define NETDEV_FIBER_TRANCEIVER_UNPLUG 0x001F
> > >
> > >  int register_netdevice_notifier(struct notifier_block *nb);  int
> > > unregister_netdevice_notifier(struct notifier_block *nb);
> > > --
> > > 1.7.9.5
> > >
> > >
> 
> It's not as simple as this patch is implying.  The ixgbe_sfp_detection_subtask function is driven by our master service task which isn't always running and doesn't always run at the same frequency.  Likewise the all hardware supported by ixgbe doesn't all behave the same way in relation to a transceiver insertion/removal event.  Some receive interrupts while others have to poll.  Off the top of my head I think you would also have to be concerned with the following cases:
> 
> - Insertion/removal while the device is down.
> - Initial query when the driver is loaded.
> - Some modules aren't supported I'm not sure how you would want to there, still report the insertion to the stack, ignore it?
> - I've also recently added a crosstalk fix that your patch would not take in to consideration.
> 
> Thanks,
> -Don Skidmore <donald.c.skidmore@intel.com>

In theory you could use exiting network device model about operstate.
If SFP is removed this is analgous to LOWERLAYER down.
