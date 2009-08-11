From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/2] mac802154: add a software MAC
 802.15.4 implementation
Date: Wed, 12 Aug 2009 00:29:29 +0400
Message-ID: <20090811202929.GB6303@doriath.ww600.siemens.net>
References: <1249913800-10176-1-git-send-email-dbaryshkov@gmail.com>
	<1249913800-10176-2-git-send-email-dbaryshkov@gmail.com>
	<20090810172843.GD6791@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090810172843.GD6791-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 10, 2009 at 10:28:43AM -0700, Paul E. McKenney wrote:
> On Mon, Aug 10, 2009 at 06:16:39PM +0400, Dmitry Eremin-Solenikov wrote:
> > Some of available devices are just dump radios implementing IEEE 802.15.4
> > PHY layer. This commit adds a common library that acts like an intermediate
> > layer between our socket family and drivers for those dumb devices.
> > 
> > Currently this is data-only part (no commands, no beacons). Control
> > interfaces will follow up shortly.
> > 
> > Note this implementaion is neither certified, nor feature complete!
> 
> One question below, otherwise looks plausible.  (I am not entirely sure
> which lists are which...)
> 
> 							Thanx, Paul

[skipped]

> 
> > +
> > +/*
> > + * This is for hw unregistration only, as it doesn't do RCU locking
> 
> So this list is different than the RCU-protected one, and readers
> always hold locks when traversing it?
> 
> I am not familiar with this code, so might be missing something, but
> it looks to me like the same list that RCU readers traverse.  If so,
> need list_del_rcu() and synchronize_rcu().

On the first glance, yes. On the second glance, list_del instead of
list_del_rcu should be safe as there should be now other list traversals
at the same time. I'll think about it however.

> 
> > + */
> > +void ieee802154_drop_slaves(struct ieee802154_dev *hw)
> > +{
> > +	struct ieee802154_priv *priv = ieee802154_to_priv(hw);
> > +	struct ieee802154_sub_if_data *sdata, *next;
> > +
> > +	ASSERT_RTNL();
> > +
> > +	list_for_each_entry_safe(sdata, next, &priv->slaves, list) {
> > +		mutex_lock(&sdata->hw->slaves_mtx);
> > +		list_del(&sdata->list);
> > +		mutex_unlock(&sdata->hw->slaves_mtx);
> > +
> > +		dev_put(sdata->hw->netdev);
> > +
> > +		unregister_netdevice(sdata->dev);
> > +	}
> > +}

-- 
With best wishes
Dmitry


------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with 
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
