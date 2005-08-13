From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] add new iptables ipt_connbytes match
Date: Sat, 13 Aug 2005 03:20:06 +0200
Message-ID: <42FD4AC6.2020506@trash.net>
References: <20050811200349.GN5353@rama.de.gnumonks.org>
	<42FC0F01.5090802@trash.net>
	<20050812115622.GD16325@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------080505060102080105040305"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20050812115622.GD16325@rama.de.gnumonks.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080505060102080105040305
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Harald Welte wrote:
> Just send two incremental patches to Dave.

Here they are. The first patch fixes the div64_64 function, the second
one renames some constants.


--------------080505060102080105040305
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

[NETFILTER]: Fix div64_64 in ipt_connbytes

Signded-off-by: Patrick McHardy <kaber@trash.net>

---
commit 62084bc1a04e2fbc492566fa30997bd0a7aa2d0a
tree 083c8042609e0da81f0be9e15583d5d31b54e685
parent 68e734a5864ba568058c3b8ea63fac3d7d567542
author Patrick McHardy <kaber@trash.net> Sat, 13 Aug 2005 03:16:32 +0200
committer Patrick McHardy <kaber@trash.net> Sat, 13 Aug 2005 03:16:32 +0200

 net/ipv4/netfilter/ipt_connbytes.c |   22 +++++++++-------------
 1 files changed, 9 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_connbytes.c b/net/ipv4/netfilter/ipt_connbytes.c
--- a/net/ipv4/netfilter/ipt_connbytes.c
+++ b/net/ipv4/netfilter/ipt_connbytes.c
@@ -22,23 +22,19 @@ MODULE_AUTHOR("Harald Welte <laforge@net
 MODULE_DESCRIPTION("iptables match for matching number of pkts/bytes per connection");
 
 /* 64bit divisor, dividend and result. dynamic precision */
-static u_int64_t div64_64(u_int64_t divisor, u_int64_t dividend)
+static u_int64_t div64_64(u_int64_t dividend, u_int64_t divisor)
 {
-	u_int64_t result = divisor;
+	u_int32_t d = divisor;
 
-	if (dividend > 0xffffffff) {
-		int first_bit = find_first_bit((unsigned long *) &dividend, sizeof(dividend));
-		/* calculate number of bits to shift. shift exactly enough
-		 * bits to make dividend fit in 32bits. */
-		int num_shift = (64 - 32 - first_bit);
-		/* first bit has to be < 32, since dividend was > 0xffffffff */
-		result = result >> num_shift;
-		dividend = dividend >> num_shift;
-	}
+	if (divisor > 0xffffffffULL) {
+		unsigned int shift = fls(divisor >> 32);
 
-	do_div(divisor, dividend);
+		d = divisor >> shift;
+		dividend >>= shift;
+	}
 
-	return divisor;
+	do_div(dividend, d);
+	return dividend;
 }
 
 static int

--------------080505060102080105040305
Content-Type: text/x-patch;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

[NETFILTER]: Nicer names for ipt_connbytes constants

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit e0d3e09ba22a139cbee328bc2622e984b65ba53e
tree 83efbc8d53045825333db5f4e321e28b331f7e30
parent 8f48c662a6f9cd2cdaec9d9866cebf8b40155f70
author Patrick McHardy <kaber@trash.net> Sat, 13 Aug 2005 03:18:30 +0200
committer Patrick McHardy <kaber@trash.net> Sat, 13 Aug 2005 03:18:30 +0200

 include/linux/netfilter_ipv4/ipt_connbytes.h |    6 +++---
 net/ipv4/netfilter/ipt_connbytes.c           |   12 ++++++------
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/include/linux/netfilter_ipv4/ipt_connbytes.h b/include/linux/netfilter_ipv4/ipt_connbytes.h
--- a/include/linux/netfilter_ipv4/ipt_connbytes.h
+++ b/include/linux/netfilter_ipv4/ipt_connbytes.h
@@ -2,9 +2,9 @@
 #define _IPT_CONNBYTES_H
 
 enum ipt_connbytes_what {
-	IPT_CONNBYTES_WHAT_PKTS,
-	IPT_CONNBYTES_WHAT_BYTES,
-	IPT_CONNBYTES_WHAT_AVGPKT,
+	IPT_CONNBYTES_PKTS,
+	IPT_CONNBYTES_BYTES,
+	IPT_CONNBYTES_AVGPKT,
 };
 
 enum ipt_connbytes_direction {
diff --git a/net/ipv4/netfilter/ipt_connbytes.c b/net/ipv4/netfilter/ipt_connbytes.c
--- a/net/ipv4/netfilter/ipt_connbytes.c
+++ b/net/ipv4/netfilter/ipt_connbytes.c
@@ -54,7 +54,7 @@ match(const struct sk_buff *skb,
 		return 0; /* no match */
 
 	switch (sinfo->what) {
-	case IPT_CONNBYTES_WHAT_PKTS:
+	case IPT_CONNBYTES_PKTS:
 		switch (sinfo->direction) {
 		case IPT_CONNBYTES_DIR_ORIGINAL:
 			what = ct->counters[IP_CT_DIR_ORIGINAL].packets;
@@ -68,7 +68,7 @@ match(const struct sk_buff *skb,
 			break;
 		}
 		break;
-	case IPT_CONNBYTES_WHAT_BYTES:
+	case IPT_CONNBYTES_BYTES:
 		switch (sinfo->direction) {
 		case IPT_CONNBYTES_DIR_ORIGINAL:
 			what = ct->counters[IP_CT_DIR_ORIGINAL].bytes;
@@ -82,7 +82,7 @@ match(const struct sk_buff *skb,
 			break;
 		}
 		break;
-	case IPT_CONNBYTES_WHAT_AVGPKT:
+	case IPT_CONNBYTES_AVGPKT:
 		switch (sinfo->direction) {
 		case IPT_CONNBYTES_DIR_ORIGINAL:
 			what = div64_64(ct->counters[IP_CT_DIR_ORIGINAL].bytes,
@@ -128,9 +128,9 @@ static int check(const char *tablename,
 	if (matchsize != IPT_ALIGN(sizeof(struct ipt_connbytes_info)))
 		return 0;
 
-	if (sinfo->what != IPT_CONNBYTES_WHAT_PKTS &&
-	    sinfo->what != IPT_CONNBYTES_WHAT_BYTES &&
-	    sinfo->what != IPT_CONNBYTES_WHAT_AVGPKT)
+	if (sinfo->what != IPT_CONNBYTES_PKTS &&
+	    sinfo->what != IPT_CONNBYTES_BYTES &&
+	    sinfo->what != IPT_CONNBYTES_AVGPKT)
 		return 0;
 
 	if (sinfo->direction != IPT_CONNBYTES_DIR_ORIGINAL &&

--------------080505060102080105040305--
