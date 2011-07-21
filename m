From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: fix ethtool_get_regs() to work with zero
 length registers
Date: Thu, 21 Jul 2011 19:46:48 +0200
Message-ID: <1311270409.28569.32.camel@localhost>
References: <20110720091850.32210.2059.stgit@localhost6.localdomain6>
	 <1311161889.1041.11.camel@localhost> <4E26C2DC.8090208@qca.qualcomm.com>
	 <20110720143611.GA18231@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@qca.qualcomm.com>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:4287 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751678Ab1GURqz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 13:46:55 -0400
In-Reply-To: <20110720143611.GA18231@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-07-20 at 10:36 -0400, John W. Linville wrote:
> On Wed, Jul 20, 2011 at 02:58:20PM +0300, Kalle Valo wrote:
> > On 07/20/2011 02:38 PM, Ben Hutchings wrote:
> > > On Wed, 2011-07-20 at 12:18 +0300, Kalle Valo wrote:
> > >> cfg80211 exports zero length register size as it currently only uses
> > >> struct ethtool_regs.version to export struct wiphy.hw_version.
> > > [...]
> > > 
> > > The ethtool_regs::version field represents the version of the register
> > > dump format.  This may or may not relate to a hardware version.
> 
> This seems like a strange claim to make...?
> 
> struct ethtool_regs {
> 	__u32	cmd;
> 	__u32	version; /* driver-specific, indicates different chips/revs */
> 	__u32	len; /* bytes */
> 	__u8	data[0];
> };
> 
> That "indicates different chips/revs" comment has been there at least
> as long as the kernel has been in git (back to the 2.6.12 era).

Well, it is most importantly *driver-specific*.

> > > If you don't actually provide a register dump then don't implement this
> > > operation.
> > 
> > Then we have a problem as cfg80211 exports the hw version without any
> > register dumps:
> > 
> > static int cfg80211_get_regs_len(struct net_device *dev)
> > {
> > 	/* For now, return 0... */
> > 	return 0;
> > }
> > 
> > static void cfg80211_get_regs(struct net_device *dev, struct
> > ethtool_regs *regs,
> > 			void *data)
> > {
> > 	struct wireless_dev *wdev = dev->ieee80211_ptr;
> > 
> > 	regs->version = wdev->wiphy->hw_version;
> > 	regs->len = 0;
> > }
> > 
> > And this has been there a long time already. How cfg80211 should export
> > hw version if this is not a proper way?
> 
> The ethool binary already has support for the at76c50x_usb driver,
> which uses this very mechanism in exactly this way.  I know this
> worked previously, although I don't know what might have changed to
> break it...?

This is due to:

commit a77f5db361ed9953b5b749353ea2c7fed2bf8d93
Author: Ben Hutchings <bhutchings@solarflare.com>
Date:   Mon Sep 20 08:42:17 2010 +0000

    ethtool: Allocate register dump buffer with vmalloc()

kmalloc() returns a non-null pointer for size=0 but vmalloc() doesn't.

I was unaware that some drivers would (ab)use this operation to export
only hardware revision.  Given that they do, I suppose this must be made
to work again - either using Kalle's fix or the one following this.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

