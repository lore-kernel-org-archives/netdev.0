From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
Date: Wed, 20 Aug 2008 15:37:13 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808201358490.4551@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0808081256560.4551@wrl-59.cs.helsinki.fi>
 <20080811.144421.234396007.davem@davemloft.net> <200808120946.19459.thomas.jarosch@intra2net.com>
 <20080812.011822.155249871.davem@davemloft.net> <20080812144309.7d62fd86@tux>
 <Pine.LNX.4.64.0808122044450.16105@wrl-59.cs.helsinki.fi> <20080813145310.0c1e534c@tux>
 <Pine.LNX.4.64.0808132108480.18807@wrl-59.cs.helsinki.fi> <20080815013407.4a594288@tux>
 <Pine.LNX.4.64.0808150939270.23522@wrl-59.cs.helsinki.fi> <20080815183511.1c81be23@tux>
 <Pine.LNX.4.64.0808160039230.6911@wrl-59.cs.helsinki.fi> <20080815231538.7999c017@tux>
 <Pine.LNX.4.64.0808161002500.7264@wrl-59.cs.helsinki.fi>
 <Pine.LNX.4.64.0808162210390.7443@wrl-59.cs.helsinki.fi> <20080816213615.689ddf8f@tux>
 <Pine.LNX.4.64.0808181042290.23854@wrl-59.cs.helsinki.fi> <20080819213417.45133573@tux>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-776036675-1219231476=:4551"
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "=?ISO-8859-1?Q?D=E2niel?= Fraga" <fragabr@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080819213417.45133573@tux>
Content-ID: <Pine.LNX.4.64.0808201510100.4551@wrl-59.cs.helsinki.fi>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-776036675-1219231476=:4551
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0808201424521.4551@wrl-59.cs.helsinki.fi>

On Tue, 19 Aug 2008, Dâniel Fraga wrote:

> On Tue, 19 Aug 2008 13:38:35 +0300 (EEST)
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> wrote:
> 
> > Perhaps, though it's not at all clear how it could do that...
> 
> 	I was thinking here of of some specific configuration I use.
> For example, I always used the wonder shaper htb script:
> 
> http://lartc.org/howto/lartc.cookbook.ultimate-tc.html#AEN2241
> 
> 	Could HTB mess with frto or cause this problem? Would it be
> useful to disable completely HTB and use just the default scheduler?

Based on irc discussion with davem, there is a htb bug which can cause 
corruption of the retransmitted TCP packets (and then a discard due to 
checksum mismatch). That would also explain the strange headers I noticed 
earlier. There's a patch below (should apply to 2.6.26), please put it at 
least on the host(s) which use htb (I don't know if both server and the 
client do use wondershaper script or just the client). An different 
failure symptoms (one could be somehow frto related as FRTO is used while 
retransmitting) are also quite well explainable.

But FRTO is mostly not a suspect based on the tcpdump you provided (no 
FRTO workaround would help in that).

If you tcpdump with -s0 at receiver, you get full payload and therefore 
it is possible to verify checksum correctness.

> > Do you have net namespaces enabled CONFIG_NET_NS in .config?
> 
> 	I couldn't find this specific option:
> 
> fraga@tux /usr/src/linux$ grep CONFIG_NET_NS .config
> fraga@tux /usr/src/linux$ 
> 
> 	But I have those:

I wasn't in error :-), it took some time also for me to figure out the 
right one, it's quite expected to be off (and even that missing) since 
it's currently !SYSFS depending.

> > Any netfilter (iptables) rules on server which could cause those packets 
> > to not reach TCP layer?
> 
> 	Here are the complete rules:

...snip...

> 	As you can see, it's a preetty simple set of rules, nothing exotic here.

...agreed.

-- 
 i.


---
From: David Miller <davem@davemloft.net>

pkt_sched: Fix return value corruption in HTB and TBF.

Packet schedulers should only return NET_XMIT_DROP iff
the packet really was dropped.  If the packet does reach
the device after we return NET_XMIT_DROP then TCP can
crash because it depends upon the enqueue path return
values being accurate.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 3fb58f4..51c3f68 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -595,11 +595,13 @@ static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		kfree_skb(skb);
 		return ret;
 #endif
-	} else if (cl->un.leaf.q->enqueue(skb, cl->un.leaf.q) !=
+	} else if ((ret = cl->un.leaf.q->enqueue(skb, cl->un.leaf.q)) !=
 		   NET_XMIT_SUCCESS) {
-		sch->qstats.drops++;
-		cl->qstats.drops++;
-		return NET_XMIT_DROP;
+		if (ret == NET_XMIT_DROP) {
+			sch->qstats.drops++;
+			cl->qstats.drops++;
+		}
+		return ret;
 	} else {
 		cl->bstats.packets +=
 			skb_is_gso(skb)?skb_shinfo(skb)->gso_segs:1;
@@ -639,11 +641,13 @@ static int htb_requeue(struct sk_buff *skb, struct Qdisc *sch)
 		kfree_skb(skb);
 		return ret;
 #endif
-	} else if (cl->un.leaf.q->ops->requeue(skb, cl->un.leaf.q) !=
+	} else if ((ret = cl->un.leaf.q->ops->requeue(skb, cl->un.leaf.q)) !=
 		   NET_XMIT_SUCCESS) {
-		sch->qstats.drops++;
-		cl->qstats.drops++;
-		return NET_XMIT_DROP;
+		if (ret == NET_XMIT_DROP) {
+			sch->qstats.drops++;
+			cl->qstats.drops++;
+		}
+		return ret;
 	} else
 		htb_activate(q, cl);
 
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 0b7d78f..fc6f8f3 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -123,15 +123,8 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	int ret;
 
-	if (skb->len > q->max_size) {
-		sch->qstats.drops++;
-#ifdef CONFIG_NET_CLS_ACT
-		if (sch->reshape_fail == NULL || sch->reshape_fail(skb, sch))
-#endif
-			kfree_skb(skb);
-
-		return NET_XMIT_DROP;
-	}
+	if (skb->len > q->max_size)
+		return qdisc_reshape_fail(skb, sch);
 
 	if ((ret = q->qdisc->enqueue(skb, q->qdisc)) != 0) {
 		sch->qstats.drops++;
---696208474-776036675-1219231476=:4551--
