From: Dustin Marquess <jailbird@alcatraz.fdf.net>
Subject: Re: [Bugme-new] [Bug 8724] New: Unaligned acess in udp_recvmsg()
 on EV56
Date: Thu, 12 Jul 2007 12:45:26 -0500
Message-ID: <469668B6.7020305@alcatraz.fdf.net>
References: <bug-8724-10286@http.bugzilla.kernel.org/> <20070708152935.b34d6e66.akpm@linux-foundation.org> <20070711174511.B1148@jurassic.park.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Richard Henderson <rth@twiddle.net>, netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@kernel-bugs.osdl.org>
To: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ptxftp01.cmsnoc.com ([63.133.152.22]:40526 "EHLO
	fxnpft01.cmsnoc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756965AbXGLSNz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 14:13:55 -0400
In-Reply-To: <20070711174511.B1148@jurassic.park.msu.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bingo!  That did it.

I copied/modified the #ifdef from tulip_core.c:

/* Set the copy breakpoint for the copy-only-tiny-buffer Rx structure. */
#if defined(__alpha__) || defined(__arm__) || defined(__hppa__) \
        || defined(CONFIG_SPARC) || defined(__ia64__) \
        || defined(__sh__) || defined(__mips__)
static int rx_copybreak = 1518;
#else
static int rx_copybreak;
#endif

And that seems to have worked like a champ.

Thanks for the help.  I knew I was asking for problems by using 
non-Digital hardware in an Alpha :).

-Dustin

Ivan Kokshaysky wrote:
> On Sun, Jul 08, 2007 at 03:29:35PM -0700, Andrew Morton wrote:
>   
>>> This problem does NOT seem to affect my Tsunami/Shark (EV68AL) box running the
>>> same kernel version on the same LAN.  Not sure if it's CPU generation related
>>> (EV5 vs EV6), or if it's the NIC (via_rhine on the EV5 vs e100 on the EV6).
>>>       
>
> It is the NIC, I suppose.
>
>   
>> I don't think there's necessarily a bug here: that's just the kernel
>> telling us that there are unaligned accesses which got successfully
>> fixed up, so we're being perhaps a bit inefficient.  Yes?
>>     
>
> Sort of. It's not exactly a bug, just an old and well known problem
> with ethernet controllers that can do DMA only at 32-bit boundaries,
> so the IP headers are not properly aligned. A workaround is to
> disable "rx_copybreak" feature, either by passing "rx_copybreak=1536"
> to the driver, or add #ifdef to via_rhine.c, like tulip, starfire and
> many other drivers have:
>
> /*
>  * Set the copy breakpoint for the copy-only-tiny-frames scheme.
>  * Setting to > 1518 effectively disables this feature.
>  *
>  * NOTE:
>  * The ia64 doesn't allow for unaligned loads even of integers being
>  * misaligned on a 2 byte boundary. Thus always force copying of
>  * packets as the starfire doesn't allow for misaligned DMAs ;-(
>  * 23/10/2000 - Jes
>  *
>  * The Alpha and the Sparc don't like unaligned loads, either. On Sparc64,
>  * at least, having unaligned frames leads to a rather serious performance
>  * penalty. -Ion
>  */
> #if defined(__ia64__) || defined(__alpha__) || defined(__sparc__)
> static int rx_copybreak = PKT_BUF_SZ;
> #else
> static int rx_copybreak /* = 0 */;
> #endif
>
> Ivan.
>
>   

