From: Ben Greear <greearb@candelatech.com>
Subject: Re: ARP table question
Date: Mon, 17 Nov 2008 16:33:57 -0800
Message-ID: <49220D75.1070803@candelatech.com>
References: <491B1841.9050404@candelatech.com>	<491B31EB.4050304@candelatech.com>	<491B5452.6020709@candelatech.com> <20081116.191628.135824721.davem@davemloft.net> <4921B521.1010305@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000204060202050305070304"
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:52095 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751061AbYKRAeB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 19:34:01 -0500
In-Reply-To: <4921B521.1010305@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000204060202050305070304
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Ben Greear wrote:
> David Miller wrote:
> 
>> This change makes a lot of sense to me, I'll add it to net-next-2.6
>> so it can cook in there for a while just in case there are some
>> unwanted side-effects.
> 
> Thanks Dave.
> 
> I think I found another problem as well:  If I start 1 TCP and 1 UDP 
> connection
> between each of the 500 interfaces on mac-vlans, the ARP tables will not 
> converge.
> 
> It seems to be because mac-vlan has to copy broadcast packets to every
> mac-vlan on a physical device, there are just too many packets:
> 
> 500 vlans arping once per second means 500 pkts per second on the
> other NIC.
> Other NIC must copy these 500 times,
> so, 250000 packets per second in each direction are
> processed by the stack (they are not all on the wire, at least).
> 
> A few get through and those UDP/TCP connections start consuming
> bandwidth, which clogs up the 1G link enough that other responses
> are lost most of the time.
> 
> I'm going to try to work on some sort of random backoff for ARP that can
> be enabled in this situation next.

Ok, here is the patch that implements this.  The idea is to spread out
arp requests when you do something like start 500 TCP connections on 500
MAC-VLANs talking to 500 other MAC-VLANs.

With a retrans timer of 1 sec, and a high volume of traffic, and a semi flaky
network in between, my system will not resolve the ARPs and the retransmits
overload my processors.

Setting the retrans timer to 5 secs on my system also works, so I'm not sure
if this patch is really required, but it might help keep arp requests somewhat
random in cases where arp timers would otherwise try to all fire at the same
time.

This is against 2.6.25.20 plus my patches, but I believe it should
apply to a clean 2.6.25.20 as well.

Comments are welcome.

Signed-Off-By  Ben Greear<greearb@candelatech.com>

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


--------------000204060202050305070304
Content-Type: text/x-patch;
 name="neigh_retrans.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="neigh_retrans.patch"

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 518ebe6..4c805b3 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -2028,6 +2028,16 @@ Expression of retrans_time, which is deprecated, is in 1/100 seconds (for
 IPv4) or in jiffies (for IPv6).
 Expression of retrans_time_ms is in milliseconds.
 
+
+retrans_rand_backof_ms
+----------------------
+
+This is an extra delay (ms) for the retransmit timer.  A random value between
+0 and retrans_rand_backof_ms will be added to the retrans_timer.  Default
+is zero.  Setting this to a larger value will help large broadcast domains
+resolve ARP (for instance, 500 mac-vlans talking to 500 other mac-vlans).
+
+
 unres_qlen
 ----------
 
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 8dbe468..a45b5df 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -608,6 +608,7 @@ enum {
 	NET_NEIGH_GC_THRESH3=16,
 	NET_NEIGH_RETRANS_TIME_MS=17,
 	NET_NEIGH_REACHABLE_TIME_MS=18,
+	NET_NEIGH_RETRANS_RAND_BACKOFF=19,
 	__NET_NEIGH_MAX
 };
 
diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 64a5f01..4947976 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -65,6 +65,7 @@ struct neigh_parms
 	int	proxy_delay;
 	int	proxy_qlen;
 	int	locktime;
+	int	retrans_rand_backoff;
 };
 
 struct neigh_statistics
diff --git a/kernel/sysctl_check.c b/kernel/sysctl_check.c
index 37c8fab..6f3467c 100644
--- a/kernel/sysctl_check.c
+++ b/kernel/sysctl_check.c
@@ -249,6 +249,7 @@ static const struct trans_ctl_table trans_net_neigh_vars_table[] = {
 	{ NET_NEIGH_GC_THRESH3,		"gc_thresh3" },
 	{ NET_NEIGH_RETRANS_TIME_MS,	"retrans_time_ms" },
 	{ NET_NEIGH_REACHABLE_TIME_MS,	"base_reachable_time_ms" },
+	{ NET_NEIGH_RETRANS_RAND_BACKOFF, "retrans_rand_backoff_ms"},
 	{}
 };
 
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 19b8e00..ec1f048 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -765,6 +765,13 @@ static __inline__ int neigh_max_probes(struct neighbour *n)
 		p->ucast_probes + p->app_probes + p->mcast_probes);
 }
 
+static unsigned long neigh_rand_retry(struct neighbour* neigh) {
+	if (neigh->parms->retrans_rand_backoff) {
+		return net_random() % neigh->parms->retrans_rand_backoff;
+	}
+	return 0;
+}
+
 /* Called when a timer expires for a neighbour entry. */
 
 static void neigh_timer_handler(unsigned long arg)
@@ -820,11 +827,11 @@ static void neigh_timer_handler(unsigned long arg)
 			neigh->nud_state = NUD_PROBE;
 			neigh->updated = jiffies;
 			atomic_set(&neigh->probes, 0);
-			next = now + neigh->parms->retrans_time;
+			next = now + neigh->parms->retrans_time + neigh_rand_retry(neigh);
 		}
 	} else {
 		/* NUD_PROBE|NUD_INCOMPLETE */
-		next = now + neigh->parms->retrans_time;
+		next = now + neigh->parms->retrans_time + neigh_rand_retry(neigh);
 	}
 
 	if ((neigh->nud_state & (NUD_INCOMPLETE | NUD_PROBE)) &&
@@ -2642,6 +2649,14 @@ static struct neigh_sysctl_table {
 			.strategy	= &sysctl_ms_jiffies,
 		},
 		{
+			.ctl_name	= NET_NEIGH_RETRANS_RAND_BACKOFF,
+			.procname	= "retrans_rand_backoff_ms",
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= &proc_dointvec_ms_jiffies,
+			.strategy	= &sysctl_ms_jiffies,
+		},
+		{
 			.ctl_name	= NET_NEIGH_GC_INTERVAL,
 			.procname	= "gc_interval",
 			.maxlen		= sizeof(int),
@@ -2712,18 +2727,19 @@ int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
 	t->neigh_vars[11].data = &p->locktime;
 	t->neigh_vars[12].data  = &p->retrans_time;
 	t->neigh_vars[13].data  = &p->base_reachable_time;
+	t->neigh_vars[14].data  = &p->retrans_rand_backoff;
 
 	if (dev) {
 		dev_name_source = dev->name;
 		neigh_path[NEIGH_CTL_PATH_DEV].ctl_name = dev->ifindex;
 		/* Terminate the table early */
-		memset(&t->neigh_vars[14], 0, sizeof(t->neigh_vars[14]));
+		memset(&t->neigh_vars[15], 0, sizeof(t->neigh_vars[14]));
 	} else {
 		dev_name_source = neigh_path[NEIGH_CTL_PATH_DEV].procname;
-		t->neigh_vars[14].data = (int *)(p + 1);
-		t->neigh_vars[15].data = (int *)(p + 1) + 1;
-		t->neigh_vars[16].data = (int *)(p + 1) + 2;
-		t->neigh_vars[17].data = (int *)(p + 1) + 3;
+		t->neigh_vars[15].data = (int *)(p + 1);
+		t->neigh_vars[16].data = (int *)(p + 1) + 1;
+		t->neigh_vars[17].data = (int *)(p + 1) + 2;
+		t->neigh_vars[18].data = (int *)(p + 1) + 3;
 	}
 
 

--------------000204060202050305070304--
