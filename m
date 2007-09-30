From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] rtnl: Simplify ASSERT_RTNL
Date: Sun, 30 Sep 2007 08:24:22 +0800
Message-ID: <20070930002421.GA7502@gondor.apana.org.au>
References: <E1IbTz0-0000FK-00@gondolin.me.apana.org.au>
	<46FE7019.4030705@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oliver@neukum.name,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	linux-usb-devel@lists.sourceforge.net, davem@davemloft.net
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-usb-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <46FE7019.4030705@trash.net>
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

On Sat, Sep 29, 2007 at 05:32:41PM +0200, Patrick McHardy wrote:
>
> For unicast addresses its not strictly necessary since they may
> only be changed under the RTNL anyway. The reason why it takes
> the tx_lock is for consistency with multicast address handling,
> which can't rely on the RTNL since IPv6 changes them from
> BH context. The idea was that the ->set_rx_mode function should
> handle both secondary unicast and multicast addresses for
> simplicity.

OK, the documentation (which predates USB NIC drivers) disagrees
with me and dev->set_multicast will always operate with the xmit
lock.

This isn't very nice for USB drivers since they have to leave
the change request hanging after dev->set_multicast returns.
I suppose the one thing that guarantees this will work is the
S in USB :)

However, at least one USB driver is buggy (kaweth) in not
allowing another set_multicast until the previous one is
done, which can lead to silent losses of set_multicast calls
since it's a void.

In any case, coming back to the original question, the RTNL
assertion is simply wrong in this case because if we're being
called from IPv6 then the RTNL won't even be held.

So I think we need to

1) Move the assert into dev_set_promiscuity.
2) Take the TX lock in dev_set_promiscuity.

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
