From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH][2.5.22] OOPS in tcp_v6_get_port
Date: Mon, 17 Jun 2002 21:57:35 -0300
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020618005735.GB1146@conectiva.com.br>
References: <Pine.LNX.4.44.0206171314460.2496-300000@lain.perlfu.co.uk> <20020617.143319.54623892.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: critson@perlfu.co.uk, torvalds@transmeta.com, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20020617.143319.54623892.davem@redhat.com>
List-Id: netdev.vger.kernel.org

Em Mon, Jun 17, 2002 at 02:33:19PM -0700, David S. Miller escreveu:
> 
> This is a known bug introduced by the struct sock splitup into
> external per-protocol pieces done by Arnaldo de Melo.  He is working
> on the proper fix, your proposed change will just paper over the real
> bug.

Carl,

	Can you try this patch?

- Arnaldo

--- orig/net/ipv6/tcp_ipv6.c	Sat May 25 23:13:56 2002
+++ linux/net/ipv6/tcp_ipv6.c	Fri Jun 14 23:23:07 2002
@@ -1240,6 +1240,7 @@
 					  struct dst_entry *dst)
 {
 	struct ipv6_pinfo *newnp, *np = inet6_sk(sk);
+	struct tcp6_sock *newtcp6sk;
 	struct flowi fl;
 	struct inet_opt *newinet;
 	struct tcp_opt *newtp;
@@ -1256,10 +1257,15 @@
 		if (newsk == NULL) 
 			return NULL;
 
+		newtcp6sk = (struct tcp6_sock *)newsk;
+		newtcp6sk->pinet6 = &newtcp6sk->inet6;
+
 		newinet = inet_sk(newsk);
 		newnp = inet6_sk(newsk);
 		newtp = tcp_sk(newsk);
 
+		memcpy(newnp, np, sizeof(struct ipv6_pinfo));
+
 		ipv6_addr_set(&newnp->daddr, 0, 0, htonl(0x0000FFFF),
 			      newinet->daddr);
 
@@ -1336,9 +1342,15 @@
 	ip6_dst_store(newsk, dst, NULL);
 	sk->route_caps = dst->dev->features&~NETIF_F_IP_CSUM;
 
+	newtcp6sk = (struct tcp6_sock *)newsk;
+	newtcp6sk->pinet6 = &newtcp6sk->inet6;
+
 	newtp = tcp_sk(newsk);
 	newinet = inet_sk(newsk);
 	newnp = inet6_sk(newsk);
+
+	memcpy(newnp, np, sizeof(struct ipv6_pinfo));
+
 	ipv6_addr_copy(&newnp->daddr, &req->af.v6_req.rmt_addr);
 	ipv6_addr_copy(&newnp->saddr, &req->af.v6_req.loc_addr);
 	ipv6_addr_copy(&newnp->rcv_saddr, &req->af.v6_req.loc_addr);


-- 
Russell King (rmk@arm.linux.org.uk)                The developer of ARM Linux
             http://www.arm.linux.org.uk/personal/aboutme.html
