From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [BK PATCH] minor SCTP updates
Date: Mon, 3 May 2004 14:20:18 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0405031413390.2682@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

Please do a
	bk pull http://linux-lksctp.bkbits.net/lksctp-2.5.work &
	bk pull http://linux-lksctp.bkbits.net/lksctp-2.4.work
to get the following udpates to 2.6 and 2.4 SCTP.

Thanks
Sridhar

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/05/03 11:17:48-07:00 sri@us.ibm.com
#   [SCTP] Rename SCTP_ADDR_REACHABLE as SCTP_ADDR_AVAILABLE to be
#   consistent with the SCTP sockets API draft.
#
# net/sctp/associola.c
# include/net/sctp/user.h
# include/net/sctp/constants.h
#
# ChangeSet
#   2004/05/03 11:14:28-07:00 sri@us.ibm.com
#   [SCTP] Fix bugs in handling overlapping INIT and peer restart over a
#   multihomed association.
#
# net/sctp/associola.c
#
# ChangeSet
#   2004/05/03 11:11:07-07:00 shemminger@osdl.org
#   [PATCH] SCTP crc table can be static const
#
# net/sctp/crc32c.c
#
diff -Nru a/include/net/sctp/constants.h b/include/net/sctp/constants.h
--- a/include/net/sctp/constants.h	Mon May  3 14:12:01 2004
+++ b/include/net/sctp/constants.h	Mon May  3 14:12:01 2004
@@ -231,11 +231,6 @@
 /* This is a table of printable names of sctp_state_t's.  */
 extern const char *sctp_state_tbl[], *sctp_evttype_tbl[], *sctp_status_tbl[];

-/* SCTP reachability state for each address */
-#define SCTP_ADDR_NOHB			4
-#define SCTP_ADDR_REACHABLE		2
-#define SCTP_ADDR_NOT_REACHABLE		1
-
 /* Maximum chunk length considering padding requirements. */
 enum { SCTP_MAX_CHUNK_LEN = ((1<<16) - sizeof(__u32)) };

diff -Nru a/include/net/sctp/user.h b/include/net/sctp/user.h
--- a/include/net/sctp/user.h	Mon May  3 14:12:01 2004
+++ b/include/net/sctp/user.h	Mon May  3 14:12:01 2004
@@ -1,7 +1,7 @@
 /* SCTP kernel reference Implementation
+ * (C) Copyright IBM Corp. 2001, 2004
  * Copyright (c) 1999-2000 Cisco, Inc.
  * Copyright (c) 1999-2001 Motorola, Inc.
- * Copyright (c) 2001-2003 International Business Machines, Corp.
  * Copyright (c) 2002 Intel Corp.
  *
  * This file is part of the SCTP kernel reference Implementation
@@ -246,7 +246,7 @@
  *   event that happened to the address.  They include:
  */
 enum sctp_spc_state {
-	SCTP_ADDR_REACHABLE,
+	SCTP_ADDR_AVAILABLE,
 	SCTP_ADDR_UNREACHABLE,
 	SCTP_ADDR_REMOVED,
 	SCTP_ADDR_ADDED,
diff -Nru a/net/sctp/associola.c b/net/sctp/associola.c
--- a/net/sctp/associola.c	Mon May  3 14:12:01 2004
+++ b/net/sctp/associola.c	Mon May  3 14:12:01 2004
@@ -608,7 +608,7 @@
 	switch (command) {
 	case SCTP_TRANSPORT_UP:
 		transport->active = SCTP_ACTIVE;
-		spc_state = SCTP_ADDR_REACHABLE;
+		spc_state = SCTP_ADDR_AVAILABLE;
 		break;

 	case SCTP_TRANSPORT_DOWN:
@@ -936,6 +936,9 @@
 void sctp_assoc_update(struct sctp_association *asoc,
 		       struct sctp_association *new)
 {
+	struct sctp_transport *trans;
+	struct list_head *pos, *temp;
+
 	/* Copy in new parameters of peer. */
 	asoc->c = new->c;
 	asoc->peer.rwnd = new->peer.rwnd;
@@ -944,20 +947,19 @@
 	sctp_tsnmap_init(&asoc->peer.tsn_map, SCTP_TSN_MAP_SIZE,
 			 asoc->peer.i.initial_tsn);

-	/* FIXME:
-	 *    Do we need to copy primary_path etc?
-	 *
-	 *    More explicitly, addresses may have been removed and
-	 *    this needs accounting for.
-	 */
+	/* Remove any peer addresses not present in the new association. */
+	list_for_each_safe(pos, temp, &asoc->peer.transport_addr_list) {
+		trans = list_entry(pos, struct sctp_transport, transports);
+		if (!sctp_assoc_lookup_paddr(new, &trans->ipaddr))
+			sctp_assoc_del_peer(asoc, &trans->ipaddr);
+	}

 	/* If the case is A (association restart), use
 	 * initial_tsn as next_tsn. If the case is B, use
 	 * current next_tsn in case data sent to peer
 	 * has been discarded and needs retransmission.
 	 */
-	if (sctp_state(asoc, ESTABLISHED)) {
-
+	if (asoc->state >= SCTP_STATE_ESTABLISHED) {
 		asoc->next_tsn = new->next_tsn;
 		asoc->ctsn_ack_point = new->ctsn_ack_point;
 		asoc->adv_peer_ack_point = new->adv_peer_ack_point;
@@ -968,6 +970,15 @@
 		sctp_ssnmap_clear(asoc->ssnmap);

 	} else {
+		/* Add any peer addresses from the new association. */
+		list_for_each(pos, &new->peer.transport_addr_list) {
+			trans = list_entry(pos, struct sctp_transport,
+					   transports);
+			if (!sctp_assoc_lookup_paddr(asoc, &trans->ipaddr))
+				sctp_assoc_add_peer(asoc, &trans->ipaddr,
+						    GFP_ATOMIC);
+		}
+
 		asoc->ctsn_ack_point = asoc->next_tsn - 1;
 		asoc->adv_peer_ack_point = asoc->ctsn_ack_point;
 		if (!asoc->ssnmap) {
@@ -976,7 +987,6 @@
 			new->ssnmap = NULL;
 		}
 	}
-
 }

 /* Update the retran path for sending a retransmitted packet.
diff -Nru a/net/sctp/crc32c.c b/net/sctp/crc32c.c
--- a/net/sctp/crc32c.c	Mon May  3 14:12:01 2004
+++ b/net/sctp/crc32c.c	Mon May  3 14:12:01 2004
@@ -69,7 +69,7 @@
 /* with 24 and 32 Parity Bits",                                  */
 /* IEEE Transactions on Communications, Vol.41, No.6, June 1993  */
 /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
-__u32 crc_c[256] = {
+static const __u32 crc_c[256] = {
 	0x00000000, 0xF26B8303, 0xE13B70F7, 0x1350F3F4,
 	0xC79A971F, 0x35F1141C, 0x26A1E7E8, 0xD4CA64EB,
 	0x8AD958CF, 0x78B2DBCC, 0x6BE22838, 0x9989AB3B,
