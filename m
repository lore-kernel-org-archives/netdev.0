From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] rcu: fix a race in hlist_nulls_for_each_entry_rcu
 macro
Date: Wed, 22 May 2013 07:16:55 -0700
Message-ID: <1369232215.3301.338.camel@edumazet-glaptop>
References: <519B38EC.90401@yandex-team.ru>
	 <20130521120906.GD3578@linux.vnet.ibm.com>
	 <1369143885.3301.221.camel@edumazet-glaptop>
	 <519B8908.9080007@yandex-team.ru>
	 <1369150693.3301.233.camel@edumazet-glaptop>
	 <519BB90B.6080706@yandex-team.ru>
	 <1369188080.3301.268.camel@edumazet-glaptop>
	 <20130522095839.GC3578@linux.vnet.ibm.com>
	 <1369225727.3301.322.camel@edumazet-glaptop>
	 <20130522130030.GB3431@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Roman Gushchin <klamm@yandex-team.ru>,
	Dipankar Sarma <dipankar@in.ibm.com>, zhmurov@yandex-team.ru,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130522130030.GB3431@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-05-22 at 06:00 -0700, Paul E. McKenney wrote:

> Right, rcu_read_lock() is part of the protection, but rcu_dereference()
> is the other part.
> 
> All that aside, I can't claim that I understand what problem the various
> patches would solve.  ;-)

Problem is that rcu_dereference(expr) might be optimized by the compiler
to cache the dereferenced data in certain circumstances.

Following patch shows the difference if you look at the generated code:

This patch fixes the problem, and its not really obvious why !

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 0bf5d39..6aa8088 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -416,11 +416,12 @@ static struct sock *udp4_lib_lookup2(struct net *net,
 	struct hlist_nulls_node *node;
 	int score, badness, matches = 0, reuseport = 0;
 	u32 hash = 0;
+	struct hlist_nulls_head *head = &hslot2->head;
 
 begin:
 	result = NULL;
 	badness = 0;
-	udp_portaddr_for_each_entry_rcu(sk, node, &hslot2->head) {
+	udp_portaddr_for_each_entry_rcu(sk, node, head) {
 		score = compute_score2(sk, net, saddr, sport,
 				      daddr, hnum, dif);
 		if (score > badness) {
