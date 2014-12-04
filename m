From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 3/6] bridge/fdb: add flag/indication for FDB entry synced from offload device
Date: Thu,  4 Dec 2014 09:57:15 +0100
Message-ID: <1417683438-10935-4-git-send-email-jiri@resnulli.us>
References: <1417683438-10935-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org, hemal@broadcom.co
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:40366 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753211AbaLDI5Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 03:57:25 -0500
Received: by mail-wi0-f172.google.com with SMTP id n3so33904052wiv.17
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2014 00:57:24 -0800 (PST)
In-Reply-To: <1417683438-10935-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Add NTF_EXT_LEARNED flag to neigh flags to indicate FDB entry learned by
device has been learned externally to bridge FDB.  For these entries,
add "external" annotation in bridge fdb show output:

  00:02:00:00:03:00 dev swp2 used 2/2 master br0 external
  00:02:00:00:03:00 dev swp2 self permanent

In the example above, 00:02:00:00:03:00 is shown twice on dev swp2.  The
first entry if from the bridge (master) and is marked as "external" by
the offload device.  The second entry is from the brport offload device (self),
and was learned by the device.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 bridge/fdb.c              | 2 ++
 include/linux/neighbour.h | 1 +
 2 files changed, 3 insertions(+)

diff --git a/bridge/fdb.c b/bridge/fdb.c
index d678342..c01a502 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -154,6 +154,8 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		fprintf(fp, "master ");
 	if (r->ndm_flags & NTF_ROUTER)
 		fprintf(fp, "router ");
+	if (r->ndm_flags & NTF_EXT_LEARNED)
+		fprintf(fp, "external ");
 
 	fprintf(fp, "%s\n", state_n2a(r->ndm_state));
 	return 0;
diff --git a/include/linux/neighbour.h b/include/linux/neighbour.h
index 4a1d7e9..3a9b0df 100644
--- a/include/linux/neighbour.h
+++ b/include/linux/neighbour.h
@@ -40,6 +40,7 @@ enum {
 
 #define NTF_SELF	0x02
 #define NTF_MASTER	0x04
+#define NTF_EXT_LEARNED	0x10
 
 /*
  *	Neighbor Cache Entry States.
-- 
1.9.3
