From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] tipc: fix endianness on tipc subscriber messages
Date: Mon, 8 Mar 2010 15:03:15 -0500
Message-ID: <20100308200315.GE23634@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: allan.stephens@windriver.com, davem@davemloft.net,
	nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:54973 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755540Ab0CHUDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 15:03:20 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove htohl implementation from tipc

I was working on forward porting the downstream commits for TIPC and ran accross this one:
http://tipc.cslab.ericsson.net/cgi-bin/gitweb.cgi?p=people/allan/tipc.git;a=commitdiff;h=894279b9437b63cbb02405ad5b8e033b51e4e31e

I was going to just take it, when I looked closer and noted what it was doing.
This is basically a routine to byte swap fields of data in sent/received packets
for tipc, dependent upon the receivers guessed endianness of the peer when a
connection is established.  Asside from just seeming silly to me, it appears to
violate the latest RFC draft for tipc:
http://tipc.sourceforge.net/doc/draft-spec-tipc-02.txt
Which, according to section 4.2 and 4.3.3, requires that all fields of all
commands be sent in network byte order.  So instead of just taking this patch,
instead I'm removing the htohl function and replacing the calls with calls to
ntohl in the rx path and htonl in the send path.

As part of this fix, I'm also changing the subscr_cancel function, which
searches the list of subscribers, using a memcmp of the entire subscriber list,
for the entry to tear down.  unfortunately it memcmps the entire tipc_subscr
structure which has several bits that are private to the local side, so nothing
will ever match.  section 5.2 of the draft spec indicates the <type,upper,lower>
tuple should uniquely identify a subscriber, so convert subscr_cancel to just
match on those fields (properly endian swapped).

I've tested this using the tipc test suite, and its passed without issue.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Allan Stephens <allan.stephens@windriver.com>


 subscr.c |   57 ++++++++++++++++++++++-----------------------------------
 subscr.h |    2 --
 2 files changed, 22 insertions(+), 37 deletions(-)

diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index ac91f0d..ff123e5 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -76,19 +76,6 @@ struct top_srv {
 static struct top_srv topsrv = { 0 };
 
 /**
- * htohl - convert value to endianness used by destination
- * @in: value to convert
- * @swap: non-zero if endianness must be reversed
- *
- * Returns converted value
- */
-
-static u32 htohl(u32 in, int swap)
-{
-	return swap ? swab32(in) : in;
-}
-
-/**
  * subscr_send_event - send a message containing a tipc_event to the subscriber
  *
  * Note: Must not hold subscriber's server port lock, since tipc_send() will
@@ -107,11 +94,11 @@ static void subscr_send_event(struct subscription *sub,
 	msg_sect.iov_base = (void *)&sub->evt;
 	msg_sect.iov_len = sizeof(struct tipc_event);
 
-	sub->evt.event = htohl(event, sub->swap);
-	sub->evt.found_lower = htohl(found_lower, sub->swap);
-	sub->evt.found_upper = htohl(found_upper, sub->swap);
-	sub->evt.port.ref = htohl(port_ref, sub->swap);
-	sub->evt.port.node = htohl(node, sub->swap);
+	sub->evt.event = htonl(event);
+	sub->evt.found_lower = htonl(found_lower);
+	sub->evt.found_upper = htonl(found_upper);
+	sub->evt.port.ref = htonl(port_ref);
+	sub->evt.port.node = htonl(node);
 	tipc_send(sub->server_ref, 1, &msg_sect);
 }
 
@@ -287,16 +274,23 @@ static void subscr_cancel(struct tipc_subscr *s,
 {
 	struct subscription *sub;
 	struct subscription *sub_temp;
+	__u32 type, lower, upper;
 	int found = 0;
 
 	/* Find first matching subscription, exit if not found */
 
+	type = ntohl(s->seq.type);
+	lower = ntohl(s->seq.lower);
+	upper = ntohl(s->seq.upper);
+
 	list_for_each_entry_safe(sub, sub_temp, &subscriber->subscription_list,
 				 subscription_list) {
-		if (!memcmp(s, &sub->evt.s, sizeof(struct tipc_subscr))) {
-			found = 1;
-			break;
-		}
+			if ((type == sub->seq.type) &&
+			    (lower == sub->seq.lower) &&
+			    (upper == sub->seq.upper)) {
+				found = 1;
+				break;
+			}
 	}
 	if (!found)
 		return;
@@ -325,16 +319,10 @@ static struct subscription *subscr_subscribe(struct tipc_subscr *s,
 					     struct subscriber *subscriber)
 {
 	struct subscription *sub;
-	int swap;
-
-	/* Determine subscriber's endianness */
-
-	swap = !(s->filter & (TIPC_SUB_PORTS | TIPC_SUB_SERVICE));
 
 	/* Detect & process a subscription cancellation request */
 
-	if (s->filter & htohl(TIPC_SUB_CANCEL, swap)) {
-		s->filter &= ~htohl(TIPC_SUB_CANCEL, swap);
+	if (ntohl(s->filter) & TIPC_SUB_CANCEL) {
 		subscr_cancel(s, subscriber);
 		return NULL;
 	}
@@ -359,11 +347,11 @@ static struct subscription *subscr_subscribe(struct tipc_subscr *s,
 
 	/* Initialize subscription object */
 
-	sub->seq.type = htohl(s->seq.type, swap);
-	sub->seq.lower = htohl(s->seq.lower, swap);
-	sub->seq.upper = htohl(s->seq.upper, swap);
-	sub->timeout = htohl(s->timeout, swap);
-	sub->filter = htohl(s->filter, swap);
+	sub->seq.type = ntohl(s->seq.type);
+	sub->seq.lower = ntohl(s->seq.lower);
+	sub->seq.upper = ntohl(s->seq.upper);
+	sub->timeout = ntohl(s->timeout);
+	sub->filter = ntohl(s->filter);
 	if ((!(sub->filter & TIPC_SUB_PORTS) ==
 	     !(sub->filter & TIPC_SUB_SERVICE)) ||
 	    (sub->seq.lower > sub->seq.upper)) {
@@ -376,7 +364,6 @@ static struct subscription *subscr_subscribe(struct tipc_subscr *s,
 	INIT_LIST_HEAD(&sub->nameseq_list);
 	list_add(&sub->subscription_list, &subscriber->subscription_list);
 	sub->server_ref = subscriber->port_ref;
-	sub->swap = swap;
 	memcpy(&sub->evt.s, s, sizeof(struct tipc_subscr));
 	atomic_inc(&topsrv.subscription_count);
 	if (sub->timeout != TIPC_WAIT_FOREVER) {
diff --git a/net/tipc/subscr.h b/net/tipc/subscr.h
index 45d89bf..c20f496 100644
--- a/net/tipc/subscr.h
+++ b/net/tipc/subscr.h
@@ -53,7 +53,6 @@ typedef void (*tipc_subscr_event) (struct subscription *sub,
  * @nameseq_list: adjacent subscriptions in name sequence's subscription list
  * @subscription_list: adjacent subscriptions in subscriber's subscription list
  * @server_ref: object reference of server port associated with subscription
- * @swap: indicates if subscriber uses opposite endianness in its messages
  * @evt: template for events generated by subscription
  */
 
@@ -66,7 +65,6 @@ struct subscription {
 	struct list_head nameseq_list;
 	struct list_head subscription_list;
 	u32 server_ref;
-	int swap;
 	struct tipc_event evt;
 };
 
