From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net-next 01/10] sctp: silence warns on sctp_stream_init allocations
Date: Thu, 28 Sep 2017 17:25:14 -0300
Message-ID: <78853a7e413d1900fb410d73d064558fa09f221d.1506536044.git.marcelo.leitner@gmail.com>
References: <cover.1506536044.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Xin Long <lucien.xin@gmail.com>,
        David Laight <David.Laight@ACULAB.COM>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:35001 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750880AbdI1UZj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 16:25:39 -0400
In-Reply-To: <cover.1506536044.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As SCTP supports up to 65535 streams, that can lead to very large
allocations in sctp_stream_init(). As Xin Long noticed, systems with
small amounts of memory are more prone to not have enough memory and
dump warnings on dmesg initiated by user actions. Thus, silence them.

Also, if the reallocation of stream->out is not necessary, skip it and
keep the memory we already have.

Reported-by: Xin Long <lucien.xin@gmail.com>
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/stream.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/sctp/stream.c b/net/sctp/stream.c
index 63ea1550371493ec8863627c7a43f46a22f4a4c9..1afa9555808390d5fc736727422d9700a3855613 100644
--- a/net/sctp/stream.c
+++ b/net/sctp/stream.c
@@ -40,9 +40,14 @@ int sctp_stream_init(struct sctp_stream *stream, __u16 outcnt, __u16 incnt,
 {
 	int i;
 
+	gfp |= __GFP_NOWARN;
+
 	/* Initial stream->out size may be very big, so free it and alloc
-	 * a new one with new outcnt to save memory.
+	 * a new one with new outcnt to save memory if needed.
 	 */
+	if (outcnt == stream->outcnt)
+		goto in;
+
 	kfree(stream->out);
 
 	stream->out = kcalloc(outcnt, sizeof(*stream->out), gfp);
@@ -53,6 +58,7 @@ int sctp_stream_init(struct sctp_stream *stream, __u16 outcnt, __u16 incnt,
 	for (i = 0; i < stream->outcnt; i++)
 		stream->out[i].state = SCTP_STREAM_OPEN;
 
+in:
 	if (!incnt)
 		return 0;
 
-- 
2.13.5
