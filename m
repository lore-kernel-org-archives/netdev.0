From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2.6.12-rc2] bonding: partially back out dev_set_mac_address
Date: Mon, 25 Apr 2005 22:41:36 +1000
Message-ID: <20050425124136.GA20159@gondor.apana.org.au>
References: <20050408221629.GA21125@gondor.apana.org.au> <200504082356.j38Ntr7k010144@death.nxdomain.ibm.com> <20050409002137.GA21726@gondor.apana.org.au> <20050409003108.GA21962@gondor.apana.org.au> <20050424185149.278ffb93.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="4Ckj6UjgE2iN1+kY"
Cc: fubar@us.ibm.com, netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050424185149.278ffb93.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Apr 24, 2005 at 06:51:49PM -0700, David S. Miller wrote:
>
> > So if you want a quick and dirty fix, why not make bonding call
> > dev_set_mac_address from a work queue?
> 
> I'd say we still have at least two weeks until 2.6.12 final goes out.
> So if you want to work on the proper long-term fix now, by all means
> please do so.

Well I had a go at it but I realised that this isn't something that
can be fixed properly in two weeks.  The work queue hack can
probably be done in that time frame but it'll be darn ugly.

I found another reason why we need to defer the dev_set_mac_address to
process context: We need to hold the RTNL while it's taking place.
Otherwise someone else could come along and change the slave's MAC
address at the same time.  Because device drivers tend to rely on the
RTNL to guarantee non-reentrancy, this is likely to break.

I also managed to find a little bug along the way though so let's quash
it :) bond_alb_set_mac_address did not acquire bond->lock before
operating on the slaves.  As it can be done at any time by the user,
this could interfere with the timers.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

drivers/net/bonding/bond_alb.c: 5ce606d9dc03f9b145c3024abecfca20ec65fd9d
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1666,6 +1666,7 @@ int bond_alb_set_mac_address(struct net_
 		}
 	}
 
+	write_lock_bh(&bond->lock);
 	if (swap_slave) {
 		alb_swap_mac_addr(bond, swap_slave, bond->curr_active_slave);
 	} else {
@@ -1678,6 +1679,7 @@ int bond_alb_set_mac_address(struct net_
 			rlb_req_update_slave_clients(bond, bond->curr_active_slave);
 		}
 	}
+	write_unlock_bh(&bond->lock);
 
 	return 0;
 }

--4Ckj6UjgE2iN1+kY--
