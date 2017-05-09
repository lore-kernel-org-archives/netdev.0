From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net] ipv4: restore rt->fi for reference counting
Date: Tue, 09 May 2017 16:50:05 -0700
Message-ID: <1494373805.7796.98.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1493934857-6693-1-git-send-email-xiyou.wangcong@gmail.com>
         <20170508.143557.105629611489969352.davem@davemloft.net>
         <1494288080.7796.59.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170508.212211.1291611254198273979.davem@davemloft.net>
         <1494296302.7796.61.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpWQoLppsMfDOQWsdifGd56CAY24tCNm0Jm02QCe7ZThOw@mail.gmail.com>
         <1494348962.7796.88.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpXADa6AyQ3X-EbmRPGCQArgPWygvHMYgWtfUYV082oF3Q@mail.gmail.com>
         <CAM_iQpVhdzeen+ZJ3jyK7Qb=yVuoRSZ7BFB3RoVMShY8KPBTZA@mail.gmail.com>
         <1494370367.7796.92.camel@edumazet-glaptop3.roam.corp.google.com>
         <1494370451.7796.93.camel@edumazet-glaptop3.roam.corp.google.com>
         <1494371348.7796.95.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpU+fXO7eFroAYMv6vqDzCK_ZYXjrTPAMfoDR2BDqaK9rQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36114 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750733AbdEIXuI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 19:50:08 -0400
Received: by mail-pg0-f67.google.com with SMTP id 64so1774991pgb.3
        for <netdev@vger.kernel.org>; Tue, 09 May 2017 16:50:07 -0700 (PDT)
In-Reply-To: <CAM_iQpU+fXO7eFroAYMv6vqDzCK_ZYXjrTPAMfoDR2BDqaK9rQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-05-09 at 16:35 -0700, Cong Wang wrote:

> All of them take RCU read lock, so, as I explained in the code comment,
> they all should be fine because of synchronize_net() on unregister path.
> Do you see anything otherwise?

They might take rcu lock, but compiler is still allowed to read
fi->fib_dev multiple times, and crashes might happen.

You will need to audit all code and fix it, using proper
rcu_dereference() or similar code ensuring compiler wont do stupid
things.

Like :

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 1201409ba1dcb18ee028003b065410b87bf4a602..ab69517befbb5f300af785fbb20071a3d1086593 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -2666,11 +2666,13 @@ static int fib_route_seq_show(struct seq_file *seq, void *v)
 
 		seq_setwidth(seq, 127);
 
-		if (fi)
+		if (fi) {
+			struct net_device *dev = rcu_dereference(fi->fib_dev);
+
 			seq_printf(seq,
 				   "%s\t%08X\t%08X\t%04X\t%d\t%u\t"
 				   "%d\t%08X\t%d\t%u\t%u",
-				   fi->fib_dev ? fi->fib_dev->name : "*",
+				   dev ? dev->name : "*",
 				   prefix,
 				   fi->fib_nh->nh_gw, flags, 0, 0,
 				   fi->fib_priority,
@@ -2679,13 +2681,13 @@ static int fib_route_seq_show(struct seq_file *seq, void *v)
 				    fi->fib_advmss + 40 : 0),
 				   fi->fib_window,
 				   fi->fib_rtt >> 3);
-		else
+		} else {
 			seq_printf(seq,
 				   "*\t%08X\t%08X\t%04X\t%d\t%u\t"
 				   "%d\t%08X\t%d\t%u\t%u",
 				   prefix, 0, flags, 0, 0, 0,
 				   mask, 0, 0, 0);
-
+		}
 		seq_pad(seq, '\n');
 	}
 
