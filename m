From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] select appropriate skb size in tcp_sendmsg when TSO is used
Date: Tue, 26 Oct 2004 21:19:12 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041026111912.GA18095@gondor.apana.org.au>
References: <OF96546AB5.ACE12043-ONC1256F33.0027BC6B-C1256F33.002D4A6E@de.ibm.com> <E1CKE5P-0005SP-00@gondolin.me.apana.org.au> <20041020163510.6d13e9c7.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: thomas.spatzier@de.ibm.com, netdev@oss.sgi.com,
        Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041020163510.6d13e9c7.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Oct 20, 2004 at 04:35:10PM -0700, David S. Miller wrote:
> 
> BTW, we allow mucking of all of these SG, TSO, CSUM settings
> via ethtool yet the "X needs Y" rules are not enforced.  I
> can't think of an easy way to do this without touching a lot
> of drivers.  Perhaps something like:

Well since they're all being invoked through ethtool, you can
just enforce the policy there.  So let's take set_tx_csum
as the example again, you'd do this in ethtool_set_tx_csum:

	if (!dev->ethtool_ops->set_tx_csum)
		return -EOPNOTSUPP;

	if (copy_from_user(&edata, useraddr, sizeof(edata)))
		return -EFAULT;

	if (!edata.data && (dev->features & NETIF_F_SG))
		__ethtool_set_sg(dev, 0);

	return dev->ethtool_ops->set_tx_csum(dev, edata.data);

Where __ethtool_set_sg would be ethtool_set_sg with the second
argument turned into a simple int.  It can then do a similar
check to turn off TSO.
 
> It just occured to me that instead of manually clearing
> dev->feature bits we should invoke the appropriate ethtool
> op to accomplish that just in case the device needs to do
> something implementation specific when disabling said features.
> This implies that ethtool_feature_change() should be invoked
> without any device locks set to prevent deadlocks.

Absolutely.  That sounds exactly like what I've just described :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
