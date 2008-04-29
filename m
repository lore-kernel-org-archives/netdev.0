From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [BUG,NETFILTER] nfqnl_mangle() not requesting enough space for bigger reinjected packet.
Date: Tue, 29 Apr 2008 19:31:31 +0200
Message-ID: <87skx44lfw.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>,
	Debian Kernel Team <debian-kernel@lists.debian.org>,
	Silviu Vlasceanu <silviuvlasceanu@yahoo.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moog.chdir.org ([88.191.42.160]:41343 "EHLO moog.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764628AbYD2Rbi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 13:31:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Sorry for the latency.

I think I just found why the 2.6.24 *Debian* kernel undergo the same
issue. Basically because 2.6.24.4 kernel are also affected. Debian
maintainers do apply during the build the patch switching to the use of
skb_copy_expand() instead of pskb_expand_head() (as part of 2.6.24.4
patch) ;-) :

$:/tmp/linux-2.6-2.6.24/debian/patches$ grep -R _expand .
./features/all/vserver/vs2.2.0-rc5.patch:@@ -2098,6 +2107,8 @@ int may_expand_vm(struct mm_struct *mm, 
./features/all/vserver/vs2.2.0-rc5.patch:       if (!may_expand_vm(mm, (new_len - old_len) >> PAGE_SHIFT)) {
./bugfix/all/stable/2.6.24.3.patch: static inline int audit_expand(struct audit_buffer *ab, int extra)
./bugfix/all/stable/2.6.24.3.patch:-    int ret = pskb_expand_head(skb, skb_headroom(skb), extra,
./bugfix/all/stable/2.6.24.3.patch:+    int ret = pskb_expand_head(skb, 0, extra, ab->gfp_mask);
./bugfix/all/stable/2.6.24.3.patch:             audit_log_lost("out of memory in audit_expand");
./bugfix/all/stable/2.6.24.4.patch:@@ -1699,6 +1699,11 @@ mptsas_sas_expander_pg0(MPT_ADAPTER *ioc, struct mptsas_portinfo *port_info,
./bugfix/all/stable/2.6.24.4.patch:-                    err = pskb_expand_head(e->skb, 0,
./bugfix/all/stable/2.6.24.4.patch:+                    nskb = skb_copy_expand(e->skb, 0,
./bugfix/all/stable/2.6.24.4.patch:-                    err = pskb_expand_head(e->skb, 0,
./bugfix/all/stable/2.6.24.4.patch:+                    nskb = skb_copy_expand(e->skb, 0,
./bugfix/all/stable/2.6.24.4.patch:-                    err = pskb_expand_head(e->skb, 0,
./bugfix/all/stable/2.6.24.4.patch:+                    nskb = skb_copy_expand(e->skb, 0,


I do not know precisely the process but I added the Debian Kernel
Team in Cc, so that they are aware of the issue, with a pointer to the
beginning of the thread: 

Archived-At: <http://permalink.gmane.org/gmane.linux.network/92426>

>From my understanding, I think that the Debian version of the 2.6.24 on
which I initially made my tests on was ok (pre-2.6.24.4). Then, I
updated it to a new 2.6.24-1 Debian version (so did Silviu), which
introduced the bug (it is in fact 2.6.24.4-based).

To sum it up, all post 2.6.24.4 kernels need the patch (2.6.24.4
included). This includes all 2.6.25.

Cheers,

a+


