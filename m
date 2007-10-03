From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] rtnl: Simplify ASSERT_RTNL
Date: Wed, 3 Oct 2007 14:06:03 +0800
Message-ID: <20071003060603.GA6457@gondor.apana.org.au>
References: <E1IbTz0-0000FK-00@gondolin.me.apana.org.au>
	<46FE7019.4030705@trash.net>
	<20070930002421.GA7502@gondor.apana.org.au>
	<46FFC512.9060101@trash.net>
	<20071002092819.GA29824@gondor.apana.org.au>
	<alpine.DEB.0.9999.0710021658100.12705@x2>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oliver@neukum.name,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	linux-usb-devel@lists.sourceforge.net, davem@davemloft.net
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-usb-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.0.9999.0710021658100.12705@x2>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-usb-devel>
List-Post: <mailto:linux-usb-devel@lists.sourceforge.net>
List-Help: <mailto:linux-usb-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: linux-usb-devel-bounces@lists.sourceforge.net
Errors-To: linux-usb-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, Oct 02, 2007 at 05:29:11PM +0200, Patrick McHardy wrote:
>
> I think this doesn't completely fix it, when dev_unicast_add is
> interrupted by dev_mc_add before the unicast changes are performed,
> they will get committed in the dev_mc_add context, so we might still
> call change_flags with BH disabled. Taking the TX lock around the
> dev->uc_count and dev->uc_promisc checks and changes in __dev_set_rx_mode
> should fix this.

Good catch.  Digging back in history it seems that you added
the change_rx_flags function so that the driver didn't have to
do it under TX lock, right?

The problem with this is that the stack can now call
change_rx_flags and set_multicast_list simultaneously
which presents a potential headache for the driver
author (if they were to use change_rx_flags).

It seems to me what we could do is in fact separate out the
part that adds the address and the part that syncs it with
hardware.

That way we can call the hardware from a process context later
and use the RTNL to guarantee that we only enter the driver
once.

So dev_mc_add would look like:

1) Hold some form of lock L.
2) Modify mc list A (a copy of the current mc list).
3) Drop lock.
4) Schedule an update to the hardware.

The update to the hardware would look lie:

1) Hold RTNL.
2) Hold lock L.
3) Copy list A to list B (B would be our current list).
4) Drop lock L.
5) Call the hardware.
6) Drop RTNL.

For compatibility, set_multicast_list would still be invoked
under the TX lock while set_rx_mode would do exactly the same
thing but would only hold the RTNL.

What do you think about this approach?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
linux-usb-devel@lists.sourceforge.net
To unsubscribe, use the last form field at:
https://lists.sourceforge.net/lists/listinfo/linux-usb-devel
