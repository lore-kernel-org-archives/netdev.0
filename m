From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NAT stops forwarding ACKs after PMTU discovery
Date: Sun, 18 Aug 2013 17:03:12 -0700
Message-ID: <1376870592.4226.27.camel@edumazet-glaptop>
References: <521061B4.1030508@fatooh.org>
	 <1376839467.21329.36.camel@edumazet-glaptop>
	 <alpine.DEB.2.00.1308182314050.25515@blackhole.kfki.hu>
	 <1376870425.4226.25.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Corey Hickey <bugfood-ml@fatooh.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1376870425.4226.25.camel@edumazet-glaptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2013-08-18 at 17:00 -0700, Eric Dumazet wrote:

> Code like this seems very suspect to me :
> 
> before(sack, receiver->td_end + 1)
> 

My suggestion would be to try :

diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 2f80107..1862902 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -656,12 +656,12 @@ static bool tcp_in_window(const struct nf_conn *ct,
 	pr_debug("tcp_in_window: I=%i II=%i III=%i IV=%i\n",
 		 before(seq, sender->td_maxend + 1),
 		 (in_recv_win ? 1 : 0),
-		 before(sack, receiver->td_end + 1),
+		 before(sack, receiver->td_end + MAXACKWINDOW(sender) + 1),
 		 after(sack, receiver->td_end - MAXACKWINDOW(sender) - 1));
 
 	if (before(seq, sender->td_maxend + 1) &&
 	    in_recv_win &&
-	    before(sack, receiver->td_end + 1) &&
+	    before(sack, receiver->td_end + MAXACKWINDOW(sender) + 1) &&
 	    after(sack, receiver->td_end - MAXACKWINDOW(sender) - 1)) {
 		/*
 		 * Take into account window scaling (RFC 1323).


