From: Xufeng Zhang <xufengzhang.main@gmail.com>
Subject: Re: [PATCH] sctp: Make "Invalid Stream Identifier" ERROR follows SACK
 when bundling
Date: Tue, 31 Jul 2012 14:17:27 +0800
Message-ID: <CA+=dFzhXY9aJ6_Yu-4a3g+6RyN5_mxXY=U3HnzKdi8TH-rqWcA@mail.gmail.com>
References: <1342677450-21810-1-git-send-email-xufengzhang.main@gmail.com>
	<500CDE35.6000009@windriver.com>
	<42fcd21f-68bd-4dc7-8460-0cb968eb512e@email.android.com>
	<500E1057.3020509@windriver.com>
	<75bdd73e-1c47-4fd6-bc29-5b86ee6da69a@email.android.com>
	<CA+=dFzg=Bpsv5bMzECoAXYVcbD95eYy6xDAzL6fwiHrunfq-tg@mail.gmail.com>
	<e7f8a685-9635-4aa9-bd67-1044e0720b29@email.android.com>
	<CA+=dFzifKwbiXmw=pu0+rWmz72+4jsbv6bXOBHyL0LmxaL9byg@mail.gmail.com>
	<CA+=dFzgXq3Sx-Ny+6oDZ3BEdsMQCgswNEVPVnhmhedHFvazzWw@mail.gmail.com>
	<50100A29.8010705@gmail.com>
	<CA+=dFzj11c9K0TS0T7D1aBVz+ppdFK91ZzBbevLV23FrWJNzmw@mail.gmail.com>
	<CA+=dFziK09TVcK29x1SLg+JanOj6o__bJKf8yohw6dTYCUCF5A@mail.gmail.com>
	<8ea83e51-81d1-407a-be06-98d2c99c876d@email.android.com>
	<CA+=dFzguqjjnnqHO53Mx859VB6NU=4MaPWAUzGQB2qtZGfdAUg@mail.gmail.com>
	<5013069F.3080306@gmail.com>
	<CA+=dFzh4dFatOy42FydbVvoXB8=5CvLu5AwPvUA16h+kymq0Lw@mail.gmail.com>
	<CA+=dFzh1wQx2rBs_2RAwrXsz79WS3njnO8=2ntQZUbB5So69gg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Neil Horman <nhorman@tuxdriver.com>,
	xufeng zhang <xufeng.zhang@windriver.com>, sri@us.ibm.com,
	davem@davemloft.net, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+=dFzh1wQx2rBs_2RAwrXsz79WS3njnO8=2ntQZUbB5So69gg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm wondering if the below solution is fine to you which is based on
your changes.
BTW, I have verified this patch and it works ok for all the situation,
but only one problem persists:
there is a potential that commands will exceeds SCTP_MAX_NUM_COMMANDS
which happens during sending lots of small error DATA chunks.

Thanks,
Xufeng Zhang

---
diff --git a/include/net/sctp/command.h b/include/net/sctp/command.h
index 712b3be..62c34f5 100644
--- a/include/net/sctp/command.h
+++ b/include/net/sctp/command.h
@@ -110,6 +110,7 @@ typedef enum {
        SCTP_CMD_SEND_NEXT_ASCONF, /* Send the next ASCONF after ACK */
        SCTP_CMD_PURGE_ASCONF_QUEUE, /* Purge all asconf queues.*/
        SCTP_CMD_SET_ASOC,       /* Restore association context */
+       SCTP_CMD_GEN_BAD_STREAM, /* Invalid Stream errors happened command */
        SCTP_CMD_LAST
 } sctp_verb_t;

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index fc5e600..3d218e0 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1183,6 +1183,9 @@ struct sctp_outq {
         */
        struct list_head abandoned;

+       /* Put Invalid Stream error chunks on this list */
+       struct list_head bad_stream_err;
+
        /* How many unackd bytes do we have in-flight?  */
        __u32 outstanding_bytes;

diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index e7aa177..1e87b0b 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -211,6 +211,7 @@ void sctp_outq_init(struct sctp_association *asoc,
struct sctp_outq *q)
        INIT_LIST_HEAD(&q->retransmit);
        INIT_LIST_HEAD(&q->sacked);
        INIT_LIST_HEAD(&q->abandoned);
+       INIT_LIST_HEAD(&q->bad_stream_err);

        q->fast_rtx = 0;
        q->outstanding_bytes = 0;
@@ -283,6 +284,12 @@ void sctp_outq_teardown(struct sctp_outq *q)
                list_del_init(&chunk->list);
                sctp_chunk_free(chunk);
        }
+
+       /* Throw away any pending Invalid Stream error chunks */
+       list_for_each_entry_safe(chunk, tmp, &q->bad_stream_err, list) {
+               list_del_init(&chunk->list);
+               sctp_chunk_free(chunk);
+       }
 }

 /* Free the outqueue structure and any related pending chunks.  */
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index fe99628..ab63fa1 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -1060,6 +1060,17 @@ static void sctp_cmd_send_asconf(struct
sctp_association *asoc)
        }
 }

+static void sctp_cmd_make_inv_stream_err(sctp_cmd_seq_t *commands,
+               struct sctp_association *asoc)
+{
+       struct sctp_chunk *err, *tmp;
+       struct sctp_outq *q = &asoc->outqueue;
+
+       list_for_each_entry_safe(err, tmp, &q->bad_stream_err, list) {
+               list_del_init(&err->list);
+               sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(err));
+               struct sctp_association *asoc)
+{
+       struct sctp_chunk *err, *tmp;
+       struct sctp_outq *q = &asoc->outqueue;
+
+       list_for_each_entry_safe(err, tmp, &q->bad_stream_err, list) {
+               list_del_init(&err->list);
+               sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(err));
+       }
+}

 /* These three macros allow us to pull the debugging code out of the
  * main flow of sctp_do_sm() to keep attention focused on the real
@@ -1724,6 +1735,10 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
                        asoc = cmd->obj.asoc;
                        break;

+               case SCTP_CMD_GEN_BAD_STREAM:
+                       sctp_cmd_make_inv_stream_err(commands, asoc);
+                       break;
+
                default:
                        pr_warn("Impossible command: %u, %p\n",
                                cmd->verb, cmd->obj.ptr);
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 9fca103..cab539f 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -2967,8 +2967,14 @@ discard_force:
        return SCTP_DISPOSITION_DISCARD;

 discard_noforce:
-       if (chunk->end_of_packet)
+       if (chunk->end_of_packet) {
+               struct sctp_outq *q = &asoc->outqueue;
+
                sctp_add_cmd_sf(commands, SCTP_CMD_GEN_SACK, force);
+               /* Queue the INVALID STREAM error after the SACK if
one is needed. */
+               if (!list_empty(&q->bad_stream_err))
+                       sctp_add_cmd_sf(commands,
SCTP_CMD_GEN_BAD_STREAM, SCTP_NULL());
+       }

        return SCTP_DISPOSITION_DISCARD;
 consume:
@@ -3037,11 +3043,15 @@ sctp_disposition_t
sctp_sf_eat_data_fast_4_4(const struct sctp_endpoint *ep,
         * with a SACK, a SHUTDOWN chunk, and restart the T2-shutdown timer
         */
        if (chunk->end_of_packet) {
+               struct sctp_outq *q = &asoc->outqueue;
                /* We must delay the chunk creation since the cumulative
                 * TSN has not been updated yet.
                 */
                sctp_add_cmd_sf(commands, SCTP_CMD_GEN_SHUTDOWN, SCTP_NULL());
                sctp_add_cmd_sf(commands, SCTP_CMD_GEN_SACK, SCTP_FORCE());
+               /* Queue the INVALID STREAM error after the SACK if
one is needed. */
+               if (!list_empty(&q->bad_stream_err))
+                       sctp_add_cmd_sf(commands,
SCTP_CMD_GEN_BAD_STREAM, SCTP_NULL());
                sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_RESTART,
                                SCTP_TO(SCTP_EVENT_TIMEOUT_T2_SHUTDOWN));
        }
@@ -6136,6 +6146,7 @@ static int sctp_eat_data(const struct
sctp_association *asoc,
         */
        sid = ntohs(data_hdr->stream);
        if (sid >= asoc->c.sinit_max_instreams) {
+               struct sctp_outq *q = &asoc->outqueue;
                /* Mark tsn as received even though we drop it */
                sctp_add_cmd_sf(commands, SCTP_CMD_REPORT_TSN, SCTP_U32(tsn));

@@ -6144,8 +6155,7 @@ static int sctp_eat_data(const struct
sctp_association *asoc,
                                         sizeof(data_hdr->stream),
                                         sizeof(u16));
                if (err)
-                       sctp_add_cmd_sf(commands, SCTP_CMD_REPLY,
-                                       SCTP_CHUNK(err));
+                       list_add_tail(&err->list, &q->bad_stream_err);
                return SCTP_IERROR_BAD_STREAM;
        }
