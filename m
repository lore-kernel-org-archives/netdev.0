From: Simon Horman <horms@verge.net.au>
Subject: IPVS: use proper timeout instead of fixed value
Date: Mon, 29 Oct 2007 16:05:55 +0900 (JST)
Message-ID: <20071029070555.78D694FA13@tabatha.lab.ultramonkey.org>
Cc: wensong@linux-vs.org, ja@ssi.bg, Joseph Mack NA3T <jmack@wm7d.net>,
	Graeme Fowler <graeme@graemef.net>,
	Andreas Lundqvist <lvs@rsv.se>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org, lvs-devel@linuxvirtualserver.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:58088 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751001AbXJ2HF7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 03:05:59 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Gospodarek <andy@greyhouse.net>

Instead of using the default timeout of 3 minutes, this uses the timeout
specific to the protocol used for the connection. The 3 minute timeout
seems somewhat arbitrary (though I know it is used other places in the
ipvs code) and when failing over it would be much nicer to use one of
the configured timeout values.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
Acked-by: Simon Horman <horms@verge.net.au>

---

Hi,

I'd like to revisit this patch which was originally posted
to netdev in May 2006.

Looking through the archives as far as I can see there was
some discussion as to whether it would be good to send timeout
information in the synchronisation packet, and some discussion
as to whether it would be good to make the timeout configurable
on the slave side, and then the ball was dropped.

It seems to me that regardless of whether or not the syncronisation
protocol should be expanded to include timeout information,
and wheather or not it should be configurable on the slave side,
this patch is a good idea as the default that it provides seems
to be much more sensible than the current arrangement.

Andreas Lundqvist provided me with an example where his
cluser has long often idle connections and that in this case
the short, 3 minute default timeout, really is quite useless.

 ip_vs_sync.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_sync.c b/net/ipv4/ipvs/ip_vs_sync.c
--- a/net/ipv4/ipvs/ip_vs_sync.c
+++ b/net/ipv4/ipvs/ip_vs_sync.c
@@ -67,7 +67,6 @@ struct ip_vs_sync_conn_options {
 	struct ip_vs_seq        out_seq;        /* outgoing seq. struct */
 };
 
-#define IP_VS_SYNC_CONN_TIMEOUT (3*60*HZ)
 #define SIMPLE_CONN_SIZE  (sizeof(struct ip_vs_sync_conn))
 #define FULL_CONN_SIZE  \
 (sizeof(struct ip_vs_sync_conn) + sizeof(struct ip_vs_sync_conn_options))
@@ -279,6 +278,7 @@ static void ip_vs_process_message(const 
 	struct ip_vs_sync_conn *s;
 	struct ip_vs_sync_conn_options *opt;
 	struct ip_vs_conn *cp;
+	struct ip_vs_protocol *pp;
 	char *p;
 	int i;
 
@@ -337,7 +337,8 @@ static void ip_vs_process_message(const 
 			p += SIMPLE_CONN_SIZE;
 
 		atomic_set(&cp->in_pkts, sysctl_ip_vs_sync_threshold[0]);
-		cp->timeout = IP_VS_SYNC_CONN_TIMEOUT;
+		pp = ip_vs_proto_get(s->protocol);
+		cp->timeout = pp->timeout_table[cp->state];
 		ip_vs_conn_put(cp);
 
 		if (p > buffer+buflen) {
