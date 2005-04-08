From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2.6.12-rc2] bonding: partially back out dev_set_mac_address
Date: Fri, 08 Apr 2005 22:36:28 +1000
Message-ID: <E1DJsiq-0006xJ-00@gondolin.me.apana.org.au>
References: <200504072135.j37LZt4f004009@death.nxdomain.ibm.com>
Cc: davem@davemloft.net, netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: fubar@us.ibm.com (Jay Vosburgh)
In-Reply-To: <200504072135.j37LZt4f004009@death.nxdomain.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jay Vosburgh <fubar@us.ibm.com> wrote:
> 
>        Yes, that works, and yes, the troublesome calls come from
> softirq (timers).  In that case, the rtnetlink patch would be:

This should work.

However, this is a bit of an eye sore as it is the only place
where rtmsg_ifinfo is called from softirq context.  In fact,
this is probably the only place where CHANGEADDR (and perhaps
even call_netdevice_notifiers) is called from softirq context.

It just so happens that all the CHANGEADDR handlers were coded to be
on the safe side and this seems to be the only place where it sleeps.

Nevertheless, I'd like to ask the possibility for bond to not do
this from softirq context.

I looked at bond_alb.c briefly and it appears that the MAC addresses
aren't actually set from the timers.  It is however set in user
context with spin locks held to guard against the timer.

I looked at one of those places: alb_handle_addr_collision_on_attach.
As far as I can see, there is no need for the address change to occur
under the write_lock.

It would work just as well if that function returned the MAC address
to be set and performed the actual setting after dropping the lock.

So if you have time, could you please comb through the bonding driver
and let us know if it is possible to move the setting of the MAC
address outside atomic areas.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
