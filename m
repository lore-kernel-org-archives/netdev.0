From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: [PATCH 1/1] ixgbe: replace rtnl_lock with
	rcu_read_lock
Date: Tue, 7 Jun 2016 14:30:40 +0800
Message-ID: <CAD=hENfktHTUBhqVZczRB42y9de5UWGXUKfG8g7WX4feuKweXw@mail.gmail.com>
References: <1465118091-6233-1-git-send-email-zyjzyj2000@gmail.com>
	<1465118091-6233-2-git-send-email-zyjzyj2000@gmail.com>
	<CAKgT0UeF-Ktx5my99NAR4j7ATwUWx249yAZD+sMkQkjBJaeEdA@mail.gmail.com>
	<CAD=hENfNuCrBXbKjcPYzJ7+dPEx4KNeEEds1O7LYdqrObZXscg@mail.gmail.com>
	<CAKgT0UcxJy=eRKKiz3RxS74qjUsg6P44EU4Me0WXT8XoXuvkjw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2751616605217849713=="
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	Netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <CAKgT0UcxJy=eRKKiz3RxS74qjUsg6P44EU4Me0WXT8XoXuvkjw@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

--===============2751616605217849713==
Content-Type: multipart/alternative; boundary=001a113d469ef611900534aa5349

--001a113d469ef611900534aa5349
Content-Type: text/plain; charset=UTF-8

Hi, Alex

You are very nice to explain it in details.

In the file ixgbe_main.c, the function is

6638 static void ixgbe_watchdog_link_is_up(struct ixgbe_adapter *adapter)

...
6705         netif_carrier_on(netdev);
6706         ixgbe_check_vf_rate_limit(adapter);
6707
6708         /* enable transmits */
*6709         netif_tx_wake_all_queues(adapter->netdev);  <---This will
change ixgbe nic state*
6710
6711         /* enable any upper devices */
6712         rtnl_lock();
6713         netdev_for_each_all_upper_dev_rcu(adapter->netdev, upper,
iter) {
6714                 if (netif_is_macvlan(upper)) {
6715                         struct macvlan_dev *vlan = netdev_priv(upper);
6716
6717                         if (vlan->fwd_priv)
*6718                                 netif_tx_wake_all_queues(upper);
<---This will change upper(macvlan) nic state*
6719                 }
6720         }
6721         rtnl_unlock();

...

In the above, the ixgbe nic state is changed without rtnl_lock protection.
But upper device state change needs the rtnl_lock protection.

I am confused about this.

Thanks for your reply.

Zhu Yanjun

On Tue, Jun 7, 2016 at 12:12 AM, Alexander Duyck <alexander.duyck@gmail.com>
wrote:

> Just a quick scan has me wondering what code you are comparing it to?
>
> The key bit here that is the reason for taking the RTNL lock is
> because this section is handled in the watchdog which is not an RTNL
> protected region, and because it is messing with devices other than
> the ones controlled by the ixgbe driver itself.  As far as I can tell
> I don't see similar code in the other drivers.  You end up having to
> take the RTNL lock any time you start trying to manipulate some state
> of a device that is not protected through other means.  For example
> pretty much all the net device operations expect that the RTNL lock
> has already been taken before calling them, however a driver can call
> into those functions if it is maintaining the state for the devices
> without the RTNL lock assuming it has some other means of keeping the
> state consistent such as a __IXGBE_DOWN state bit in the ixgbe driver.
>
> - Alex
>
> On Mon, Jun 6, 2016 at 6:37 AM, zhuyj <zyjzyj2000@gmail.com> wrote:
> > Hi, Alex
> >
> > Thanks for your reply.
> >
> > I checked all the nic driver in driver/net/ethernet/intel. And I found
> that
> > only here the rtnl_lock is used.
> > So I am curios why rtnl_lock is used when waking up the tupper device tx
> > queue here. And the rtnl_lock is not used in other places.
> >
> > Best Regards!
> > Zhu Yanjun
> >
> > On Mon, Jun 6, 2016 at 2:40 AM, Alexander Duyck <
> alexander.duyck@gmail.com>
> > wrote:
> >>
> >> On Sun, Jun 5, 2016 at 2:14 AM,  <zyjzyj2000@gmail.com> wrote:
> >> > From: Zhu Yanjun <zyjzyj2000@gmail.com>
> >> >
> >> >
> >> > Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
> >> > ---
> >> >  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    4 ++--
> >> >  1 file changed, 2 insertions(+), 2 deletions(-)
> >> >
> >> > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> >> > b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> >> > index 088c47c..cb19cbc 100644
> >> > --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> >> > +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> >> > @@ -6840,7 +6840,7 @@ static void ixgbe_watchdog_link_is_up(struct
> >> > ixgbe_adapter *adapter)
> >> >         netif_tx_wake_all_queues(adapter->netdev);
> >> >
> >> >         /* enable any upper devices */
> >> > -       rtnl_lock();
> >> > +       rcu_read_lock();
> >> >         netdev_for_each_all_upper_dev_rcu(adapter->netdev, upper,
> iter)
> >> > {
> >> >                 if (netif_is_macvlan(upper)) {
> >> >                         struct macvlan_dev *vlan = netdev_priv(upper);
> >> > @@ -6849,7 +6849,7 @@ static void ixgbe_watchdog_link_is_up(struct
> >> > ixgbe_adapter *adapter)
> >> >                                 netif_tx_wake_all_queues(upper);
> >> >                 }
> >> >         }
> >> > -       rtnl_unlock();
> >> > +       rcu_read_unlock();
> >> >
> >> >         /* update the default user priority for VFs */
> >> >         ixgbe_update_default_up(adapter);
> >>
> >> The rtnl_lock is being used to prevent any changes to the upper
> >> devices while the interface is going through and updating the Tx queue
> >> configuration on them.  Without that lock you introduce possible bugs
> >> since you could have queues freed or added while this loop is in the
> >> middle of trying to update the state of it.
> >>
> >> As a general rule you use rcu_read_lock when you are only reading an
> >> RCU protected structure, you use rtnl_lock when you have to protect
> >> the system from any other changes while you are updating network
> >> configuration.  In this case netif_tx_wake_all_queues changes the
> >> state of the upper device.  The use of rtnl_lock here is intentional
> >> and it is best to just leave it as is unless you have some actual bug
> >> you are seeing.
> >>
> >> - Alex
> >
> >
>

--001a113d469ef611900534aa5349--


--===============2751616605217849713==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
What NetFlow Analyzer can do for you? Monitors network bandwidth and traffic
patterns at an interface-level. Reveals which users, apps, and protocols are 
consuming the most bandwidth. Provides multi-vendor support for NetFlow, 
J-Flow, sFlow and other flows. Make informed decisions using capacity 
planning reports. https://ad.doubleclick.net/ddm/clk/305295220;132659582;e
--===============2751616605217849713==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============2751616605217849713==--
