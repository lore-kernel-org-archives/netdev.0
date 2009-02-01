From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [RFC] netlink broadcast return value
Date: Sun, 01 Feb 2009 14:33:57 +0100
Message-ID: <4985A4C5.4050908@netfilter.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070908070406070501080408"
Cc: Patrick McHardy <kaber@trash.net>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070908070406070501080408
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Currently, and according to my interpretation of the source code,
netlink_broadcast() return-value reports errors to the caller if no
messages at all were delivered:

1) If, at least, one message has been delivered correctly, returns 0.
2) Otherwise, if no messages at all were delivered due to skb_clone()
failure, return -ENOBUFS.
3) Otherwise, if there are no listeners, return -ESRCH.

I would need to know if the caller has failed delivering any of the
messages to the listeners as follows:

1) If it fails to deliver any message (for whatever reason), return
-ENOBUFS.
2) If all messages were delivered OK, returns 0.
3) If no listeners, return -ESRCH.

In the current ctnetlink code and in Netfilter in general, we can add
reliable logging and connection tracking event delivery by dropping the
packets whose events were not successfully delivered over Netlink. Of
course, this option would be settable via /proc as this approach reduces
performance (in terms of filtered connections per seconds by a stateful
firewall) but providing reliable logging and event delivery (for
conntrackd) in return.

I have check the whole kernel code to look for current users of
netlink_broadcast() to see how they are handling errors reported and how
a change in the return value would affect them. Here it follows a short
summary:

= current list of clients of netlink_broadcast() =
== netlink_broadcast() ==

                                          Handling

drivers/scsi/scsi_transport_iscsi.c	: printk error
drivers/connector/connector.c		: cn_netlink_send() return value
include/net/netlink.h			: nlmsg_multicast() return value
lib/kobject_uevent.c			: ignores return value
net/core/rtnetlink.c			: ignores return value
net/ipv4/netfilter/ipt_ULOG.c		: ignores return value
net/bridge/netfilter/ebt_ulog.c		: ignores return value
net/decnet/netfilter/dn_rtmsg.c		: ignores return value
security/selinux/netlink.c		: ignores return value

== cn_netlink_send (uses netlink_broadcast return value) ==
drivers/w1/w1_netlink.c			: ignores return value
drivers/video/uvesafb.c			: printk error (if err != ESRCH)

== nlmsg_multicast (calls netlink_broadcast) ==
drivers/scsi/scsi_transport_fc.c	: printk error (if err != -ESRCH)
include/net/genetlink.h			: genlmsg_multicast() return value
net/xfrm/xfrm_user.c			: xfrm_send_migrate() return value
					  xfrm_exp_state_notify() return value
					  xfrm_aevent_state_notify() return value
					  xfrm_notify_sa_flush() return value
					  xfrm_notify_sa() return value
					  xfrm_send_acquire() return value
					  xfrm_exp_policy_notify() return value
					  xfrm_notify_policy() return value
					  xfrm_notify_policy_flush() return val
					  xfrm_send_report() return value
					  xfrm_send_mapping() return value
					  ...
					  later they all ignore the return value

== genlmsg_multicast (calls nlmsg_multicast) ==
net/netlink/genetlink.c			: ignores return value
drivers/acpi/event.c			: printk error
fs/dquot.c				: printk error (if err != -ESRCH)
net/wireless/nl80211.c			: ignores return value

In short, I think that the change that I'm proposing would also require
to fix some netlink_broadcast() clients to skip ENOBUFS errors: they are
not meaningful for them since they assume that Netlink is unreliable and
so the return value does not provide any useful information.

Please, let me know how crazy this idea is ;).

-- 
"Los honestos son inadaptados sociales" -- Les Luthiers

--------------070908070406070501080408
Content-Type: text/x-diff;
 name="netlink-broadcast-delivery-failure.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="netlink-broadcast-delivery-failure.patch"

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 480184a..26e1a89 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -943,6 +943,7 @@ struct netlink_broadcast_data {
 	u32 pid;
 	u32 group;
 	int failure;
+	int delivery_failure;
 	int congested;
 	int delivered;
 	gfp_t allocation;
@@ -992,6 +993,7 @@ static inline int do_one_broadcast(struct sock *sk,
 		p->skb2 = NULL;
 	} else if ((val = netlink_broadcast_deliver(sk, p->skb2)) < 0) {
 		netlink_overrun(sk);
+		p->delivery_failure = 1;
 	} else {
 		p->congested |= val;
 		p->delivered = 1;
@@ -1018,6 +1020,7 @@ int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, u32 pid,
 	info.pid = pid;
 	info.group = group;
 	info.failure = 0;
+	info.delivery_failure = 0;
 	info.congested = 0;
 	info.delivered = 0;
 	info.allocation = allocation;
@@ -1038,13 +1041,14 @@ int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, u32 pid,
 	if (info.skb2)
 		kfree_skb(info.skb2);
 
+	if (info.delivery_failure || info.failure)
+		return -ENOBUFS;
+
 	if (info.delivered) {
 		if (info.congested && (allocation & __GFP_WAIT))
 			yield();
 		return 0;
 	}
-	if (info.failure)
-		return -ENOBUFS;
 	return -ESRCH;
 }
 EXPORT_SYMBOL(netlink_broadcast);

--------------070908070406070501080408--
