From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: ping: do not abuse udp_poll()
Date: Sat, 03 Jun 2017 09:29:25 -0700
Message-ID: <1496507365.5031.16.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170603051742.m6jtztnn4b3me2co@sasha-lappy>
         <CANn89iKFcPwzVP_gfwkLND9ZTo-+PF8Ex1uePqaawTaLF=Qzmg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>,
        "pabeni@redhat.com" <pabeni@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Lorenzo Colitti <lorenzo@google.com>,
        Vasiliy Kulikov <segoon@openwall.com>,
        Solar Designer <solar@openwall.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35451 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750876AbdFCQ33 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Jun 2017 12:29:29 -0400
In-Reply-To: <CANn89iKFcPwzVP_gfwkLND9ZTo-+PF8Ex1uePqaawTaLF=Qzmg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Alexander reported various KASAN messages triggered in recent kernels 

The problem is that ping sockets should not use udp_poll() in the first
place, and recent changes in UDP stack finally exposed this old bug.

Fixes: c319b4d76b9e ("net: ipv4: add IPPROTO_ICMP socket kind")
Fixes: 6d0bfe226116 ("net: ipv6: Add IPv6 support to the ping socket.")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Sasha Levin <alexander.levin@verizon.com>
Cc: Solar Designer <solar@openwall.com>
Cc: Vasiliy Kulikov <segoon@openwall.com>
Cc: Lorenzo Colitti <lorenzo@google.com>
---
 include/net/ipv6.h |    1 +
 net/ipv4/af_inet.c |    2 +-
 net/ipv6/ping.c    |    2 +-
 net/ipv6/raw.c     |    2 +-
 4 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index dbf0abba33b8da21be05abf6e719f69542da80fc..3e505bbff8ca4a41f8d39fefcd59aa01b85424f4 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -1007,6 +1007,7 @@ int inet6_hash_connect(struct inet_timewait_death_row *death_row,
  */
 extern const struct proto_ops inet6_stream_ops;
 extern const struct proto_ops inet6_dgram_ops;
+extern const struct proto_ops inet6_sockraw_ops;
 
 struct group_source_req;
 struct group_filter;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index f3dad16613437c0c7ac3e9c7518a0929cddb3ca7..58925b6597de83e7d643fb9b1c7e992c9748ae1c 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1043,7 +1043,7 @@ static struct inet_protosw inetsw_array[] =
 		.type =       SOCK_DGRAM,
 		.protocol =   IPPROTO_ICMP,
 		.prot =       &ping_prot,
-		.ops =        &inet_dgram_ops,
+		.ops =        &inet_sockraw_ops,
 		.flags =      INET_PROTOSW_REUSE,
        },
 
diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
index 9b522fa90e6d8f4a87ebed7cf574a36ceea89c61..ac826dd338ff0825eaf0d2d74cee92d008e018bb 100644
--- a/net/ipv6/ping.c
+++ b/net/ipv6/ping.c
@@ -192,7 +192,7 @@ static struct inet_protosw pingv6_protosw = {
 	.type =      SOCK_DGRAM,
 	.protocol =  IPPROTO_ICMPV6,
 	.prot =      &pingv6_prot,
-	.ops =       &inet6_dgram_ops,
+	.ops =       &inet6_sockraw_ops,
 	.flags =     INET_PROTOSW_REUSE,
 };
 
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 1f992d9e261d8b75226659a4cead95f8dc04dc4f..60be012fe7085cc7a199e84333cef5ee95ed1f04 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1338,7 +1338,7 @@ void raw6_proc_exit(void)
 #endif	/* CONFIG_PROC_FS */
 
 /* Same as inet6_dgram_ops, sans udp_poll.  */
-static const struct proto_ops inet6_sockraw_ops = {
+const struct proto_ops inet6_sockraw_ops = {
 	.family		   = PF_INET6,
 	.owner		   = THIS_MODULE,
 	.release	   = inet6_release,
