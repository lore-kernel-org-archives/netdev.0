From: Pablo Neira <pablo@eurodev.net>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Tue, 28 Sep 2004 23:07:04 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4159D278.4060809@eurodev.net>
References: <20040923120707.GB32624@gondor.apana.org.au>	 <1095995042.1044.34.camel@jzny.localdomain>	 <20040924032440.GB6384@gondor.apana.org.au>	 <1096289189.1075.37.camel@jzny.localdomain>	 <20040927213607.GD7243@gondor.apana.org.au>	 <1096339407.8660.33.camel@jzny.localdomain>	 <20040928024614.GA9911@gondor.apana.org.au>	 <1096340772.8659.51.camel@jzny.localdomain>	 <20040928032321.GB10116@gondor.apana.org.au>	 <1096343125.8661.96.camel@jzny.localdomain>	 <20040928035921.GA10675@gondor.apana.org.au> <1096367787.8662.146.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000001000007080107080702"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1096367787.8662.146.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000001000007080107080702
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

If buffer overruns we lost all the messages which are enqueued, so 
before enqueing the packet, we can check if there's space available in 
the buffer. I think that this way we can save these messages at least.

I'm also thinking in doing something with netlink_ack's since they can 
be drop if buffer is full. We could give more priority to error messages 
in some way, for example, check if there's space for an error message in 
the buffer, if there's not, drop as many packets in buffer as we get 
space to enqueue the error message.

regards,
Pablo

--------------000001000007080107080702
Content-Type: text/x-patch;
 name="unicast-dont-overrun.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="unicast-dont-overrun.patch"

===== net/netlink/af_netlink.c 1.58 vs edited =====
--- 1.58/net/netlink/af_netlink.c	Sat Sep 25 17:43:43 2004
+++ edited/net/netlink/af_netlink.c	Tue Sep 28 22:23:44 2004
@@ -475,7 +475,7 @@
 	if (nlk->handler)
 		return 0;
 #endif
-	if (atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf ||
+	if (atomic_read(&sk->sk_rmem_alloc) + skb->len > sk->sk_rcvbuf ||
 	    test_bit(0, &nlk->state)) {
 		DECLARE_WAITQUEUE(wait, current);
 		if (!timeo) {

--------------000001000007080107080702--
