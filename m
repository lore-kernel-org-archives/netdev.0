From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 4/10] s390: network driver.
Date: Mon, 20 Dec 2004 13:54:53 -0500
Message-ID: <41C71FFD.7090308@pobox.com>
References: <OF28701C56.81E1D26E-ONC1256F6B.00513EDD-C1256F6B.0052AF84@de.ibm.com>	 <1103484552.1046.155.camel@jzny.localdomain>  <41C600D7.70005@tpack.net>	 <1103497516.1046.231.camel@jzny.localdomain>  <41C612BC.5070909@tpack.net> <1103551830.1047.316.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tommy Christensen <tommy.christensen@tpack.net>,
        Thomas Spatzier <thomas.spatzier@de.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Hasso Tepper <hasso@estpak.ee>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        Paul Jakma <paul@clubi.ie>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1103551830.1047.316.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> I beginuing to think thats the simplest way to achieve this: i.e not to
> stop the queue but rather to let the packets continue showing up and
> drop them at the driver when the link is down . The netlink async
> carrier signal to the app is to be used to reroute instead of being a
> signal to flush buffers. In other words the other Thomas got it right
> (with the exception of setting the IFF_RUNNIGN flags)
> 
> Jeff? 


I haven't heard anything to convince me that the same change should be 
deployed across NNN drivers.  The drivers already signal the net core 
that the link is down; to me, that implies there should be code in _one_ 
place that handles this condition, not NNN places.

Further,
* if this policy ("drop them in the driver") ever changes, we must again 
touch NNN drivers

* dropping them in the driver but not stopping the queue means that the 
system is allowed to continue to stream data into the driver, only for 
the driver to free it.  That will scale -- right up to (worst case) 100% 
CPU, with userland sending packets as fast as it can, and the driver 
dropping packets as fast as it can.  The only places the net stack 
currently checks carrier is dev_get_flags() and dev_watchdog().

* If you need a hook to flush the in-hardware buffers, add such a hook. 
  Don't hack it in like this.  Yeah, adding a hook touches NNN drivers 
but at least the hook is far more self-contained, it's semantics will be 
more clear, and it will increase the likelihood that the driver changes 
do not affect the hot path nor current netif_{start,stop}_queue() logic.

	Jeff
