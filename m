From: Alexander Duyck <aduyck@mirantis.com>
Subject: [RFC PATCH 1/9] ipv4/GRO: Allow multiple frames to use the same IP
 ID
Date: Fri, 18 Mar 2016 16:24:45 -0700
Message-ID: <20160318232444.14955.38133.stgit@localhost.localdomain>
References: <20160318230945.14955.63211.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: ecree@solarflare.com, netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com, tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:36520 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753125AbcCRXYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 19:24:47 -0400
Received: by mail-pf0-f176.google.com with SMTP id u190so186556951pfb.3
        for <netdev@vger.kernel.org>; Fri, 18 Mar 2016 16:24:46 -0700 (PDT)
In-Reply-To: <20160318230945.14955.63211.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In RFC 6864 it is stated that we can essentially ignore the IPv4 ID field
if we have not and will not use fragmentation.  Such a frame is defined
as having the DF flag set to 1, and the MF and frag_offset as 0.  Currently
for GRO we were requiring that the inner header always have an increasing
IPv4 ID, but we are ignoring the outer value.

This patch is a first step in trying to reverse some of that.  Specifically
what this patch does is allow us to coalesce frames that have a static IPv4
ID value.  So for example if we had a series of frames where the DF flag
was set we would allow the same IPv4 ID value to be used for all the frames
belonging to that flow.  This would become the standard behavior for TCP so
it would support either a fixed IPv4 ID value, or one in which the value
increments.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 include/linux/netdevice.h |    5 ++++-
 net/ipv4/af_inet.c        |    8 ++++++--
 net/ipv4/tcp_offload.c    |   15 ++++++++++++++-
 3 files changed, 24 insertions(+), 4 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index be693b34662f..31474d9d8a96 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2113,7 +2113,10 @@ struct napi_gro_cb {
 	/* Used in foo-over-udp, set in udp[46]_gro_receive */
 	u8	is_ipv6:1;
 
-	/* 7 bit hole */
+	/* Flag indicating if IP ID can be ignored on receive */
+	u8	rfc6864:1;
+
+	/* 6 bit hole */
 
 	/* used to support CHECKSUM_COMPLETE for tunneling protocols */
 	__wsum	csum;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 0cc923f83e10..5e3885672907 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1320,6 +1320,8 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 
 	id = ntohl(*(__be32 *)&iph->id);
 	flush = (u16)((ntohl(*(__be32 *)iph) ^ skb_gro_len(skb)) | (id & ~IP_DF));
+
+	NAPI_GRO_CB(skb)->rfc6864 = !!(id & IP_DF);
 	id >>= 16;
 
 	for (p = *head; p; p = p->next) {
@@ -1352,8 +1354,10 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 		 * This is because some GSO/TSO implementations do not
 		 * correctly increment the IP ID for the outer hdrs.
 		 */
-		NAPI_GRO_CB(p)->flush_id =
-			    ((u16)(ntohs(iph2->id) + NAPI_GRO_CB(p)->count) ^ id);
+		NAPI_GRO_CB(p)->flush_id = (u16)(id - ntohs(iph2->id));
+		if (!NAPI_GRO_CB(p)->rfc6864 || !NAPI_GRO_CB(skb)->rfc6864)
+			NAPI_GRO_CB(p)->flush_id ^= NAPI_GRO_CB(p)->count;
+
 		NAPI_GRO_CB(p)->flush |= flush;
 	}
 
diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index 773083b7f1e9..1a2e9957c177 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -237,7 +237,7 @@ struct sk_buff **tcp_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 
 found:
 	/* Include the IP ID check below from the inner most IP hdr */
-	flush = NAPI_GRO_CB(p)->flush | NAPI_GRO_CB(p)->flush_id;
+	flush = NAPI_GRO_CB(p)->flush;
 	flush |= (__force int)(flags & TCP_FLAG_CWR);
 	flush |= (__force int)((flags ^ tcp_flag_word(th2)) &
 		  ~(TCP_FLAG_CWR | TCP_FLAG_FIN | TCP_FLAG_PSH));
@@ -246,6 +246,19 @@ found:
 		flush |= *(u32 *)((u8 *)th + i) ^
 			 *(u32 *)((u8 *)th2 + i);
 
+	/* Some devices may make use of RFC6864 to skip the need to
+	 * increment the IP ID on inner headers of tunneled frames.  This
+	 * allows them to make use of TSO by not updating the headers from
+	 * the outer L4 to inner L3.  We should be able to identify any such
+	 * frames on the second frame received and then after that we expect
+	 * the same ID on all remaining frames in the flow.
+	 */
+	if ((NAPI_GRO_CB(p)->flush_id == 1) && NAPI_GRO_CB(p)->rfc6864 &&
+	    (NAPI_GRO_CB(p)->count == 1))
+		NAPI_GRO_CB(p)->rfc6864 = 0;
+	else
+		flush |= NAPI_GRO_CB(p)->flush_id;
+
 	mss = skb_shinfo(p)->gso_size;
 
 	flush |= (len - 1) >= mss;
