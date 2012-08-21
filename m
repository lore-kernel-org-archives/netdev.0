From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH 1/2] ipv6: do not hold route table lock when send ndisc
 probe
Date: Tue, 21 Aug 2012 11:44:03 +0800
Message-ID: <1345520643.12468.6.camel@cr0>
References: <1345187499-16929-1-git-send-email-amwang@redhat.com>
	 <CAATkVEzKuTeUbU75B6EoSfFvGVsz_eK47XNWmsP5KcCvjTDEDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-hAInxMpNrFB1TmTwA511"
Cc: netdev@vger.kernel.org,
	"Banerjee, Debabrata" <dbanerje@akamai.com>,
	"David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Debabrata Banerjee <dbavatar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47905 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750807Ab2HUDoQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Aug 2012 23:44:16 -0400
In-Reply-To: <CAATkVEzKuTeUbU75B6EoSfFvGVsz_eK47XNWmsP5KcCvjTDEDA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-hAInxMpNrFB1TmTwA511
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

Hi, Debabrata,

Could you help to test the attached patch below?

Thanks!


--=-hAInxMpNrFB1TmTwA511
Content-Disposition: attachment; filename="ipv6-deadlock.diff"
Content-Type: text/x-patch; name="ipv6-deadlock.diff"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index eb3f1e4..cd141a5 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -440,9 +440,26 @@ out:
 }
 
 #ifdef CONFIG_IPV6_ROUTER_PREF
+struct ndisc_work {
+	struct work_struct work;
+	struct in6_addr mcaddr;
+	struct in6_addr target;
+	struct net_device *dev;
+};
+
+static void queue_ndisc(struct work_struct *work)
+{
+	struct ndisc_work *nw =
+		container_of(work, struct ndisc_work, work);
+	ndisc_send_ns(nw->dev, NULL, &nw->target, &nw->mcaddr, NULL);
+	kfree(nw);
+}
+
 static void rt6_probe(struct rt6_info *rt)
 {
 	struct neighbour *neigh;
+	struct ndisc_work *nw;
+
 	/*
 	 * Okay, this does not seem to be appropriate
 	 * for now, however, we need to check if it
@@ -457,15 +474,18 @@ static void rt6_probe(struct rt6_info *rt)
 	read_lock_bh(&neigh->lock);
 	if (!(neigh->nud_state & NUD_VALID) &&
 	    time_after(jiffies, neigh->updated + rt->rt6i_idev->cnf.rtr_probe_interval)) {
-		struct in6_addr mcaddr;
-		struct in6_addr *target;
 
 		neigh->updated = jiffies;
 		read_unlock_bh(&neigh->lock);
 
-		target = (struct in6_addr *)&neigh->primary_key;
-		addrconf_addr_solict_mult(target, &mcaddr);
-		ndisc_send_ns(rt->dst.dev, NULL, target, &mcaddr, NULL);
+		nw = kmalloc(sizeof(*nw), GFP_ATOMIC);
+		if (nw) {
+			memcpy(&nw->target, &neigh->primary_key, sizeof(struct in6_addr));
+			addrconf_addr_solict_mult(&nw->target, &nw->mcaddr);
+			nw->dev = rt->dst.dev;
+			INIT_WORK(&nw->work, queue_ndisc);
+			schedule_work(&nw->work);
+		}
 	} else {
 		read_unlock_bh(&neigh->lock);
 	}

--=-hAInxMpNrFB1TmTwA511--
