From: Pablo Neira <pablo@eurodev.net>
Subject: Re: [NETLINK] introduce netlink bucket
Date: Sun, 21 Nov 2004 23:24:35 +0100
Message-ID: <41A115A3.3020509@eurodev.net>
References: <4187FF18.5050608@eurodev.net> <20041103154833.164e33f5.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070806010308000800010700"
Cc: netdev@oss.sgi.com, davem@redhat.com, herbert@gondor.apana.org.au
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041103154833.164e33f5.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070806010308000800010700
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

David S. Miller wrote:

>On Tue, 02 Nov 2004 22:41:44 +0100
>Pablo Neira <pablo@eurodev.net> wrote:
>
>  
>
>>This patch introduces the netlink bucket struct, it joins three arrays 
>>into an array of netlink bucket.
>>
>>Signed-off-by: Pablo Neira Ayuso <pablo@eurodev.net>
>>    
>>
>
>Here is the work Herbert and I were talking about.  It kind
>of makes your patch taken care of already :-)
>  
>

Move netlink_kernel and nl_nonroot arrays to nl_table structure. Do you 
like it?

--
Pablo

--------------070806010308000800010700
Content-Type: text/plain;
 name="X"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="X"

===== net/netlink/af_netlink.c 1.62 vs edited =====
--- 1.62/net/netlink/af_netlink.c	2004-11-15 23:57:51 +01:00
+++ edited/net/netlink/af_netlink.c	2004-11-21 20:43:06 +01:00
@@ -91,16 +91,15 @@
 struct netlink_table {
 	struct nl_pid_hash hash;
 	struct hlist_head mc_list;
+	unsigned int nl_nonroot;
+#ifdef NL_EMULATE_DEV
+	struct socket *netlink_kernel;
+#endif
 };
 
 static struct netlink_table *nl_table;
 
 static DECLARE_WAIT_QUEUE_HEAD(nl_table_wait);
-static unsigned int nl_nonroot[MAX_LINKS];
-
-#ifdef NL_EMULATE_DEV
-static struct socket *netlink_kernel[MAX_LINKS];
-#endif
 
 static int netlink_dump(struct sock *sk);
 static void netlink_destroy_callback(struct netlink_callback *cb);
@@ -442,7 +441,7 @@
 
 static inline int netlink_capable(struct socket *sock, unsigned int flag) 
 { 
-	return (nl_nonroot[sock->sk->sk_protocol] & flag) ||
+	return (nl_table[sock->sk->sk_protocol].nl_nonroot & flag) ||
 	       capable(CAP_NET_ADMIN);
 } 
 
@@ -1066,7 +1065,7 @@
 void netlink_set_nonroot(int protocol, unsigned int flags)
 { 
 	if ((unsigned int)protocol < MAX_LINKS) 
-		nl_nonroot[protocol] = flags;
+		nl_table[protocol].nl_nonroot = flags;
 } 
 
 static void netlink_destroy_callback(struct netlink_callback *cb)
@@ -1217,7 +1216,7 @@
 		return -ENOBUFS;
 	nlk_sk(sk)->handler = function;
 	write_lock_bh(&nl_emu_lock);
-	netlink_kernel[unit] = sk->sk_socket;
+	nl_table[unit].netlink_kernel = sk->sk_socket;
 	write_unlock_bh(&nl_emu_lock);
 	return 0;
 }
@@ -1227,8 +1226,8 @@
 	struct socket *sock;
 
 	write_lock_bh(&nl_emu_lock);
-	sock = netlink_kernel[unit];
-	netlink_kernel[unit] = NULL;
+	sock = nl_table[unit].netlink_kernel;
+	nl_table[unit].netlink_kernel = NULL;
 	write_unlock_bh(&nl_emu_lock);
 
 	sock_release(sock);
@@ -1239,7 +1238,7 @@
 	struct socket *sock;
 
 	read_lock(&nl_emu_lock);
-	sock = netlink_kernel[unit];
+	sock = nl_table[unit].netlink_kernel;
 	if (sock) {
 		struct sock *sk = sock->sk;
 		memset(skb->cb, 0, sizeof(skb->cb));

--------------070806010308000800010700--
