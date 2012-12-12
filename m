From: Ani Sinha <ani@aristanetworks.com>
Subject: Re: [tcpdump-workers] vlan tagged packets and libpcap breakage
Date: Wed, 12 Dec 2012 13:53:16 -0800 (PST)
Message-ID: <alpine.OSX.2.00.1212121205040.78903@animac.local>
References: <CAOxq_8Nd8VP3MaNBfUt9v82nmGDpxZz5_5QMdsruET1tjwuQPw@mail.gmail.com> <3246.1351717319@obiwan.sandelman.ca> <CAOxq_8PsXb-oUy85Eji7GSAbUZD_Bds8skmGNP4BWSewQWx8PA@mail.gmail.com> <21992.1351723328@obiwan.sandelman.ca>
Reply-To: ani@aristanetworks.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, tcpdump-workers@lists.tcpdump.org,
	Francesco Ruggeri <fruggeri@aristanetworks.com>
To: Michael Richardson <mcr@sandelman.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:49177 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754756Ab2LLVxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 16:53:19 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so956700pbc.19
        for <netdev@vger.kernel.org>; Wed, 12 Dec 2012 13:53:19 -0800 (PST)
In-Reply-To: <21992.1351723328@obiwan.sandelman.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>
> unsigned int netdev_8021q_inskb = 1;
>
> ...
> 	{
> 		.ctl_name	= NET_CORE_8021q_INSKB,
> 		.procname	= "netdev_8021q_inskb",
> 		.data		= &netdev_8021q_inskb,
> 		.maxlen		= sizeof(int),
> 		.mode		= 0444,
> 		.proc_handler	= proc_dointvec
> 	},
>
> would seem to do it to me.
> Then pcap can fopen("/proc/sys/net/core/netdev_8021q_inskb") and if it
> finds it, and it is >0, then do the cmsg thing.
>

Does this work? This is just an experimental patch and by no means final.
I just want to have an idea what everyone thought about it. Once we debate
and discusss, I can cook up a final patch that would be worth commiting.

Also instead of having this /proc interface, we can perhaps check for a
specific
kernel version that :

(a) has the vlan tag info in the skb metadata (as opposed to in the packet
itself)
(b) has the following patch that adds the capability to generate a filter
based on the tag value :

commit f3335031b9452baebfe49b8b5e55d3fe0c4677d1
Author: Eric Dumazet <edumazet@google.com>
Date:   Sat Oct 27 02:26:17 2012 +0000

    net: filter: add vlan tag access

WE need both of the above two things for the userland to generate a filter
code that compares vlan tag values in the skb metadata. For kernels that
has the vlan tag in
the skb metadata but does not have the above commit (b), there is nothing
that can be done. For older kernels that had the vlan tag info in the
packet itself, the filter code can be generated differently to look at
specific offsets within the packet (something that libpcap does
currently).

We have already ruled out the idea of generating a filter and trying to
load and see if that fails (see previous emails on this thread).

Hope this makes sense.


diff --git a/include/linux/filter.h b/include/linux/filter.h
index c45eabc..91e2ba3 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -36,6 +36,7 @@ static inline unsigned int sk_filter_len(const struct sk_filter *fp)
 	return fp->len * sizeof(struct sock_filter) + sizeof(*fp);
 }

+extern bool sysctl_8021q_inskb;
 extern int sk_filter(struct sock *sk, struct sk_buff *skb);
 extern unsigned int sk_run_filter(const struct sk_buff *skb,
 				  const struct sock_filter *filter);
diff --git a/net/core/filter.c b/net/core/filter.c
index c23543c..4f5a657 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -41,6 +41,8 @@
 #include <linux/seccomp.h>
 #include <linux/if_vlan.h>

+bool sysctl_8021q_inskb = 1;
+
 /* No hurry in this branch
  *
  * Exported for the bpf jit load helper.
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index d1b0804..f9a3700 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -15,6 +15,7 @@
 #include <linux/init.h>
 #include <linux/slab.h>
 #include <linux/kmemleak.h>
+#include <linux/filter.h>

 #include <net/ip.h>
 #include <net/sock.h>
@@ -189,6 +190,13 @@ static struct ctl_table net_core_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "8021q_inskb",
+		.data		= &sysctl_8021q_inskb,
+		.maxlen		= sizeof(bool),
+		.mode		= 0444,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
