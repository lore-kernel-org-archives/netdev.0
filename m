From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fw: [Bugme-new] [Bug 4138] New: ipsec with racoon in transport
 mode with esp and ah hangs (problem is in xfrm_state_add)
Date: Tue, 08 Mar 2005 23:36:06 +0100
Message-ID: <422E28D6.1070103@trash.net>
References: <E1CvZCT-00017g-00@gondolin.me.apana.org.au> <200501311640.16118.au@unterluggauer.org> <20050131211102.GA20323@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000802070007090409010108"
Cc: Andreas Unterluggauer <au@unterluggauer.org>, netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050131211102.GA20323@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000802070007090409010108
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Herbert Xu wrote:
> Hi Andreas:
> 
> On Mon, Jan 31, 2005 at 03:40:16PM +0000, Andreas Unterluggauer wrote:
> 
>>2005-01-31 16:29:58: DEBUG: ===
>>2005-01-31 16:29:58: DEBUG: get pfkey ADD message
>>andi: libipsec/pfkey.c, pfkey_check: start (msg->sadb_msg_satype: 3)
>>2005-01-31 16:29:58: DEBUG: andi: in pfkey.c, pk_recvadd: msg->sadb_msg_seq 2, msg->sadb_msg_type: ADD
>>2005-01-31 16:29:58: INFO: IPsec-SA established: ESP/Transport 192.168.2.5->192.168.2.3 spi=103868257(0x630e761)
>>2005-01-31 16:29:58: DEBUG: ===
> 
> 
> Does the machine hang at this point in time? If not, then this is
> simply a racoon bug.  Although the acquire message carries a policy
> with it, it's really only acquiring a single SA.  Therefore, only
> the SA being acquired should be added with that sequence number.

You're right, but I think there is also kernel misbehaviour here that
is fixed by the patch for __xfrm_state_find_acq_byseq() I sent to Dave
earlier. Andreas, can you try this patch please ?

Regards
Patrick

--------------000802070007090409010108
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

===== net/xfrm/xfrm_state.c 1.55 vs edited =====
--- 1.55/net/xfrm/xfrm_state.c	2005-03-07 06:23:53 +01:00
+++ edited/net/xfrm/xfrm_state.c	2005-03-08 18:42:13 +01:00
@@ -609,7 +609,7 @@
 
 	for (i = 0; i < XFRM_DST_HSIZE; i++) {
 		list_for_each_entry(x, xfrm_state_bydst+i, bydst) {
-			if (x->km.seq == seq) {
+			if (x->km.seq == seq && x->km.state == XFRM_STATE_ACQ) {
 				xfrm_state_hold(x);
 				return x;
 			}

--------------000802070007090409010108--
