From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH] merge raw4_opt with raw_sock
Date: Fri, 14 Jan 2005 20:13:25 -0200
Message-ID: <41E84405.7070002@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060703010009090906040604"
Cc: Networking Team <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060703010009090906040604
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David,

	Now the raw_sock one, available at:

bk://kernel.bkbits.net/acme/connection_sock-2.6

	Later today I'll reclone and redo the SCTP and IPv6 bits,
then the connection_sock introduction.

- Arnaldo

--------------060703010009090906040604
Content-Type: text/plain;
 name="raw_sock.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="raw_sock.patch"

You can import this changeset into BK by piping this whole message to:
'| bk receive [path to repository]' or apply the patch as usual.

===================================================================


ChangeSet@1.2280, 2005-01-14 02:39:01-02:00, acme@conectiva.com.br
  [RAW] merge raw_sock with raw_opt
  
  No need for two structs, follow the new inet_sock layout
  style.
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@davemloft.net>


 include/net/icmp.h |   15 +++++++--------
 net/ipv4/raw.c     |   11 ++++++-----
 2 files changed, 13 insertions(+), 13 deletions(-)


diff -Nru a/include/net/icmp.h b/include/net/icmp.h
--- a/include/net/icmp.h	2005-01-14 19:59:34 -02:00
+++ b/include/net/icmp.h	2005-01-14 19:59:34 -02:00
@@ -46,16 +46,15 @@
 /* Move into dst.h ? */
 extern int 	xrlim_allow(struct dst_entry *dst, int timeout);
 
-struct raw_opt {
-	struct icmp_filter filter;
-};
-
-/* WARNING: don't change the layout of the members in raw_sock! */
 struct raw_sock {
-	struct inet_sock  inet;
-	struct raw_opt	  raw4;
+	/* inet_sock has to be the first member */
+	struct inet_sock   inet;
+	struct icmp_filter filter;
 };
 
-#define raw4_sk(__sk) (&((struct raw_sock *)__sk)->raw4)
+static inline struct raw_sock *raw_sk(const struct sock *sk)
+{
+	return (struct raw_sock *)sk;
+}
 
 #endif	/* _ICMP_H */
diff -Nru a/net/ipv4/raw.c b/net/ipv4/raw.c
--- a/net/ipv4/raw.c	2005-01-14 19:59:34 -02:00
+++ b/net/ipv4/raw.c	2005-01-14 19:59:34 -02:00
@@ -135,7 +135,7 @@
 
 	type = skb->h.icmph->type;
 	if (type < 32) {
-		__u32 data = raw4_sk(sk)->filter.data;
+		__u32 data = raw_sk(sk)->filter.data;
 
 		return ((1 << type) & data) != 0;
 	}
@@ -615,9 +615,10 @@
 
 static int raw_init(struct sock *sk)
 {
-	struct raw_opt *tp = raw4_sk(sk);
+	struct raw_sock *rp = raw_sk(sk);
+
 	if (inet_sk(sk)->num == IPPROTO_ICMP)
-		memset(&tp->filter, 0, sizeof(tp->filter));
+		memset(&rp->filter, 0, sizeof(rp->filter));
 	return 0;
 }
 
@@ -625,7 +626,7 @@
 {
 	if (optlen > sizeof(struct icmp_filter))
 		optlen = sizeof(struct icmp_filter);
-	if (copy_from_user(&raw4_sk(sk)->filter, optval, optlen))
+	if (copy_from_user(&raw_sk(sk)->filter, optval, optlen))
 		return -EFAULT;
 	return 0;
 }
@@ -643,7 +644,7 @@
 		len = sizeof(struct icmp_filter);
 	ret = -EFAULT;
 	if (put_user(len, optlen) ||
-	    copy_to_user(optval, &raw4_sk(sk)->filter, len))
+	    copy_to_user(optval, &raw_sk(sk)->filter, len))
 		goto out;
 	ret = 0;
 out:	return ret;


--------------060703010009090906040604--
