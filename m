From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: IPsec with aes-cbc and geode-aes driver completely freezes 2.6.20.1
Date: Thu, 15 Mar 2007 17:23:42 +0300
Message-ID: <20070315142342.GB8597@2ka.mipt.ru>
References: <20070315134533.21402.qmail@web51408.mail.re2.yahoo.com> <20070315141506.GA8597@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, info-linux@geode.amd.com
To: Joerg Pommnitz <pommnitz@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:49882 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422715AbXCOOX5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2007 10:23:57 -0400
Content-Disposition: inline
In-Reply-To: <20070315141506.GA8597@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 15, 2007 at 05:15:06PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> On Thu, Mar 15, 2007 at 06:45:33AM -0700, Joerg Pommnitz (pommnitz@yahoo.com) wrote:
> > Hello all,
> > the subject line basically says it all. I was trying to offload IPsec encryption to the hardware encryption engine on my Geode LX800. The exact same setkey command works fine with software aes.
> > 
> > In case it matters: this is with a MSEP800/A board from DIGITAL-LOGIC AG (see http://www.digitallogic.com/english/products/catalog07/epic_detail.asp?id=MSEP800_L).
> > 
> > Did anybody ever succeed with Geode hardware accelerated IPsec? Did you have to do anything special?
> 
> Please enable as much kernel debugging options as possible and rerun the
> test - our mind readers are currently on vacations, so we fail to
> find a problem.
> 
> If there will not be any signs of the problem, try to add several printk
> into main geode crypto functions (there are not that many of them) or
> press various sysrq combinations to determine where stall happens.

As additional debug patch: try this one:

diff --git a/drivers/crypto/geode-aes.c b/drivers/crypto/geode-aes.c
index 6d3840e..edacc64 100644
--- a/drivers/crypto/geode-aes.c
+++ b/drivers/crypto/geode-aes.c
@@ -49,7 +49,7 @@
  *  operation in case of trouble
  */
 
-#define AES_OP_TIMEOUT    0x50000
+#define AES_OP_TIMEOUT    0x500
 
 /* Static structures */
 
@@ -91,6 +91,8 @@ do_crypt(void *src, void *dst, int len, u32 flags)
 		status = ioread32(_iobase + AES_INTR_REG);
 	while(!(status & AES_INTRA_PENDING) && --counter);
 
+	BUG_ON(!counter);
+
 	/* Clear the event */
 	iowrite32((status & 0xFF) | AES_INTRA_PENDING, _iobase + AES_INTR_REG);
 	return counter ? 0 : 1;


-- 
	Evgeniy Polyakov
