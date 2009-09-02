From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Subject: [PATCH 4/5] Adds options DROPPED PACKETS and LOSS INTERVALS to
	receiver
Date: Tue, 1 Sep 2009 23:45:59 -0300
Message-ID: <cb00fa210909011945u2d82da97i7a7f2d1f12519a5f@mail.gmail.com>
References: <cb00fa210909011736w7fc7245cq22a04171f525ec8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: dccp <dccp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f181.google.com ([209.85.210.181]:42792 "EHLO
	mail-yx0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755583AbZIBCqQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 22:46:16 -0400
In-Reply-To: <cb00fa210909011736w7fc7245cq22a04171f525ec8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds options DROPPED PACKETS and LOSS INTERVALS to receiver. In this
patch is added the
mechanism of gathering information about loss intervals and storing
it, for later
construction of these two options.

Changes:
=A0- Adds tfrc_loss_data and tfrc_loss_data_entry, structures that
register loss intervals info
=A0- Adds dccp_skb_is_ecn_ect0 and dccp_skb_is_ecn_ect1 as necessary, s=
o
ecn can be verified and
=A0 used in loss intervals option, that reports ecn nonce sum
=A0- Adds tfrc_sp_update_li_data that updates information about loss in=
tervals
=A0- Adds tfrc_sp_ld_prepare_data, that fills fields on tfrc_loss_data
with current options values
=A0- And adds a field of type struct tfrc_loss_data to struct tfrc_hc_r=
x_sock

Signed-off-by: Ivo Calado, Erivaldo Xavier, Leandro Sales
<ivocalado@embedded.ufcg.edu.br>, <desadoc@gmail.com>,
<leandroal@gmail.com>

Index: b/net/dccp/ccids/lib/packet_history_sp.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- a/net/dccp/ccids/lib/packet_history_sp.c =A0 =A02009-08-26
23:49:59.000000000 -0300
+++ b/net/dccp/ccids/lib/packet_history_sp.c =A0 =A02009-08-27
22:36:43.000000000 -0300
@@ -339,10 +339,12 @@
=A0*/
=A0bool tfrc_sp_rx_congestion_event(struct tfrc_rx_hist *h,
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct tfrc_=
loss_hist *lh,
- =A0 =A0 =A0 =A0struct sk_buff *skb, const u64 ndp,
- =A0u32 (*first_li)(struct sock *), struct sock *sk)
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct tfrc_l=
oss_data *ld,
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sk_buf=
f *skb, const u64 ndp,
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 (*first_l=
i)(struct sock *), struct sock *sk)
=A0{
=A0 =A0 =A0 =A0bool new_event =3D false;
+ =A0 =A0 =A0 bool new_loss =3D false;

=A0 =A0 =A0 =A0if (tfrc_sp_rx_hist_duplicate(h, skb))
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
@@ -355,11 +357,12 @@
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__one_after_loss(h, skb, ndp);
=A0 =A0 =A0 =A0} else if (h->loss_count !=3D 2) {
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0DCCP_BUG("invalid loss_count %d", h->los=
s_count);
- =A0 =A0 =A0 } else if (__two_after_loss(h, skb, ndp)) {
+ =A0 =A0 =A0 } else if ((new_loss =3D __two_after_loss(h, skb, ndp))) =
{
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Update Loss Interval database and recy=
cle RX records
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0new_event =3D tfrc_sp_lh_interval_add(lh=
, h, first_li, sk,
dccp_hdr(skb)->dccph_ccval);
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 tfrc_sp_update_li_data(ld, h, skb, new_lo=
ss, new_event);
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__three_after_loss(h);

=A0 =A0 =A0 =A0} else if (dccp_data_packet(skb) && dccp_skb_is_ecn_ce(s=
kb)) {
@@ -384,6 +387,8 @@
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
=A0 =A0 =A0 =A0}

+ =A0 =A0 =A0 tfrc_sp_update_li_data(ld, h, skb, new_loss, new_event);
+
=A0 =A0 =A0 =A0/*
=A0 =A0 =A0 =A0* Update moving-average of `s' and the sum of received p=
ayload bytes.
=A0 =A0 =A0 =A0*/
Index: b/net/dccp/ccids/lib/loss_interval_sp.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- a/net/dccp/ccids/lib/loss_interval_sp.c =A0 =A0 2009-08-26
23:53:32.000000000 -0300
+++ b/net/dccp/ccids/lib/loss_interval_sp.c =A0 =A0 2009-08-27
22:36:43.000000000 -0300
@@ -14,9 +14,89 @@
=A0#include "tfrc_sp.h"

=A0static struct kmem_cache =A0*tfrc_lh_slab =A0__read_mostly;
+static struct kmem_cache =A0*tfrc_ld_slab =A0__read_mostly;
+
=A0/* Loss Interval weights from [RFC 3448, 5.4], scaled by 10 */
=A0static const int tfrc_lh_weights[NINTERVAL] =3D { 10, 10, 10, 10, 8,=
 6, 4, 2 };

+/*
+ * Allocation routine for new entries of loss interval data
+ */
+static struct tfrc_loss_data_entry* tfrc_ld_add_new(struct tfrc_loss_d=
ata* ld)
+{
+ =A0 =A0 =A0 struct tfrc_loss_data_entry* new =3D
kmem_cache_alloc(tfrc_ld_slab, GFP_ATOMIC);
+
+ =A0 =A0 =A0 if(new =3D=3D NULL)
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
+
+ =A0 =A0 =A0 memset(new, 0, sizeof(struct tfrc_loss_data_entry));
+
+ =A0 =A0 =A0 new->next =3D ld->head;
+ =A0 =A0 =A0 ld->head =3D new;
+ =A0 =A0 =A0 ld->counter++;
+
+ =A0 =A0 =A0 return new;
+}
+
+void tfrc_sp_ld_cleanup(struct tfrc_loss_data *ld)
+{
+ =A0 =A0 =A0 struct tfrc_loss_data_entry *next, *h =3D ld->head;
+
+ =A0 =A0 =A0 if(!h)
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
+
+ =A0 =A0 =A0 while(h)
+ =A0 =A0 =A0 {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 next =3D h->next;
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 kmem_cache_free(tfrc_ld_slab, h);
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 h =3D next;
+ =A0 =A0 =A0 }
+
+ =A0 =A0 =A0 ld->head =3D NULL;
+ =A0 =A0 =A0 ld->counter =3D 0;
+}
+
+void tfrc_sp_ld_prepare_data(u8 loss_count, struct tfrc_loss_data* ld)
+{
+ =A0 =A0 =A0 u8* li_ofs, *d_ofs;
+ =A0 =A0 =A0 struct tfrc_loss_data_entry* e;
+ =A0 =A0 =A0 u16 count;
+
+ =A0 =A0 =A0 li_ofs =3D &ld->loss_intervals_opts[0];
+ =A0 =A0 =A0 d_ofs =3D &ld->drop_opts[0];
+
+ =A0 =A0 =A0 count =3D 0;
+ =A0 =A0 =A0 e =3D ld->head;
+
+ =A0 =A0 =A0 *li_ofs =3D loss_count + 1;
+ =A0 =A0 =A0 li_ofs++;
+
+ =A0 =A0 =A0 while (e !=3D NULL) {
+
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if(count<TFRC_LOSS_INTERVALS_OPT_MAX_LENG=
TH)
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *li_ofs =3D ((htonl(e->lo=
ssless_length)&0x00FFFFFF)<<8);
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 li_ofs +=3D 3;
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *li_ofs =3D
((e->ecn_nonce_sum&0x1)<<31)&(htonl((e->loss_length&0x00FFFFFF))<<8);
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 li_ofs +=3D 3;
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *li_ofs =3D ((htonl(e->da=
ta_length)&0x00FFFFFF)<<8);
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 li_ofs +=3D 3;
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
+
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if(count<TFRC_DROP_OPT_MAX_LENGTH)
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *d_ofs =3D (htonl(e->drop=
_count)&0x00FFFFFF)<<8;
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 d_ofs +=3D 3;
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
+
+
if((count>=3DTFRC_LOSS_INTERVALS_OPT_MAX_LENGTH)&&(count>=3DTFRC_DROP_O=
PT_MAX_LENGTH))
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
+
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 count++;
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 e =3D e->next;
+ =A0 =A0 =A0 }
+}
+
=A0/* implements LIFO semantics on the array */
=A0static inline u8 LIH_INDEX(const u8 ctr)
=A0{
@@ -235,13 +315,166 @@
=A0 =A0 =A0 =A0return true;
=A0}

+void tfrc_sp_update_li_data(struct tfrc_loss_data *ld, struct
tfrc_rx_hist *rh, struct sk_buff *skb, bool new_loss, bool new_event)
+{
+ =A0 =A0 =A0 struct tfrc_loss_data_entry* new, *h;
+
+ =A0 =A0 =A0 if(!dccp_data_packet(skb))
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
+
+ =A0 =A0 =A0 if (ld->head =3D=3D NULL)
+ =A0 =A0 =A0 {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 new =3D tfrc_ld_add_new(ld);
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(new =3D=3D NULL)) {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 DCCP_CRIT("Cannot allocat=
e new loss data registry.");
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
+
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (new_loss)
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 new->drop_count =3D rh->n=
um_losses;
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 new->lossless_length =3D =
1;
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 new->loss_length =3D rh->=
num_losses;
+
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (dccp_data_packet(skb)=
)
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 new->data=
_length =3D 1;
+
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if(dccp_data_packet(skb) =
&& dccp_skb_is_ecn_ect1(skb))
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 new->ecn_=
nonce_sum =3D 1;
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 new->ecn_=
nonce_sum =3D 0;
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 new->drop_count =3D 0;
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 new->lossless_length =3D =
1;
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 new->loss_length =3D 0;
+
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (dccp_data_packet(skb)=
)
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 new->data=
_length =3D 1;
+
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if(dccp_data_packet(skb) =
&& dccp_skb_is_ecn_ect1(skb))
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 new->ecn_=
nonce_sum =3D 1;
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 new->ecn_=
nonce_sum =3D 0;
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
+
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
+ =A0 =A0 =A0 }
+
+ =A0 =A0 =A0 if (new_event)
+ =A0 =A0 =A0 {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 new =3D tfrc_ld_add_new(ld);
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(new =3D=3D NULL)) {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 DCCP_CRIT("Cannot allocat=
e new loss data
registry. Cleaning up.");
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tfrc_sp_ld_cleanup(ld);
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
+
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 new->drop_count =3D rh->num_losses;
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 new->lossless_length =3D (ld->last_loss_c=
ount - rh->loss_count);
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 new->loss_length =3D rh->num_losses;
+
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 new->ecn_nonce_sum =3D 0;
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 new->data_length =3D 0;
+
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 while (ld->last_loss_count > rh->loss_cou=
nt)
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ld->last_loss_count--;
+
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ld->sto_is_data&(1 <<=
 (ld->last_loss_count)))
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 new->data=
_length++;
+
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ld->s=
to_ecn&(1 << (ld->last_loss_count)))
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 new->ecn_nonce_sum =3D
!new->ecn_nonce_sum;
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
+
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
+ =A0 =A0 =A0 }
+
+ =A0 =A0 =A0 h =3D ld->head;
+
+ =A0 =A0 =A0 if (rh->loss_count > ld->last_loss_count)
+ =A0 =A0 =A0 {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 ld->last_loss_count =3D rh->loss_count;
+
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (dccp_data_packet(skb))
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ld->sto_is_data |=3D (1 <=
< (ld->last_loss_count - 1));
+
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (dccp_skb_is_ecn_ect1(skb))
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ld->sto_ecn |=3D (1 << (l=
d->last_loss_count - 1));
+
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
+ =A0 =A0 =A0 }
+
+ =A0 =A0 =A0 if (new_loss)
+ =A0 =A0 =A0 {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 h->drop_count +=3D rh->num_losses;
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 h->lossless_length =3D (ld->last_loss_cou=
nt - rh->loss_count);
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 h->loss_length +=3D h->lossless_length + =
rh->num_losses;
+
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 h->ecn_nonce_sum =3D 0;
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 h->data_length =3D 0;
+
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 while (ld->last_loss_count > rh->loss_cou=
nt)
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ld->last_loss_count--;
+
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ld->sto_is_data&(1 <<=
 (ld->last_loss_count)))
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 h->data_l=
ength++;
+
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ld->s=
to_ecn&(1 << (ld->last_loss_count)))
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 h->ecn_nonce_sum =3D !h->ecn_nonce_sum;
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
+
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
+ =A0 =A0 =A0 }
+
+ =A0 =A0 =A0 if (ld->last_loss_count > rh->loss_count)
+ =A0 =A0 =A0 {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 while (ld->last_loss_count > rh->loss_cou=
nt)
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ld->last_loss_count--;
+
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 h->lossless_length++;
+
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ld->sto_is_data&(1 <<=
 (ld->last_loss_count)))
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 h->data_l=
ength++;
+
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ld->s=
to_ecn&(1 << (ld->last_loss_count)))
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 h->ecn_nonce_sum =3D !h->ecn_nonce_sum;
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
+
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
+ =A0 =A0 =A0 }
+
+ =A0 =A0 =A0 h->lossless_length++;
+
+ =A0 =A0 =A0 if(dccp_data_packet(skb))
+ =A0 =A0 =A0 {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 h->data_length++;
+
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (dccp_skb_is_ecn_ect1(skb))
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 h->ecn_nonce_sum =3D !h->=
ecn_nonce_sum;
+ =A0 =A0 =A0 }
+}
+
=A0int __init tfrc_sp_li_init(void)
=A0{
=A0 =A0 =A0 =A0tfrc_lh_slab =3D kmem_cache_create("tfrc_sp_li_hist",
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 sizeof(struct tfrc_loss_interval), 0,
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 SLAB_HWCACHE_ALIGN, NULL);
+ =A0 =A0 =A0 tfrc_ld_slab =3D kmem_cache_create("tfrc_sp_li_data",
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0sizeof(struct tfrc_loss_data_entry), 0,
+
SLAB_HWCACHE_ALIGN, NULL);

- =A0 =A0 =A0 if((tfrc_lh_slab !=3D NULL))
+ =A0 =A0 =A0 if((tfrc_lh_slab !=3D NULL)||(tfrc_ld_slab !=3D NULL))
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;

=A0 =A0 =A0 =A0if(tfrc_lh_slab !=3D NULL)
@@ -250,6 +483,12 @@
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tfrc_lh_slab =3D NULL;
=A0 =A0 =A0 =A0}

+ =A0 =A0 =A0 if(tfrc_ld_slab !=3D NULL)
+ =A0 =A0 =A0 {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 kmem_cache_destroy(tfrc_ld_slab);
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 tfrc_ld_slab =3D NULL;
+ =A0 =A0 =A0 }
+
=A0 =A0 =A0 =A0return -ENOBUFS;
=A0}

@@ -259,4 +498,9 @@
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kmem_cache_destroy(tfrc_lh_slab);
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tfrc_lh_slab =3D NULL;
=A0 =A0 =A0 =A0}
+
+ =A0 =A0 =A0 if (tfrc_ld_slab !=3D NULL) {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 kmem_cache_destroy(tfrc_ld_slab);
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 tfrc_ld_slab =3D NULL;
+ =A0 =A0 =A0 }
=A0}
Index: b/net/dccp/ccids/lib/loss_interval_sp.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- a/net/dccp/ccids/lib/loss_interval_sp.h =A0 =A0 2009-08-26
23:44:20.000000000 -0300
+++ b/net/dccp/ccids/lib/loss_interval_sp.h =A0 =A0 2009-08-27
22:37:40.000000000 -0300
@@ -67,12 +67,44 @@
=A0 =A0 =A0 =A0return min(lh->counter, (u8)LIH_SIZE);
=A0}

-struct tfrc_rx_hist;
=A0#endif

+struct tfrc_loss_data_entry {
+ =A0 =A0 =A0 struct tfrc_loss_data_entry =A0 =A0 *next;
+ =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 lossless_length:24;
+ =A0 =A0 =A0 u8 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0ecn_nonce_sum:1;
+ =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 loss_length:24;
+ =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 data_length:24;
+ =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 drop_count:24;
+};
+
+#define TFRC_LOSS_INTERVALS_OPT_MAX_LENGTH =A0 =A0 28
+#define TFRC_DROP_OPT_MAX_LENGTH =A0 =A0 =A0 =A0 =A0 =A0 =A0 84
+
+struct tfrc_loss_data {
+ =A0 =A0 =A0 struct tfrc_loss_data_entry =A0 =A0 *head;
+ =A0 =A0 =A0 u16 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 counter;
+ =A0 =A0 =A0 u8 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0loss_intervals_opts[2 +
TFRC_LOSS_INTERVALS_OPT_MAX_LENGTH*9];
+ =A0 =A0 =A0 u8 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0drop_opts[1 +
TFRC_DROP_OPT_MAX_LENGTH*3];
+ =A0 =A0 =A0 u8 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0last_loss_count;
+ =A0 =A0 =A0 u8 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0sto_ecn;
+ =A0 =A0 =A0 u8 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0sto_is_data;
+};
+
+static inline void tfrc_ld_init(struct tfrc_loss_data* ld)
+{
+ =A0 =A0 =A0 memset(ld, 0, sizeof(struct tfrc_loss_data));
+}
+
+struct tfrc_rx_hist;
+
=A0extern bool tfrc_sp_lh_interval_add(struct tfrc_loss_hist *, struct
tfrc_rx_hist *,
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
u32 (*first_li)(struct sock *),
struct sock *, __u8 ccval);
+extern void tfrc_sp_update_li_data(struct tfrc_loss_data *, =A0struct
tfrc_rx_hist *,
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0st=
ruct sk_buff *, bool new_loss,
bool new_event);
=A0extern void tfrc_sp_lh_update_i_mean(struct tfrc_loss_hist *lh,
struct sk_buff *);
=A0extern void tfrc_sp_lh_cleanup(struct tfrc_loss_hist *lh);
+extern void tfrc_sp_ld_cleanup(struct tfrc_loss_data *ld);
+extern void tfrc_sp_ld_prepare_data(u8 loss_count, struct tfrc_loss_da=
ta* ld);

=A0#endif /* _DCCP_LI_HIST_SP_ */
Index: b/net/dccp/ccids/lib/tfrc_ccids_sp.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- a/net/dccp/ccids/lib/tfrc_ccids_sp.h =A0 =A0 =A0 =A02009-08-27
00:50:46.000000000 -0300
+++ b/net/dccp/ccids/lib/tfrc_ccids_sp.h =A0 =A0 =A0 =A02009-08-27
22:36:43.000000000 -0300
@@ -128,6 +128,7 @@
=A0* =A0@tstamp_last_feedback =A0- =A0Time at which last feedback was s=
ent
=A0* =A0@hist =A0- =A0Packet history (loss detection + RTT sampling)
=A0* =A0@li_hist =A0- =A0Loss Interval database
+ * =A0@li_data =A0- =A0Loss Interval data for options
=A0* =A0@p_inverse =A0- =A0Inverse of Loss Event Rate (RFC 4342, sec. 8=
=2E5)
=A0*/
=A0struct tfrc_hc_rx_sock {
@@ -137,6 +138,7 @@
=A0 =A0 =A0 =A0ktime_t =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
tstamp_last_feedback;
=A0 =A0 =A0 =A0struct tfrc_rx_hist =A0 =A0 =A0 =A0 =A0 =A0 hist;
=A0 =A0 =A0 =A0struct tfrc_loss_hist =A0 =A0 =A0 =A0 =A0 li_hist;
+ =A0 =A0 =A0 struct tfrc_loss_data =A0 =A0 =A0 =A0 =A0 li_data;
=A0#define p_inverse =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0li_hist=
=2Ei_mean
=A0};

Index: b/net/dccp/ccids/lib/packet_history_sp.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- a/net/dccp/ccids/lib/packet_history_sp.h =A0 =A02009-08-26
22:55:58.000000000 -0300
+++ b/net/dccp/ccids/lib/packet_history_sp.h =A0 =A02009-08-27
22:36:43.000000000 -0300
@@ -200,6 +200,7 @@

=A0extern bool tfrc_sp_rx_congestion_event(struct tfrc_rx_hist *h,
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 struct tfrc_loss_hist *lh,
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
struct tfrc_loss_data *ld,
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 struct sk_buff *skb, const u64 ndp,
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 u32 (*first_li)(struct sock *sk),
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 struct sock *sk);
Index: b/net/dccp/dccp.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- a/net/dccp/dccp.h =A0 2009-08-26 22:59:10.000000000 -0300
+++ b/net/dccp/dccp.h =A0 2009-08-27 22:36:43.000000000 -0300
@@ -403,6 +403,16 @@
=A0 =A0 =A0 =A0return (DCCP_SKB_CB(skb)->dccpd_ecn & INET_ECN_MASK) =3D=
=3D INET_ECN_CE;
=A0}

+static inline bool dccp_skb_is_ecn_ect0(const struct sk_buff *skb)
+{
+ =A0 =A0 =A0 return (DCCP_SKB_CB(skb)->dccpd_ecn & INET_ECN_MASK) =3D=3D=
 INET_ECN_ECT_0;
+}
+
+static inline bool dccp_skb_is_ecn_ect1(const struct sk_buff *skb)
+{
+ =A0 =A0 =A0 return (DCCP_SKB_CB(skb)->dccpd_ecn & INET_ECN_MASK) =3D=3D=
 INET_ECN_ECT_0;
+}
+
=A0/* RFC 4340, sec. 7.7 */
=A0static inline int dccp_non_data_packet(const struct sk_buff *skb)
=A0{
