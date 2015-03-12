From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: fix CONFIG_NET_NS=n compilation
Date: Wed, 11 Mar 2015 20:27:52 -0700
Message-ID: <1426130872.11398.141.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1426113035.11398.90.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1426114608.11398.94.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1426125194.11398.131.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150311.215553.1544350193194225837.davem@davemloft.net>
	 <1426128863.11398.135.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, salo@google.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:35844 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751494AbbCLD1y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 23:27:54 -0400
Received: by iegc3 with SMTP id c3so13748697ieg.3
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 20:27:53 -0700 (PDT)
In-Reply-To: <1426128863.11398.135.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

I forgot to use write_pnet() in three locations.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Fixes: 33cf7c90fe2f9 ("net: add real socket cookies")
Reported-by: kbuild test robot <fengguang.wu@intel.com>
---
 net/dccp/ipv4.c       |    2 +-
 net/ipv4/syncookies.c |    2 +-
 net/ipv4/tcp_input.c  |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 207281ae3536..a78e0b999f96 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -641,7 +641,7 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	ireq = inet_rsk(req);
 	ireq->ir_loc_addr = ip_hdr(skb)->daddr;
 	ireq->ir_rmt_addr = ip_hdr(skb)->saddr;
-	ireq->ireq_net = sock_net(sk);
+	write_pnet(&ireq->ireq_net, sock_net(sk));
 	atomic64_set(&ireq->ir_cookie, 0);
 
 	/*
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index ece31b426013..18e5a67fda81 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -346,7 +346,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	req->ts_recent		= tcp_opt.saw_tstamp ? tcp_opt.rcv_tsval : 0;
 	treq->snt_synack	= tcp_opt.saw_tstamp ? tcp_opt.rcv_tsecr : 0;
 	treq->listener		= NULL;
-	ireq->ireq_net		= sock_net(sk);
+	write_pnet(&ireq->ireq_net, sock_net(sk));
 
 	/* We throwed the options of the initial SYN away, so we hope
 	 * the ACK carries the same options again (see RFC1122 4.2.3.8)
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d7045f5f6ebf..26f24995bd3d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5965,7 +5965,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 
 	tmp_opt.tstamp_ok = tmp_opt.saw_tstamp;
 	tcp_openreq_init(req, &tmp_opt, skb, sk);
-	inet_rsk(req)->ireq_net = sock_net(sk);
+	write_pnet(&inet_rsk(req)->ireq_net, sock_net(sk));
 	atomic64_set(&inet_rsk(req)->ir_cookie, 0);
 
 	af_ops->init_req(req, sk, skb);
