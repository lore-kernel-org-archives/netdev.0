From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH][NET] Assign inet transport sockets to the right module
Date: Mon, 15 Nov 2004 04:19:34 -0200
Message-ID: <41984A76.70406@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060107090406070700050700"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060107090406070700050700
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David,

	Please take a look if it makes sense, if so please pull from:

bk://kernel.bkbits.net/acme/sock-2.6

Regards,

- Arnaldo

--------------060107090406070700050700
Content-Type: text/plain;
 name="sk_prot_owner.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sk_prot_owner.patch"

===================================================================


ChangeSet@1.2148, 2004-11-15 04:05:17-02:00, acme@conectiva.com.br
  [NET] Assign inet transport sockets to the right module
  
  This is another case where when all the protocols use sk->sk_prot
  we can remove another member from struct sock, sk->sk_owner, instead
  using the sk->sk_prot->owner, i.e. this property is not per socket
  instance, but per protocol.
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@davemloft.net>


 include/net/sock.h  |    2 ++
 net/ipv4/af_inet.c  |    2 +-
 net/ipv4/raw.c      |    1 +
 net/ipv4/tcp_ipv4.c |    1 +
 net/ipv4/udp.c      |    1 +
 net/ipv6/af_inet6.c |    2 +-
 net/ipv6/raw.c      |    1 +
 net/ipv6/tcp_ipv6.c |    1 +
 net/ipv6/udp.c      |    1 +
 net/sctp/socket.c   |    2 ++
 10 files changed, 12 insertions(+), 2 deletions(-)


diff -Nru a/include/net/sock.h b/include/net/sock.h
--- a/include/net/sock.h	2004-11-15 04:12:55 -02:00
+++ b/include/net/sock.h	2004-11-15 04:12:55 -02:00
@@ -556,6 +556,8 @@
 	kmem_cache_t		*slab;
 	int			slab_obj_size;
 
+	struct module		*owner;
+
 	char			name[32];
 
 	struct {
diff -Nru a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
--- a/net/ipv4/af_inet.c	2004-11-15 04:12:55 -02:00
+++ b/net/ipv4/af_inet.c	2004-11-15 04:12:55 -02:00
@@ -309,7 +309,7 @@
 	inet->id = 0;
 
 	sock_init_data(sock, sk);
-	sk_set_owner(sk, THIS_MODULE);
+	sk_set_owner(sk, sk->sk_prot->owner);
 
 	sk->sk_destruct	   = inet_sock_destruct;
 	sk->sk_family	   = PF_INET;
diff -Nru a/net/ipv4/raw.c b/net/ipv4/raw.c
--- a/net/ipv4/raw.c	2004-11-15 04:12:55 -02:00
+++ b/net/ipv4/raw.c	2004-11-15 04:12:55 -02:00
@@ -706,6 +706,7 @@
 
 struct proto raw_prot = {
 	.name =		"RAW",
+	.owner =	THIS_MODULE,
 	.close =	raw_close,
 	.connect =	ip4_datagram_connect,
 	.disconnect =	udp_disconnect,
diff -Nru a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
--- a/net/ipv4/tcp_ipv4.c	2004-11-15 04:12:55 -02:00
+++ b/net/ipv4/tcp_ipv4.c	2004-11-15 04:12:55 -02:00
@@ -2598,6 +2598,7 @@
 
 struct proto tcp_prot = {
 	.name			= "TCP",
+	.owner			= THIS_MODULE,
 	.close			= tcp_close,
 	.connect		= tcp_v4_connect,
 	.disconnect		= tcp_disconnect,
diff -Nru a/net/ipv4/udp.c b/net/ipv4/udp.c
--- a/net/ipv4/udp.c	2004-11-15 04:12:55 -02:00
+++ b/net/ipv4/udp.c	2004-11-15 04:12:55 -02:00
@@ -1306,6 +1306,7 @@
 
 struct proto udp_prot = {
  	.name =		"UDP",
+	.owner =	THIS_MODULE,
 	.close =	udp_close,
 	.connect =	ip4_datagram_connect,
 	.disconnect =	udp_disconnect,
diff -Nru a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
--- a/net/ipv6/af_inet6.c	2004-11-15 04:12:55 -02:00
+++ b/net/ipv6/af_inet6.c	2004-11-15 04:12:55 -02:00
@@ -174,7 +174,7 @@
 		goto out;
 
 	sock_init_data(sock, sk);
-	sk_set_owner(sk, THIS_MODULE);
+	sk_set_owner(sk, sk->sk_prot->owner);
 
 	rc = 0;
 	sk->sk_prot = answer_prot;
diff -Nru a/net/ipv6/raw.c b/net/ipv6/raw.c
--- a/net/ipv6/raw.c	2004-11-15 04:12:55 -02:00
+++ b/net/ipv6/raw.c	2004-11-15 04:12:55 -02:00
@@ -975,6 +975,7 @@
 
 struct proto rawv6_prot = {
 	.name =		"RAW",
+	.owner =	THIS_MODULE,
 	.close =	rawv6_close,
 	.connect =	ip6_datagram_connect,
 	.disconnect =	udp_disconnect,
diff -Nru a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
--- a/net/ipv6/tcp_ipv6.c	2004-11-15 04:12:55 -02:00
+++ b/net/ipv6/tcp_ipv6.c	2004-11-15 04:12:55 -02:00
@@ -2132,6 +2132,7 @@
 
 struct proto tcpv6_prot = {
 	.name			= "TCPv6",
+	.owner			= THIS_MODULE,
 	.close			= tcp_close,
 	.connect		= tcp_v6_connect,
 	.disconnect		= tcp_disconnect,
diff -Nru a/net/ipv6/udp.c b/net/ipv6/udp.c
--- a/net/ipv6/udp.c	2004-11-15 04:12:55 -02:00
+++ b/net/ipv6/udp.c	2004-11-15 04:12:55 -02:00
@@ -1033,6 +1033,7 @@
 
 struct proto udpv6_prot = {
 	.name =		"UDP",
+	.owner =	THIS_MODULE,
 	.close =	udpv6_close,
 	.connect =	ip6_datagram_connect,
 	.disconnect =	udp_disconnect,
diff -Nru a/net/sctp/socket.c b/net/sctp/socket.c
--- a/net/sctp/socket.c	2004-11-15 04:12:55 -02:00
+++ b/net/sctp/socket.c	2004-11-15 04:12:55 -02:00
@@ -4652,6 +4652,7 @@
 /* This proto struct describes the ULP interface for SCTP.  */
 struct proto sctp_prot = {
 	.name        =	"SCTP",
+	.owner       =	THIS_MODULE,
 	.close       =	sctp_close,
 	.connect     =	sctp_connect,
 	.disconnect  =	sctp_disconnect,
@@ -4675,6 +4676,7 @@
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 struct proto sctpv6_prot = {
 	.name		= "SCTPv6",
+	.owner		= THIS_MODULE,
 	.close		= sctp_close,
 	.connect	= sctp_connect,
 	.disconnect	= sctp_disconnect,


--------------060107090406070700050700--
