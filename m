From: Chris Brookes <chris@txrx.org>
Subject: identification field in ip datagrams
Date: 07 Apr 2003 09:52:22 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1049727143.13680.42.camel@tinkerbell.uhc.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello, 

I'm pre-testing the deployment of some Cisco 11000 series content
switches which amongst other things will load balance a few million DNS
queries per day. 

During the testing it appeared that the CSS device was correctly
distributing UDP53 based queries between 2 real name servers for all
tested client systems apart from ones running Linux. 

I did some investigating and it turns out Linux systems are putting out
small IP datagrams that can't/won't fragment with the IP identification
field set to zero. I looked through the relevant RFC and it seems to
spend a lot of time describing how to use the identification field for
handling datagram fragmentation, but has no advice for what to do with
the field when the datagram won't fragment. 

I see from the kernel source that there's been an implementation
decision to set the field to zero. Can we consider changing this? I've
checked AIX, Solaris, OpenBSD and even some Windows TCP/IP stack
implementations and they all pick a random number regardless of the
datagram not fragmenting, so we'd be more in line with the "de facto
behavior" for that scenario? 

I'm not much of a C programmer but in an effort to see whether fixing
the ID field would solve my original problem, in the development kernel
(2.5.66) I hacked net/ipv4/ip_output.c like this: 

--- ip_output.c.orig    2003-04-06 12:55:04.000000000 -0500 
+++ ip_output.c 2003-04-06 12:56:10.000000000 -0500 
@@ -1142,11 +1142,7 @@ 
        iph->tos = inet->tos; 
        iph->tot_len = htons(skb->len); 
        iph->frag_off = df; 
-       if (!df) { 
-               __ip_select_ident(iph, &rt->u.dst, 0); 
-       } else { 
-                iph->id = htons(inet->id++); 
-       } 
+       __ip_select_ident(iph, &rt->u.dst, 0); 
        iph->ttl = ttl; 
        iph->protocol = sk->protocol; 
        iph->saddr = rt->rt_src; 

And that did fix my issue for those development kernels. On the 2.4.21
series, I changed include/net/ip.h like this: 

--- ip.h.orig   2003-04-07 09:42:37.000000000 -0500 
+++ ip.h        2003-04-06 22:42:35.000000000 -0500 
@@ -190,18 +190,9 @@ 

static inline void ip_select_ident(struct iphdr *iph, struct dst_entry
*dst, struct sock *sk) 
{ 
-        if (iph->frag_off&__constant_htons(IP_DF)) { 
-                /* This is only to work around buggy Windows95/2000 
-                 * VJ compression implementations.  If the ID field 
-                 * does not change, they drop every other packet in 
-                 * a TCP stream using header compression. 
-                 */ 
-                iph->id = ((sk && sk->daddr) ?
htons(sk->protinfo.af_inet.id++) : 0); 
-        } else 
-                __ip_select_ident(iph, dst); 
+               __ip_select_ident(iph, dst); 
} 

- 
/* 
  *     Map a multicast IP onto multicast MAC for type ethernet. 
  */ 

And again, that did seem to give the small datagrams good identification
fields. I expect if anyone was  going to change the implementation to
give all datagrams identification fields, they'd want to do the patch
themselves ;-) but in the meantime, is what I've done likely to
negatively impact anything else? 

Regards 
Chris Brookes 
