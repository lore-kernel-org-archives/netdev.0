From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 06/21] orinoco: remove debug buffer code and userspace include support
Date: Fri, 07 Apr 2006 04:10:30 -0400
Message-ID: <20060407081030.16107.57728.stgit@dv.roinet.com>
References: <20060407081019.16107.67672.stgit@dv.roinet.com>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
In-Reply-To: <20060407081019.16107.67672.stgit-fdEtzkpK75rby3iVrkZq2A@public.gmane.org>
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
---

 drivers/net/wireless/hermes.c |   19 -------------------
 drivers/net/wireless/hermes.h |   34 ----------------------------------
 2 files changed, 0 insertions(+), 53 deletions(-)

diff --git a/drivers/net/wireless/hermes.c b/drivers/net/wireless/hermes.=
c
index 346c6fe..456d934 100644
--- a/drivers/net/wireless/hermes.c
+++ b/drivers/net/wireless/hermes.c
@@ -121,12 +121,6 @@ void hermes_struct_init(hermes_t *hw, vo
 	hw->iobase =3D address;
 	hw->reg_spacing =3D reg_spacing;
 	hw->inten =3D 0x0;
-
-#ifdef HERMES_DEBUG_BUFFER
-	hw->dbufp =3D 0;
-	memset(&hw->dbuf, 0xff, sizeof(hw->dbuf));
-	memset(&hw->profile, 0, sizeof(hw->profile));
-#endif
 }
=20
 int hermes_init(hermes_t *hw)
@@ -345,20 +339,7 @@ static int hermes_bap_seek(hermes_t *hw,
 		k--;
 		udelay(1);
 		reg =3D hermes_read_reg(hw, oreg);
-	}
-
-#ifdef HERMES_DEBUG_BUFFER
-	hw->profile[HERMES_BAP_BUSY_TIMEOUT - k]++;
-
-	if (k < HERMES_BAP_BUSY_TIMEOUT) {
-		struct hermes_debug_entry *e =3D=20
-			&hw->dbuf[(hw->dbufp++) % HERMES_DEBUG_BUFSIZE];
-		e->bap =3D bap;
-		e->id =3D id;
-		e->offset =3D offset;
-		e->cycles =3D HERMES_BAP_BUSY_TIMEOUT - k;
 	}
-#endif
=20
 	if (reg & HERMES_OFFSET_BUSY)
 		return -ETIMEDOUT;
diff --git a/drivers/net/wireless/hermes.h b/drivers/net/wireless/hermes.=
h
index 7644f72..34ccba2 100644
--- a/drivers/net/wireless/hermes.h
+++ b/drivers/net/wireless/hermes.h
@@ -328,16 +328,6 @@ struct hermes_multicast {
 	u8 addr[HERMES_MAX_MULTICAST][ETH_ALEN];
 } __attribute__ ((packed));
=20
-// #define HERMES_DEBUG_BUFFER 1
-#define HERMES_DEBUG_BUFSIZE 4096
-struct hermes_debug_entry {
-	int bap;
-	u16 id, offset;
-	int cycles;
-};
-
-#ifdef __KERNEL__
-
 /* Timeouts */
 #define HERMES_BAP_BUSY_TIMEOUT (10000) /* In iterations of ~1us */
=20
@@ -347,14 +337,7 @@ typedef struct hermes {
 	int reg_spacing;
 #define HERMES_16BIT_REGSPACING	0
 #define HERMES_32BIT_REGSPACING	1
-
 	u16 inten; /* Which interrupts should be enabled? */
-
-#ifdef HERMES_DEBUG_BUFFER
-	struct hermes_debug_entry dbuf[HERMES_DEBUG_BUFSIZE];
-	unsigned long dbufp;
-	unsigned long profile[HERMES_BAP_BUSY_TIMEOUT+1];
-#endif
 } hermes_t;
=20
 /* Register access convenience macros */
@@ -461,22 +444,5 @@ static inline int hermes_write_wordrec(h
 	__le16 rec =3D cpu_to_le16(word);
 	return HERMES_WRITE_RECORD(hw, bap, rid, &rec);
 }
-
-#else /* ! __KERNEL__ */
-
-/* These are provided for the benefit of userspace drivers and testing p=
rograms
-   which use ioperm() or iopl() */
-
-#define hermes_read_reg(base, off) (inw((base) + (off)))
-#define hermes_write_reg(base, off, val) (outw((val), (base) + (off)))
-
-#define hermes_read_regn(base, name) (hermes_read_reg((base), HERMES_##n=
ame))
-#define hermes_write_regn(base, name, val) (hermes_write_reg((base), HER=
MES_##name, (val)))
-
-/* Note that for the next two, the count is in 16-bit words, not bytes *=
/
-#define hermes_read_data(base, off, buf, count) (insw((base) + (off), (b=
uf), (count)))
-#define hermes_write_data(base, off, buf, count) (outsw((base) + (off), =
(buf), (count)))
-
-#endif /* ! __KERNEL__ */
=20
 #endif  /* _HERMES_H */



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting langua=
ge
that extends applications into web and mobile media. Attend the live webc=
ast
and join the prime developer group breaking into this new coding territor=
y!
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D110944&bid=3D241720&dat=3D=
121642
