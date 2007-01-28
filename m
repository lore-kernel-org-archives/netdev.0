From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.20-rc6-mm1
Date: Sun, 28 Jan 2007 15:10:39 -0800
Message-ID: <20070128151039.636b3680.akpm@osdl.org>
References: <20070127234928.64d8e437.akpm@osdl.org>
	<45BD2424.7020604@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:40983 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932957AbXA1XKq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Jan 2007 18:10:46 -0500
In-Reply-To: <45BD2424.7020604@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 28 Jan 2007 23:31:00 +0100
Michal Piotrowski <michal.k.k.piotrowski@gmail.com> wrote:

> Jan 28 22:58:29 euridica kernel: BUG: using smp_processor_id() in preemptible [00000001] code: yum-updatesd/2846
> Jan 28 22:58:29 euridica kernel: caller is nf_conntrack_in+0x363/0x47f [nf_conntrack]

I'll plug that with this:


diff -puN include/net/netfilter/nf_conntrack.h~netfilter-warning-fix include/net/netfilter/nf_conntrack.h
--- a/include/net/netfilter/nf_conntrack.h~netfilter-warning-fix
+++ a/include/net/netfilter/nf_conntrack.h
@@ -254,7 +254,12 @@ extern atomic_t nf_conntrack_count;
 extern int nf_conntrack_max;
 
 DECLARE_PER_CPU(struct ip_conntrack_stat, nf_conntrack_stat);
-#define NF_CT_STAT_INC(count) (__get_cpu_var(nf_conntrack_stat).count++)
+#define NF_CT_STAT_INC(count)						\
+	do {								\
+		preempt_disable();					\
+		__get_cpu_var(nf_conntrack_stat).count++;		\
+		preempt_enable();					\
+	} while (0);
 
 /* no helper, no nat */
 #define	NF_CT_F_BASIC	0
_

and will let others worry about what the real fix (for 2.6.20, please) is.
