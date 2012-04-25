From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 2/8] isdn/gigaset: fix CAPI disconnect B3 handling
Date: Thu, 26 Apr 2012 01:02:20 +0200 (CEST)
Message-ID: <20120425-patch-gigaset-02.tilman@imap.cc>
References: <20120425-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120425-patch-gigaset-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If DISCONNECT_B3_IND was synthesized because of a DISCONNECT_REQ
with existing logical connections, the connection state wasn't
updated accordingly. Also the emitted DISCONNECT_B3_IND message
wasn't included in the debug log as requested.
This patch fixes both of these issues.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
CC: stable <stable@kernel.org>
---
 drivers/isdn/gigaset/capi.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/isdn/gigaset/capi.c b/drivers/isdn/gigaset/capi.c
index 292ca2f..579aa02 100644
--- a/drivers/isdn/gigaset/capi.c
+++ b/drivers/isdn/gigaset/capi.c
@@ -1887,6 +1887,9 @@ static void do_disconnect_req(struct gigaset_capi_ctr *iif,
 
 	/* check for active logical connection */
 	if (bcs->apconnstate >= APCONN_ACTIVE) {
+		/* clear it */
+		bcs->apconnstate = APCONN_SETUP;
+
 		/*
 		 * emit DISCONNECT_B3_IND with cause 0x3301
 		 * use separate cmsg structure, as the content of iif->acmsg
@@ -1911,6 +1914,7 @@ static void do_disconnect_req(struct gigaset_capi_ctr *iif,
 		}
 		capi_cmsg2message(b3cmsg,
 				  __skb_put(b3skb, CAPI_DISCONNECT_B3_IND_BASELEN));
+		dump_cmsg(DEBUG_CMD, __func__, b3cmsg);
 		kfree(b3cmsg);
 		capi_ctr_handle_message(&iif->ctr, ap->id, b3skb);
 	}
-- 
1.7.3.4
