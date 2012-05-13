From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] codel: use Newton method instead of sqrt()
 and divides
Date: Sun, 13 May 2012 09:23:23 +0200
Message-ID: <1336893803.8512.43.camel@edumazet-glaptop>
References: <1336855256.31653.1329.camel@edumazet-glaptop>
	 <20120512.164513.1156706853054390966.davem@davemloft.net>
	 <1336859324.31653.1385.camel@edumazet-glaptop>
	 <20120512.175217.1632102067268101115.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: dave.taht@bufferbloat.net, netdev@vger.kernel.org,
	nichols@pollere.com, van@pollere.net, codel@lists.bufferbloat.net,
	ycheng@google.com, mattmathis@google.com, therbert@google.com,
	shemminger@vyatta.com, nanditad@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:46215 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751761Ab2EMHXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 May 2012 03:23:30 -0400
Received: by weyu7 with SMTP id u7so1156942wey.19
        for <netdev@vger.kernel.org>; Sun, 13 May 2012 00:23:29 -0700 (PDT)
In-Reply-To: <20120512.175217.1632102067268101115.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On Sat, 2012-05-12 at 17:52 -0400, David Miller wrote:

> Ok, fair enough.

Oh well, I sent my mail too late. The error made no sense after a good
night. Also, when Van says something, you can be fairly sure its right,
and if it's not, then you didn't understand what Van said ;)

16bit precision is OK, once the maths are correctly done in the userland
program I wrote yesterday...

count=16525, precision=16 bits, sqrt(scaled_count)=4113, reciprocal(sq)=1fde240, Newton=1fd0000
  interval/sqrt(16525) = 
	777909 (float compute)  // (u32)(interval/sqrt(count))
	778020 (integer approx) // reciprocal_divide(interval, rec)
	777926 (int_sqrt_div)   // int_sqrt_div(interval, count)
	776672 (Newton approx)  // reciprocal_divide(interval, previnv << shift)

count=9889134, precision=16 bits, sqrt(scaled_count)=50315,
reciprocal(sq)=14d720, Newton=140000
  interval/sqrt(9889134) = 
	31799 (float compute)
	31799 (integer approx)
	31799 (int_sqrt_div)
	30517 (Newton approx)


And kernel code using u16 :

 6a1:	0f b7 72 0a          	movzwl 0xa(%rdx),%esi
 6a5:	8b 3a                	mov    (%rdx),%edi
 6a7:	83 c7 01             	add    $0x1,%edi
 6aa:	c1 e6 10             	shl    $0x10,%esi
 6ad:	89 3a                	mov    %edi,(%rdx)  vars->count++
 6af:	89 ff                	mov    %edi,%edi
 6b1:	89 f6                	mov    %esi,%esi
 6b3:	48 89 f1             	mov    %rsi,%rcx
 6b6:	48 0f af ce          	imul   %rsi,%rcx
 6ba:	48 c1 e9 20          	shr    $0x20,%rcx
 6be:	48 0f af cf          	imul   %rdi,%rcx
 6c2:	48 bf 00 00 00 00 03 	mov    $0x300000000,%rdi
 6c9:	00 00 00 
 6cc:	48 29 cf             	sub    %rcx,%rdi
 6cf:	48 89 f9             	mov    %rdi,%rcx
 6d2:	48 c1 e9 02          	shr    $0x2,%rcx
 6d6:	48 0f af ce          	imul   %rsi,%rcx
 6da:	48 c1 e9 2f          	shr    $0x2f,%rcx
 6de:	66 89 4a 0a          	mov    %cx,0xa(%rdx)


Fell free to add following cleanup patch, if you like it ;)

Thanks

[PATCH net-next] codel: use u16 field instead of 31bits for rec_inv_sqrt

David pointed out gcc might generate poor code with 31bit fields.

Using u16 is more than enough and permits a better code output.

Also make the code intent more readable using constants, fixed point arithmetic
not being trivial for everybody.

Suggested-by: David Miller <davem@davemloft.net>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/codel.h |   25 +++++++++++++++----------
 1 file changed, 15 insertions(+), 10 deletions(-)

diff --git a/include/net/codel.h b/include/net/codel.h
index bd8747c..7546517 100644
--- a/include/net/codel.h
+++ b/include/net/codel.h
@@ -133,13 +133,17 @@ struct codel_params {
 struct codel_vars {
 	u32		count;
 	u32		lastcount;
-	bool		dropping:1;
-	u32		rec_inv_sqrt:31;
+	bool		dropping;
+	u16		rec_inv_sqrt;
 	codel_time_t	first_above_time;
 	codel_time_t	drop_next;
 	codel_time_t	ldelay;
 };
 
+#define REC_INV_SQRT_BITS (8 * sizeof(u16)) /* or sizeof_in_bits(rec_inv_sqrt) */
+/* needed shift to get a Q0.32 number from rec_inv_sqrt */
+#define REC_INV_SQRT_SHIFT (32 - REC_INV_SQRT_BITS)
+
 /**
  * struct codel_stats - contains codel shared variables and stats
  * @maxpacket:	largest packet we've seen so far
@@ -173,17 +177,18 @@ static void codel_stats_init(struct codel_stats *stats)
  * http://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Iterative_methods_for_reciprocal_square_roots
  * new_invsqrt = (invsqrt / 2) * (3 - count * invsqrt^2)
  *
- * Here, invsqrt is a fixed point number (< 1.0), 31bit mantissa)
+ * Here, invsqrt is a fixed point number (< 1.0), 32bit mantissa, aka Q0.32
  */
 static void codel_Newton_step(struct codel_vars *vars)
 {
-	u32 invsqrt = vars->rec_inv_sqrt;
-	u32 invsqrt2 = ((u64)invsqrt * invsqrt) >> 31;
-	u64 val = (3LL << 31) - ((u64)vars->count * invsqrt2);
+	u32 invsqrt = ((u32)vars->rec_inv_sqrt) << REC_INV_SQRT_SHIFT;
+	u32 invsqrt2 = ((u64)invsqrt * invsqrt) >> 32;
+	u64 val = (3LL << 32) - ((u64)vars->count * invsqrt2);
 
-	val = (val * invsqrt) >> 32;
+	val >>= 2; /* avoid overflow in following multiply */
+	val = (val * invsqrt) >> (32 - 2 + 1);
 
-	vars->rec_inv_sqrt = val;
+	vars->rec_inv_sqrt = val >> REC_INV_SQRT_SHIFT;
 }
 
 /*
@@ -195,7 +200,7 @@ static codel_time_t codel_control_law(codel_time_t t,
 				      codel_time_t interval,
 				      u32 rec_inv_sqrt)
 {
-	return t + reciprocal_divide(interval, rec_inv_sqrt << 1);
+	return t + reciprocal_divide(interval, rec_inv_sqrt << REC_INV_SQRT_SHIFT);
 }
 
 
@@ -326,7 +331,7 @@ static struct sk_buff *codel_dequeue(struct Qdisc *sch,
 			codel_Newton_step(vars);
 		} else {
 			vars->count = 1;
-			vars->rec_inv_sqrt = 0x7fffffff;
+			vars->rec_inv_sqrt = ~0U >> REC_INV_SQRT_SHIFT;
 		}
 		vars->lastcount = vars->count;
 		vars->drop_next = codel_control_law(now, params->interval,
