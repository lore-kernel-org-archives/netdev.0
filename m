From: Nivedita Singhvi <niv@us.ibm.com>
Subject: [PATCH 2.4.5  Re: Fw: Stack sends SYN/ACKs even though accept queue
 is full
Date: Sat, 01 May 2004 11:23:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4093EB32.6070203@us.ibm.com>
References: <15FDCE057B48784C80836803AE3598D50627AC8B@racerx.ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, David Miller <davem@redhat.com>,
        Andrew Morton <akpm@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jan Olderdissen <jan@ixiacom.com>
In-Reply-To: <15FDCE057B48784C80836803AE3598D50627AC8B@racerx.ixiacom.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jan Olderdissen wrote:

>We'll be happy to test it. We would prefer a 2.4 kernel patch though. Ideal
>would be 2.4.21 vanilla which we use in our embedded systems, but we can
>make other targets work as well.
>  
>
Attached is a patch against 2.4.25.  This adds the sysctl variable
/proc/sys/net/ipv4/tcp_preload_synq as before, but the default
value is 0.  So by default, TCP will not preload, i.e.
it will drop connection requests when the accept queue is full,
rather than holding on to them on the synq.

Enabling tcp_preload_synq will restore the original behaviour.

Would it be possible for you to collect some run-time statistics
(Accept failures from netstat -s, for instance) and performance
data for both code paths and provide some real world feedback
on how much of a difference it actually makes? That would be
very much appreciated, if possible.  I'm assuming there was a
difference since you noticed the problem to begin with.

>all others have already had their full timeout. I will argue that in high
>load conditions it doesn't really matter whether you have one or two warm
>connections sitting around or not because other new connections are going to
>

In high load and long lived connections, it is definitely not helpful for
performance. Hence being able to turn it off/on is a good thing.

>come by anyway sooner than you want to have them. If the server is able to
>keep up, the accept queue is going to be mostly empty anyway.
>  
>

Yep, but that is not the environment this is intended to affect.
This only comes into the picture when the accept queue is full.

>The idea of having warm connections is a good one - that is what the accept
>queue is for. As long as the accept queue is not full, the syn queue will
>have warm bodies for you. If the user wanted to achieve a very similar
>effect, he could simply increase the accept queue size by 2.
>  
>

I agree that having the accept queue just be the original holding
slot for connection requests is a nice thing, without overloading
the synq,  but simply increasing the accept queue might not be
equivalent  to what this feature is actually giving you.  Especially
if apps use setsockopt to specify an accept queue len, and other
such scenarios.  And think of satellite round trip times of 900ms,
and so on..

>In the end I don't think the minimal benefit warrants complicating the code
>and/or adding an option that few would understand or care to know about.
>Also, the concept of suggesting to the client that there is a receiver and
>then just dropping all the packets it sends seems a bit rude if not outright
>non-compliant.
>  
>

It is not actually non-compliant, since the last ack and data sent
could all be lost, and both ends have to deal with that possibility.
Certainly within protocol specs.  Just a question of optimizing between
a retransmission of data on an established connection and setting up
a new connection.  Typically, if the other side is also well-behaved,
it will be doing slow start and won't have opened the window, so
we should not be seeing uncontrolled data thrown at us, just the
initial 2 segments, blocked by the ack.  I'd also wager that not too
many people would even detect this as a problem. Still, the less we
have to have users do, the better, probably.

Please let me know if you have problems with the patch..just
moved to a new email client..

thanks,
Nivedita

diff -urN linux-2.4.25/include/linux/sysctl.h 
linux-2.4.25synq/include/linux/sysctl.h
--- linux-2.4.25/include/linux/sysctl.h    2004-02-18 05:36:32.000000000 
-0800
+++ linux-2.4.25synq/include/linux/sysctl.h    2004-05-01 
01:54:39.000000000 -0700
@@ -312,6 +312,7 @@
     NET_TCP_FRTO=92,
     NET_TCP_LOW_LATENCY=93,
     NET_IPV4_IPFRAG_SECRET_INTERVAL=94,
+    NET_TCP_PRELOAD_SYNQ=95,
 };
 
 enum {
diff -urN linux-2.4.25/include/net/tcp.h linux-2.4.25synq/include/net/tcp.h
--- linux-2.4.25/include/net/tcp.h    2003-11-28 10:26:21.000000000 -0800
+++ linux-2.4.25synq/include/net/tcp.h    2004-05-01 01:55:13.000000000 
-0700
@@ -463,6 +463,7 @@
 extern int sysctl_tcp_tw_reuse;
 extern int sysctl_tcp_frto;
 extern int sysctl_tcp_low_latency;
+extern int sysctl_tcp_preload_synq;
 
 extern atomic_t tcp_memory_allocated;
 extern atomic_t tcp_sockets_allocated;
diff -urN linux-2.4.25/net/ipv4/sysctl_net_ipv4.c 
linux-2.4.25synq/net/ipv4/sysctl_net_ipv4.c
--- linux-2.4.25/net/ipv4/sysctl_net_ipv4.c    2003-06-13 
07:51:39.000000000 -0700
+++ linux-2.4.25synq/net/ipv4/sysctl_net_ipv4.c    2004-05-01 
01:56:31.000000000 -0700
@@ -229,6 +229,8 @@
     {NET_IPV4_IPFRAG_SECRET_INTERVAL, "ipfrag_secret_interval",
      &sysctl_ipfrag_secret_interval, sizeof(int), 0644, NULL, 
&proc_dointvec_jiffies,
      &sysctl_jiffies},
+    {NET_TCP_PRELOAD_SYNQ, "tcp_preload_synq",
+     &sysctl_tcp_preload_synq, sizeof(int), 0644, NULL, &proc_dointvec},
     {0}
 };
 
diff -urN linux-2.4.25/net/ipv4/tcp_ipv4.c 
linux-2.4.25synq/net/ipv4/tcp_ipv4.c
--- linux-2.4.25/net/ipv4/tcp_ipv4.c    2003-11-28 10:26:21.000000000 -0800
+++ linux-2.4.25synq/net/ipv4/tcp_ipv4.c    2004-05-01 
02:00:02.000000000 -0700
@@ -72,6 +72,7 @@
 extern int sysctl_ip_default_ttl;
 int sysctl_tcp_tw_reuse = 0;
 int sysctl_tcp_low_latency = 0;
+int sysctl_tcp_preload_synq = 0;
 
 /* Check TCP sequence numbers in ICMP packets. */
 #define ICMP_MIN_LENGTH 8
@@ -1428,8 +1429,11 @@
      * clogging syn queue with openreqs with exponentially increasing
      * timeout.
      */
-    if (tcp_acceptq_is_full(sk) && tcp_synq_young(sk) > 1)
-        goto drop;
+    if (tcp_acceptq_is_full(sk)) {
+        if (!sysctl_tcp_preload_synq ||
+           (sysctl_tcp_preload_synq && (tcp_synq_young(sk) > 1)))
+            goto drop;
+    }
 
     req = tcp_openreq_alloc();
     if (req == NULL)
