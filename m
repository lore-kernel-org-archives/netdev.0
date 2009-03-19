From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [net-next PATCH 1/2] igbvf: add new driver to support 82576
 virtual functions
Date: Wed, 18 Mar 2009 18:56:30 -0700
Message-ID: <20090318185630.11f3d557.akpm@linux-foundation.org>
References: <20090311020928.23138.20790.stgit@lost.foo-projects.org>
	<20090310222154.4bc8c12c.akpm@linux-foundation.org>
	<49C03C80.5020203@intel.com>
	<20090317180826.8f3c596b.akpm@linux-foundation.org>
	<49C111C6.2010905@intel.com>
	<20090318145340.6b282829.akpm@linux-foundation.org>
	<49C1948F.1060300@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"greg@kroah.com" <greg@kroah.com>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"Zhao, Yu" <yu.zhao@intel.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <49C1948F.1060300@intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 18 Mar 2009 17:40:47 -0700 Alexander Duyck <alexander.h.duyck@intel.com> wrote:

> Andrew Morton wrote:
> > On Wed, 18 Mar 2009 08:22:46 -0700 Alexander Duyck <alexander.h.duyck@intel.com> wrote:
> > 
> >>>>>> +static int igbvf_set_ringparam(struct net_device *netdev,
> >>>>>> +                               struct ethtool_ringparam *ring)
> >>>>>> +{
> >>>>>> +     struct igbvf_adapter *adapter = netdev_priv(netdev);
> >>>>>> +     struct igbvf_ring *tx_ring, *tx_old;
> >>>>>> +     struct igbvf_ring *rx_ring, *rx_old;
> >>>>>> +     int err;
> >>>>>> +
> >>>>>> +     if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending))
> >>>>>> +             return -EINVAL;
> >>>>>> +
> >>>>>> +     while (test_and_set_bit(__IGBVF_RESETTING, &adapter->state))
> >>>>>> +             msleep(1);
> >>>>> No timeout needed here?  Interrupts might not be working, for example..
> >>>> This bit isn't set in interrupt context.  This is always used out of 
> >>>> interrupt context and is just to prevent multiple setting changes at the 
> >>>> same time.
> >>> Oh.  Can't use plain old mutex_lock()?
> >> We have one or two spots that actually check to see if the bit is set 
> >> and just report a warning instead of actually waiting on the bit to clear.
> > 
> > mutex_is_locked()?
> 
> I suppose that would work, but I still would prefer to keep this bit of 
> code as it is.  My main motivation is just to use what was already 
> proven, and the fact is the e1000, e1000e, igb, and several other 
> drivers all use this same approach and it works.

OK, that's a reason.

> I don't think we need the extra overhead of the mutex lock since most of 
> the calls that end up setting the __IGBVF_RESETTING bit will already be 
> wrapped within rtnl_lock/unlock calls.  As far as I can tell it looks 
> like the only two threads that would ever be competing for the lock 
> would be the igbvf_reinit_locked and whatever ethtool or ifconfig 
> requests that decide to make changes to the configuration of the netdevice.

You may well find that mutex_lock is more efficient than setting a timer
and waking up once per millisecond.  Certainly much lower latency on some
setups given clock granularities of as much as 10 milliseconds.

But it sounds like that's all a separate standalone exercise.
