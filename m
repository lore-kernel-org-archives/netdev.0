From: Florian Westphal <fw@strlen.de>
Subject: Re: Netfilter: BUG: unable to handle kernel paging request, RIP:
 physdev_mt+0xd6/0x160
Date: Mon, 14 Sep 2015 16:45:16 +0200
Message-ID: <20150914144516.GM24810@breakpoint.cc>
References: <1620a50057d1e8aadafe27c74ee42d93@eikelenboom.it>
 <20150913180620.GK24810@breakpoint.cc>
 <57e23f8e80b57dff72f6bc5b7e9b2d53@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	netfilter@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:33466 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752336AbbINOpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2015 10:45:18 -0400
Content-Disposition: inline
In-Reply-To: <57e23f8e80b57dff72f6bc5b7e9b2d53@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sander Eikelenboom <linux@eikelenboom.it> wrote:
> On 2015-09-13 20:06, Florian Westphal wrote:
> >Sander Eikelenboom <linux@eikelenboom.it> wrote:
> >>Using a linux-4.3-rc1 kernel i encountered the splat below:
> >
> >Thanks for reporting this bug.
> >
> >>[  290.200642] BUG: unable to handle kernel paging request at
> >>000000000484195d
> >>[  290.211702] IP: [<ffffffff819bc3e6>] physdev_mt+0xd6/0x160
> >[..]
> >
> >>[  290.444088]  [<ffffffff81a4e6c0>] ipt_do_table+0x210/0x390
> >>[  290.461951]  [<ffffffff81a510ae>] iptable_filter_hook+0x2e/0x70
> >>[  290.470756]  [<ffffffff8199279c>] nf_iterate+0x4c/0x80
> >>[  290.479587]  [<ffffffff81992834>] nf_hook_slow+0x64/0xc0
> >>[  290.488341]  [<ffffffff81a06779>] ip_forward+0x369/0x3c0
> >>[  290.496927]  [<ffffffff81a06380>] ? ip_frag_mem+0x40/0x40
> >>[  290.505365]  [<ffffffff81a04961>] ip_rcv_finish+0x101/0x330
> >>[  290.513480]  [<ffffffff81a05001>] ip_rcv+0x291/0x390
> >>[  290.521562]  [<ffffffff81a04860>] ?
> >
> >Aye, ip forwarding of bridged packets with call-iptables=1 is broken.
> >
> >Please, could you try this patch?  It fixes this bug for me.
> 
> Hi Florian,
> 
> Works for me too, thx for the fix !

Sorry, I made this claim too early.

We cannot use this fix, since it will still cause kernel oops when using
-j NFQUEUE in PRE_ROUTING (We would bump refcnt on ->physoutdev, which is
garbage in this case).

Only option is to undo 72b1e5e4cac as follows:

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -183,7 +183,8 @@ struct nf_bridge_info {
 		/* prerouting: detect dnat in orig/reply direction */
 		__be32          ipv4_daddr;
 		struct in6_addr ipv6_daddr;
-
+	};
+	union {
 		/* after prerouting + nat detected: store original source
 		 * mac since neigh resolution overwrites it, only used while
 		 * skb is out in neigh layer.
