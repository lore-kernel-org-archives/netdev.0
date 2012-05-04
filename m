From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [Lksctp-developers] Bug: sctp packets are dropped after IPSEC
 rekeying (route cache issue)
Date: Fri, 04 May 2012 17:24:54 +0200
Message-ID: <4FA3F4C6.7070605@6wind.com>
References: <4C46AA7B.3090601@6wind.com> <4C46FD58.9030107@hp.com> <4FA3AA6A.4070503@6wind.com> <20120504.104812.502049217620285020.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020702020800080306070100"
Cc: babu.srinivasan@gmail.com, lksctp-developers@lists.sourceforge.net,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	michael.kreuzer@nsn.com
To: David Miller <davem@davemloft.net>, vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:42866 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751247Ab2EDPZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 11:25:09 -0400
Received: by eaaq12 with SMTP id q12so872511eaa.19
        for <netdev@vger.kernel.org>; Fri, 04 May 2012 08:25:07 -0700 (PDT)
In-Reply-To: <20120504.104812.502049217620285020.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020702020800080306070100
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

Le 04/05/2012 16:48, David Miller a écrit :
> From: Nicolas Dichtel<nicolas.dichtel@6wind.com>
> Date: Fri, 04 May 2012 12:07:38 +0200
>
>> Finally, this patch was never integrated into the mainline. Should I
>> rebase it on the head?
>>
>> I've attach the last approved patch.
>>
>> Here is the original thread:
>> http://sourceforge.net/mailarchive/message.php?msg_id=25786006
>
> Vlad no longer works for HP so your email likely will bounce, and
> he will not see it.
Right.

>
> His new email address is vyasevich@gmail.com, as per the MAINTAINERS
> file.

I put the right email address now. I attach the patch again, for Vlad.


Thank you,
Nicolas

--------------020702020800080306070100
Content-Type: text/x-patch;
 name="0001-sctp-check-cached-dst-before-using-it.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0001-sctp-check-cached-dst-before-using-it.patch"

>From a54926eded11de99a0cfcda45d852d2f6e919b77 Mon Sep 17 00:00:00 2001
From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed, 21 Jul 2010 09:59:49 +0200
Subject: [PATCH] sctp: check cached dst before using it

dst_check() will take care of SA (and obsolete field), hence
IPsec rekeying scenario is taken into account.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/sctp/sctp.h |   13 +++++++++++++
 net/sctp/output.c       |    4 +---
 net/sctp/transport.c    |   17 -----------------
 3 files changed, 14 insertions(+), 20 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 65946bc..ab54df3 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -691,4 +691,17 @@ static inline void sctp_v4_map_v6(union sctp_addr *addr)
 	addr->v6.sin6_addr.s6_addr32[2] = htonl(0x0000ffff);
 }
 
+/* The cookie is always 0 since this is how it's used in the
+ * pmtu code.
+ */
+static inline struct dst_entry *sctp_transport_dst_check(struct sctp_transport *t)
+{
+	if (t->dst && !dst_check(t->dst, 0)) {
+		dst_release(t->dst);
+		t->dst = NULL;
+	}
+
+	return t->dst;
+}
+
 #endif /* __net_sctp_h__ */
diff --git a/net/sctp/output.c b/net/sctp/output.c
index a646681..93daf59 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -376,9 +376,7 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 	 */
 	skb_set_owner_w(nskb, sk);
 
-	/* The 'obsolete' field of dst is set to 2 when a dst is freed. */
-	if (!dst || (dst->obsolete > 1)) {
-		dst_release(dst);
+	if (!sctp_transport_dst_check(tp)) {
 		sctp_transport_route(tp, NULL, sctp_sk(sk));
 		if (asoc && (asoc->param_flags & SPP_PMTUD_ENABLE)) {
 			sctp_assoc_sync_pmtu(asoc);
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index 132046c..bce3f06 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -222,23 +222,6 @@ void sctp_transport_pmtu(struct sctp_transport *transport)
 		transport->pathmtu = SCTP_DEFAULT_MAXSEGMENT;
 }
 
-/* this is a complete rip-off from __sk_dst_check
- * the cookie is always 0 since this is how it's used in the
- * pmtu code
- */
-static struct dst_entry *sctp_transport_dst_check(struct sctp_transport *t)
-{
-	struct dst_entry *dst = t->dst;
-
-	if (dst && dst->obsolete && dst->ops->check(dst, 0) == NULL) {
-		dst_release(t->dst);
-		t->dst = NULL;
-		return NULL;
-	}
-
-	return dst;
-}
-
 void sctp_transport_update_pmtu(struct sctp_transport *t, u32 pmtu)
 {
 	struct dst_entry *dst;
-- 
1.5.4.5


--------------020702020800080306070100--
