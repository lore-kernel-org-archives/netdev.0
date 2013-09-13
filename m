From: Andre Naujoks <nautsch2@gmail.com>
Subject: [PATCH net 3/3] slcan: rewrite of slc_bump and slc_encaps
Date: Fri, 13 Sep 2013 19:37:13 +0200
Message-ID: <1379093833-4949-4-git-send-email-nautsch2@gmail.com>
References: <1379093833-4949-1-git-send-email-nautsch2@gmail.com>
To: davem@davemloft.net, Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1379093833-4949-1-git-send-email-nautsch2@gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The old implementation was heavy on str* functions and sprintf calls.
This version is more manual, but faster.

Profiling just the printing of a 3 char CAN-id resulted in 60 instructions
for the manual method and over 2000 for the sprintf method. Bear in
mind the profiling was done against libc and not the kernel sprintf.

Together with this rewrite an issue with sending and receiving of RTR frames
has been fixed by Oliver for the cases that the DLC is not zero.

Signed-off-by: Andre Naujoks <nautsch2@gmail.com>
Tested-by: Oliver Hartkopp <socketcan@hartkopp.net>
---
 drivers/net/can/slcan.c | 136 +++++++++++++++++++++++++++++++-----------------
 1 file changed, 87 insertions(+), 49 deletions(-)

diff --git a/drivers/net/can/slcan.c b/drivers/net/can/slcan.c
index d571e2e..25377e5 100644
--- a/drivers/net/can/slcan.c
+++ b/drivers/net/can/slcan.c
@@ -76,6 +76,10 @@ MODULE_PARM_DESC(maxdev, "Maximum number of slcan interfaces");
 /* maximum rx buffer len: extended CAN frame with timestamp */
 #define SLC_MTU (sizeof("T1111222281122334455667788EA5F\r")+1)
 
+#define SLC_CMD_LEN 1
+#define SLC_SFF_ID_LEN 3
+#define SLC_EFF_ID_LEN 8
+
 struct slcan {
 	int			magic;
 
@@ -142,47 +146,63 @@ static void slc_bump(struct slcan *sl)
 {
 	struct sk_buff *skb;
 	struct can_frame cf;
-	int i, dlc_pos, tmp;
-	unsigned long ultmp;
-	char cmd = sl->rbuff[0];
-
-	if ((cmd != 't') && (cmd != 'T') && (cmd != 'r') && (cmd != 'R'))
+	int i, tmp;
+	u32 tmpid;
+	char *cmd = sl->rbuff;
+
+	cf.can_id = 0;
+
+	switch (*cmd) {
+	case 'r':
+		cf.can_id = CAN_RTR_FLAG;
+		/* fallthrough */
+	case 't':
+		/* store dlc ASCII value and terminate SFF CAN ID string */
+		cf.can_dlc = sl->rbuff[SLC_CMD_LEN + SLC_SFF_ID_LEN];
+		sl->rbuff[SLC_CMD_LEN + SLC_SFF_ID_LEN] = 0;
+		/* point to payload data behind the dlc */
+		cmd += SLC_CMD_LEN + SLC_SFF_ID_LEN + 1;
+		break;
+	case 'R':
+		cf.can_id = CAN_RTR_FLAG;
+		/* fallthrough */
+	case 'T':
+		cf.can_id |= CAN_EFF_FLAG;
+		/* store dlc ASCII value and terminate EFF CAN ID string */
+		cf.can_dlc = sl->rbuff[SLC_CMD_LEN + SLC_EFF_ID_LEN];
+		sl->rbuff[SLC_CMD_LEN + SLC_EFF_ID_LEN] = 0;
+		/* point to payload data behind the dlc */
+		cmd += SLC_CMD_LEN + SLC_EFF_ID_LEN + 1;
+		break;
+	default:
 		return;
+	}
 
-	if (cmd & 0x20) /* tiny chars 'r' 't' => standard frame format */
-		dlc_pos = 4; /* dlc position tiiid */
-	else
-		dlc_pos = 9; /* dlc position Tiiiiiiiid */
-
-	if (!((sl->rbuff[dlc_pos] >= '0') && (sl->rbuff[dlc_pos] < '9')))
+	if (kstrtou32(sl->rbuff + SLC_CMD_LEN, 16, &tmpid))
 		return;
 
-	cf.can_dlc = sl->rbuff[dlc_pos] - '0'; /* get can_dlc from ASCII val */
+	cf.can_id |= tmpid;
 
-	sl->rbuff[dlc_pos] = 0; /* terminate can_id string */
-
-	if (kstrtoul(sl->rbuff+1, 16, &ultmp))
+	/* get can_dlc from sanitized ASCII value */
+	if (cf.can_dlc >= '0' && cf.can_dlc < '9')
+		cf.can_dlc -= '0';
+	else
 		return;
 
-	cf.can_id = ultmp;
-
-	if (!(cmd & 0x20)) /* NO tiny chars => extended frame format */
-		cf.can_id |= CAN_EFF_FLAG;
-
-	if ((cmd | 0x20) == 'r') /* RTR frame */
-		cf.can_id |= CAN_RTR_FLAG;
-
 	*(u64 *) (&cf.data) = 0; /* clear payload */
 
-	for (i = 0, dlc_pos++; i < cf.can_dlc; i++) {
-		tmp = hex_to_bin(sl->rbuff[dlc_pos++]);
-		if (tmp < 0)
-			return;
-		cf.data[i] = (tmp << 4);
-		tmp = hex_to_bin(sl->rbuff[dlc_pos++]);
-		if (tmp < 0)
-			return;
-		cf.data[i] |= tmp;
+	/* RTR frames may have a dlc > 0 but they never have any data bytes */
+	if (!(cf.can_id & CAN_RTR_FLAG)) {
+		for (i = 0; i < cf.can_dlc; i++) {
+			tmp = hex_to_bin(*cmd++);
+			if (tmp < 0)
+				return;
+			cf.data[i] = (tmp << 4);
+			tmp = hex_to_bin(*cmd++);
+			if (tmp < 0)
+				return;
+			cf.data[i] |= tmp;
+		}
 	}
 
 	skb = dev_alloc_skb(sizeof(struct can_frame) +
@@ -209,7 +229,6 @@ static void slc_bump(struct slcan *sl)
 /* parse tty input stream */
 static void slcan_unesc(struct slcan *sl, unsigned char s)
 {
-
 	if ((s == '\r') || (s == '\a')) { /* CR or BEL ends the pdu */
 		if (!test_and_clear_bit(SLF_ERROR, &sl->flags) &&
 		    (sl->rcount > 4))  {
@@ -236,27 +255,46 @@ static void slcan_unesc(struct slcan *sl, unsigned char s)
 /* Encapsulate one can_frame and stuff into a TTY queue. */
 static void slc_encaps(struct slcan *sl, struct can_frame *cf)
 {
-	int actual, idx, i;
-	char cmd;
+	int actual, i;
+	unsigned char *pos;
+	unsigned char *endpos;
+	canid_t id = cf->can_id;
+
+	pos = sl->xbuff;
 
 	if (cf->can_id & CAN_RTR_FLAG)
-		cmd = 'R'; /* becomes 'r' in standard frame format */
+		*pos = 'R'; /* becomes 'r' in standard frame format (SFF) */
 	else
-		cmd = 'T'; /* becomes 't' in standard frame format */
+		*pos = 'T'; /* becomes 't' in standard frame format (SSF) */
 
-	if (cf->can_id & CAN_EFF_FLAG)
-		sprintf(sl->xbuff, "%c%08X%d", cmd,
-			cf->can_id & CAN_EFF_MASK, cf->can_dlc);
-	else
-		sprintf(sl->xbuff, "%c%03X%d", cmd | 0x20,
-			cf->can_id & CAN_SFF_MASK, cf->can_dlc);
+	/* determine number of chars for the CAN-identifier */
+	if (cf->can_id & CAN_EFF_FLAG) {
+		id &= CAN_EFF_MASK;
+		endpos = pos + SLC_EFF_ID_LEN;
+	} else {
+		*pos |= 0x20; /* convert R/T to lower case for SFF */
+		id &= CAN_SFF_MASK;
+		endpos = pos + SLC_SFF_ID_LEN;
+	}
+
+	/* build 3 (SFF) or 8 (EFF) digit CAN identifier */
+	pos++;
+	while (endpos >= pos) {
+		*endpos-- = hex_asc_upper[id & 0xf];
+		id >>= 4;
+	}
+
+	pos += (cf->can_id & CAN_EFF_FLAG) ? SLC_EFF_ID_LEN : SLC_SFF_ID_LEN;
 
-	idx = strlen(sl->xbuff);
+	*pos++ = cf->can_dlc + '0';
 
-	for (i = 0; i < cf->can_dlc; i++)
-		sprintf(&sl->xbuff[idx + 2*i], "%02X", cf->data[i]);
+	/* RTR frames may have a dlc > 0 but they never have any data bytes */
+	if (!(cf->can_id & CAN_RTR_FLAG)) {
+		for (i = 0; i < cf->can_dlc; i++)
+			pos = hex_byte_pack_upper(pos, cf->data[i]);
+	}
 
-	strcat(sl->xbuff, "\r"); /* add terminating character */
+	*pos++ = '\r';
 
 	/* Order of next two lines is *very* important.
 	 * When we are sending a little amount of data,
@@ -267,8 +305,8 @@ static void slc_encaps(struct slcan *sl, struct can_frame *cf)
 	 *       14 Oct 1994  Dmitry Gorodchanin.
 	 */
 	set_bit(TTY_DO_WRITE_WAKEUP, &sl->tty->flags);
-	actual = sl->tty->ops->write(sl->tty, sl->xbuff, strlen(sl->xbuff));
-	sl->xleft = strlen(sl->xbuff) - actual;
+	actual = sl->tty->ops->write(sl->tty, sl->xbuff, pos - sl->xbuff);
+	sl->xleft = (pos - sl->xbuff) - actual;
 	sl->xhead = sl->xbuff + actual;
 	sl->dev->stats.tx_bytes += cf->can_dlc;
 }
-- 
1.8.4.rc3

