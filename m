From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV6: eliminating magic number for sizeof(struct frag_hdr)
 (Re: [PATCH] IPV6: fix payload length of reassembled packet)
Date: Thu, 12 Jun 2003 02:39:19 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030612.023919.126807101.yoshfuji@linux-ipv6.org>
References: <20030612.020716.37975763.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.44.0306112014560.2321-100000@netcore.fi>
	<20030612.022753.56899094.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, pekkas@netcore.fi, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20030612.022753.56899094.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030612.022753.56899094.yoshfuji@linux-ipv6.org> (at Thu, 12 Jun 2003 02:27:53 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> > s/8/sizeof(struct frag_hdr)/ ?
> 
> Yes, sizeof(struct frag_hdr). 
> I, however, use 8 for now to focus on the bug itself.
> (We have more "8"s there which should be substituted.)

s/8/sizeof(struct frag_hdr)/;
please apply this on top of the original patch.
Thanks.

--- linux-2.5+fix/net/ipv6/reassembly.c	Thu Jun 12 02:33:42 2003
+++ linux-2.5+fix+edited/net/ipv6/reassembly.c	Thu Jun 12 02:34:27 2003
@@ -596,7 +596,7 @@
 	BUG_TRAP(FRAG6_CB(head)->offset == 0);
 
 	/* Unfragmented part is taken from the first segment. */
-	payload_len = (head->data - head->nh.raw) - sizeof(struct ipv6hdr) + fq->len - 8;
+	payload_len = (head->data - head->nh.raw) - sizeof(struct ipv6hdr) + fq->len - sizeof(struct frag_hdr);
 	if (payload_len > 65535)
 		goto out_oversize;
 
@@ -631,9 +631,10 @@
 	 * header in order to calculate ICV correctly. */
 	nhoff = fq->nhoffset;
 	head->nh.raw[nhoff] = head->h.raw[0];
-	memmove(head->head+8, head->head, (head->data-head->head)-8);
-	head->mac.raw += 8;
-	head->nh.raw += 8;
+	memmove(head->head + sizeof(struct frag_hdr), head->head, 
+		(head->data - head->head) - sizeof(struct frag_hdr));
+	head->mac.raw += sizeof(struct frag_hdr);
+	head->nh.raw += sizeof(struct frag_hdr);
 
 	skb_shinfo(head)->frag_list = head->next;
 	head->h.raw = head->data;


-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
