From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch net-next v2 01/15] net: introduce upper device
	lists
Date: Tue, 14 Aug 2012 23:33:44 +0100
Message-ID: <1344983624.2690.77.camel@bwh-desktop.uk.solarflarecom.com>
References: <1344956748-2099-1-git-send-email-jiri@resnulli.us>
	<1344956748-2099-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, ursula.braun@de.ibm.com,
	john.r.fastabend@intel.com, edumazet@google.com,
	shemminger@vyatta.com, sean.hefty@intel.com, therbert@google.com,
	roland@kernel.org, linux-s390@vger.kernel.org,
	linux-rdma@vger.kernel.org, fubar@us.ibm.com, fbl@redhat.com,
	hal.rosenstock@gmail.com, faisal.latif@intel.com,
	linux-driver@qlogic.com, blaschka@linux.vnet.ibm.com,
	sony.chacko@qlogic.com, gregory.v.rose@intel.com,
	xiyou.wangcong@gmail.com, jitendra.kalsaria@qlogic.com,
	divy@chelsio.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kaber@trash.net, joe@perches.com,
	linux390@de.ibm.com, davem@davemloft.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1344956748-2099-2-git-send-email-jiri@resnulli.us>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-08-14 at 17:05 +0200, Jiri Pirko wrote:
> This lists are supposed to serve for storing pointers to all upper devices.
> Eventually it will replace dev->master pointer which is used for
> bonding, bridge, team but it cannot be used for vlan, macvlan where
> there might be multiple upper present. In case the upper link is
> replacement for dev->master, it is marked with "master" flag.

Something I found interesting is that the dev->master pointer and now
netdev_master_upper_dev_get{,_rcu}() are hardly used by the stackled
drivers that set the master.  They also have to set an rx_handler on the
lower device (which is itself mutually exclusive) which gets its own
context pointer (rx_handler_data).

Instead, the master pointer is mostly used by device drivers to find out
about a bridge or bonding device above *their* devices.  And that seems
to work only for those specific device drivers, not e.g. openvswitch or
team.  I wonder if we could find a better way to encapsulate the things
they want do do, in a later step (not holding up this change!).

[...]
> +static int __netdev_upper_dev_link(struct net_device *dev,
> +                                  struct net_device *upper_dev, bool master)
> +{
> +       struct netdev_upper *upper;
> +
> +       ASSERT_RTNL();
> +
> +       if (dev == upper_dev)
> +               return -EBUSY;
> +       /*
> +        * To prevent loops, check if dev is not upper device to upper_dev.
> +        */
> +       if (__netdev_has_upper_dev(upper_dev, dev, true))
> +               return -EBUSY;
[...]

I think we will also need to limit the depth of the device stack so we
don't run out of stack space here.  __netif_receive() implements a kind
of tail recursion whenever a packet is passed up, but
__netdev_has_upper_dev() can't avoid doing real recursion (without the
addition of a flag to net_device so it can mark its progress).

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
