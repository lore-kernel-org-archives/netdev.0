From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Wed, 22 Aug 2012 15:24:59 +0100
Message-ID: <1345645499.15245.8.camel@deadeye.wl.decadent.org.uk>
References: <1345598601.2659.76.camel@bwh-desktop.uk.solarflarecom.com>
	 <503437D4.8090706@zytor.com>
	 <1345601051.2659.93.camel@bwh-desktop.uk.solarflarecom.com>
	 <20120821.193446.1534561579811962053.davem@davemloft.net>
	 <503450E2.2040504@zytor.com>
	 <CA+55aFy=ohFoZ1yZGdj1DCcNXU9gsndgH9Qod4q8+s=sbGKUzQ@mail.gmail.com>
	 <1345642009.15245.0.camel@deadeye.wl.decadent.org.uk>
	 <CA+55aFzxhxjOeFSUUJ6XQGUmnaZf7QPSz611zmj2VziEDUB_sA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "H. Peter Anvin" <hpa@zytor.com>,
	David Miller <davem@davemloft.net>, <tglx@linutronix.de>,
	<mingo@redhat.com>, <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>, <x86@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:27721 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753085Ab2HVOZF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 10:25:05 -0400
In-Reply-To: <CA+55aFzxhxjOeFSUUJ6XQGUmnaZf7QPSz611zmj2VziEDUB_sA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-08-22 at 07:20 -0700, Linus Torvalds wrote:
> On Wed, Aug 22, 2012 at 6:26 AM, Ben Hutchings
> <bhutchings@solarflare.com> wrote:
> >
> > It's <1345598804.2659.78.camel@bwh-desktop.uk.solarflarecom.com>.
> 
> That doesn't help me in the least. I don't *have* that email. It was
> never sent to me. I don't know what list it went on, and googling the
> ID doesn't get me anything. So sending me the mail ID is kind of
> pointless.
> 
> So I still don't see the actual patch. But everything I heard about it
> indirectly makes me go "That's just crazy".

Sorry, I'll paste it below.

> > When updating a TX DMA ring pointer in sfc, we can push the first new
> > descriptor at the same time, so that for a linear packet only one DMA
> > read is then required before the packet goes out on the wire.  Currently
> > this requires 2-4 MMIO writes (each a separate PCIe transactions),
> > depending on the host word size.  There is a measurable reduction in
> > latency if we can reduce it to 1 PCIe transaction.  (But as previously
> > discussed, write-combining isn't suitable for this.)
> 
> Quite frankly, this isn't even *remotely* changing my mind about our
> FPU model. I'm like "ok, some random driver is trying to be clever,
> and it's almost certainly getting things entirely wrong and doing
> things that only work on certain machines".
> 
> If you really think it's a big deal, do it in *your* driver, and make
> it do the whole irq_fpu_usable() check together with
> kernel_fpu_begin/end(). And make it very much x86-specific and with a
> fallback to non-atomic accesses.
[...]

Which is what I first submitted, but David wanted it to be generic.

Ben.

---
Subject: sfc: Use __raw_writeo() to perform TX descriptor push where possible

Use the new __raw_writeo() function for TX descriptor push where
available.  This means we now use only a single PCIe transaction
on x86_64 (vs 2 before), reducing TX latency slightly.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/bitfield.h |    3 +++
 drivers/net/ethernet/sfc/io.h       |   18 ++++++++++++++++--
 2 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/bitfield.h b/drivers/net/ethernet/sfc/bitfield.h
index b26a954..5feeba2 100644
--- a/drivers/net/ethernet/sfc/bitfield.h
+++ b/drivers/net/ethernet/sfc/bitfield.h
@@ -83,6 +83,9 @@ typedef union efx_qword {
 
 /* An octword (eight-word, i.e. 16 byte) datatype - little-endian in HW */
 typedef union efx_oword {
+#ifdef HAVE_INT128
+       __le128 u128;
+#endif
        __le64 u64[2];
        efx_qword_t qword[2];
        __le32 u32[4];
diff --git a/drivers/net/ethernet/sfc/io.h b/drivers/net/ethernet/sfc/io.h
index 751d1ec..fbcdc6d 100644
--- a/drivers/net/ethernet/sfc/io.h
+++ b/drivers/net/ethernet/sfc/io.h
@@ -57,10 +57,22 @@
  *   current state.
  */
 
-#if BITS_PER_LONG == 64
+#if defined(writeo)
+#define EFX_USE_OWORD_IO 1
+#endif
+
+#if defined(readq) && defined(writeq)
 #define EFX_USE_QWORD_IO 1
 #endif
 
+#ifdef EFX_USE_OWORD_IO
+static inline void _efx_writeo(struct efx_nic *efx, __le128 value,
+                              unsigned int reg)
+{
+       __raw_writeo((__force u128)value, efx->membase + reg);
+}
+#endif
+
 #ifdef EFX_USE_QWORD_IO
 static inline void _efx_writeq(struct efx_nic *efx, __le64 value,
                                  unsigned int reg)
@@ -235,7 +247,9 @@ static inline void _efx_writeo_page(struct efx_nic *efx, efx_oword_t *value,
                   "writing register %x with " EFX_OWORD_FMT "\n", reg,
                   EFX_OWORD_VAL(*value));
 
-#ifdef EFX_USE_QWORD_IO
+#if defined(EFX_USE_OWORD_IO)
+       _efx_writeo(efx, value->u128, reg);
+#elif defined(EFX_USE_QWORD_IO)
        _efx_writeq(efx, value->u64[0], reg + 0);
        _efx_writeq(efx, value->u64[1], reg + 8);
 #else

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
