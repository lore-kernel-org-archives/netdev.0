From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 3/3] Convert the UDP hash lock to RCU
Date: Wed, 08 Oct 2008 15:55:36 +0200
Message-ID: <48ECBBD8.9060602@cosmosbay.com>
References: <m37i8k3hv1.fsf@ursa.amorsen.dk>	<48EB5D28.7000503@cosmosbay.com>	<20081007160729.60c076c4@speedy> <20081007.135548.56141000.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020508010404090802020108"
Cc: shemminger@vyatta.com, benny+usenet@amorsen.dk, minyard@acm.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	paulmck@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755239AbYJHN4I@vger.kernel.org>
In-Reply-To: <20081007.135548.56141000.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020508010404090802020108
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

David Miller a =E9crit :
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Tue, 7 Oct 2008 16:07:29 +0200
>=20
>> The idea of keeping chains short is the problem. That code should
>> just be pulled because it doesn't help that much, and also creates
>> bias on the port randomization.
>=20
> I have that patch from Vitaly Mayatskikh which does exactly this.
>=20
> I keep looking at it, but I can't bring myself to apply it since
> I'm not completely convinced.

Vitaly patch might be appropriate if only few UDP ports are opened.

We could zap the code to search short chains and extend Vitaly's
idea with following patch :

[PATCH] udp: Improve port randomization

Current UDP port allocation is suboptimal.
We select the shortest chain to chose a port (out of 512)
that will hash in this shortest chain.

First, it can lead to give not so ramdom ports and ease
give attackers more opportunities to break the system.

Second, it can consume a lot of CPU to scan all table
in order to find the shortest chain.

Third, in some pathological cases we can fail to find
a free port even if they are plenty of them.

This patch zap the search for a short chain and only
use one random seed. Problem of getting long chains
should be addressed in another way, since we can
obtain long chains with non random ports.

Based on a report and patch from Vitaly Mayatskikh

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>



--------------020508010404090802020108
Content-Type: text/plain;
 name="udp_random.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="udp_random.patch"

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 85f8e8e..67d8430 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -155,55 +155,23 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 	write_lock_bh(&udp_hash_lock);
 
 	if (!snum) {
-		int i, low, high, remaining;
-		unsigned rover, best, best_size_so_far;
+		int low, high, remaining;
+		unsigned rand;
+		unsigned short first;
 
 		inet_get_local_port_range(&low, &high);
 		remaining = (high - low) + 1;
 
-		best_size_so_far = UINT_MAX;
-		best = rover = net_random() % remaining + low;
-
-		/* 1st pass: look for empty (or shortest) hash chain */
-		for (i = 0; i < UDP_HTABLE_SIZE; i++) {
-			int size = 0;
-
-			head = &udptable[udp_hashfn(net, rover)];
-			if (hlist_empty(head))
-				goto gotit;
-
-			sk_for_each(sk2, node, head) {
-				if (++size >= best_size_so_far)
-					goto next;
-			}
-			best_size_so_far = size;
-			best = rover;
-		next:
-			/* fold back if end of range */
-			if (++rover > high)
-				rover = low + ((rover - low)
-					       & (UDP_HTABLE_SIZE - 1));
-
-
-		}
-
-		/* 2nd pass: find hole in shortest hash chain */
-		rover = best;
-		for (i = 0; i < (1 << 16) / UDP_HTABLE_SIZE; i++) {
-			if (! __udp_lib_lport_inuse(net, rover, udptable))
-				goto gotit;
-			rover += UDP_HTABLE_SIZE;
-			if (rover > high)
-				rover = low + ((rover - low)
-					       & (UDP_HTABLE_SIZE - 1));
+		rand = net_random();
+		snum = first = rand % remaining + low;
+		rand |= 1;
+		while (__udp_lib_lport_inuse(net, snum, udptable)) {
+			do {
+				snum = snum + rand;
+			} while (snum < low || snum > high);
+			if (snum == first)
+				goto fail;
 		}
-
-
-		/* All ports in use! */
-		goto fail;
-
-gotit:
-		snum = rover;
 	} else {
 		head = &udptable[udp_hashfn(net, snum)];
 

--------------020508010404090802020108--
