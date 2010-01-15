From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH net-2.6] ax25: netrom: rose: Fix timer oopses
Date: Fri, 15 Jan 2010 21:36:54 +0100
Message-ID: <20100115203654.GA3084@del.dom.local>
References: <4B2CD772.1030106@upmc.fr>
 <4B2D1025.1020106@gmail.com>
 <4B2E6729.1090102@free.fr>
 <4B507FAA.8010007@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bernard Pidoux <bpidoux@free.fr>,
	Bernard Pidoux <bernard.pidoux@upmc.fr>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	Ralf Baechle <ralf@linux-mips.org>, linux-hams@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758254Ab0AOUhG@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B507FAA.8010007@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 15, 2010 at 03:46:02PM +0100, Bernard Pidoux wrote:
> Hi Jarek,
Hi Bernard,

> 
> Congratulation. With your patch I did not see any more kernel panics
> since my last post.
> I think it should be commited.
> Many thanks.
> 
> Wishing you a happy new year 2010.
> 
Happy new year to you as well.

Thanks,
Jarek P.
-------------------->

Wrong ax25_cb refcounting in ax25_send_frame() and by its callers can
cause timer oopses (first reported with 2.6.29.6 kernel).

Fixes: http://bugzilla.kernel.org/show_bug.cgi?id=14905

Reported-by: Bernard Pidoux <bpidoux@free.fr>
Tested-by: Bernard Pidoux <bpidoux@free.fr>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 include/net/netrom.h  |    2 ++
 net/ax25/ax25_out.c   |    6 ++++++
 net/netrom/nr_route.c |   11 ++++++-----
 net/rose/rose_link.c  |    8 ++++++++
 net/rose/rose_route.c |    5 +++++
 5 files changed, 27 insertions(+), 5 deletions(-)

diff --git a/include/net/netrom.h b/include/net/netrom.h
index 15696b1..ab170a6 100644
--- a/include/net/netrom.h
+++ b/include/net/netrom.h
@@ -132,6 +132,8 @@ static __inline__ void nr_node_put(struct nr_node *nr_node)
 static __inline__ void nr_neigh_put(struct nr_neigh *nr_neigh)
 {
 	if (atomic_dec_and_test(&nr_neigh->refcount)) {
+		if (nr_neigh->ax25)
+			ax25_cb_put(nr_neigh->ax25);
 		kfree(nr_neigh->digipeat);
 		kfree(nr_neigh);
 	}
diff --git a/net/ax25/ax25_out.c b/net/ax25/ax25_out.c
index bf706f8..1491260 100644
--- a/net/ax25/ax25_out.c
+++ b/net/ax25/ax25_out.c
@@ -92,6 +92,12 @@ ax25_cb *ax25_send_frame(struct sk_buff *skb, int paclen, ax25_address *src, ax2
 #endif
 	}
 
+	/*
+	 * There is one ref for the state machine; a caller needs
+	 * one more to put it back, just like with the existing one.
+	 */
+	ax25_cb_hold(ax25);
+
 	ax25_cb_add(ax25);
 
 	ax25->state = AX25_STATE_1;
diff --git a/net/netrom/nr_route.c b/net/netrom/nr_route.c
index aacba76..e2e2d33 100644
--- a/net/netrom/nr_route.c
+++ b/net/netrom/nr_route.c
@@ -843,12 +843,13 @@ int nr_route_frame(struct sk_buff *skb, ax25_cb *ax25)
 	dptr  = skb_push(skb, 1);
 	*dptr = AX25_P_NETROM;
 
-	ax25s = ax25_send_frame(skb, 256, (ax25_address *)dev->dev_addr, &nr_neigh->callsign, nr_neigh->digipeat, nr_neigh->dev);
-	if (nr_neigh->ax25 && ax25s) {
-		/* We were already holding this ax25_cb */
+	ax25s = nr_neigh->ax25;
+	nr_neigh->ax25 = ax25_send_frame(skb, 256,
+					 (ax25_address *)dev->dev_addr,
+					 &nr_neigh->callsign,
+					 nr_neigh->digipeat, nr_neigh->dev);
+	if (ax25s)
 		ax25_cb_put(ax25s);
-	}
-	nr_neigh->ax25 = ax25s;
 
 	dev_put(dev);
 	ret = (nr_neigh->ax25 != NULL);
diff --git a/net/rose/rose_link.c b/net/rose/rose_link.c
index bd86a63..5ef5f69 100644
--- a/net/rose/rose_link.c
+++ b/net/rose/rose_link.c
@@ -101,13 +101,17 @@ static void rose_t0timer_expiry(unsigned long param)
 static int rose_send_frame(struct sk_buff *skb, struct rose_neigh *neigh)
 {
 	ax25_address *rose_call;
+	ax25_cb *ax25s;
 
 	if (ax25cmp(&rose_callsign, &null_ax25_address) == 0)
 		rose_call = (ax25_address *)neigh->dev->dev_addr;
 	else
 		rose_call = &rose_callsign;
 
+	ax25s = neigh->ax25;
 	neigh->ax25 = ax25_send_frame(skb, 260, rose_call, &neigh->callsign, neigh->digipeat, neigh->dev);
+	if (ax25s)
+		ax25_cb_put(ax25s);
 
 	return (neigh->ax25 != NULL);
 }
@@ -120,13 +124,17 @@ static int rose_send_frame(struct sk_buff *skb, struct rose_neigh *neigh)
 static int rose_link_up(struct rose_neigh *neigh)
 {
 	ax25_address *rose_call;
+	ax25_cb *ax25s;
 
 	if (ax25cmp(&rose_callsign, &null_ax25_address) == 0)
 		rose_call = (ax25_address *)neigh->dev->dev_addr;
 	else
 		rose_call = &rose_callsign;
 
+	ax25s = neigh->ax25;
 	neigh->ax25 = ax25_find_cb(rose_call, &neigh->callsign, neigh->digipeat, neigh->dev);
+	if (ax25s)
+		ax25_cb_put(ax25s);
 
 	return (neigh->ax25 != NULL);
 }
diff --git a/net/rose/rose_route.c b/net/rose/rose_route.c
index 795c4b0..70a0b3b 100644
--- a/net/rose/rose_route.c
+++ b/net/rose/rose_route.c
@@ -235,6 +235,8 @@ static void rose_remove_neigh(struct rose_neigh *rose_neigh)
 
 	if ((s = rose_neigh_list) == rose_neigh) {
 		rose_neigh_list = rose_neigh->next;
+		if (rose_neigh->ax25)
+			ax25_cb_put(rose_neigh->ax25);
 		kfree(rose_neigh->digipeat);
 		kfree(rose_neigh);
 		return;
@@ -243,6 +245,8 @@ static void rose_remove_neigh(struct rose_neigh *rose_neigh)
 	while (s != NULL && s->next != NULL) {
 		if (s->next == rose_neigh) {
 			s->next = rose_neigh->next;
+			if (rose_neigh->ax25)
+				ax25_cb_put(rose_neigh->ax25);
 			kfree(rose_neigh->digipeat);
 			kfree(rose_neigh);
 			return;
@@ -812,6 +816,7 @@ void rose_link_failed(ax25_cb *ax25, int reason)
 
 	if (rose_neigh != NULL) {
 		rose_neigh->ax25 = NULL;
+		ax25_cb_put(ax25);
 
 		rose_del_route_by_neigh(rose_neigh);
 		rose_kill_by_neigh(rose_neigh);
