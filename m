From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 4/4] caif: Add debug connection type for CAIF.
Date: Thu, 17 Jun 2010 18:55:41 +0200
Message-ID: <1276793741-20278-4-git-send-email-sjur.brandeland@stericsson.com>
References: <1276793741-20278-1-git-send-email-sjur.brandeland@stericsson.com>
 <1276793741-20278-2-git-send-email-sjur.brandeland@stericsson.com>
 <1276793741-20278-3-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: linus.walleij@stericsson.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: sjurbr@gmail.com, netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from thalia-smout.broadpark.no ([80.202.8.21]:37367 "EHLO
	thalia-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933085Ab0FQQ4B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jun 2010 12:56:01 -0400
Received: from ignis-smin.broadpark.no ([unknown] [80.202.8.11])
 by thalia-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L4600FHQ4DC0S90@thalia-smout.broadpark.no> for
 netdev@vger.kernel.org; Thu, 17 Jun 2010 18:56:00 +0200 (CEST)
Received: from localhost.localdomain ([unknown] [84.49.77.207])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L4600ITZ4D6RO21@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Thu, 17 Jun 2010 18:56:00 +0200 (CEST)
In-reply-to: <1276793741-20278-3-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Added new CAIF protocol type CAIFPROTO_DEBUG for accessing
CAIF debug on the ST Ericsson modems.

There are two debug servers on the modem, one for radio related
debug (CAIF_RADIO_DEBUG_SERVICE) and the other for
communication/application related debug (CAIF_COM_DEBUG_SERVICE).

The debug connection can contain trace debug printouts or
interactive debug used for debugging and test.

Debug connections can be of type STREAM or SEQPACKET.

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 include/linux/caif/caif_socket.h |   34 ++++++++++++++++++++++++++++++++++
 net/caif/caif_config_util.c      |    5 +++++
 2 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/include/linux/caif/caif_socket.h b/include/linux/caif/caif_socket.h
index 2a61eb1..d9cb19b 100644
--- a/include/linux/caif/caif_socket.h
+++ b/include/linux/caif/caif_socket.h
@@ -62,6 +62,7 @@ enum caif_channel_priority {
  * @CAIFPROTO_DATAGRAM_LOOP:	Datagram loopback channel, used for testing.
  * @CAIFPROTO_UTIL:		Utility (Psock) channel.
  * @CAIFPROTO_RFM:		Remote File Manager
+ * @CAIFPROTO_DEBUG:		Debug link
  *
  * This enum defines the CAIF Channel type to be used. This defines
  * the service to connect to on the modem.
@@ -72,6 +73,7 @@ enum caif_protocol_type {
 	CAIFPROTO_DATAGRAM_LOOP,
 	CAIFPROTO_UTIL,
 	CAIFPROTO_RFM,
+	CAIFPROTO_DEBUG,
 	_CAIFPROTO_MAX
 };
 #define	CAIFPROTO_MAX _CAIFPROTO_MAX
@@ -83,6 +85,28 @@ enum caif_protocol_type {
 enum caif_at_type {
 	CAIF_ATTYPE_PLAIN = 2
 };
+ /**
+ * enum caif_debug_type - Content selection for debug connection
+ * @CAIF_DEBUG_TRACE_INTERACTIVE: Connection will contain
+ *				both trace and interactive debug.
+ * @CAIF_DEBUG_TRACE:		Connection contains trace only.
+ * @CAIF_DEBUG_INTERACTIVE:	Connection to interactive debug.
+ */
+enum caif_debug_type {
+	CAIF_DEBUG_TRACE_INTERACTIVE = 0,
+	CAIF_DEBUG_TRACE,
+	CAIF_DEBUG_INTERACTIVE,
+};
+
+/**
+ * enum caif_debug_service - Debug Service Endpoint
+ * @CAIF_RADIO_DEBUG_SERVICE:	Debug service on the Radio sub-system
+ * @CAIF_APP_DEBUG_SERVICE:	Debug for the applications sub-system
+ */
+enum caif_debug_service {
+	CAIF_RADIO_DEBUG_SERVICE = 1,
+	CAIF_APP_DEBUG_SERVICE
+};
 
 /**
  * struct sockaddr_caif - the sockaddr structure for CAIF sockets.
@@ -109,6 +133,12 @@ enum caif_at_type {
  *
  * @u.rfm.volume:            Volume to mount.
  *
+ * @u.dbg:		      Applies when family = CAIFPROTO_DEBUG.
+ *
+ * @u.dbg.type:			     Type of debug connection to set up
+ *			      (caif_debug_type).
+ *
+ * @u.dbg.service:	      Service sub-system to connect (caif_debug_service
  * Description:
  * This structure holds the connect parameters used for setting up a
  * CAIF Channel. It defines the service to connect to on the modem.
@@ -130,6 +160,10 @@ struct sockaddr_caif {
 			__u32 connection_id;
 			char	  volume[16];
 		} rfm;				/* CAIFPROTO_RFM */
+		struct {
+			__u8  type;		/* type:enum caif_debug_type */
+			__u8  service;		/* service:caif_debug_service */
+		} dbg;				/* CAIFPROTO_DEBUG */
 	} u;
 };
 
diff --git a/net/caif/caif_config_util.c b/net/caif/caif_config_util.c
index 6f36580..76ae683 100644
--- a/net/caif/caif_config_util.c
+++ b/net/caif/caif_config_util.c
@@ -80,6 +80,11 @@ int connect_req_to_link_param(struct cfcnfg *cnfg,
 		       l->u.utility.paramlen);
 
 		break;
+	case CAIFPROTO_DEBUG:
+		l->linktype = CFCTRL_SRV_DBG;
+		l->endpoint = s->sockaddr.u.dbg.service;
+		l->chtype = s->sockaddr.u.dbg.type;
+		break;
 	default:
 		return -EINVAL;
 	}
-- 
1.6.3.3

