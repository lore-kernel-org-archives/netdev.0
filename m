From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: assign the sock correctly to an outgoing SYNACK
 packet
Date: Mon, 08 Apr 2013 11:30:25 -0700
Message-ID: <1365445825.3887.35.camel@edumazet-glaptop>
References: <20130408154519.18177.57709.stgit@localhost>
	 <1558855.HGIqa4tJdt@sifl> <1365443267.3887.28.camel@edumazet-glaptop>
	 <1725553.maWFXblPLa@sifl> <1365445303.3887.33.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	mvadkert@redhat.com
To: Paul Moore <pmoore@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:52033 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935106Ab3DHSa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 14:30:27 -0400
Received: by mail-pd0-f175.google.com with SMTP id g10so3145794pdj.20
        for <netdev@vger.kernel.org>; Mon, 08 Apr 2013 11:30:27 -0700 (PDT)
In-Reply-To: <1365445303.3887.33.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-08 at 11:21 -0700, Eric Dumazet wrote:
> On Mon, 2013-04-08 at 14:12 -0400, Paul Moore wrote:
> 
> > 
> > It seems a bit fragile to me, perhaps even hacky, but in some ways I guess it 
> > isn't anymore fragile than relying on skb->sk - as this problem demonstrates.  
> > My other concern is that adding this hook *correctly* is likely to touch a lot 
> > of files and may be a bit much so late in the 3.9 cycle, Dave, what say you?
> 
> I don't get it, 90ba9b1986b5ac4b2d18 was in 3.6, why do you care of
> 3.9 ?
> 
> I am preparing a fix right now. Not a revert, thank you.
> 

Is the following patch not good enough ?

 include/linux/security.h |    7 +++++++
 net/ipv4/tcp_output.c    |    1 +
 security/security.c      |    6 ++++++
 3 files changed, 14 insertions(+)

diff --git a/include/linux/security.h b/include/linux/security.h
index eee7478..1bde8bb 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -2588,6 +2588,8 @@ int security_tun_dev_attach_queue(void *security);
 int security_tun_dev_attach(struct sock *sk, void *security);
 int security_tun_dev_open(void *security);
 
+void security_skb_owned_by(struct sk_buff *skb, struct sock *sk);
+
 #else	/* CONFIG_SECURITY_NETWORK */
 static inline int security_unix_stream_connect(struct sock *sock,
 					       struct sock *other,
@@ -2779,6 +2781,11 @@ static inline int security_tun_dev_open(void *security)
 {
 	return 0;
 }
+
+static inline void security_skb_owned_by(struct sk_buff *skb, struct sock *sk)
+{
+}
+
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 5d0b438..b44cf81 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2709,6 +2709,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	skb_reserve(skb, MAX_TCP_HEADER);
 
 	skb_dst_set(skb, dst);
+	security_skb_owned_by(skb, sk);
 
 	mss = dst_metric_advmss(dst);
 	if (tp->rx_opt.user_mss && tp->rx_opt.user_mss < mss)
diff --git a/security/security.c b/security/security.c
index 7b88c6a..cdabd4d 100644
--- a/security/security.c
+++ b/security/security.c
@@ -25,6 +25,7 @@
 #include <linux/personality.h>
 #include <linux/backing-dev.h>
 #include <net/flow.h>
+#include <net/sock.h>
 
 #define MAX_LSM_EVM_XATTR	2
 
@@ -1290,6 +1291,11 @@ int security_tun_dev_open(void *security)
 }
 EXPORT_SYMBOL(security_tun_dev_open);
 
+void security_skb_owned_by(struct sk_buff *skb, struct sock *sk)
+{
+	skb_set_owner_w(skb, sk);
+}
+
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
