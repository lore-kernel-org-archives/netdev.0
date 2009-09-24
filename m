From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [AX25] kernel panic
Date: Thu, 24 Sep 2009 08:07:19 +0000
Message-ID: <20090924080719.GA12279@ff.dom.local>
References: <20090921201157.GA5460@del.dom.local> <4ABA9058.3010605@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bernard Pidoux <bernard.pidoux@upmc.fr>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-hams <linux-hams@vger.kernel.org>
To: Bernard Pidoux F6BVP <f6bvp@free.fr>
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4ABA9058.3010605@free.fr>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 23, 2009 at 11:17:12PM +0200, Bernard Pidoux F6BVP wrote:
> Hi Jarek,
Hi Bernard,

>
> After applying your second patch I had to wait until today before I catched
> these kernel messages.
> The last three ones where single lines.
> There was no kernel panic. 

Probably you didn't hit the some kind of traffic/problems, because
there was only some additional reporting in this patch vs. take 1.

In the meantime I found some strangeness in refcounting around
ax25_send_frame, and below is a patch which IMHO should fix it. I
don't know if it matters in your case (the previous report suggested
there should be something more), but let's try. Please, don't remove
the previous debugging patch yet, while testing this one.

Thanks,
Jarek P.
--- (ax25_send_frame patch take 1 for testing)

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
index 4eb1ac9..850ffc0 100644
--- a/net/netrom/nr_route.c
+++ b/net/netrom/nr_route.c
@@ -842,12 +842,13 @@ int nr_route_frame(struct sk_buff *skb, ax25_cb *ax25)
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
index 9478d9b..8e5d5ac 100644
--- a/net/rose/rose_route.c
+++ b/net/rose/rose_route.c
@@ -234,6 +234,8 @@ static void rose_remove_neigh(struct rose_neigh *rose_neigh)
 
 	if ((s = rose_neigh_list) == rose_neigh) {
 		rose_neigh_list = rose_neigh->next;
+		if (rose_neigh->ax25)
+			ax25_cb_put(rose_neigh->ax25);
 		kfree(rose_neigh->digipeat);
 		kfree(rose_neigh);
 		return;
@@ -242,6 +244,8 @@ static void rose_remove_neigh(struct rose_neigh *rose_neigh)
 	while (s != NULL && s->next != NULL) {
 		if (s->next == rose_neigh) {
 			s->next = rose_neigh->next;
+			if (rose_neigh->ax25)
+				ax25_cb_put(rose_neigh->ax25);
 			kfree(rose_neigh->digipeat);
 			kfree(rose_neigh);
 			return;
@@ -814,6 +818,7 @@ void rose_link_failed(ax25_cb *ax25, int reason)
 
 	if (rose_neigh != NULL) {
 		rose_neigh->ax25 = NULL;
+		ax25_cb_put(ax25);
 
 		rose_del_route_by_neigh(rose_neigh);
 		rose_kill_by_neigh(rose_neigh);
