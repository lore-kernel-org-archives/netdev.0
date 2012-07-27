From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] sctp: Make "Invalid Stream Identifier" ERROR follows
 SACK when bundling
Date: Fri, 27 Jul 2012 17:22:39 -0400
Message-ID: <5013069F.3080306@gmail.com>
References: <1342677450-21810-1-git-send-email-xufengzhang.main@gmail.com> <500CDE35.6000009@windriver.com> <42fcd21f-68bd-4dc7-8460-0cb968eb512e@email.android.com> <500E1057.3020509@windriver.com> <75bdd73e-1c47-4fd6-bc29-5b86ee6da69a@email.android.com> <CA+=dFzg=Bpsv5bMzECoAXYVcbD95eYy6xDAzL6fwiHrunfq-tg@mail.gmail.com> <e7f8a685-9635-4aa9-bd67-1044e0720b29@email.android.com> <CA+=dFzifKwbiXmw=pu0+rWmz72+4jsbv6bXOBHyL0LmxaL9byg@mail.gmail.com> <CA+=dFzgXq3Sx-Ny+6oDZ3BEdsMQCgswNEVPVnhmhedHFvazzWw@mail.gmail.com> <50100A29.8010705@gmail.com> <CA+=dFzj11c9K0TS0T7D1aBVz+ppdFK91ZzBbevLV23FrWJNzmw@mail.gmail.com> <CA+=dFziK09TVcK29x1SLg+JanOj6o__bJKf8yohw6dTYCUCF5A@mail.gmail.com> <8ea83e51-81d1-407a-be06-98d2c99c876d@email.android.com> <CA+=dFzguqjjnnqHO53Mx859VB6NU=4MaPWAUzGQB2qtZGfdAUg@mail
 .gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	xufeng zhang <xufeng.zhang@windriver.com>, sri@us.ibm.com,
	davem@davemloft.net, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Xufeng Zhang <xufengzhang.main@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+=dFzguqjjnnqHO53Mx859VB6NU=4MaPWAUzGQB2qtZGfdAUg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

here is an untested prototype of what I was talking about.  This should 
handle multiple data chunks.

-vlad

---
  include/net/sctp/command.h |    1 +
  net/sctp/sm_sideeffect.c   |   22 ++++++++++++++++++++++
  net/sctp/sm_statefuns.c    |   18 ++++++++++--------
  3 files changed, 33 insertions(+), 8 deletions(-)

diff --git a/include/net/sctp/command.h b/include/net/sctp/command.h
index 712b3be..4043445 100644
--- a/include/net/sctp/command.h
+++ b/include/net/sctp/command.h
@@ -110,6 +110,7 @@ typedef enum {
  	SCTP_CMD_SEND_NEXT_ASCONF, /* Send the next ASCONF after ACK */
  	SCTP_CMD_PURGE_ASCONF_QUEUE, /* Purge all asconf queues.*/
  	SCTP_CMD_SET_ASOC,	 /* Restore association context */
+	SCTP_CMD_GEN_BAD_STREAM, /* Issue an Invalid Stream error */
  	SCTP_CMD_LAST
  } sctp_verb_t;

diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 1ff51c9..c5a1322 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -1036,6 +1036,22 @@ static void sctp_cmd_send_asconf(struct 
sctp_association *asoc)
  	}
  }

+static void sctp_cmd_make_inv_stream_err(sctp_cmd_seq_t *commands,
+					 struct sctp_association *asoc,
+					 struct sctp_chunk *chunk,
+					 struct sctp_datahdr *data_hdr)
+{
+	struct sctp_chunk *err;
+
+	err = sctp_make_op_error(asoc, chunk, SCTP_ERROR_INV_STRM,
+				 &data_hdr->stream,
+				 sizeof(data_hdr->stream),
+				 sizeof(u16));
+	if (err)
+		sctp_add_cmd_sf(commands, SCTP_CMD_REPLY,
+					SCTP_CHUNK(err));
+}
+

  /* These three macros allow us to pull the debugging code out of the
   * main flow of sctp_do_sm() to keep attention focused on the real
@@ -1700,6 +1716,12 @@ static int sctp_cmd_interpreter(sctp_event_t 
event_type,
  			asoc = cmd->obj.asoc;
  			break;

+		case SCTP_CMD_GEN_BAD_STREAM:
+			sctp_cmd_make_inv_stream_err(commands,
+					 asoc, chunk,
+					 (struct sctp_datahdr *)cmd->obj.ptr);
+			break;
+
  		default:
  			pr_warn("Impossible command: %u, %p\n",
  				cmd->verb, cmd->obj.ptr);
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 891f5db..57532e3 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -2972,6 +2972,12 @@ discard_noforce:
  	if (chunk->end_of_packet)
  		sctp_add_cmd_sf(commands, SCTP_CMD_GEN_SACK, force);

+	/* Queue the INVALID STREAM error after the SACK if one is needed. */
+	if (SCTP_IERROR_BAD_STREAM == error) {
+		sctp_add_cmd_sf(commands, SCTP_CMD_GEN_BAD_STREAM,
+				SCTP_PTR(chunk->subh.data_hdr));
+	}
+
  	return SCTP_DISPOSITION_DISCARD;
  consume:
  	return SCTP_DISPOSITION_CONSUME;
@@ -3044,6 +3050,10 @@ sctp_disposition_t 
sctp_sf_eat_data_fast_4_4(const struct sctp_endpoint *ep,
  		 */
  		sctp_add_cmd_sf(commands, SCTP_CMD_GEN_SHUTDOWN, SCTP_NULL());
  		sctp_add_cmd_sf(commands, SCTP_CMD_GEN_SACK, SCTP_FORCE());
+		if (SCTP_IERROR_BAD_STREAM == error) {
+			sctp_add_cmd_sf(commands, SCTP_CMD_GEN_BAD_STREAM,
+					SCTP_PTR(chunk->subh.data_hdr));
+		}
  		sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_RESTART,
  				SCTP_TO(SCTP_EVENT_TIMEOUT_T2_SHUTDOWN));
  	}
@@ -6140,14 +6150,6 @@ static int sctp_eat_data(const struct 
sctp_association *asoc,
  	if (sid >= asoc->c.sinit_max_instreams) {
  		/* Mark tsn as received even though we drop it */
  		sctp_add_cmd_sf(commands, SCTP_CMD_REPORT_TSN, SCTP_U32(tsn));
-
-		err = sctp_make_op_error(asoc, chunk, SCTP_ERROR_INV_STRM,
-					 &data_hdr->stream,
-					 sizeof(data_hdr->stream),
-					 sizeof(u16));
-		if (err)
-			sctp_add_cmd_sf(commands, SCTP_CMD_REPLY,
-					SCTP_CHUNK(err));
  		return SCTP_IERROR_BAD_STREAM;
  	}

-- 1.7.7.6
