From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [BK PATCH] 2.6 SCTP updates.
Date: Tue, 6 Apr 2004 10:28:36 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0404061014340.6232@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,

Please do a
	bk pull http://linux-lksctp.bkbits.net/lksctp-2.5.work
to get the following updates to SCTP on top of linux 2.6.5

Thanks
Sridhar

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/04/06 07:32:30-07:00 sri@us.ibm.com
#   [SCTP] Use id to ptr translation service in lib/idr.c to assign and
#   validate ids of associations.
#
#   This patch avoids the use of virt_addr_valid() to validate the address
#   of associations passed by the user. Currently the address of an
#   association is used as its id. virt_addr_valid doesn't work as
#   expected when PAGEALLOC debugging is enabled.
#
# net/sctp/socket.c
# net/sctp/sm_make_chunk.c
# net/sctp/protocol.c
# net/sctp/associola.c
# include/net/sctp/structs.h
# include/net/sctp/sctp.h
# ChangeSet
#   2004/04/06 07:24:04-07:00 sri@us.ibm.com
#   [SCTP] Update sctp_ulpevent structure to include assoc pointer and
#   only the receive specific fields of sctp_sndrcvinfo.
#
# net/sctp/ulpqueue.c
# net/sctp/ulpevent.c
# net/sctp/socket.c
# net/sctp/protocol.c
# net/sctp/ipv6.c
# include/net/sctp/ulpevent.h
#
# ChangeSet
#   2004/04/06 00:28:31-07:00 sri@us.ibm.com
#   [SCTP] Fix typo in entry name of the remove_proc_entry() call.
#
# net/sctp/objcnt.c
#
diff -Nru a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
--- a/include/net/sctp/sctp.h	Tue Apr  6 07:35:28 2004
+++ b/include/net/sctp/sctp.h	Tue Apr  6 07:35:28 2004
@@ -1,5 +1,5 @@
 /* SCTP kernel reference Implementation
- * (C) Copyright IBM Corp. 2001, 2003
+ * (C) Copyright IBM Corp. 2001, 2004
  * Copyright (c) 1999-2000 Cisco, Inc.
  * Copyright (c) 1999-2001 Motorola, Inc.
  * Copyright (c) 2001-2003 Intel Corp.
@@ -78,6 +78,7 @@
 #include <linux/proc_fs.h>
 #include <linux/spinlock.h>
 #include <linux/jiffies.h>
+#include <linux/idr.h>

 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 #include <net/ipv6.h>
@@ -223,24 +224,6 @@
 #define SCTP_INC_STATS_USER(field) SNMP_INC_STATS_USER(sctp_statistics, field)
 #define SCTP_DEC_STATS(field)      SNMP_DEC_STATS(sctp_statistics, field)

-/* Determine if this is a valid kernel address.  */
-static inline int sctp_is_valid_kaddr(unsigned long addr)
-{
-	struct page *page;
-
-	/* Make sure the address is not in the user address space. */
-	if (addr < PAGE_OFFSET)
-		return 0;
-
-	page = virt_to_page(addr);
-
-	/* Is this page valid? */
-	if (!virt_addr_valid(addr) || PageReserved(page))
-		return 0;
-
-	return 1;
-}
-
 #endif /* !TEST_FRAME */


@@ -357,7 +340,7 @@
 /* Map an association to an assoc_id. */
 static inline sctp_assoc_t sctp_assoc2id(const struct sctp_association *asoc)
 {
-	return (sctp_assoc_t) asoc;
+	return (asoc?asoc->assoc_id:NULL);
 }

 /* Look up the association by its id.  */
@@ -518,6 +501,9 @@
 extern struct proto sctp_prot;
 extern struct proc_dir_entry *proc_net_sctp;
 void sctp_put_port(struct sock *sk);
+
+extern struct idr sctp_assocs_id;
+extern spinlock_t sctp_assocs_id_lock;

 /* Static inline functions. */

diff -Nru a/include/net/sctp/structs.h b/include/net/sctp/structs.h
--- a/include/net/sctp/structs.h	Tue Apr  6 07:35:28 2004
+++ b/include/net/sctp/structs.h	Tue Apr  6 07:35:28 2004
@@ -1,5 +1,5 @@
 /* SCTP kernel reference Implementation
- * (C) Copyright IBM Corp. 2001, 2003
+ * (C) Copyright IBM Corp. 2001, 2004
  * Copyright (c) 1999-2000 Cisco, Inc.
  * Copyright (c) 1999-2001 Motorola, Inc.
  * Copyright (c) 2001 Intel Corp.
@@ -1282,11 +1282,8 @@
 	/* Associations on the same socket. */
 	struct list_head asocs;

-	/* This is a signature that lets us know that this is a
-	 * struct sctp_association data structure.  Used for mapping an
-	 * association id to an association.
-	 */
-	__u32 eyecatcher;
+	/* association id. */
+	sctp_assoc_t assoc_id;

 	/* This is our parent endpoint.	 */
 	struct sctp_endpoint *ep;
diff -Nru a/include/net/sctp/ulpevent.h b/include/net/sctp/ulpevent.h
--- a/include/net/sctp/ulpevent.h	Tue Apr  6 07:35:27 2004
+++ b/include/net/sctp/ulpevent.h	Tue Apr  6 07:35:27 2004
@@ -1,7 +1,7 @@
 /* SCTP kernel reference Implementation
+ * (C) Copyright IBM Corp. 2001, 2004
  * Copyright (c) 1999-2000 Cisco, Inc.
  * Copyright (c) 1999-2001 Motorola, Inc.
- * Copyright (c) 2001 International Business Machines, Corp.
  * Copyright (c) 2001 Intel Corp.
  * Copyright (c) 2001 Nokia, Inc.
  * Copyright (c) 2001 La Monte H.P. Yarroll
@@ -54,7 +54,13 @@
  * growing this structure as it is at the maximum limit now.
  */
 struct sctp_ulpevent {
-	struct sctp_sndrcvinfo sndrcvinfo;
+	struct sctp_association *asoc;
+	__u16 stream;
+	__u16 ssn;
+	__u16 flags;
+	__u32 ppid;
+	__u32 tsn;
+	__u32 cumtsn;
 	int msg_flags;
 	int iif;
 };
diff -Nru a/net/sctp/associola.c b/net/sctp/associola.c
--- a/net/sctp/associola.c	Tue Apr  6 07:35:27 2004
+++ b/net/sctp/associola.c	Tue Apr  6 07:35:27 2004
@@ -1,5 +1,5 @@
 /* SCTP kernel reference Implementation
- * (C) Copyright IBM Corp. 2001, 2003
+ * (C) Copyright IBM Corp. 2001, 2004
  * Copyright (c) 1999-2000 Cisco, Inc.
  * Copyright (c) 1999-2001 Motorola, Inc.
  * Copyright (c) 2001 Intel Corp.
@@ -276,7 +276,7 @@

 	asoc->need_ecne = 0;

-	asoc->eyecatcher = SCTP_ASSOC_EYECATCHER;
+	asoc->assoc_id = (sctp_assoc_t)-1;

 	/* Assume that peer would support both address types unless we are
 	 * told otherwise.
@@ -360,8 +360,6 @@
 		sctp_transport_free(transport);
 	}

-	asoc->eyecatcher = 0;
-
 	/* Free any cached ASCONF_ACK chunk. */
 	if (asoc->addip_last_asconf_ack)
 		sctp_chunk_free(asoc->addip_last_asconf_ack);
@@ -381,6 +379,12 @@
 	sctp_endpoint_put(asoc->ep);
 	sock_put(asoc->base.sk);

+	if ((int)asoc->assoc_id != -1) {
+		spin_lock_bh(&sctp_assocs_id_lock);
+		idr_remove(&sctp_assocs_id, (int)asoc->assoc_id);
+		spin_unlock_bh(&sctp_assocs_id_lock);
+	}
+
 	if (asoc->base.malloced) {
 		kfree(asoc);
 		SCTP_DBG_OBJCNT_DEC(assoc);
@@ -856,26 +860,6 @@
 	return transport;
 }

-/*  Is this a live association structure. */
-int sctp_assoc_valid(struct sock *sk, struct sctp_association *asoc)
-{
-
-	/* First, verify that this is a kernel address. */
-	if (!sctp_is_valid_kaddr((unsigned long) asoc))
-		return 0;
-
-	/* Verify that this _is_ an sctp_association
-	 * data structure and if so, that the socket matches.
-	 */
-	if (SCTP_ASSOC_EYECATCHER != asoc->eyecatcher)
-		return 0;
-	if (asoc->base.sk != sk)
-		return 0;
-
-	/* The association is valid. */
-	return 1;
-}
-
 /* Do delayed input processing.  This is scheduled by sctp_rcv(). */
 static void sctp_assoc_bh_rcv(struct sctp_association *asoc)
 {
@@ -891,6 +875,7 @@
 	sk = asoc->base.sk;

 	inqueue = &asoc->base.inqueue;
+	sctp_association_hold(asoc);
 	while (NULL != (chunk = sctp_inq_pop(inqueue))) {
 		state = asoc->state;
 		subtype = chunk->chunk_hdr->type;
@@ -913,14 +898,14 @@
 		/* Check to see if the association is freed in response to
 		 * the incoming chunk.  If so, get out of the while loop.
 		 */
-		if (!sctp_assoc_valid(sk, asoc))
+		if (asoc->base.dead)
 			break;

 		/* If there is an error on chunk, discard this packet. */
 		if (error && chunk)
 			chunk->pdiscard = 1;
 	}
-
+	sctp_association_put(asoc);
 }

 /* This routine moves an association from its old sk to a new sk.  */
diff -Nru a/net/sctp/ipv6.c b/net/sctp/ipv6.c
--- a/net/sctp/ipv6.c	Tue Apr  6 07:35:28 2004
+++ b/net/sctp/ipv6.c	Tue Apr  6 07:35:28 2004
@@ -1,7 +1,7 @@
 /* SCTP kernel reference Implementation
+ * (C) Copyright IBM Corp. 2002, 2004
  * Copyright (c) 2001 Nokia, Inc.
  * Copyright (c) 2001 La Monte H.P. Yarroll
- * Copyright (c) 2002-2003 International Business Machines, Corp.
  * Copyright (c) 2002-2003 Intel Corp.
  *
  * This file is part of the SCTP kernel reference Implementation
@@ -698,7 +698,7 @@
 		union sctp_addr *addr;
 		struct sctp_association *asoc;

-		asoc = event->sndrcvinfo.sinfo_assoc_id;
+		asoc = event->asoc;
 		sctp_inet6_msgname(msgname, addrlen);
 		sin6 = (struct sockaddr_in6 *)msgname;
 		sin6->sin6_port = htons(asoc->peer.port);
diff -Nru a/net/sctp/objcnt.c b/net/sctp/objcnt.c
--- a/net/sctp/objcnt.c	Tue Apr  6 07:35:27 2004
+++ b/net/sctp/objcnt.c	Tue Apr  6 07:35:27 2004
@@ -1,5 +1,5 @@
 /* SCTP kernel reference Implementation
- * Copyright (c) 2001 International Business Machines Corp.
+ * (C) Copyright IBM Corp. 2001, 2004
  *
  * This file is part of the SCTP kernel reference Implementation
  *
@@ -134,7 +134,7 @@
 /* Cleanup the objcount entry in the proc filesystem.  */
 void sctp_dbg_objcnt_exit(void)
 {
-	remove_proc_entry("sctp_dbg_objcount", proc_net_sctp);
+	remove_proc_entry("sctp_dbg_objcnt", proc_net_sctp);
 }


diff -Nru a/net/sctp/protocol.c b/net/sctp/protocol.c
--- a/net/sctp/protocol.c	Tue Apr  6 07:35:28 2004
+++ b/net/sctp/protocol.c	Tue Apr  6 07:35:28 2004
@@ -64,6 +64,9 @@
 struct proc_dir_entry	*proc_net_sctp;
 DEFINE_SNMP_STAT(struct sctp_mib, sctp_statistics);

+struct idr sctp_assocs_id;
+spinlock_t sctp_assocs_id_lock = SPIN_LOCK_UNLOCKED;
+
 /* This is the global socket data structure used for responding to
  * the Out-of-the-blue (OOTB) packets.  A control sock will be created
  * for this socket at the initialization time.
@@ -721,7 +724,7 @@
 	if (msgname) {
 		struct sctp_association *asoc;

-		asoc = event->sndrcvinfo.sinfo_assoc_id;
+		asoc = event->asoc;
 		sctp_inet_msgname(msgname, addr_len);
 		sin = (struct sockaddr_in *)msgname;
 		sinfrom = &asoc->peer.primary_addr.v4;
@@ -1048,6 +1051,9 @@
 	/* Initialize default stream count setup information. */
 	sctp_max_instreams    		= SCTP_DEFAULT_INSTREAMS;
 	sctp_max_outstreams   		= SCTP_DEFAULT_OUTSTREAMS;
+
+	/* Initialize handle used for association ids. */
+	idr_init(&sctp_assocs_id);

 	/* Size and allocate the association hash table.
 	 * The methodology is similar to that of the tcp hash tables.
diff -Nru a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
--- a/net/sctp/sm_make_chunk.c	Tue Apr  6 07:35:28 2004
+++ b/net/sctp/sm_make_chunk.c	Tue Apr  6 07:35:28 2004
@@ -1,5 +1,5 @@
 /* SCTP kernel reference Implementation
- * (C) Copyright IBM Corp. 2001, 2003
+ * (C) Copyright IBM Corp. 2001, 2004
  * Copyright (c) 1999-2000 Cisco, Inc.
  * Copyright (c) 1999-2001 Motorola, Inc.
  * Copyright (c) 2001-2002 Intel Corp.
@@ -1817,10 +1817,23 @@
 	/* Allocate storage for the negotiated streams if it is not a temporary 	 * association.
 	 */
 	if (!asoc->temp) {
+		sctp_assoc_t assoc_id;
+
 		asoc->ssnmap = sctp_ssnmap_new(asoc->c.sinit_max_instreams,
 					       asoc->c.sinit_num_ostreams, gfp);
 		if (!asoc->ssnmap)
-			goto nomem_ssnmap;
+			goto clean_up;
+
+		do {
+			if (unlikely(!idr_pre_get(&sctp_assocs_id, gfp)))
+				goto clean_up;
+			spin_lock_bh(&sctp_assocs_id_lock);
+			assoc_id = (sctp_assoc_t)idr_get_new(&sctp_assocs_id,
+							     (void *)asoc);
+			spin_unlock_bh(&sctp_assocs_id_lock);
+		} while (unlikely((int)assoc_id == -1));
+
+		asoc->assoc_id = assoc_id;
 	}

 	/* ADDIP Section 4.1 ASCONF Chunk Procedures
@@ -1836,7 +1849,6 @@
 	asoc->peer.addip_serial = asoc->peer.i.initial_tsn - 1;
 	return 1;

-nomem_ssnmap:
 clean_up:
 	/* Release the transport structures. */
 	list_for_each_safe(pos, temp, &asoc->peer.transport_addr_list) {
diff -Nru a/net/sctp/socket.c b/net/sctp/socket.c
--- a/net/sctp/socket.c	Tue Apr  6 07:35:28 2004
+++ b/net/sctp/socket.c	Tue Apr  6 07:35:28 2004
@@ -135,8 +135,14 @@
 	}

 	/* Otherwise this is a UDP-style socket. */
-	asoc = (struct sctp_association *)id;
-	if (!sctp_assoc_valid(sk, asoc))
+	if (!id || (id == (sctp_assoc_t)-1))
+		return NULL;
+
+	spin_lock_bh(&sctp_assocs_id_lock);
+	asoc = (struct sctp_association *)idr_find(&sctp_assocs_id, (int)id);
+	spin_unlock_bh(&sctp_assocs_id_lock);
+
+	if (!asoc || (asoc->base.sk != sk) || asoc->base.dead)
 		return NULL;

 	return asoc;
@@ -1498,8 +1504,7 @@
 		 * rwnd by that amount. If all the data in the skb is read,
 		 * rwnd is updated when the event is freed.
 		 */
-		sctp_assoc_rwnd_increase(event->sndrcvinfo.sinfo_assoc_id,
-					 copied);
+		sctp_assoc_rwnd_increase(event->asoc, copied);
 		goto out;
 	} else if ((event->msg_flags & MSG_NOTIFICATION) ||
 		   (event->msg_flags & MSG_EOR))
@@ -4477,7 +4482,7 @@
 	 */
 	sctp_skb_for_each(skb, &oldsk->sk_receive_queue, tmp) {
 		event = sctp_skb2event(skb);
-		if (event->sndrcvinfo.sinfo_assoc_id == assoc) {
+		if (event->asoc == assoc) {
 			__skb_unlink(skb, skb->list);
 			__skb_queue_tail(&newsk->sk_receive_queue, skb);
 		}
@@ -4506,7 +4511,7 @@
 		 */
 		sctp_skb_for_each(skb, &oldsp->pd_lobby, tmp) {
 			event = sctp_skb2event(skb);
-			if (event->sndrcvinfo.sinfo_assoc_id == assoc) {
+			if (event->asoc == assoc) {
 				__skb_unlink(skb, skb->list);
 				__skb_queue_tail(queue, skb);
 			}
diff -Nru a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
--- a/net/sctp/ulpevent.c	Tue Apr  6 07:35:28 2004
+++ b/net/sctp/ulpevent.c	Tue Apr  6 07:35:28 2004
@@ -1,7 +1,7 @@
 /* SCTP kernel reference Implementation
+ * (C) Copyright IBM Corp. 2001, 2004
  * Copyright (c) 1999-2000 Cisco, Inc.
  * Copyright (c) 1999-2001 Motorola, Inc.
- * Copyright (c) 2001 International Business Machines, Corp.
  * Copyright (c) 2001 Intel Corp.
  * Copyright (c) 2001 Nokia, Inc.
  * Copyright (c) 2001 La Monte H.P. Yarroll
@@ -590,8 +590,7 @@
 						struct sctp_chunk *chunk,
 						int gfp)
 {
-	struct sctp_ulpevent *event;
-	struct sctp_sndrcvinfo *info;
+	struct sctp_ulpevent *event = NULL;
 	struct sk_buff *skb;
 	size_t padding, len;

@@ -624,101 +623,21 @@
 	/* Initialize event with flags 0.  */
 	sctp_ulpevent_init(event, 0);

-	event->iif = sctp_chunk_iif(chunk);
-
 	sctp_ulpevent_receive_data(event, asoc);

-	info = (struct sctp_sndrcvinfo *) &event->sndrcvinfo;
-
-	/* Sockets API Extensions for SCTP
-	 * Section 5.2.2 SCTP Header Information Structure (SCTP_SNDRCV)
-	 *
-	 * sinfo_stream: 16 bits (unsigned integer)
-	 *
-	 * For recvmsg() the SCTP stack places the message's stream number in
-	 * this value.
-	 */
-	info->sinfo_stream = ntohs(chunk->subh.data_hdr->stream);
-
-	/* Sockets API Extensions for SCTP
-	 * Section 5.2.2 SCTP Header Information Structure (SCTP_SNDRCV)
-	 *
-	 * sinfo_ssn: 16 bits (unsigned integer)
-	 *
-	 * For recvmsg() this value contains the stream sequence number that
-	 * the remote endpoint placed in the DATA chunk.  For fragmented
-	 * messages this is the same number for all deliveries of the message
-	 * (if more than one recvmsg() is needed to read the message).
-	 */
-	info->sinfo_ssn = ntohs(chunk->subh.data_hdr->ssn);
-
-        /* Sockets API Extensions for SCTP
-	 * Section 5.2.2 SCTP Header Information Structure (SCTP_SNDRCV)
-	 *
-	 * sinfo_ppid: 32 bits (unsigned integer)
-	 *
-	 * In recvmsg() this value is
-	 * the same information that was passed by the upper layer in the peer
-	 * application.  Please note that byte order issues are NOT accounted
-	 * for and this information is passed opaquely by the SCTP stack from
-	 * one end to the other.
-	 */
-	info->sinfo_ppid = chunk->subh.data_hdr->ppid;
-
-	/* Sockets API Extensions for SCTP
-	 * Section 5.2.2 SCTP Header Information Structure (SCTP_SNDRCV)
-	 *
-	 * sinfo_flags: 16 bits (unsigned integer)
-	 *
-	 * This field may contain any of the following flags and is composed of
-	 * a bitwise OR of these values.
-	 *
-	 * recvmsg() flags:
-	 *
-	 * MSG_UNORDERED - This flag is present when the message was sent
-	 *                 non-ordered.
-	 */
+	event->stream = ntohs(chunk->subh.data_hdr->stream);
+	event->ssn = ntohs(chunk->subh.data_hdr->ssn);
+	event->ppid = chunk->subh.data_hdr->ppid;
 	if (chunk->chunk_hdr->flags & SCTP_DATA_UNORDERED) {
-		info->sinfo_flags |= MSG_UNORDERED;
-
-		/* sinfo_cumtsn: 32 bit (unsigned integer)
-		 *
-		 * This field will hold the current cumulative TSN as
-		 * known by the underlying SCTP layer.  Note this field is
-		 * ignored when sending and only valid for a receive
-		 * operation when sinfo_flags are set to MSG_UNORDERED.
-		 */
-		info->sinfo_cumtsn = sctp_tsnmap_get_ctsn(&asoc->peer.tsn_map);
+		event->flags |= MSG_UNORDERED;
+		event->cumtsn = sctp_tsnmap_get_ctsn(&asoc->peer.tsn_map);
 	}
-
-	/* Note:  For reassembly, we need to have the fragmentation bits.
-	 * For now, merge these into the msg_flags, since those bit
-	 * possitions are not used.
-	 */
+	event->tsn = ntohl(chunk->subh.data_hdr->tsn);
 	event->msg_flags |= chunk->chunk_hdr->flags;
-
-	/* With 04 draft, tsn moves into sndrcvinfo. */
-	info->sinfo_tsn = ntohl(chunk->subh.data_hdr->tsn);
-
-	/* Context is not used on receive. */
-	info->sinfo_context = 0;
-
-	/* Sockets API Extensions for SCTP
-	 * Section 5.2.2 SCTP Header Information Structure (SCTP_SNDRCV)
-	 *
-	 * sinfo_assoc_id: sizeof (sctp_assoc_t)
-	 *
-	 * The association handle field, sinfo_assoc_id, holds the identifier
-	 * for the association announced in the COMMUNICATION_UP notification.
-	 * All notifications for a given association have the same identifier.
-	 * Ignored for TCP-style sockets.
-	 */
-	info->sinfo_assoc_id = sctp_assoc2id(asoc);
-
-	return event;
+	event->iif = sctp_chunk_iif(chunk);

 fail:
-	return NULL;
+	return event;
 }

 /* Create a partial delivery related event.
@@ -797,11 +716,77 @@
 void sctp_ulpevent_read_sndrcvinfo(const struct sctp_ulpevent *event,
 				   struct msghdr *msghdr)
 {
-	if (!sctp_ulpevent_is_notification(event)) {
-		put_cmsg(msghdr, IPPROTO_SCTP, SCTP_SNDRCV,
-			 sizeof(struct sctp_sndrcvinfo),
-			 (void *) &event->sndrcvinfo);
-	}
+	struct sctp_sndrcvinfo sinfo;
+
+	if (sctp_ulpevent_is_notification(event))
+		return;
+
+	/* Sockets API Extensions for SCTP
+ 	 * Section 5.2.2 SCTP Header Information Structure (SCTP_SNDRCV)
+ 	 *
+ 	 * sinfo_stream: 16 bits (unsigned integer)
+ 	 *
+ 	 * For recvmsg() the SCTP stack places the message's stream number in
+ 	 * this value.
+ 	*/
+	sinfo.sinfo_stream = event->stream;
+	/* sinfo_ssn: 16 bits (unsigned integer)
+	 *
+	 * For recvmsg() this value contains the stream sequence number that
+	 * the remote endpoint placed in the DATA chunk.  For fragmented
+	 * messages this is the same number for all deliveries of the message
+	 * (if more than one recvmsg() is needed to read the message).
+	 */
+	sinfo.sinfo_ssn = event->ssn;
+	/* sinfo_ppid: 32 bits (unsigned integer)
+	 *
+	 * In recvmsg() this value is
+	 * the same information that was passed by the upper layer in the peer
+	 * application.  Please note that byte order issues are NOT accounted
+	 * for and this information is passed opaquely by the SCTP stack from
+	 * one end to the other.
+	 */
+	sinfo.sinfo_ppid = event->ppid;
+	/* sinfo_flags: 16 bits (unsigned integer)
+	 *
+	 * This field may contain any of the following flags and is composed of
+	 * a bitwise OR of these values.
+	 *
+	 * recvmsg() flags:
+	 *
+	 * MSG_UNORDERED - This flag is present when the message was sent
+	 *                 non-ordered.
+	 */
+	sinfo.sinfo_flags = event->flags;
+	/* sinfo_tsn: 32 bit (unsigned integer)
+	 *
+	 * For the receiving side, this field holds a TSN that was
+	 * assigned to one of the SCTP Data Chunks.
+	 */
+	sinfo.sinfo_tsn = event->tsn;
+	/* sinfo_cumtsn: 32 bit (unsigned integer)
+	 *
+	 * This field will hold the current cumulative TSN as
+	 * known by the underlying SCTP layer.  Note this field is
+	 * ignored when sending and only valid for a receive
+	 * operation when sinfo_flags are set to MSG_UNORDERED.
+	 */
+	sinfo.sinfo_cumtsn = event->cumtsn;
+	/* sinfo_assoc_id: sizeof (sctp_assoc_t)
+	 *
+	 * The association handle field, sinfo_assoc_id, holds the identifier
+	 * for the association announced in the COMMUNICATION_UP notification.
+	 * All notifications for a given association have the same identifier.
+	 * Ignored for one-to-one style sockets.
+	 */
+	sinfo.sinfo_assoc_id = sctp_assoc2id(event->asoc);
+
+	/* These fields are not used while receiving. */
+	sinfo.sinfo_context = 0;
+	sinfo.sinfo_timetolive = 0;
+
+	put_cmsg(msghdr, IPPROTO_SCTP, SCTP_SNDRCV,
+		 sizeof(struct sctp_sndrcvinfo), (void *)&sinfo);
 }

 /* Stub skb destructor.  */
@@ -831,14 +816,14 @@
 	sctp_association_hold((struct sctp_association *)asoc);
 	skb = sctp_event2skb(event);
 	skb->sk = asoc->base.sk;
-	event->sndrcvinfo.sinfo_assoc_id = sctp_assoc2id(asoc);
+	event->asoc = (struct sctp_association *)asoc;
 	skb->destructor = sctp_stub_rfree;
 }

 /* A simple destructor to give up the reference to the association. */
 static inline void sctp_ulpevent_release_owner(struct sctp_ulpevent *event)
 {
-	sctp_association_put(event->sndrcvinfo.sinfo_assoc_id);
+	sctp_association_put(event->asoc);
 }

 /* Do accounting for bytes received and hold a reference to the association
@@ -880,8 +865,7 @@
 	 */

 	skb = sctp_event2skb(event);
-	sctp_assoc_rwnd_increase(event->sndrcvinfo.sinfo_assoc_id,
-				 skb_headlen(skb));
+	sctp_assoc_rwnd_increase(event->asoc, skb_headlen(skb));

 	/* Don't forget the fragments. */
 	for (frag = skb_shinfo(skb)->frag_list; frag; frag = frag->next) {
diff -Nru a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
--- a/net/sctp/ulpqueue.c	Tue Apr  6 07:35:28 2004
+++ b/net/sctp/ulpqueue.c	Tue Apr  6 07:35:28 2004
@@ -1,7 +1,7 @@
 /* SCTP kernel reference Implementation
+ * (C) Copyright IBM Corp. 2001, 2004
  * Copyright (c) 1999-2000 Cisco, Inc.
  * Copyright (c) 1999-2001 Motorola, Inc.
- * Copyright (c) 2001-2003 International Business Machines, Corp.
  * Copyright (c) 2001 Intel Corp.
  * Copyright (c) 2001 Nokia, Inc.
  * Copyright (c) 2001 La Monte H.P. Yarroll
@@ -251,7 +251,7 @@
 	struct sctp_ulpevent *cevent;
 	__u32 tsn, ctsn;

-	tsn = event->sndrcvinfo.sinfo_tsn;
+	tsn = event->tsn;

 	/* See if it belongs at the end. */
 	pos = skb_peek_tail(&ulpq->reasm);
@@ -262,7 +262,7 @@

 	/* Short circuit just dropping it at the end. */
 	cevent = sctp_skb2event(pos);
-	ctsn = cevent->sndrcvinfo.sinfo_tsn;
+	ctsn = cevent->tsn;
 	if (TSN_lt(ctsn, tsn)) {
 		__skb_queue_tail(&ulpq->reasm, sctp_event2skb(event));
 		return;
@@ -271,7 +271,7 @@
 	/* Find the right place in this list. We store them by TSN.  */
 	skb_queue_walk(&ulpq->reasm, pos) {
 		cevent = sctp_skb2event(pos);
-		ctsn = cevent->sndrcvinfo.sinfo_tsn;
+		ctsn = cevent->tsn;

 		if (TSN_lt(tsn, ctsn))
 			break;
@@ -368,7 +368,7 @@
 	 */
 	skb_queue_walk(&ulpq->reasm, pos) {
 		cevent = sctp_skb2event(pos);
-		ctsn = cevent->sndrcvinfo.sinfo_tsn;
+		ctsn = cevent->tsn;

 		switch (cevent->msg_flags & SCTP_DATA_FRAG_MASK) {
 		case SCTP_DATA_FIRST_FRAG:
@@ -425,7 +425,7 @@

 	skb_queue_walk(&ulpq->reasm, pos) {
 		cevent = sctp_skb2event(pos);
-		ctsn = cevent->sndrcvinfo.sinfo_tsn;
+		ctsn = cevent->tsn;

 		switch (cevent->msg_flags & SCTP_DATA_FRAG_MASK) {
 		case SCTP_DATA_MIDDLE_FRAG:
@@ -486,7 +486,7 @@
 		/* Do not even bother unless this is the next tsn to
 		 * be delivered.
 		 */
-		ctsn = event->sndrcvinfo.sinfo_tsn;
+		ctsn = event->tsn;
 		ctsnap = sctp_tsnmap_get_ctsn(&ulpq->asoc->peer.tsn_map);
 		if (TSN_lte(ctsn, ctsnap))
 			retval = sctp_ulpq_retrieve_partial(ulpq);
@@ -517,7 +517,7 @@

 	skb_queue_walk(&ulpq->reasm, pos) {
 		cevent = sctp_skb2event(pos);
-		ctsn = cevent->sndrcvinfo.sinfo_tsn;
+		ctsn = cevent->tsn;

 		switch (cevent->msg_flags & SCTP_DATA_FRAG_MASK) {
 		case SCTP_DATA_FIRST_FRAG:
@@ -563,15 +563,15 @@
 	__u16 sid, csid;
 	__u16 ssn, cssn;

-	sid = event->sndrcvinfo.sinfo_stream;
-	ssn = event->sndrcvinfo.sinfo_ssn;
+	sid = event->stream;
+	ssn = event->ssn;
 	in  = &ulpq->asoc->ssnmap->in;

 	/* We are holding the chunks by stream, by SSN.  */
 	sctp_skb_for_each(pos, &ulpq->lobby, tmp) {
 		cevent = (struct sctp_ulpevent *) pos->cb;
-		csid = cevent->sndrcvinfo.sinfo_stream;
-		cssn = cevent->sndrcvinfo.sinfo_ssn;
+		csid = cevent->stream;
+		cssn = cevent->ssn;

 		/* Have we gone too far?  */
 		if (csid > sid)
@@ -609,12 +609,12 @@
 		return;
 	}

-	sid = event->sndrcvinfo.sinfo_stream;
-	ssn = event->sndrcvinfo.sinfo_ssn;
+	sid = event->stream;
+	ssn = event->ssn;

 	cevent = (struct sctp_ulpevent *) pos->cb;
-	csid = cevent->sndrcvinfo.sinfo_stream;
-	cssn = cevent->sndrcvinfo.sinfo_ssn;
+	csid = cevent->stream;
+	cssn = cevent->ssn;
 	if (sid > csid) {
 		__skb_queue_tail(&ulpq->lobby, sctp_event2skb(event));
 		return;
@@ -630,8 +630,8 @@
 	 */
 	skb_queue_walk(&ulpq->lobby, pos) {
 		cevent = (struct sctp_ulpevent *) pos->cb;
-		csid = cevent->sndrcvinfo.sinfo_stream;
-		cssn = cevent->sndrcvinfo.sinfo_ssn;
+		csid = cevent->stream;
+		cssn = cevent->ssn;

 		if (csid > sid)
 			break;
@@ -656,8 +656,8 @@
 		return event;

 	/* Note: The stream ID must be verified before this routine.  */
-	sid = event->sndrcvinfo.sinfo_stream;
-	ssn = event->sndrcvinfo.sinfo_ssn;
+	sid = event->stream;
+	ssn = event->ssn;
 	in  = &ulpq->asoc->ssnmap->in;

 	/* Is this the expected SSN for this stream ID?  */
@@ -694,7 +694,7 @@
 	while ((skb = __skb_dequeue_tail(&ulpq->lobby))) {
 		freed += skb_headlen(skb);
 		event = sctp_skb2event(skb);
-		tsn = event->sndrcvinfo.sinfo_tsn;
+		tsn = event->tsn;

 		sctp_ulpevent_free(event);
 		sctp_tsnmap_renege(tsnmap, tsn);
@@ -720,7 +720,7 @@
 	while ((skb = __skb_dequeue_tail(&ulpq->reasm))) {
 		freed += skb_headlen(skb);
 		event = sctp_skb2event(skb);
-		tsn = event->sndrcvinfo.sinfo_tsn;
+		tsn = event->tsn;

 		sctp_ulpevent_free(event);
 		sctp_tsnmap_renege(tsnmap, tsn);
