From: jamal <hadi@cyberus.ca>
Subject: [PATCH][RFC]: ingress socket filter by mark
Date: Sun, 18 Oct 2009 08:42:38 -0400
Message-ID: <1255869758.4815.40.camel@dogo.mojatatu.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-e9dyI/LHVN6Uuy2tXfeE"
Cc: David Miller <davem@davemloft.net>, Atis Elsts <atis@mikrotik.com>,
	eric.dumazet@gmail.com,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f194.google.com ([209.85.221.194]:58556 "EHLO
	mail-qy0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754305AbZJRMpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2009 08:45:39 -0400
Received: by qyk32 with SMTP id 32so2437638qyk.4
        for <netdev@vger.kernel.org>; Sun, 18 Oct 2009 05:45:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-e9dyI/LHVN6Uuy2tXfeE
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Maciej forced me to dig into this ;->

at the socket level if a packet arrives with a different mark than
what we bind to, drop it. I have tested this patch and it drops a packet
with mismatching mark.

There are several approaches - and i think the patch suggestion i have
made here maybe too strict. I assume that if someone binds to a mark,
they want to not only send packets with that mark but receive
only if that mark is set. 
A looser check would be something along the line accept as well if mark
is not set i.e
if (sk->sk_mark && skb->mark && sk->sk_mark != skb->mark)

Alternatively i could add one bit in the socket flags and have it so
that check is made only if app has been explicit:
if (sock_flag(sk, SOCK_CHK_SOMARK) && sk->sk_mark != skb->mark) drop

Another approach  is to set sock filter from app. I dont like this
approach because it will be the least usable from app level and would be
the least simple from kernel level.

cheers,
jamal

--=-e9dyI/LHVN6Uuy2tXfeE
Content-Disposition: attachment; filename=filt-sock-m
Content-Type: text/x-patch; name=filt-sock-m; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff --git a/net/core/filter.c b/net/core/filter.c
index d1d779c..6fcf577 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -85,6 +85,9 @@ int sk_filter(struct sock *sk, struct sk_buff *skb)
 	if (err)
 		return err;
 
+	if (sk->sk_mark && sk->sk_mark != skb->mark)
+		return -EPERM;
+
 	rcu_read_lock_bh();
 	filter = rcu_dereference(sk->sk_filter);
 	if (filter) {

--=-e9dyI/LHVN6Uuy2tXfeE--

