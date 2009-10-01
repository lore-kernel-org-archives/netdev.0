From: Atis Elsts <atis@mikrotik.com>
Subject: [PATCH] Use sk_mark for routing lookup in more places
Date: Thu, 1 Oct 2009 18:14:47 +0300
Message-ID: <200910011814.47689.atis@mikrotik.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Laszlo Attila Toth <panther@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bute.mt.lv ([159.148.172.196]:45846 "EHLO bute.mt.lv"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753792AbZJAPQ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2009 11:16:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch against v2.6.31 adds support for route lookup using sk_mark in some 
more places. The benefits from this patch are the following.
First, SO_MARK option now has effect on UDP sockets too.
Second, ip_queue_xmit() and inet_sk_rebuild_header() could fail to do routing 
lookup correctly if TCP sockets with SO_MARK were used.

Signed-off-by: Atis Elsts <atis@mikrotik.com>
---
 net/ipv4/af_inet.c   |    1 +
 net/ipv4/ip_output.c |    1 +
 net/ipv4/udp.c       |    1 +
 3 files changed, 3 insertions(+)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 566ea6c..7917963 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1103,6 +1103,7 @@ int inet_sk_rebuild_header(struct sock *sk)
 {
        struct flowi fl = {
                .oif = sk->sk_bound_dev_if,
+               .mark = sk->sk_mark,
                .nl_u = {
                        .ip4_u = {
                                .daddr  = daddr,
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 7ffcd96..e088a97 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -335,6 +335,7 @@ int ip_queue_xmit(struct sk_buff *skb, int ipfragok)

                {
                        struct flowi fl = { .oif = sk->sk_bound_dev_if,
+                                           .mark = sk->sk_mark,
                                            .nl_u = { .ip4_u =
                                                      { .daddr = daddr,
                                                        .saddr = inet->saddr,
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 80e3812..f90cdcc 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -688,6 +688,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, 
struct msghdr *msg,

        if (rt == NULL) {
                struct flowi fl = { .oif = ipc.oif,
+                                   .mark = sk->sk_mark,
                                    .nl_u = { .ip4_u =
                                              { .daddr = faddr,
                                                .saddr = saddr,
