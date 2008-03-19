From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 2/3 nwt-2.6.26] Remove unused ip_options->is_data.
Date: Wed, 19 Mar 2008 15:42:46 +0300
Message-ID: <1205930567-30956-2-git-send-email-den@openvz.org>
References: <1205930508.24116.14.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:63469 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754053AbYCTGkV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Mar 2008 02:40:21 -0400
In-Reply-To: <1205930508.24116.14.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip_options->is_data is assigned only and never checked. The structure is
not a part of kernel interface to the userspace. So, it is safe to remove
this field.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/inet_sock.h |    3 +--
 net/ipv4/cipso_ipv4.c   |    1 -
 net/ipv4/ip_options.c   |    5 -----
 3 files changed, 1 insertions(+), 8 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 8660cb0..b6db16d 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -43,8 +43,7 @@ struct ip_options {
 	unsigned char	srr;
 	unsigned char	rr;
 	unsigned char	ts;
-	unsigned char	is_data:1,
-			is_strictroute:1,
+	unsigned char	is_strictroute:1,
 			srr_is_hit:1,
 			is_changed:1,
 			rr_needaddr:1,
diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index 8cd357f..4637ded 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -1800,7 +1800,6 @@ int cipso_v4_sock_setattr(struct sock *sk,
 	}
 	memcpy(opt->__data, buf, buf_len);
 	opt->optlen = opt_len;
-	opt->is_data = 1;
 	opt->cipso = sizeof(struct iphdr);
 	kfree(buf);
 	buf = NULL;
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 7e94bf8..2fa4113 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -45,7 +45,6 @@ void ip_options_build(struct sk_buff * skb, struct ip_options * opt,
 	memcpy(&(IPCB(skb)->opt), opt, sizeof(struct ip_options));
 	memcpy(iph+sizeof(struct iphdr), opt->__data, opt->optlen);
 	opt = &(IPCB(skb)->opt);
-	opt->is_data = 0;
 
 	if (opt->srr)
 		memcpy(iph+opt->srr+iph[opt->srr+1]-4, &daddr, 4);
@@ -95,8 +94,6 @@ int ip_options_echo(struct ip_options * dopt, struct sk_buff * skb)
 
 	memset(dopt, 0, sizeof(struct ip_options));
 
-	dopt->is_data = 1;
-
 	sopt = &(IPCB(skb)->opt);
 
 	if (sopt->optlen == 0) {
@@ -265,7 +262,6 @@ int ip_options_compile(struct ip_options * opt, struct sk_buff * skb)
 		iph = skb_network_header(skb);
 		opt->optlen = ((struct iphdr *)iph)->ihl*4 - sizeof(struct iphdr);
 		optptr = iph + sizeof(struct iphdr);
-		opt->is_data = 0;
 	} else {
 		optptr = opt->__data;
 		iph = optptr - sizeof(struct iphdr);
@@ -519,7 +515,6 @@ static int ip_options_get_finish(struct ip_options **optp,
 	while (optlen & 3)
 		opt->__data[optlen++] = IPOPT_END;
 	opt->optlen = optlen;
-	opt->is_data = 1;
 	if (optlen && ip_options_compile(opt, NULL)) {
 		kfree(opt);
 		return -EINVAL;
-- 
1.5.3.rc5

