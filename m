From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Check connect address in NETLINK
Date: Wed, 30 Jun 2004 21:27:51 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040630112751.GA31160@gondor.apana.org.au>
References: <20040628231439.GA3021@gondor.apana.org.au> <20040629082252.GA26866@ms2.inr.ac.ru> <20040629084552.GA6202@gondor.apana.org.au> <20040629111433.GA28463@ms2.inr.ac.ru> <20040629111833.GA22880@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="9amGYk9869ThD9tj"
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
In-Reply-To: <20040629111833.GA22880@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--9amGYk9869ThD9tj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Jun 29, 2004 at 09:18:33PM +1000, herbert wrote:
> > > Or we can set the disconnected pid to a negative value since POSIX
> > > requires pid_t to be signed.  I see that you've reserved everything
> > > between -4096 and 0.  So perhaps we can pick -1?

Actually that doesn't quite work.  Users are allowed to bind to any
non-zero address including -1.  Besides, we already have sock->sk_state
and socket->state which are perfect for this.

So here is a patch to disallow sending unicast messages to connected
sockets from addresses other than the one that it is connected to.

I've tested it with a locally patched Openswan and it works as
intended by stopping me from sending bogus messages to it and
still allowing kernel messages to go through.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--9amGYk9869ThD9tj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/netlink/af_netlink.c 1.48 vs edited =====
--- 1.48/net/netlink/af_netlink.c	2004-06-19 04:43:31 +10:00
+++ edited/net/netlink/af_netlink.c	2004-06-30 20:53:00 +10:00
@@ -365,6 +365,7 @@
 	struct sockaddr_nl *nladdr=(struct sockaddr_nl*)addr;
 
 	if (addr->sa_family == AF_UNSPEC) {
+		sock->state	= SS_UNCONNECTED;
 		nlk->dst_pid	= 0;
 		nlk->dst_groups = 0;
 		return 0;
@@ -380,6 +381,7 @@
 		err = netlink_autobind(sock);
 
 	if (err == 0) {
+		sock->state	= SS_CONNECTED;
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
+	if (sock->sk_socket->state == SS_CONNECTED &&
+	    nlk->dst_pid != nlk_sk(ssk)->pid) {
 		sock_put(sock);
 		return ERR_PTR(-ECONNREFUSED);
 	}

--9amGYk9869ThD9tj--
