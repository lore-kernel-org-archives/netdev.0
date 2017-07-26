From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: fix the check for _sctp_walk_params and _sctp_walk_errors
Date: Wed, 26 Jul 2017 16:24:59 +0800
Message-ID: <81a6fb647ad305525c840eae623c41b7ba52c975.1501057499.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, glider@google.com
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:37235 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750816AbdGZIZI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 04:25:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit b1f5bfc27a19 ("sctp: don't dereference ptr before leaving
_sctp_walk_{params, errors}()") tried to fix the issue that it
may overstep the chunk end for _sctp_walk_{params, errors} with
'chunk_end > offset(length) + sizeof(length)'.

But it introduced a side effect: When processing INIT, it verifies
the chunks with 'param.v == chunk_end' after iterating all params
by sctp_walk_params(). With the check 'chunk_end > offset(length)
+ sizeof(length)', it would return when the last param is not yet
accessed. Because the last param usually is fwdtsn supported param
whose size is 4 and 'chunk_end == offset(length) + sizeof(length)'

This is a badly issue even causing sctp couldn't process 4-shakes.
Client would always get abort when connecting to server, due to
the failure of INIT chunk verification on server.

The patch is to use 'chunk_end <= offset(length) + sizeof(length)'
instead of 'chunk_end < offset(length) + sizeof(length)' for both
_sctp_walk_params and _sctp_walk_errors.

Fixes: b1f5bfc27a19 ("sctp: don't dereference ptr before leaving _sctp_walk_{params, errors}()")
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/sctp.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 980807d..45fd4c6 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -469,7 +469,7 @@ _sctp_walk_params((pos), (chunk), ntohs((chunk)->chunk_hdr.length), member)
 
 #define _sctp_walk_params(pos, chunk, end, member)\
 for (pos.v = chunk->member;\
-     (pos.v + offsetof(struct sctp_paramhdr, length) + sizeof(pos.p->length) <\
+     (pos.v + offsetof(struct sctp_paramhdr, length) + sizeof(pos.p->length) <=\
       (void *)chunk + end) &&\
      pos.v <= (void *)chunk + end - ntohs(pos.p->length) &&\
      ntohs(pos.p->length) >= sizeof(struct sctp_paramhdr);\
@@ -481,7 +481,7 @@ _sctp_walk_errors((err), (chunk_hdr), ntohs((chunk_hdr)->length))
 #define _sctp_walk_errors(err, chunk_hdr, end)\
 for (err = (sctp_errhdr_t *)((void *)chunk_hdr + \
 	    sizeof(struct sctp_chunkhdr));\
-     ((void *)err + offsetof(sctp_errhdr_t, length) + sizeof(err->length) <\
+     ((void *)err + offsetof(sctp_errhdr_t, length) + sizeof(err->length) <=\
       (void *)chunk_hdr + end) &&\
      (void *)err <= (void *)chunk_hdr + end - ntohs(err->length) &&\
      ntohs(err->length) >= sizeof(sctp_errhdr_t); \
-- 
2.1.0
