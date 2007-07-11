From: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
Subject: Re: [Bugme-new] [Bug 8724] New: Unaligned acess in udp_recvmsg() on EV56
Date: Wed, 11 Jul 2007 17:45:11 +0400
Message-ID: <20070711174511.B1148@jurassic.park.msu.ru>
References: <bug-8724-10286@http.bugzilla.kernel.org/> <20070708152935.b34d6e66.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Richard Henderson <rth@twiddle.net>, netdev@vger.kernel.org,
	jailbird@alcatraz.fdf.net,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@kernel-bugs.osdl.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jurassic.park.msu.ru ([195.208.223.243]:43182 "EHLO
	jurassic.park.msu.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760528AbXGKNpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 09:45:11 -0400
Content-Disposition: inline
In-Reply-To: <20070708152935.b34d6e66.akpm@linux-foundation.org>; from akpm@linux-foundation.org on Sun, Jul 08, 2007 at 03:29:35PM -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 08, 2007 at 03:29:35PM -0700, Andrew Morton wrote:
> > This problem does NOT seem to affect my Tsunami/Shark (EV68AL) box running the
> > same kernel version on the same LAN.  Not sure if it's CPU generation related
> > (EV5 vs EV6), or if it's the NIC (via_rhine on the EV5 vs e100 on the EV6).

It is the NIC, I suppose.

> I don't think there's necessarily a bug here: that's just the kernel
> telling us that there are unaligned accesses which got successfully
> fixed up, so we're being perhaps a bit inefficient.  Yes?

Sort of. It's not exactly a bug, just an old and well known problem
with ethernet controllers that can do DMA only at 32-bit boundaries,
so the IP headers are not properly aligned. A workaround is to
disable "rx_copybreak" feature, either by passing "rx_copybreak=1536"
to the driver, or add #ifdef to via_rhine.c, like tulip, starfire and
many other drivers have:

/*
 * Set the copy breakpoint for the copy-only-tiny-frames scheme.
 * Setting to > 1518 effectively disables this feature.
 *
 * NOTE:
 * The ia64 doesn't allow for unaligned loads even of integers being
 * misaligned on a 2 byte boundary. Thus always force copying of
 * packets as the starfire doesn't allow for misaligned DMAs ;-(
 * 23/10/2000 - Jes
 *
 * The Alpha and the Sparc don't like unaligned loads, either. On Sparc64,
 * at least, having unaligned frames leads to a rather serious performance
 * penalty. -Ion
 */
#if defined(__ia64__) || defined(__alpha__) || defined(__sparc__)
static int rx_copybreak = PKT_BUF_SZ;
#else
static int rx_copybreak /* = 0 */;
#endif

Ivan.
