From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [BUGS] [CHECKER] 99 synchronization bugs and a lock summary
 database
Date: Fri, 02 Jul 2004 17:47:53 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040702.174753.93406678.yoshfuji@linux-ipv6.org>
References: <Pine.LNX.4.44.0407011747040.4015-100000@kaki.stanford.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, yxie@cs.stanford.edu
In-Reply-To: <Pine.LNX.4.44.0407011747040.4015-100000@kaki.stanford.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

In article <Pine.LNX.4.44.0407011747040.4015-100000@kaki.stanford.edu> (at Thu, 1 Jul 2004 18:01:00 -0700 (PDT)), Yichen Xie <yxie@cs.stanford.edu> says:

>     http://glide.stanford.edu/linux-lock/err1.html (69 errors)
:
> err1.html consists of potential double locks/unlocks. Acquiring a lock
> twice in a row may result in a system hang, and releasing a lock more than
> once with certain mutex functions (e.g. up) may cause critical section
> violations.

Well,
lapb_iface.c:lapb_unregister() has typo and we failed to get lapb_list_lock.
rose_route.c:rose_remove_node()'s caller has rose_node_list_lock; so, this is 
dead lock.

Here's the fix.

===== net/lapb/lapb_iface.c 1.14 vs edited =====
--- 1.14/net/lapb/lapb_iface.c	2004-01-11 08:39:04 +09:00
+++ edited/net/lapb/lapb_iface.c	2004-07-02 17:23:27 +09:00
@@ -176,7 +176,7 @@
 	struct lapb_cb *lapb;
 	int rc = LAPB_BADTOKEN;
 
-	write_unlock_bh(&lapb_list_lock);
+	write_lock_bh(&lapb_list_lock);
 	lapb = __lapb_devtostruct(dev);
 	if (!lapb)
 		goto out;
===== net/rose/rose_route.c 1.12 vs edited =====
--- 1.12/net/rose/rose_route.c	2004-06-04 09:11:24 +09:00
+++ edited/net/rose/rose_route.c	2004-07-02 17:26:08 +09:00
@@ -206,7 +206,6 @@
 {
 	struct rose_node *s;
 
-	spin_lock_bh(&rose_node_list_lock);
 	if ((s = rose_node_list) == rose_node) {
 		rose_node_list = rose_node->next;
 		kfree(rose_node);

Thanks.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
