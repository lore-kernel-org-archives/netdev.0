From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: TODO list before feature freeze
Date: 30 Jul 2002 15:08:24 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <1028034504.12617.135.camel@tux>
References: <Pine.GSO.4.30.0207300818480.15727-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick Schaaf <bof@bof.de>, Andi Kleen <ak@suse.de>,
   Rusty Russell <rusty@rustcorp.com.au>,
   Netfilter-devel <netfilter-devel@lists.netfilter.org>, netdev@oss.sgi.com,
   netfilter-core@lists.netfilter.org
Return-path: <owner-netdev@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <Pine.GSO.4.30.0207300818480.15727-100000@shell.cyberus.ca>
List-Id: netdev.vger.kernel.org

On Tue, 2002-07-30 at 14:29, jamal wrote:

> On Tue, 30 Jul 2002, Patrick Schaaf wrote:
> > Most likely things leading to such a result, in no specific suborder:
> >
> > - skb linearization
> > - always-defragment
> > - ip_conntrack_lock contention
> > - per-packet timer management

> If i was to use instinct i would say
> the last two items you list are probably the things you may want to chase.

Here's two small patches.

The first is a small patch to avoid updating the per-connection timer
for every packet. With this patch you get one update per second per
connection. Things are complicated by the fact that connections can
change timeouts. This patch isn't verified for correctness, YMMV.
(the pptp helper needs updating to work in combination with this patch)

The second patch changes the hashtable lookup slightly so we don't hash
the tuple each iteration, once is enough.

I don't have any numbers for these patches and I can't find the url to
the tests one of the netfilter-devel people has done.


diff -x *.orig -urN linux.orig/net/ipv4/netfilter/ip_conntrack_core.c linux/net/ipv4/netfilter/ip_conntrack_core.c
--- linux.orig/net/ipv4/netfilter/ip_conntrack_core.c	Tue Jul 30 14:38:41 2002
+++ linux/net/ipv4/netfilter/ip_conntrack_core.c	Tue Jul 30 14:40:06 2002
@@ -855,8 +855,10 @@
 	if (!is_confirmed(ct))
 		ct->timeout.expires = extra_jiffies;
 	else {
-		/* Need del_timer for race avoidance (may already be dying). */
-		if (del_timer(&ct->timeout)) {
+		/* Don't update timer for each packet, only if it's been >HZ
+		 * ticks since last update or change is negative.
+		 * Need del_timer for race avoidance (may already be dying). */
+		if ((unsigned long)(jiffies + extra_jiffies - ct->timeout.expires) >= HZ && del_timer(&ct->timeout)) {
 			ct->timeout.expires = jiffies + extra_jiffies;
 			add_timer(&ct->timeout);
 		}



--- linux-2.4.19-pre10/net/ipv4/netfilter/ip_conntrack_core.c.orig	Sat Jun  8 00:48:59 2002
+++ linux-2.4.19-pre10/net/ipv4/netfilter/ip_conntrack_core.c	Sat Jun  8 00:49:56 2002
@@ -292,9 +292,10 @@
 		    const struct ip_conntrack *ignored_conntrack)
 {
 	struct ip_conntrack_tuple_hash *h;
+	size_t hash = hash_conntrack(tuple);
 
 	MUST_BE_READ_LOCKED(&ip_conntrack_lock);
-	h = LIST_FIND(&ip_conntrack_hash[hash_conntrack(tuple)],
+	h = LIST_FIND(&ip_conntrack_hash[hash],
 		      conntrack_tuple_cmp,
 		      struct ip_conntrack_tuple_hash *,
 		      tuple, ignored_conntrack);

-- 
/Martin

Never argue with an idiot. They drag you down to their level, then beat
you with experience.
