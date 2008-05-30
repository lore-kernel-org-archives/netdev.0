From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Inconsistend lock state in inet_frag_find
Date: Fri, 30 May 2008 10:53:34 +0000
Message-ID: <20080530105334.GA7378@ff.dom.local>
References: <20080529120248.GA9702@alice>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Eric Sesterhenn <snakebyte@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:27063 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751185AbYE3Ktp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2008 06:49:45 -0400
Received: by fg-out-1718.google.com with SMTP id 19so96655fgg.17
        for <netdev@vger.kernel.org>; Fri, 30 May 2008 03:49:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080529120248.GA9702@alice>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29-05-2008 14:02, Eric Sesterhenn wrote:
> hi,
> 
> the following just popped up on my test box with
> tcpsic6  -s ::1 -d ::1 -p 100000 -r 4995
> 
> [   63.616218] =================================
> [   63.616456] [ INFO: inconsistent lock state ]
> [   63.616456] 2.6.26-rc4 #5
> [   63.616456] ---------------------------------
> [   63.616456] inconsistent {softirq-on-W} -> {in-softirq-R} usage.
> [   63.616456] tcpsic6/3869 [HC0[0]:SC1[1]:HE1:SE0] takes:
> [   63.616456]  (&f->lock){---?}, at: [<c06be62e>]
> inet_frag_find+0x1e/0x140
...

Hi,

Could you try this patch?

Regards,
Jarek P.

---

 net/ipv6/netfilter/nf_conntrack_reasm.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 2dccad4..f3c36d6 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -209,7 +209,9 @@ fq_find(__be32 id, struct in6_addr *src, struct in6_addr *dst)
 	arg.dst = dst;
 	hash = ip6qhashfn(id, src, dst);
 
+	local_bh_disable();
 	q = inet_frag_find(&nf_init_frags, &nf_frags, &arg, hash);
+	local_bh_enable();
 	if (q == NULL)
 		goto oom;
 
