From: Sasikanth V <sasikanth.v19@gmail.com>
Subject: =?UTF-8?q?=5BPATCH=5D=20BRIDGE=3A=20As=20per=20802=2E1D=20clause=209=2E3=2E4=20Added=20support=20to=20prevent=20processing=20port=27s=20own=20BPDU=20=28If=20a=20loopback=20condition=20exists=29?=
Date: Wed, 30 Mar 2011 21:03:36 +0530
Message-ID: <1301499216-3836-1-git-send-email-sasikanth.v19@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Sasikanth V <sasikanth.v19@gmail.com>
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:43844 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932136Ab1C3Pdp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2011 11:33:45 -0400
Received: by ywj3 with SMTP id 3so559911ywj.19
        for <netdev@vger.kernel.org>; Wed, 30 Mar 2011 08:33:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Sasikanth V <sasikanth.v19@gmail.com>
---
 net/bridge/br_private.h   |    1 +
 net/bridge/br_stp.c       |   20 ++++++++++++++++++--
 net/bridge/br_stp_if.c    |    2 ++
 net/bridge/br_stp_timer.c |    1 +
 4 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 387013d..d9f79dd 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -149,6 +149,7 @@ struct net_bridge_port
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	struct netpoll			*np;
 #endif
+	u8                              is_own_bpdu; /*Port recvd its own BPD=
U*/
 };
=20
 #define br_port_exists(dev) (dev->priv_flags & IFF_BRIDGE_PORT)
diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index 7370d14..491d9c6 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -107,6 +107,12 @@ static void br_root_selection(struct net_bridge *b=
r)
 	u16 root_port =3D 0;
=20
 	list_for_each_entry(p, &br->port_list, list) {
+		/*Don't consider the Port for root selection
+  		  which rx'd its own bpdu because of loopback
+		  in the bridge
+  		 */
+		if (p->is_own_bpdu)
+			continue;
 		if (br_should_become_root_port(p, root_port))
 			root_port =3D p->port_no;
=20
@@ -278,8 +284,16 @@ static int br_supersedes_port_info(struct net_brid=
ge_port *p, struct br_config_b
 	if (memcmp(&bpdu->bridge_id, &p->br->bridge_id, 8))
 		return 1;
=20
-	if (bpdu->port_id <=3D p->designated_port)
+	if (bpdu->port_id <=3D p->designated_port) {
+		/*802.1D 9.3.4 Validation of received BPDUs
+ 		 NOTE 1=E2=80=94If the Bridge Identifier and Port Identifier both=20
+ 		 match the values that would be transmitted in a Configuration
+		 BPDU, the BPDU is discarded to prevent processing of the Port=E2=80=
=99s=20
+		 own BPDUs;*/
+		if (bpdu->port_id =3D=3D p->designated_port)
+			p->is_own_bpdu =3D 1;
 		return 1;
+	}
=20
 	return 0;
 }
@@ -411,7 +425,7 @@ void br_port_state_selection(struct net_bridge *br)
 			p->config_pending =3D 0;
 			p->topology_change_ack =3D 0;
 			br_make_forwarding(p);
-		} else if (br_is_designated_port(p)) {
+		} else if (!p->is_own_bpdu && br_is_designated_port(p)) {
 			del_timer(&p->message_age_timer);
 			br_make_forwarding(p);
 		} else {
@@ -446,6 +460,8 @@ void br_received_config_bpdu(struct net_bridge_port=
 *p, struct br_config_bpdu *b
 	br =3D p->br;
 	was_root =3D br_is_root_bridge(br);
=20
+	p->is_own_bpdu =3D 0;
+
 	if (br_supersedes_port_info(p, bpdu)) {
 		br_record_config_information(p, bpdu);
 		br_configuration_update(br);
diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index 5593f5a..fc4ec63 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -37,6 +37,7 @@ void br_init_port(struct net_bridge_port *p)
 	p->state =3D BR_STATE_BLOCKING;
 	p->topology_change_ack =3D 0;
 	p->config_pending =3D 0;
+	p->is_own_bpdu =3D 0;
 }
=20
 /* called under bridge lock */
@@ -101,6 +102,7 @@ void br_stp_disable_port(struct net_bridge_port *p)
 	p->state =3D BR_STATE_DISABLED;
 	p->topology_change_ack =3D 0;
 	p->config_pending =3D 0;
+	p->is_own_bpdu =3D 0;
=20
 	del_timer(&p->message_age_timer);
 	del_timer(&p->forward_delay_timer);
diff --git a/net/bridge/br_stp_timer.c b/net/bridge/br_stp_timer.c
index 3e96514..99ea288 100644
--- a/net/bridge/br_stp_timer.c
+++ b/net/bridge/br_stp_timer.c
@@ -67,6 +67,7 @@ static void br_message_age_timer_expired(unsigned lon=
g arg)
 	spin_lock(&br->lock);
 	if (p->state =3D=3D BR_STATE_DISABLED)
 		goto unlock;
+	p->is_own_bpdu =3D 0;
 	was_root =3D br_is_root_bridge(br);
=20
 	br_become_designated_port(p);
--=20
1.7.3.4

