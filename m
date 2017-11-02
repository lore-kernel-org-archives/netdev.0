From: David Daney <david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/7] MIPS: Octeon: Enable LMTDMA/LMTST operations.
Date: Wed,  1 Nov 2017 17:36:01 -0700
Message-ID: <20171102003606.19913-3-david.daney@cavium.com>
References: <20171102003606.19913-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        "Steven J. Hill" <steven.hill-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Carlos Munoz <cmunoz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        "Steven J . Hill" <Steven.Hill-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        David Daney <david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org,
        James Hogan <james.hogan-8NJIiSa5LzA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20171102003606.19913-1-david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Carlos Munoz <cmunoz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>

LMTDMA/LMTST operations move data between cores and I/O devices:

* LMTST operations can send an address and a variable length
  (up to 128 bytes) of data to an I/O device.
* LMTDMA operations can send an address and a variable length
  (up to 128) of data to the I/O device and then return a
  variable length (up to 128 bytes) response from the IOI device.

Signed-off-by: Carlos Munoz <cmunoz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Steven J. Hill <Steven.Hill-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: David Daney <david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
---
 arch/mips/cavium-octeon/setup.c       |  6 ++++++
 arch/mips/include/asm/octeon/octeon.h | 12 ++++++++++--
 2 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/arch/mips/cavium-octeon/setup.c b/arch/mips/cavium-octeon/setup.c
index a8034d0dcade..99e6a68bc652 100644
--- a/arch/mips/cavium-octeon/setup.c
+++ b/arch/mips/cavium-octeon/setup.c
@@ -609,6 +609,12 @@ void octeon_user_io_init(void)
 #else
 	cvmmemctl.s.cvmsegenak = 0;
 #endif
+	if (OCTEON_IS_OCTEON3()) {
+		/* Enable LMTDMA */
+		cvmmemctl.s.lmtena = 1;
+		/* Scratch line to use for LMT operation */
+		cvmmemctl.s.lmtline = 2;
+	}
 	/* R/W If set, CVMSEG is available for loads/stores in
 	 * supervisor mode. */
 	cvmmemctl.s.cvmsegenas = 0;
diff --git a/arch/mips/include/asm/octeon/octeon.h b/arch/mips/include/asm/octeon/octeon.h
index c99c4b6a79f4..92a17d67c1fa 100644
--- a/arch/mips/include/asm/octeon/octeon.h
+++ b/arch/mips/include/asm/octeon/octeon.h
@@ -179,7 +179,15 @@ union octeon_cvmemctl {
 		/* RO 1 = BIST fail, 0 = BIST pass */
 		__BITFIELD_FIELD(uint64_t wbfbist:1,
 		/* Reserved */
-		__BITFIELD_FIELD(uint64_t reserved:17,
+		__BITFIELD_FIELD(uint64_t reserved_52_57:6,
+		/* When set, LMTDMA/LMTST operations are permitted */
+		__BITFIELD_FIELD(uint64_t lmtena:1,
+		/* Selects the CVMSEG LM cacheline used by LMTDMA
+		 * LMTST and wide atomic store operations.
+		 */
+		__BITFIELD_FIELD(uint64_t lmtline:6,
+		/* Reserved */
+		__BITFIELD_FIELD(uint64_t reserved_41_44:4,
 		/* OCTEON II - TLB replacement policy: 0 = bitmask LRU; 1 = NLU.
 		 * This field selects between the TLB replacement policies:
 		 * bitmask LRU or NLU. Bitmask LRU maintains a mask of
@@ -275,7 +283,7 @@ union octeon_cvmemctl {
 		/* R/W Size of local memory in cache blocks, 54 (6912
 		 * bytes) is max legal value. */
 		__BITFIELD_FIELD(uint64_t lmemsz:6,
-		;)))))))))))))))))))))))))))))))))
+		;))))))))))))))))))))))))))))))))))))
 	} s;
 };
 
-- 
2.13.6

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
