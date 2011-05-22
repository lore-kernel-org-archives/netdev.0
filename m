From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH 4/5] caif: Update documentation of CAIF transmit and receive functions.
Date: Sun, 22 May 2011 23:18:53 +0200
Message-ID: <1306099134-12989-4-git-send-email-sjur.brandeland@stericsson.com>
References: <1306099134-12989-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sf1.isp.kq.no ([213.172.193.37]:57887 "EHLO pmx.vmail.no"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755364Ab1EVVTH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 May 2011 17:19:07 -0400
In-Reply-To: <1306099134-12989-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Trivial patch updating documentation in header files only.
Error handling of CAIF transmit errors was changed by commit:
      caif: Don't resend if dev_queue_xmit fails.
This patch updates the documentation accordingly.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
Hi Dave.

[David Miller]
>net/caif/cfctrl.c:cfctrl_enum_req() does not check the return value of
>the ->transmit() method.
>
>The documentation for this method states that one error, ownership
>of the packet is transferred back to the caller, which means that we
>have a leak here.
>
>Please fix this bug.

In this case the documentation is buggy, Error handling was of
transmit errors was changed the April 11th by commit=20
"caif: Don't resend if dev_queue_xmit fails", but documentation was not
updated.

I'm sorry about this slip-up.

Regards,
Sjur

 include/net/caif/caif_layer.h |   36 +++++++++++++++++++++------------=
---
 1 files changed, 21 insertions(+), 15 deletions(-)

diff --git a/include/net/caif/caif_layer.h b/include/net/caif/caif_laye=
r.h
index c8b07a9..35bc788 100644
--- a/include/net/caif/caif_layer.h
+++ b/include/net/caif/caif_layer.h
@@ -15,7 +15,6 @@ struct cfpktq;
 struct caif_payload_info;
 struct caif_packet_funcs;
=20
-
 #define CAIF_LAYER_NAME_SZ 16
=20
 /**
@@ -33,7 +32,6 @@ do {								\
 	}							\
 } while (0)
=20
-
 /**
  * enum caif_ctrlcmd - CAIF Stack Control Signaling sent in layer.ctrl=
cmd().
  *
@@ -141,7 +139,7 @@ enum caif_direction {
  *    - All layers must use this structure. If embedding it, then plac=
e this
  *	structure first in the layer specific structure.
  *
- *    - Each layer should not depend on any others layer private data.
+ *    - Each layer should not depend on any others layer's private dat=
a.
  *
  *    - In order to send data upwards do
  *	layer->up->receive(layer->up, packet);
@@ -155,16 +153,23 @@ struct cflayer {
 	struct list_head node;
=20
 	/*
-	 *  receive() - Receive Function.
+	 *  receive() - Receive Function (non-blocking).
 	 *  Contract: Each layer must implement a receive function passing th=
e
 	 *  CAIF packets upwards in the stack.
 	 *	Packet handling rules:
-	 *	      - The CAIF packet (cfpkt) cannot be accessed after
-	 *		     passing it to the next layer using up->receive().
+	 *	      - The CAIF packet (cfpkt) ownership is passed to the
+	 *		called receive function. This means that the the
+	 *		packet cannot be accessed after passing it to the
+	 *		above layer using up->receive().
+	 *
 	 *	      - If parsing of the packet fails, the packet must be
-	 *		     destroyed and -1 returned from the function.
+	 *		destroyed and negative error code returned
+	 *		from the function.
+	 *		EXCEPTION: If the framing layer (cffrml) returns
+	 *			-EILSEQ, the packet is not freed.
+	 *
 	 *	      - If parsing succeeds (and above layers return OK) then
-	 *		      the function must return a value > 0.
+	 *		      the function must return a value >=3D 0.
 	 *
 	 *  Returns result < 0 indicates an error, 0 or positive value
 	 *	     indicates success.
@@ -176,7 +181,7 @@ struct cflayer {
 	int (*receive)(struct cflayer *layr, struct cfpkt *cfpkt);
=20
 	/*
-	 *  transmit() - Transmit Function.
+	 *  transmit() - Transmit Function (non-blocking).
 	 *  Contract: Each layer must implement a transmit function passing t=
he
 	 *	CAIF packet downwards in the stack.
 	 *	Packet handling rules:
@@ -185,15 +190,16 @@ struct cflayer {
 	 *		cannot be accessed after passing it to the below
 	 *		layer using dn->transmit().
 	 *
-	 *	      - If transmit fails, however, the ownership is returned
-	 *		to thecaller. The caller of "dn->transmit()" must
-	 *		destroy or resend packet.
+	 *	      - Upon error the packet ownership is still passed on,
+	 *		so the packet shall be freed where error is detected.
+	 *		Callers of the transmit function shall not free packets,
+	 *		but errors shall be returned.
 	 *
 	 *	      - Return value less than zero means error, zero or
 	 *		greater than zero means OK.
 	 *
-	 *	 result < 0 indicates an error, 0 or positive value
-	 *	 indicate success.
+	 *  Returns result < 0 indicates an error, 0 or positive value
+	 *		indicates success.
 	 *
 	 *  @layr:	Pointer to the current layer the receive function
 	 *		isimplemented for (this pointer).
@@ -202,7 +208,7 @@ struct cflayer {
 	int (*transmit) (struct cflayer *layr, struct cfpkt *cfpkt);
=20
 	/*
-	 *  cttrlcmd() - Control Function upwards in CAIF Stack.
+	 *  cttrlcmd() - Control Function upwards in CAIF Stack  (non-blockin=
g).
 	 *  Used for signaling responses (CAIF_CTRLCMD_*_RSP)
 	 *  and asynchronous events from the modem  (CAIF_CTRLCMD_*_IND)
 	 *
--=20
1.7.0.4

