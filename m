From: Benjamin LaHaise <bcrl@redhat.com>
Subject: [patch] bug prematurely setting nr_frags
Date: Fri, 9 Aug 2002 16:14:39 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020809161439.E10640@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-netdev@oss.sgi.com>
To: davem@redhat.com, netdev@oss.sgi.com
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

Hello Dave et al,

The patch below fixes a case where nr_frags will be incorrectly set when an 
allocation fails in sock_alloc_send_pskb.  This bug was found while trying 
to track down a problem that shows up as an oops attempting to free a page 
that comes from an uninitialized fragment entry in an skb, and this problem 
looks like a possible causes.  Thanks goes to Stephen Tweedie for digging 
through the crash dump to find several key bits of data.

		-ben
-- 
"You will be reincarnated as a toad; and you will be much happier."

:r ~/patches/v2.4/v2.4.20-pre1-nr_frags.diff
diff -urN v2.4.20-pre1/net/core/sock.c net-2.4.20-pre1/net/core/sock.c
--- v2.4.20-pre1/net/core/sock.c	Fri Aug  9 13:50:46 2002
+++ net-2.4.20-pre1/net/core/sock.c	Fri Aug  9 15:46:46 2002
@@ -785,7 +785,6 @@
 
 				npages = (data_len + (PAGE_SIZE - 1)) >> PAGE_SHIFT;
 				skb->truesize += data_len;
-				skb_shinfo(skb)->nr_frags = npages;
 				for (i = 0; i < npages; i++) {
 					struct page *page;
 					skb_frag_t *frag;
@@ -804,6 +803,9 @@
 						      PAGE_SIZE :
 						      data_len);
 					data_len -= PAGE_SIZE;
+
+					/* frag[i] is now initialized */
+					skb_shinfo(skb)->nr_frags = i + 1;
 				}
 
 				/* Full success... */
