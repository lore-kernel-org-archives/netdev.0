From: zhuyj <zyjzyj2000@gmail.com>
Subject: SCTP_PEER_ADDR_CHANGE Notification over UNCONFIRMED path
Date: Fri, 15 Aug 2014 16:49:46 +0800
Message-ID: <53EDC9AA.9080500@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030205070701000605070006"
To: LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Vlad Yasevich <vyasevich@gmail.com>, tuexen@fh-muenster.de,
	khandelwal.deepak.1987@gmail.com,
	"Tao, Yue" <Yue.Tao@windriver.com>,
	Alexandre Dietsch <alexandre.dietsch@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	zhuyj <zyjzyj2000@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:62933 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751272AbaHOIuB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2014 04:50:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030205070701000605070006
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi, Vlad && DEEPAK && Michael && David

 From Michael && DEEPAK
"
  lxr SCTP implementation, doesn't transit the path state to INACTIVE, 
if it was never confirmed. this leads to SCTP_PEER_ADDRESS_CHANGE 
notification after each failed probe from this time.
  Is there any specific reason to have same notification to SCTP User 
with each probe in RTO time period ?
  806 case SCTP_TRANSPORT_DOWN:
  807 /* If the transport was never confirmed, do not transition it
  808 * to inactive state. Also, release the cached route since
  809 * there may be a better route next time.
  810 */
  811 if (transport->state != SCTP_UNCONFIRMED)

  812 transport->state = SCTP_INACTIVE;

  http://lxr.free-electrons.com/source/net/sctp/associola.c#L806

  we checked RFC and here it is mentioned as  Path Verification 
Section(5.4) of RFC 4960  http://tools.ietf.org/html/rfc4960

  In each RTO, a probe may be sent on an active UNCONFIRMED path in an
  attempt to move it to the CONFIRMED state. If during this probing
  the path becomes inactive, this rate is lowered to the normal
  HEARTBEAT rate. At the expiration of the RTO timer, the error
  counter of any path that was probed but not CONFIRMED is incremented
  by one and subjected to path failure detection, as defined in
  Section


  8.2
  . When probing UNCONFIRMED addresses, however, the association
  overall error counter is not incremented


  Does this mean that in attempt to move a UNCONFIRMED path to CONFIRMED 
State, the path can become INACTIVE, when transport error counter 
reaches to path_max_retrans counter ?
  I would say that the path stays UNCONFIRMED.


  I would also only expect a  SCTP_PEER_ADDRESS_CHANGE notification when 
a path state changes, not on every  try.

"

I made a patch to disable sending SCTP_PEER_ADDRESS_CHANGE notification 
every try. Now the patch is in the attachment. Please check it.

Zhu Yanjun

--------------030205070701000605070006
Content-Type: text/x-patch;
 name="0001-sctp-not-send-SCTP_PEER_ADDR_CHANGE-notifications-wi.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-sctp-not-send-SCTP_PEER_ADDR_CHANGE-notifications-wi.pa";
 filename*1="tch"

>From 78027ced63911229092c345dbac47c385259fe35 Mon Sep 17 00:00:00 2001
From: Zhu Yanjun <Yanjun.Zhu@windriver.com>
Date: Fri, 15 Aug 2014 16:32:51 +0800
Subject: [PATCH 1/1] sctp: not send SCTP_PEER_ADDR_CHANGE notifications with
 failed probe

When a failed probe comes along UNCONFIRMED path, it is not necessary
to send SCTP_PEER_ADDR_CHANGE notification.

Reported-by: DEEPAK KHANDELWAL <khandelwal.deepak.1987@gmail.com>  
Suggested-by: Vlad Yasevich <vyasevich@gmail.com> 
Suggested-by: Michael Tuexen <tuexen@fh-muenster.de>
Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
---
 net/sctp/associola.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 9de23a2..2e23f6b 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -813,6 +813,7 @@ void sctp_assoc_control_transport(struct sctp_association *asoc,
 		else {
 			dst_release(transport->dst);
 			transport->dst = NULL;
+			ulp_notify = false;
 		}
 
 		spc_state = SCTP_ADDR_UNREACHABLE;
-- 
1.9.1


--------------030205070701000605070006--
