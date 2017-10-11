From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH][next] sctp: make array sctp_sched_ops static
Date: Wed, 11 Oct 2017 03:44:50 -0700
Message-ID: <1507718690.3552.50.camel@perches.com>
References: <20171011101757.18825-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        "David S . Miller" <davem@davemloft.net>,
        linux-sctp@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0037.hostedemail.com ([216.40.44.37]:38743 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751462AbdJKKoy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 06:44:54 -0400
In-Reply-To: <20171011101757.18825-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-10-11 at 11:17 +0100, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> The array sctp_sched_ops  is local to the source and
> does not need to be in global scope, so make it static.
> 
> Cleans up sparse warning:
> symbol 'sctp_sched_ops' was not declared. Should it be static?
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  net/sctp/stream_sched.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sctp/stream_sched.c b/net/sctp/stream_sched.c
> index 03513a9fa110..0b83ec51e43b 100644
> --- a/net/sctp/stream_sched.c
> +++ b/net/sctp/stream_sched.c
> @@ -124,7 +124,7 @@ static struct sctp_sched_ops sctp_sched_fcfs = {
>  extern struct sctp_sched_ops sctp_sched_prio;
>  extern struct sctp_sched_ops sctp_sched_rr;
>  
> -struct sctp_sched_ops *sctp_sched_ops[] = {
> +static struct sctp_sched_ops *sctp_sched_ops[] = {
>  	&sctp_sched_fcfs,
>  	&sctp_sched_prio,
>  	&sctp_sched_rr,

Perhaps these should also be const to move more data to text
---
 include/net/sctp/stream_sched.h |  3 ++-
 include/net/sctp/structs.h      |  2 +-
 net/sctp/stream.c               |  6 +++---
 net/sctp/stream_sched.c         | 17 +++++++++--------
 4 files changed, 15 insertions(+), 13 deletions(-)

diff --git a/include/net/sctp/stream_sched.h b/include/net/sctp/stream_sched.h
index c676550a4c7d..431235c7587a 100644
--- a/include/net/sctp/stream_sched.h
+++ b/include/net/sctp/stream_sched.h
@@ -67,6 +67,7 @@ void sctp_sched_dequeue_done(struct sctp_outq *q, struct sctp_chunk *ch);
 
 void sctp_sched_dequeue_common(struct sctp_outq *q, struct sctp_chunk *ch);
 int sctp_sched_init_sid(struct sctp_stream *stream, __u16 sid, gfp_t gfp);
-struct sctp_sched_ops *sctp_sched_ops_from_stream(struct sctp_stream *stream);
+const struct sctp_sched_ops *
+sctp_sched_ops_from_stream(struct sctp_stream *stream);
 
 #endif /* __sctp_stream_sched_h__ */
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 6168e3449131..032ec5618e8a 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1028,7 +1028,7 @@ struct sctp_outq {
 	struct list_head out_chunk_list;
 
 	/* Stream scheduler being used */
-	struct sctp_sched_ops *sched;
+	const struct sctp_sched_ops *sched;
 
 	unsigned int out_qlen;	/* Total length of queued data chunks. */
 
diff --git a/net/sctp/stream.c b/net/sctp/stream.c
index 5ea33a2c453b..62678c2229e4 100644
--- a/net/sctp/stream.c
+++ b/net/sctp/stream.c
@@ -140,7 +140,7 @@ static int sctp_stream_alloc_in(struct sctp_stream *stream, __u16 incnt,
 int sctp_stream_init(struct sctp_stream *stream, __u16 outcnt, __u16 incnt,
 		     gfp_t gfp)
 {
-	struct sctp_sched_ops *sched = sctp_sched_ops_from_stream(stream);
+	const struct sctp_sched_ops *sched = sctp_sched_ops_from_stream(stream);
 	int i, ret = 0;
 
 	gfp |= __GFP_NOWARN;
@@ -201,7 +201,7 @@ int sctp_stream_init_ext(struct sctp_stream *stream, __u16 sid)
 
 void sctp_stream_free(struct sctp_stream *stream)
 {
-	struct sctp_sched_ops *sched = sctp_sched_ops_from_stream(stream);
+	const struct sctp_sched_ops *sched = sctp_sched_ops_from_stream(stream);
 	int i;
 
 	sched->free(stream);
@@ -224,7 +224,7 @@ void sctp_stream_clear(struct sctp_stream *stream)
 
 void sctp_stream_update(struct sctp_stream *stream, struct sctp_stream *new)
 {
-	struct sctp_sched_ops *sched = sctp_sched_ops_from_stream(stream);
+	const struct sctp_sched_ops *sched = sctp_sched_ops_from_stream(stream);
 
 	sched->unsched_all(stream);
 	sctp_stream_outq_migrate(stream, new, new->outcnt);
diff --git a/net/sctp/stream_sched.c b/net/sctp/stream_sched.c
index 03513a9fa110..642542be57ec 100644
--- a/net/sctp/stream_sched.c
+++ b/net/sctp/stream_sched.c
@@ -106,7 +106,7 @@ static void sctp_sched_fcfs_unsched_all(struct sctp_stream *stream)
 {
 }
 
-static struct sctp_sched_ops sctp_sched_fcfs = {
+static const struct sctp_sched_ops sctp_sched_fcfs = {
 	.set = sctp_sched_fcfs_set,
 	.get = sctp_sched_fcfs_get,
 	.init = sctp_sched_fcfs_init,
@@ -121,10 +121,10 @@ static struct sctp_sched_ops sctp_sched_fcfs = {
 
 /* API to other parts of the stack */
 
-extern struct sctp_sched_ops sctp_sched_prio;
-extern struct sctp_sched_ops sctp_sched_rr;
+extern const struct sctp_sched_ops sctp_sched_prio;
+extern const struct sctp_sched_ops sctp_sched_rr;
 
-struct sctp_sched_ops *sctp_sched_ops[] = {
+static const struct sctp_sched_ops *sctp_sched_ops[] = {
 	&sctp_sched_fcfs,
 	&sctp_sched_prio,
 	&sctp_sched_rr,
@@ -133,8 +133,8 @@ struct sctp_sched_ops *sctp_sched_ops[] = {
 int sctp_sched_set_sched(struct sctp_association *asoc,
 			 enum sctp_sched_type sched)
 {
-	struct sctp_sched_ops *n = sctp_sched_ops[sched];
-	struct sctp_sched_ops *old = asoc->outqueue.sched;
+	const struct sctp_sched_ops *n = sctp_sched_ops[sched];
+	const struct sctp_sched_ops *old = asoc->outqueue.sched;
 	struct sctp_datamsg *msg = NULL;
 	struct sctp_chunk *ch;
 	int i, ret = 0;
@@ -259,13 +259,14 @@ void sctp_sched_dequeue_common(struct sctp_outq *q, struct sctp_chunk *ch)
 
 int sctp_sched_init_sid(struct sctp_stream *stream, __u16 sid, gfp_t gfp)
 {
-	struct sctp_sched_ops *sched = sctp_sched_ops_from_stream(stream);
+	const struct sctp_sched_ops *sched = sctp_sched_ops_from_stream(stream);
 
 	INIT_LIST_HEAD(&stream->out[sid].ext->outq);
 	return sched->init_sid(stream, sid, gfp);
 }
 
-struct sctp_sched_ops *sctp_sched_ops_from_stream(struct sctp_stream *stream)
+const struct sctp_sched_ops *
+sctp_sched_ops_from_stream(struct sctp_stream *stream)
 {
 	struct sctp_association *asoc;
 
