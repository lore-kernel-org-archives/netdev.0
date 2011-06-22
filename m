From: "Sebastian =?ISO-8859-1?Q?P=F6hn?=" <sebastian.belden@googlemail.com>
Subject: Re: [PATCH] gianfar v5: implement nfc
Date: Wed, 22 Jun 2011 11:29:32 +0200
Message-ID: <1308734972.7885.19.camel@DENEC1DT0191>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sebastian =?ISO-8859-1?Q?P=F6hn?= <sebastian.poehn@belden.com>,
	Linux Netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:60730 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754242Ab1FVJ3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2011 05:29:38 -0400
Received: by wwe5 with SMTP id 5so642843wwe.1
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2011 02:29:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First of all thanks for the feedback. I know the fgar_swap_*bits
function is a bit ugly. The problem with your suggestion is that it is
necessary to swap a1<>a2 and b1<>b2 AT THE SAME TIME. Otherwise
information the second swap is needing is swapped away by the first one.
If you would do this as a macro I guess it will be blown up and be as
bad as it is at the moment:

#define swap_bits(a, b, c, d, bits) \
do { \
typeof(a) _bits = bits; \
typeof(a) _a_bits = (a) & _bits; \
typeof(a) _b_bits = (b) & _bits; \
typeof(a) _c_bits = (c) & _bits; \
typeof(a) _d_bits = (d) & _bits; \
\
(a) &= ~_bits; \
(b) &= ~_bits; \
(c) &= ~_bits; \
(d) &= ~_bits; \
\
(a) |= _b_bits; \
(b) |= _a_bits; \
(c) |= _d_bits; \
(d) |= _c_bits; \
} while (0)
 
> > +/* Swaps the 0xFF80 masked bits of a1<>a2 and b1<>b2 */
> > +static void gfar_swap_ff80_bits(struct gfar_filer_entry *a1,
> > + struct gfar_filer_entry *a2, struct gfar_filer_entry *b1,
> > + struct gfar_filer_entry *b2)
> > +{
> > + u32 temp[4];
> > + temp[0] = a1->ctrl & 0xFF80;
> > + temp[1] = a2->ctrl & 0xFF80;
> > + temp[2] = b1->ctrl & 0xFF80;
> > + temp[3] = b2->ctrl & 0xFF80;
> > +
> > + a1->ctrl &= ~0xFF80;
> > + a2->ctrl &= ~0xFF80;
> > + b1->ctrl &= ~0xFF80;
> > + b2->ctrl &= ~0xFF80;
> > +
> > + a1->ctrl |= temp[1];
> > + a2->ctrl |= temp[0];
> > + b1->ctrl |= temp[3];
> > + b2->ctrl |= temp[2];
> > +}
> 
> maybe add a macro similar to swap:
> 
> #define swap_bits(a, b, bits) \
> do { \
> typeof(a) _bits = bits; \
> typeof(a) _a_bits = (a) & _bits; \
> typeof(a) _b_bits = (b) & _bits; \
> \
> (a) &= ~_bits; \
> (b) &= ~_bits; \
> \
> (a) |= _b_bits; \
> (b) |= _a_bits; \
> } while (0)
> 
> and use this macro directly in gfar_sort_mask_table?
> 
> swap_bits(temp_table->fe[new_first],
>  temp_table->fe[old_first], 0xff80);
> swap_bits(temp_table->fe[new_last],
>  temp_table->fe[old_last], 0xff80);
> 
> And maybe 0xff80 should be a #define?


Signed-off-by: Sebastian Poehn <sebastian.poehn@belden.com>
---

 drivers/net/gianfar.h         |    1 +
 drivers/net/gianfar_ethtool.c |   29 ++++++++++++++++-------------
 2 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 76f14d0..27499c6 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -409,6 +409,7 @@ extern const char gfar_driver_version[];
 #define RQFCR_HASHTBL_2		0x00060000
 #define RQFCR_HASHTBL_3		0x00080000
 #define RQFCR_HASH		0x00010000
+#define RQFCR_QUEUE		0x0000FC00
 #define RQFCR_CLE		0x00000200
 #define RQFCR_RJE		0x00000100
 #define RQFCR_AND		0x00000080
diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtool.c
index 2ecdc9a..ee93bb8 100644
--- a/drivers/net/gianfar_ethtool.c
+++ b/drivers/net/gianfar_ethtool.c
@@ -1262,21 +1262,21 @@ static void gfar_cluster_filer(struct filer_table *tab)
 	}
 }
 
-/* Swaps the 0xFF80 masked bits of a1<>a2 and b1<>b2 */
-static void gfar_swap_ff80_bits(struct gfar_filer_entry *a1,
+/* Swaps the masked bits of a1<>a2 and b1<>b2 */
+static void gfar_swap_bits(struct gfar_filer_entry *a1,
 		struct gfar_filer_entry *a2, struct gfar_filer_entry *b1,
-		struct gfar_filer_entry *b2)
+		struct gfar_filer_entry *b2, u32 mask)
 {
 	u32 temp[4];
-	temp[0] = a1->ctrl & 0xFF80;
-	temp[1] = a2->ctrl & 0xFF80;
-	temp[2] = b1->ctrl & 0xFF80;
-	temp[3] = b2->ctrl & 0xFF80;
+	temp[0] = a1->ctrl & mask;
+	temp[1] = a2->ctrl & mask;
+	temp[2] = b1->ctrl & mask;
+	temp[3] = b2->ctrl & mask;
 
-	a1->ctrl &= ~0xFF80;
-	a2->ctrl &= ~0xFF80;
-	b1->ctrl &= ~0xFF80;
-	b2->ctrl &= ~0xFF80;
+	a1->ctrl &= ~mask;
+	a2->ctrl &= ~mask;
+	b1->ctrl &= ~mask;
+	b2->ctrl &= ~mask;
 
 	a1->ctrl |= temp[1];
 	a2->ctrl |= temp[0];
@@ -1356,10 +1356,13 @@ static void gfar_sort_mask_table(struct gfar_mask_entry *mask_table,
 			new_first = mask_table[start].start + 1;
 			new_last = mask_table[i - 1].end;
 
-			gfar_swap_ff80_bits(&temp_table->fe[new_first],
+			gfar_swap_bits(&temp_table->fe[new_first],
 					&temp_table->fe[old_first],
 					&temp_table->fe[new_last],
-					&temp_table->fe[old_last]);
+					&temp_table->fe[old_last],
+					RQFCR_QUEUE | RQFCR_CLE |
+						RQFCR_RJE | RQFCR_AND
+					);
 
 			start = i;
 			size = 0;


