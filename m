From: "Angelo Dell'Aera" <buffer@antifork.org>
Subject: Re: [PATCH] TCP westwood bw_sample set never used
Date: Sat, 13 Mar 2004 17:27:12 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040313172712.0d10080a.buffer@antifork.org>
References: <20040312091505.593443d1@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040312091505.593443d1@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 12 Mar 2004 09:15:05 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

>Found this while looking in detail at TCP.  The westwood.bw_sample element
>it tcp_opt is set but not used by the existing code in 2.6.4

Stephen,
I used that field in the first version of the Westwood code just for having 
the possibility of doing a bandwidth estimation tracking analysis.
 
After dropping CONFIG_TCP_WESTWOOD_STATS it's simply useless and so I agree
with your patch. But it's necessary to just point out an important thing. 
When you call westwood_filter() you're actually evaluating the bandwidth 
estimate. This is done by two constant coefficients low-pass filters one 
after the other. 

This part of the code was taken clearly separated from the rest of the code 
since you could even find a better way to do it (f.e. TCP Westwood which came 
before Westwood+ did it in improper manner). Maybe this was the reason 
bw_sample was left in the struct westwood. But being it absolutely useless 
at this time it could be removed even from there. I simply dropped another 
line wrt to your patch.    

Regards.

--

Angelo Dell'Aera 'buffer' 
Antifork Research, Inc.	  	http://buffer.antifork.org



diff -Naur linux-2.6.4-old/include/linux/tcp.h linux-2.6.4/include/linux/tcp.h
--- linux-2.6.4-old/include/linux/tcp.h	2004-02-18 16:34:15.000000000 +0100
+++ linux-2.6.4/include/linux/tcp.h	2004-03-13 16:56:39.000000000 +0100
@@ -377,7 +377,6 @@
 
 /* TCP Westwood structure */
         struct {
-                __u32    bw_sample;        /* bandwidth sample */
                 __u32    bw_ns_est;        /* first bandwidth estimation..not too smoothed 8) */
                 __u32    bw_est;           /* bandwidth estimate */
                 __u32    rtt_win_sx;       /* here starts a new evaluation... */
diff -Naur linux-2.6.4-old/net/ipv4/tcp_input.c linux-2.6.4/net/ipv4/tcp_input.c
--- linux-2.6.4-old/net/ipv4/tcp_input.c	2004-03-10 17:31:40.000000000 +0100
+++ linux-2.6.4/net/ipv4/tcp_input.c	2004-03-13 16:50:35.000000000 +0100
@@ -2065,7 +2065,6 @@
 {
         struct tcp_opt *tp = tcp_sk(sk);
 
-        tp->westwood.bw_sample = 0;
         tp->westwood.bw_ns_est = 0;
         tp->westwood.bw_est = 0;
         tp->westwood.accounted = 0;
@@ -2088,14 +2087,13 @@
 static void westwood_filter(struct sock *sk, __u32 delta)
 {
 	struct tcp_opt *tp = tcp_sk(sk);
-	__u32 sample = tp->westwood.bk / delta;
 
 	tp->westwood.bw_ns_est =
-		westwood_do_filter(tp->westwood.bw_ns_est, sample);
+		westwood_do_filter(tp->westwood.bw_ns_est, 
+				   tp->westwood.bk / delta);
 	tp->westwood.bw_est =
 		westwood_do_filter(tp->westwood.bw_est,
 				   tp->westwood.bw_ns_est);
-	tp->westwood.bw_sample = sample;
 }
 
 /* @westwood_update_rttmin
