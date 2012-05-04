From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [Lksctp-developers] Bug: sctp packets are dropped after IPSEC
 rekeying (route cache issue)
Date: Fri, 04 May 2012 12:07:38 +0200
Message-ID: <4FA3AA6A.4070503@6wind.com>
References: <AANLkTikYfUJRqlE5KR5v13-aFEzTfNyui14IcELmFNLX@mail.gmail.com> <4C408564.7040808@hp.com> <4C4456A5.3000403@6wind.com> <4C445A40.5010508@hp.com> <4C446CF5.5020007@6wind.com> <4C4470C5.7060608@hp.com> <4C456DC0.8030308@6wind.com> <4C46AA7B.3090601@6wind.com> <4C46FD58.9030107@hp.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010103040107000203090800"
Cc: Babu Srinivasan <babu.srinivasan@gmail.com>,
	lksctp-developers@lists.sourceforge.net,
	lksctp <linux-sctp@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"Kreuzer, Michael (NSN - DE/Ulm)" <michael.kreuzer@nsn.com>
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:64935 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754043Ab2EDKHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 06:07:43 -0400
Received: by eekc41 with SMTP id c41so782461eek.19
        for <netdev@vger.kernel.org>; Fri, 04 May 2012 03:07:42 -0700 (PDT)
In-Reply-To: <4C46FD58.9030107@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010103040107000203090800
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

Finally, this patch was never integrated into the mainline. Should I rebase it 
on the head?

I've attach the last approved patch.

Here is the original thread:
http://sourceforge.net/mailarchive/message.php?msg_id=25786006

Regards,
Nicolas

Le 21/07/2010 15:59, Vlad Yasevich a écrit :
> On 07/21/2010 04:06 AM, Nicolas Dichtel wrote:
>> Finally, we can use dst_check(). Please, find a new patch enclosed.
>>
>>
>> Regards,
>> Nicolas
>>
>
> I like this one a better.  Taken.
>
> Thanks
> -vlad

--------------010103040107000203090800
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


--------------010103040107000203090800--
