From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 03/42] neigh: Send a notification when DELAY_PROBE_TIME changes
Date: Fri,  1 Jul 2016 16:04:31 +0200
Message-ID: <1467381910-3445-4-git-send-email-jiri@resnulli.us>
References: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35031 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752043AbcGAQJS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 12:09:18 -0400
Received: by mail-wm0-f67.google.com with SMTP id a66so6327028wme.2
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 09:09:17 -0700 (PDT)
In-Reply-To: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When the data plane is offloaded the traffic doesn't go through the
networking stack. Therefore, after first resolving a neighbour the NUD
state machine will transition it from REACHABLE to STALE until it's
finally deleted by the garbage collector.

To prevent such situations the offloading driver should notify the NUD
state machine on any neighbours that were recently used. The driver's
polling interval should be set so that the NUD state machine can
function as if the traffic wasn't offloaded.

Currently, there are no in-tree drivers that can report confirmation for
a neighbour, but only 'used' indication. Therefore, the polling interval
should be set according to DELAY_FIRST_PROBE_TIME, as a neighbour will
transition from REACHABLE state to DELAY (instead of STALE) if "a packet
was sent within the last DELAY_FIRST_PROBE_TIME seconds" (RFC 4861).

Send a netevent whenever the DELAY_FIRST_PROBE_TIME changes - either via
netlink or sysctl - so that offloading drivers can correctly set their
polling interval.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/netevent.h | 1 +
 net/core/neighbour.c   | 2 ++
 2 files changed, 3 insertions(+)

diff --git a/include/net/netevent.h b/include/net/netevent.h
index d8bbb38..f440df1 100644
--- a/include/net/netevent.h
+++ b/include/net/netevent.h
@@ -24,6 +24,7 @@ struct netevent_redirect {
 enum netevent_notif_type {
 	NETEVENT_NEIGH_UPDATE = 1, /* arg is struct neighbour ptr */
 	NETEVENT_REDIRECT,	   /* arg is struct netevent_redirect ptr */
+	NETEVENT_DELAY_PROBE_TIME_UPDATE, /* arg is struct neigh_parms ptr */
 };
 
 int register_netevent_notifier(struct notifier_block *nb);
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 952aabb..5cdc62a 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2047,6 +2047,7 @@ static int neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh)
 			case NDTPA_DELAY_PROBE_TIME:
 				NEIGH_VAR_SET(p, DELAY_PROBE_TIME,
 					      nla_get_msecs(tbp[i]));
+				call_netevent_notifiers(NETEVENT_DELAY_PROBE_TIME_UPDATE, p);
 				break;
 			case NDTPA_RETRANS_TIME:
 				NEIGH_VAR_SET(p, RETRANS_TIME,
@@ -2930,6 +2931,7 @@ static void neigh_proc_update(struct ctl_table *ctl, int write)
 		return;
 
 	set_bit(index, p->data_state);
+	call_netevent_notifiers(NETEVENT_DELAY_PROBE_TIME_UPDATE, p);
 	if (!dev) /* NULL dev means this is default value */
 		neigh_copy_dflt_parms(net, p, index);
 }
-- 
2.5.5
