From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 27742] New: PPP over SSH tunnel triggers OOPS
Date: Fri, 28 Jan 2011 14:55:38 -0800 (PST)
Message-ID: <20110128.145538.179934184.davem@davemloft.net>
References: <bug-27742-10286@https.bugzilla.kernel.org/>
	<20110128143238.446e1821.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, ktk@bigfoot.com, paulus@samba.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45671
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752101Ab1A1WzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jan 2011 17:55:04 -0500
In-Reply-To: <20110128143238.446e1821.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Fri, 28 Jan 2011 14:32:38 -0800

>> skb_over_panic: text:c12a354f len:847 put:847 head:f57e8c00 data:f57e8c00 tail:0xf57e8f4f end:0xf57e8e80 dev:<NULL>
>> kernel BUG at net/core/skbuff.c:127!
...
>> Pid: 0, comm: swapper Not tainted 2.6.37 #1 0KH290/OptiPlex GX620
>> EIP: 0060:[<c1330110>] EFLAGS: 00010282 CPU: 0
>> EIP is at skb_put+0x82/0x84
...
>> Call Trace:
>>  [<c12a354f>] ? ppp_xmit_process+0x45a/0x4e6
>>  [<c12a354f>] ? ppp_xmit_process+0x45a/0x4e6
>>  [<c1390a0a>] ? tcp_manip_pkt+0xad/0xcb
>>  [<c12a36d4>] ? ppp_start_xmit+0xf9/0x175

I took a quick look at this, I can surmise that we have a packet we
are trying to compress (that's the only way I see in the
ppp_xmit_process() code paths that we can get an skb_put() call so
large).

And we can see from the skb_over_panic message that we have an SKB
which was allocated with 640 bytes of space, but we are trying to
"put" 847 bytes into it which is too large and overflows.

Can you run with the following debugging patch and see what it prints
out when this happens?

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 9f6d670..06c6ea7 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -1093,6 +1093,15 @@ pad_compress_skb(struct ppp *ppp, struct sk_buff *skb)
 	if (len > 0 && (ppp->flags & SC_CCP_UP)) {
 		kfree_skb(skb);
 		skb = new_skb;
+#if 1
+		if (len > (skb->end - skb->tail)) {
+			printk(KERN_ERR "pad_compress_skb: Compression overflow ["
+			       "new_skb_size(%d) compressor_skb_size(%d) "
+			       "hard_header_len(%d) len(%d)]\n",
+			       new_skb_size, compressor_skb_size,
+			       ppp->dev->hard_header_len, len);
+		}
+#endif
 		skb_put(skb, len);
 		skb_pull(skb, 2);	/* pull off A/C bytes */
 	} else if (len == 0) {
@@ -1179,6 +1188,9 @@ ppp_send_frame(struct ppp *ppp, struct sk_buff *skb)
 			/* didn't compress */
 			kfree_skb(new_skb);
 		} else {
+#if 1
+			unsigned int orig_skb_len = skb->len;
+#endif
 			if (cp[0] & SL_TYPE_COMPRESSED_TCP) {
 				proto = PPP_VJC_COMP;
 				cp[0] &= ~SL_TYPE_COMPRESSED_TCP;
@@ -1188,6 +1200,13 @@ ppp_send_frame(struct ppp *ppp, struct sk_buff *skb)
 			}
 			kfree_skb(skb);
 			skb = new_skb;
+#if 1
+			if (len > (skb->end - skb->tail)) {
+				printk(KERN_ERR "slhc_compress_skb: Compression overflow ["
+				       "skb->len(%u) hard_header_len(%d) len(%d)]\n",
+				       orig_skb_len, ppp->dev->hard_header_len, len);
+			}
+#endif
 			cp = skb_put(skb, len + 2);
 			cp[0] = 0;
 			cp[1] = proto;
