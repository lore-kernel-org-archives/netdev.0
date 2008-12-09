From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: BUG: bad unlock balance detected! e1000e
Date: Tue, 9 Dec 2008 15:08:01 -0800
Message-ID: <20081209150801.2aa76ac6.akpm@linux-foundation.org>
References: <c4e36d110812080324y68c0e453qcb68a040da7ac9a2@mail.gmail.com>
	<20081209110337.GJ4864@gambetta>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: zdenek.kabelac@gmail.com, linux-kernel@vger.kernel.org,
	tglx@linutronix.de, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"David S. Miller" <davem@davemloft.net>, stable@kernel.org
To: Frederik Deweerdt <frederik.deweerdt@xprog.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46265 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751989AbYLIXIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 18:08:18 -0500
In-Reply-To: <20081209110337.GJ4864@gambetta>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 9 Dec 2008 12:03:37 +0100
Frederik Deweerdt <frederik.deweerdt@xprog.eu> wrote:

> It some error checking is missing in e1000e: debug contention on NVM
> SWFLAG
> On Mon, Dec 08, 2008 at 12:24:09PM +0100, Zdenek Kabelac wrote:
> > Hi
> > 
> > During occasional scan of message log - I've found out this BUG which
> > happened on Dec3 with the -rc7 from that day.
> > (So if it's now fixed in current git feel free to ignore :))
> > 
> > My machine T61 - C2D, 2GB, 64bit kernel - message appeared during
> > shutdown and was actually not noticed by me...
> > 
> > 
> > NetworkManager: <WARN>  nm_signal_handler(): Caught signal 15,
> > shutting down normally.
> > NetworkManager: <info>  (eth0): now unmanaged
> > NetworkManager: <info>  (eth0): device state change: 3 -> 1
> > NetworkManager: <info>  (eth0): cleaning up...
> > NetworkManager: <info>  (eth0): taking down device.
> > 
> > =====================================
> > [ BUG: bad unlock balance detected! ]
> > -------------------------------------

(top-posting repaired.  Please don't do that!!!).

> Hello Zdenek,
> 
> This could be due to 717d438d1fde94decef874b9808379d1f4523453
>     "e1000e: debug contention on NVM SWFLAG"
> Error handling is missing from e1000_reset_hw_ich8lan so it may happen
> that we don't acquire the nvm_mutex if the card times out.
> 
> Adding Thomas to CC.

yup.  2.6.27 needs fixing also.

Like this?

From: Andrew Morton <akpm@linux-foundation.org>

=====================================
[ BUG: bad unlock balance detected! ]
-------------------------------------

A regression added by 717d438d1fde94decef874b9808379d1f4523453 ("e1000e:
debug contention on NVM SWFLAG").

Reported-by: "Zdenek Kabelac" <zdenek.kabelac@gmail.com>
Cc: Frederik Deweerdt <frederik.deweerdt@xprog.eu>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: <stable@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/e1000e/ich8lan.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff -puN drivers/net/e1000e/ich8lan.c~drivers-net-e1000e-ich8lanc-fix-locking drivers/net/e1000e/ich8lan.c
--- a/drivers/net/e1000e/ich8lan.c~drivers-net-e1000e-ich8lanc-fix-locking
+++ a/drivers/net/e1000e/ich8lan.c
@@ -400,6 +400,7 @@ static s32 e1000_acquire_swflag_ich8lan(
 {
 	u32 extcnf_ctrl;
 	u32 timeout = PHY_CFG_TIMEOUT;
+	s32 ret = 0;
 
 	might_sleep();
 
@@ -427,11 +428,11 @@ static s32 e1000_acquire_swflag_ich8lan(
 		extcnf_ctrl &= ~E1000_EXTCNF_CTRL_SWFLAG;
 		ew32(EXTCNF_CTRL, extcnf_ctrl);
 		nvm_owner = -1;
-		mutex_unlock(&nvm_mutex);
-		return -E1000_ERR_CONFIG;
+		ret = -E1000_ERR_CONFIG;
 	}
 
-	return 0;
+	mutex_unlock(&nvm_mutex);
+	return ret;
 }
 
 /**
_

