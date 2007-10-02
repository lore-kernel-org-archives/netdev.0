From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] rtnl: Simplify ASSERT_RTNL
Date: Tue, 2 Oct 2007 17:29:11 +0200 (CEST)
Message-ID: <alpine.DEB.0.9999.0710021658100.12705@x2>
References: <E1IbTz0-0000FK-00@gondolin.me.apana.org.au>
	<46FE7019.4030705@trash.net>
	<20070930002421.GA7502@gondor.apana.org.au>
	<46FFC512.9060101@trash.net>
	<20071002092819.GA29824@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oliver@neukum.name,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	linux-usb-devel@lists.sourceforge.net, davem@davemloft.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-usb-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20071002092819.GA29824@gondor.apana.org.au>
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

On Tue, 2 Oct 2007, Herbert Xu wrote:

> On Sun, Sep 30, 2007 at 05:47:30PM +0200, Patrick McHardy wrote:
>>
> I'm a bit uncomfortable with having a function (change_flags)
> that's sometimes in a sleepable context and sometimes running
> with BH disabled.
>
> So how about splitting up the unicast/multicast entry points
> as follows?

>
> [NET]: Restore multicast-only __dev_mc_upload
>
> As it is dev_set_rx_mode needs to cope with being called with
> or without the RTNL.  This is rather confusing when it comes
> to understanding what locks are being held at a particular
> point.
>
> Since the only path that calls it without the RTNL is in the
> multicast code, we could avoid the confusion by splitting that
> out.
>
> This patch restores the old __dev_mc_upload as a multicast-only
> variant of dev_set_rx_mode.  It also gets rid of the now-unused
> __dev_set_rx_mod and makes dev_set_rx_mode static since it's
> only used in net/core/dev.c.
>
> As a side-effect this fixes the warning triggered by the
> RTNL_ASSERT in __dev_set_promiscuity.


I think this doesn't completely fix it, when dev_unicast_add is
interrupted by dev_mc_add before the unicast changes are performed,
they will get committed in the dev_mc_add context, so we might still
call change_flags with BH disabled. Taking the TX lock around the
dev->uc_count and dev->uc_promisc checks and changes in __dev_set_rx_mode
should fix this.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
linux-usb-devel@lists.sourceforge.net
To unsubscribe, use the last form field at:
https://lists.sourceforge.net/lists/listinfo/linux-usb-devel
