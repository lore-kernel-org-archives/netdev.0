From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: [net-next PATCH] net: codel: Avoid undefined behavior from
 signed overflow
Date: Thu, 31 Oct 2013 22:53:32 +0100
Message-ID: <20131031225332.38534539@redhat.com>
References: <20131030172341.19203.93490.stgit@dragon>
	<1383161748.1601.24.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	<netdev@vger.kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Dave Taht <dave.taht@gmail.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12605 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751823Ab3JaVyE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Oct 2013 17:54:04 -0400
In-Reply-To: <1383161748.1601.24.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Oct 2013 19:35:48 +0000
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Wed, 2013-10-30 at 18:23 +0100, Jesper Dangaard Brouer wrote:
> > From: Jesper Dangaard Brouer <netoptimizer@brouer.com>
> > 
> > As described in commit 5a581b367 (jiffies: Avoid undefined
> > behavior from signed overflow), according to the C standard
> > 3.4.3p3, overflow of a signed integer results in undefined
> > behavior.
> [...]
> 
> According to the real processors that Linux runs on, signed arithmetic
> uses 2's complement representation and overflow wraps accordingly.  And
> we rely on that behaviour in many places, so we use
> '-fno-strict-overflow' to tell gcc not to assume we avoid signed
> overflow.  (There is also '-fwrapv' which tells gcc to assume the
> processor behaves this way, but shouldn't it already know how the target
> machine works?)

For 16-bit I have tested that is fails, and that it does not help to
use the compiler flag: '-fno-strict-overflow' or '-fwrapv'. (this was
userspace test code, so I might be missing some kernel compiler options
that would make this work for 16-bit, but I doubt it)

#define works_u16_time_after(a,b)			\
	(typecheck(u_int16_t, a) &&		\
	 typecheck(u_int16_t, b) &&		\
	 ((int16_t)((b) - (a)) < 0))

#define bad_u16_time_after(a,b)			\
	(typecheck(u_int16_t, a) &&		\
	 typecheck(u_int16_t, b) &&		\
	 (((int16_t)(b) - (int16_t)(a)) < 0))


The bnx2x have a wrong/dangerup construct:

 File: drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
 #define SUB_S16(a, b)		(s16)((s16)(a) - (s16)(b))
 #define SUB_S32(a, b)		(s32)((s32)(a) - (s32)(b))

I have tested this case, and it surprisingly works, due to the outer
(s16) cast I believe.

I think this should/could be fixed like:

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 4e01c57..8969733 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -838,8 +838,8 @@ static inline bool bnx2x_fp_ll_polling(struct bnx2x_fastpath *fp)
 #define RCQ_TH_HI(bp)          (RCQ_TH_LO(bp) + DROPLESS_FC_HEADROOM)
 
 /* This is needed for determining of last_max */
-#define SUB_S16(a, b)          (s16)((s16)(a) - (s16)(b))
-#define SUB_S32(a, b)          (s32)((s32)(a) - (s32)(b))
+#define SUB_S16(a, b)          (s16)((u16)(a) - (u16)(b))
+#define SUB_S32(a, b)          (s32)((u32)(a) - (u32)(b))
 
 #define BNX2X_SWCID_SHIFT      17
 #define BNX2X_SWCID_MASK       ((0x1 << BNX2X_SWCID_SHIFT) - 1)


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
