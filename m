From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next V2] gro: introduce gro_mac_header_len
Date: Mon, 06 Feb 2012 15:15:09 -0500 (EST)
Message-ID: <20120206.151509.1959432192519622134.davem@davemloft.net>
References: <20120206.145148.558736903670696169.davem@davemloft.net>
	<20120206.145652.1575591691467905094.davem@davemloft.net>
	<CAG4TOxNcB8+SP3f0WhZG1GZ481s+=7pVRv91vzAbwDzUZD8g_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, herbert-F6s6mLieUQo7FNHlEwC/lvQIK84fMopw@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAG4TOxNcB8+SP3f0WhZG1GZ481s+=7pVRv91vzAbwDzUZD8g_A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date: Mon, 6 Feb 2012 12:01:13 -0800

> On Mon, Feb 6, 2012 at 11:56 AM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
>> But this needs a little bit of work since the qdisc_skb_cb ends with a
>> variable length array, but we can put an upper bound on this just like
>> we do for skb->cb[] itself to fix this issue.
>>
>> I'll toss something together.
> 
> OK thanks.  We need something like 20 bytes of space to stash an
> ipoib LL addr.  Which I guess leaves 28 bytes for sch use.

I just pushed the following into net-next, you have 24 bytes
available.

--------------------
net: Make qdisc_skb_cb upper size bound explicit.

Just like skb->cb[], so that qdisc_skb_cb can be encapsulated inside
of other data structures.

This is intended to be used by IPoIB so that it can remember
addressing information stored at hard_header_ops->create() time that
it can fetch when the packet gets to the transmit routine.

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 include/net/sch_generic.h |    9 ++++++++-
 net/sched/sch_choke.c     |    3 +--
 net/sched/sch_netem.c     |    3 +--
 net/sched/sch_sfb.c       |    3 +--
 net/sched/sch_sfq.c       |    5 ++---
 5 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index f6bb08b..55ce96b 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -220,9 +220,16 @@ struct tcf_proto {
 
 struct qdisc_skb_cb {
 	unsigned int		pkt_len;
-	long			data[];
+	unsigned char		data[24];
 };
 
+static inline void qdisc_cb_private_validate(const struct sk_buff *skb, int sz)
+{
+	struct qdisc_skb_cb *qcb;
+	BUILD_BUG_ON(sizeof(skb->cb) < sizeof(unsigned int) + sz);
+	BUILD_BUG_ON(sizeof(qcb->data) < sz);
+}
+
 static inline int qdisc_qlen(const struct Qdisc *q)
 {
 	return q->q.qlen;
diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index e465064..7e267d7 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -148,8 +148,7 @@ struct choke_skb_cb {
 
 static inline struct choke_skb_cb *choke_skb_cb(const struct sk_buff *skb)
 {
-	BUILD_BUG_ON(sizeof(skb->cb) <
-		sizeof(struct qdisc_skb_cb) + sizeof(struct choke_skb_cb));
+	qdisc_cb_private_validate(skb, sizeof(struct choke_skb_cb));
 	return (struct choke_skb_cb *)qdisc_skb_cb(skb)->data;
 }
 
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 2776012..e83d61c 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -130,8 +130,7 @@ struct netem_skb_cb {
 
 static inline struct netem_skb_cb *netem_skb_cb(struct sk_buff *skb)
 {
-	BUILD_BUG_ON(sizeof(skb->cb) <
-		sizeof(struct qdisc_skb_cb) + sizeof(struct netem_skb_cb));
+	qdisc_cb_private_validate(skb, sizeof(struct netem_skb_cb));
 	return (struct netem_skb_cb *)qdisc_skb_cb(skb)->data;
 }
 
diff --git a/net/sched/sch_sfb.c b/net/sched/sch_sfb.c
index 96e42ca..d7eea99 100644
--- a/net/sched/sch_sfb.c
+++ b/net/sched/sch_sfb.c
@@ -94,8 +94,7 @@ struct sfb_skb_cb {
 
 static inline struct sfb_skb_cb *sfb_skb_cb(const struct sk_buff *skb)
 {
-	BUILD_BUG_ON(sizeof(skb->cb) <
-		sizeof(struct qdisc_skb_cb) + sizeof(struct sfb_skb_cb));
+	qdisc_cb_private_validate(skb, sizeof(struct sfb_skb_cb));
 	return (struct sfb_skb_cb *)qdisc_skb_cb(skb)->data;
 }
 
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 67494ae..60d4718 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -166,9 +166,8 @@ struct sfq_skb_cb {
 
 static inline struct sfq_skb_cb *sfq_skb_cb(const struct sk_buff *skb)
 {
-       BUILD_BUG_ON(sizeof(skb->cb) <
-               sizeof(struct qdisc_skb_cb) + sizeof(struct sfq_skb_cb));
-       return (struct sfq_skb_cb *)qdisc_skb_cb(skb)->data;
+	qdisc_cb_private_validate(skb, sizeof(struct sfq_skb_cb));
+	return (struct sfq_skb_cb *)qdisc_skb_cb(skb)->data;
 }
 
 static unsigned int sfq_hash(const struct sfq_sched_data *q,
-- 
1.7.7.6

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
