From: Ben Greear <greearb@candelatech.com>
Subject: Re: Problems with e1000 in 2.4.23
Date: Sun, 30 Nov 2003 21:39:48 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FCAD424.70103@candelatech.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDD09@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>,
        "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDD09@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Feldman, Scott wrote:
>>Could the problem happen because I do the set-multi even if
>>the NIC is down?  Is there enough locking in the 
>>e1000_ethtool additions?
> 
> 
> Change ETHTOOL_SETRXALL to work more like ETHTOOL_SRXCSUM, with the
> check for netif_running and down/up or reset.

The set_multi is called from net/core/dev.c (or near-abouts) when
the promisc changes, and I'm quite sure that does not require the
NIC to be bounced.

So, if I really have to bounce the NIC to change the 'rx-all' flags,
then I'll have to move that code path out of the 'set-multi' method
and have it be a stand-alone method.

Or, is the problem just that I should NOT be twiddling any bits when
the NIC is down?  Unless I'm confused, the only lock acquired when
changing PROMISC (which on e100 at least used to flush a bunch of the
rx-all flags, even though the receive logic threw them away later)
is the tx-lock.

For instance, would this perhaps be a better method:

static int e1000_ethtool_setrxall(struct net_device *netdev, uint32_t val) {
	unsigned short old_flags = netdev->priv_flags;
	if (val) {
		netdev->priv_flags |= IFF_ACCEPT_ALL_FRAMES;
	}
	else {
		netdev->priv_flags &= ~(IFF_ACCEPT_ALL_FRAMES);
	}

	/* printk("e1000_ethtool_setrxall (%s) val: %d\n",
	   netdev->name, val); */
	if (old_flags != netdev->priv_flags) {
		spin_lock_bh(&netdev->xmit_lock);
		if (netif_running(netdev)) {
			/*printk("Kicking e1000 for setrxall..\n");*/
			e1000_set_multi(netdev);
		} else {
			/* Value will be flushed into the hardware when the device is
			 * brought up.
			 */
		}
		spin_unlock_bh(&netdev->xmit_lock);
	}
	return 0;
}


...

	case ETHTOOL_SETRXALL: {
		struct ethtool_value id;
		if (copy_from_user(&id, addr, sizeof(id)))
			return -EFAULT;
		e1000_ethtool_setrxall(netdev, id.data);
		return 0;
	}


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
