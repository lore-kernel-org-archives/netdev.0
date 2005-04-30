From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPV6] Fix raw socket checksums with IPsec
Date: Sat, 30 Apr 2005 22:33:01 +1000
Message-ID: <20050430123301.GA25174@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="opJtzjQTFsWo+cga"
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
        David Stevens <dlstevens@us.ibm.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--opJtzjQTFsWo+cga
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

I made a mistake in my last patch to the raw socket checksum code.
I used the value of inet->cork.length as the length of the payload.
While this works with normal packets, it breaks down when IPsec is
present since the cork length includes the extension header length.

So here is a patch to fix the length calculations.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--opJtzjQTFsWo+cga
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=rawv6-csum

--- k/net/ipv6/raw.c  (mode:100644)
+++ l/net/ipv6/raw.c  (mode:100644)
@@ -455,11 +455,11 @@ csum_copy_err:
 static int rawv6_push_pending_frames(struct sock *sk, struct flowi *fl,
 				     struct raw6_sock *rp)
 {
-	struct inet_sock *inet = inet_sk(sk);
 	struct sk_buff *skb;
 	int err = 0;
 	int offset;
 	int len;
+	int total_len;
 	u32 tmp_csum;
 	u16 csum;
 
@@ -470,7 +470,8 @@ static int rawv6_push_pending_frames(str
 		goto out;
 
 	offset = rp->offset;
-	if (offset >= inet->cork.length - 1) {
+	total_len = inet_sk(sk)->cork.length - (skb->nh.raw - skb->data);
+	if (offset >= total_len - 1) {
 		err = -EINVAL;
 		ip6_flush_pending_frames(sk);
 		goto out;
@@ -514,7 +515,7 @@ static int rawv6_push_pending_frames(str
 
 	tmp_csum = csum_ipv6_magic(&fl->fl6_src,
 				   &fl->fl6_dst,
-				   inet->cork.length, fl->proto, tmp_csum);
+				   total_len, fl->proto, tmp_csum);
 
 	if (tmp_csum == 0)
 		tmp_csum = -1;

--opJtzjQTFsWo+cga--
