From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Check connect address in NETLINK
Date: Wed, 30 Jun 2004 22:40:50 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040630124050.GA1619@gondor.apana.org.au>
References: <20040628231439.GA3021@gondor.apana.org.au> <20040629082252.GA26866@ms2.inr.ac.ru> <20040629084552.GA6202@gondor.apana.org.au> <20040629111433.GA28463@ms2.inr.ac.ru> <20040629111833.GA22880@gondor.apana.org.au> <20040630112751.GA31160@gondor.apana.org.au> <20040630120045.GA7973@ms2.inr.ac.ru> <20040630120828.GA31498@gondor.apana.org.au> <20040630121420.GA8183@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="VbJkn9YxBvnuCH5J"
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
In-Reply-To: <20040630121420.GA8183@ms2.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--VbJkn9YxBvnuCH5J
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jun 30, 2004 at 04:14:20PM +0400, Alexey Kuznetsov wrote:
> 
> cpu 0:				cpu1 (or just preempted cpu)
> 
> sk = netlink_lookup(...);
> 				... closing sk
> 				netlink_release() clears sk_socket
> 
> use sk->sk_socket. Oops.

Thanks for the example.

Here is a version that uses sk_state instead.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--VbJkn9YxBvnuCH5J
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== include/linux/netlink.h 1.15 vs edited =====
--- 1.15/include/linux/netlink.h	2004-04-17 02:24:35 +10:00
+++ edited/include/linux/netlink.h	2004-06-30 22:34:18 +10:00
@@ -90,6 +90,11 @@
 
 #define NET_MAJOR 36		/* Major 36 is reserved for networking 						*/
 
+enum {
+	NETLINK_UNCONNECTED = 0,
+	NETLINK_CONNECTED,
+};
+
 #ifdef __KERNEL__
 
 #include <linux/capability.h>
===== net/netlink/af_netlink.c 1.48 vs edited =====
--- 1.48/net/netlink/af_netlink.c	2004-06-19 04:43:31 +10:00
+++ edited/net/netlink/af_netlink.c	2004-06-30 22:34:24 +10:00
@@ -365,6 +365,7 @@
 	struct sockaddr_nl *nladdr=(struct sockaddr_nl*)addr;
 
 	if (addr->sa_family == AF_UNSPEC) {
+		sk->sk_state	= NETLINK_UNCONNECTED;
 		nlk->dst_pid	= 0;
 		nlk->dst_groups = 0;
 		return 0;
@@ -380,6 +381,7 @@
 		err = netlink_autobind(sock);
 
 	if (err == 0) {
+		sk->sk_state	= NETLINK_CONNECTED;
 		nlk->dst_pid 	= nladdr->nl_pid;
 		nlk->dst_groups = nladdr->nl_groups;
 	}
@@ -428,6 +430,12 @@
 	/* Don't bother queuing skb if kernel socket has no input function */
 	nlk = nlk_sk(sock);
 	if (nlk->pid == 0 && !nlk->data_ready) {
+		sock_put(sock);
+		return ERR_PTR(-ECONNREFUSED);
+	}
+
+	if (sock->sk_state == NETLINK_CONNECTED &&
+	    nlk->dst_pid != nlk_sk(ssk)->pid) {
 		sock_put(sock);
 		return ERR_PTR(-ECONNREFUSED);
 	}

--VbJkn9YxBvnuCH5J--
