From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [Intel-wired-lan] [RFC PATCH net] e1000e: keep vlan interfaces
 functional after rxvlan off
Date: Thu, 9 Jun 2016 16:55:01 -0400
Message-ID: <20160609205501.GS56933@redhat.com>
References: <1463511831-13684-1-git-send-email-jarod@redhat.com>
 <CAKgT0UfKV23p18L=wCoyy7WXa7s7pQQRVVK8F_mVea0dOJKekA@mail.gmail.com>
 <20160601192724.GA56933@redhat.com>
 <CAKgT0UdXyHt1tbFijqiN57H49TBxSrJ4VcT4A7uKS0oXUouWTA@mail.gmail.com>
 <20160609180204.GR56933@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160609180204.GR56933@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 09, 2016 at 02:02:04PM -0400, Jarod Wilson wrote:
> On Wed, Jun 01, 2016 at 03:31:46PM -0700, Alexander Duyck wrote:
> > On Wed, Jun 1, 2016 at 12:27 PM, Jarod Wilson <jarod@redhat.com> wrote:
> > > On Wed, Jun 01, 2016 at 07:31:53AM -0700, Alexander Duyck wrote:
> > >> On Tue, May 17, 2016 at 12:03 PM, Jarod Wilson <jarod@redhat.com> wrote:
> > >> > I've got a bug report about an e1000e interface, where a vlan interface is
> > >> > set up on top of it:
> > >> >
> > >> > $ ip link add link ens1f0 name ens1f0.99 type vlan id 99
> > >> > $ ip link set ens1f0 up
> > >> > $ ip link set ens1f0.99 up
> > >> > $ ip addr add 192.168.99.92 dev ens1f0.99
> > >> >
> > >> > At this point, I can ping another host on vlan 99, ip 192.168.99.91.
> > >> > However, if I do the following:
> > >> >
> > >> > $ ethtool -K ens1f0 rxvlan off
> > >> >
> > >> > Then no traffic passes on ens1f0.99. It comes back if I toggle rxvlan on
> > >> > again. I'm not sure if this is actually intended behavior, or if there's a
> > >> > lack of software vlan stripping fallback, or what, but things continue to
> > >> > work if I simply don't call e1000e_vlan_strip_disable() if there are
> > >> > active vlans (plagiarizing a function from the e1000 driver here) on the
> > >> > interface.
> > >> >
> > >> > Also slipped a related-ish fix to the kerneldoc text for
> > >> > e1000e_vlan_strip_disable here...
> > >> >
> > >> > CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > >> > CC: intel-wired-lan@lists.osuosl.org
> > >> > CC: netdev@vger.kernel.org
> > >> > Signed-off-by: Jarod Wilson <jarod@redhat.com>
> > >> > ---
> > >> >  drivers/net/ethernet/intel/e1000e/netdev.c | 15 +++++++++++++--
> > >> >  1 file changed, 13 insertions(+), 2 deletions(-)
> > >> >
> > >> > diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
> > >> > index 75e6089..73f7452 100644
> > >> > --- a/drivers/net/ethernet/intel/e1000e/netdev.c
> > >> > +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
> > >> > @@ -154,6 +154,16 @@ void __ew32(struct e1000_hw *hw, unsigned long reg, u32 val)
> > >> >         writel(val, hw->hw_addr + reg);
> > >> >  }
> > >> >
> > >> > +static bool e1000e_vlan_used(struct e1000_adapter *adapter)
> > >> > +{
> > >> > +       u16 vid;
> > >> > +
> > >> > +       for_each_set_bit(vid, adapter->active_vlans, VLAN_N_VID)
> > >> > +               return true;
> > >> > +
> > >>
> > >> I'm pretty sure this is always going to return true if 8021q is loaded
> > >> because VLAN 0 is always added to the device even if no other VLANs
> > >> are in use.
> > >
> > > Ah, hadn't considered that, I just plucked it straight from e1000.
> > >
> > >> > +       return false;
> > >> > +}
> > >> > +
> > >> >  /**
> > >> >   * e1000_regdump - register printout routine
> > >> >   * @hw: pointer to the HW structure
> > >> > @@ -2789,7 +2799,7 @@ static void e1000e_vlan_filter_enable(struct e1000_adapter *adapter)
> > >> >  }
> > >> >
> > >> >  /**
> > >> > - * e1000e_vlan_strip_enable - helper to disable HW VLAN stripping
> > >> > + * e1000e_vlan_strip_disable - helper to disable HW VLAN stripping
> > >> >   * @adapter: board private structure to initialize
> > >> >   **/
> > >> >  static void e1000e_vlan_strip_disable(struct e1000_adapter *adapter)
> > >> > @@ -3443,7 +3453,8 @@ static void e1000e_set_rx_mode(struct net_device *netdev)
> > >> >
> > >> >         ew32(RCTL, rctl);
> > >> >
> > >> > -       if (netdev->features & NETIF_F_HW_VLAN_CTAG_RX)
> > >> > +       if (netdev->features & NETIF_F_HW_VLAN_CTAG_RX ||
> > >> > +           e1000e_vlan_used(adapter))
> > >> >                 e1000e_vlan_strip_enable(adapter);
> > >> >         else
> > >> >                 e1000e_vlan_strip_disable(adapter);
> > >>
> > >> So if the VLAN tag stripping is disabled what happens that is causing
> > >> the VLAN test to fail?  It sounds like this might be working around a
> > >> kernel bug where a VLAN created on a device that supports hardware tag
> > >> stripping only supports hardware tag stripping.  Maybe a better fix
> > >> would be to add a fall back so if the VLAN tag is in the frame instead
> > >> of stripped it still makes it to the correct spot.
> > >
> > > That's the main reason I labeled it as an RFC -- I wasn't sure exactly how
> > > things were intended to work when the hardware stripping was disabled. It
> > > seems quite plausible to me that this patch simply papers over the real
> > > bug: lack of a functional software fallback. I'm not particularly up on
> > > the vlan code just yet though, so I'm not yet sure where to poke next.
> > > Suggestions welcomed. :)
> > 
> > Well the software fallback should be the call to skb_vlan_untag in
> > __netif_receive_skb_core.  If that isn't being triggered then we
> > should probably be fixing the files in the core code then.
> 
> So I've been poking at a debug-spew-laden kernel some, and skb_vlan_untag
> is most definitely not getting called when rxvlan off is set. I'm still
> poking around, trying to track down where things are going askew.

Okay, so rxvlan is *supposed* to only impact the rx path, right? It's
looking like it is actually impacting the tx path too here. I actually
*do* see calls to skb_vlan_untag with rxvlan off, if I ping from an
external host, so it seems only the packets from the host with rxvlan
toggled off aren't escaping correctly for some reason.

-- 
Jarod Wilson
jarod@redhat.com
