From: Sebastian Poehn <sebastian.poehn@gmail.com>
Subject: [FYI] xfrm: Don't lookup sk_policy for timewait sockets
Date: Thu, 09 Apr 2015 10:09:01 +0200
Message-ID: <1428566941.6875.7.camel@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:34055 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751691AbbDIIJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 04:09:04 -0400
Received: by wgbdm7 with SMTP id dm7so111929571wgb.1
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2015 01:09:02 -0700 (PDT)
Received: from de-ka-36785.green.sophos ([2001:1a80:2000:2:4637:e6ff:feaa:80c4])
        by mx.google.com with ESMTPSA id ln8sm18965294wjc.18.2015.04.09.01.09.01
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Apr 2015 01:09:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are running a couple of thousand machines with 3.8 and 3.12. On very few systems
(something below 10) we encounter panics in xfrm code. The main characteristic seams
to be the usage of TPROXY.

Attached patch is only a workaround, as problems may also happen in other code portions
(actually on even fewer systems this happens).

For timewait sockets the memory region of sk_policy does not belong
to us anymore. So there may be someone else using it and we may panic
because of corrupted pointers.

xfrm_sk_policy_lookup+0x38/0x66
xfrm_lookup+0x93/0x48f
nf_nat_packet+0x92/0xa4 [nf_nat]
_decode_session4+0xd9/0x294
nf_xfrm_me_harder+0x50/0xc5 [nf_nat]
nf_nat_ipv4_out+0xad/0xc4 [iptable_nat]
nf_iterate+0x42/0x7d
ip_finish_output2+0x2b1/0x2b1
nf_hook_slow+0x22f/0x2c9
ip_finish_output2+0x2b1/0x2b1
ip_finish_output2+0x2b1/0x2b1
__xfrm_route_forward+0x7a/0x97
ip_finish_output2+0x2b1/0x2b1
NF_HOOK_COND+0x3f/0x54
ip_output+0x5a/0x5e
__netif_receive_skb+0x4b2/0x514
process_backlog+0xee/0x1c5
net_rx_action+0xa7/0x1fe

Signed-off-by: Sebastian Poehn <sebastian.poehn@gmail.com>
---
 net/xfrm/xfrm_policy.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 9c6b1ab..e9a74fa 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2072,7 +2072,7 @@ restart:
 	xdst = NULL;
 	route = NULL;
 
-	if (sk && sk->sk_policy[XFRM_POLICY_OUT]) {
+	if (sk && sk->sk_state != TCP_TIME_WAIT && sk->sk_policy[XFRM_POLICY_OUT]) {
 		num_pols = 1;
 		pols[0] = xfrm_sk_policy_lookup(sk, XFRM_POLICY_OUT, fl);
 		err = xfrm_expand_policies(fl, family, pols,
@@ -2349,7 +2349,7 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 	}
 
 	pol = NULL;
-	if (sk && sk->sk_policy[dir]) {
+	if (sk && sk->sk_state != TCP_TIME_WAIT && sk->sk_policy[dir]) {
 		pol = xfrm_sk_policy_lookup(sk, dir, &fl);
 		if (IS_ERR(pol)) {
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMINPOLERROR);
-- 
2.1.0
