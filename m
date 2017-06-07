From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Fw: [Bug 195969] New: ipsec icmp and udp works, tcp doesn't work
Date: Wed, 7 Jun 2017 07:50:39 +0200
Message-ID: <20170607055039.GT2631@secunet.com>
References: <20170606121439.6d24d7f0@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Herbert Xu <herbert@gondor.apana.org.au>, <netdev@vger.kernel.org>,
        <dev@djagoo.io>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:49860 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750730AbdFGFun (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Jun 2017 01:50:43 -0400
Content-Disposition: inline
In-Reply-To: <20170606121439.6d24d7f0@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc the reporter.

On Tue, Jun 06, 2017 at 12:14:39PM -0700, Stephen Hemminger wrote:
> 
> 
> Begin forwarded message:
> 
> Date: Sat, 03 Jun 2017 06:25:05 +0000
> From: bugzilla-daemon@bugzilla.kernel.org
> To: stephen@networkplumber.org
> Subject: [Bug 195969] New: ipsec icmp and udp works, tcp doesn't work
> 
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=195969
> 
>             Bug ID: 195969
>            Summary: ipsec icmp and udp works, tcp doesn't work
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 4.11.3-1-ARCH
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>           Assignee: stephen@networkplumber.org
>           Reporter: dev@djagoo.io
>         Regression: No
> 
> A few days ago I updated to 4.11.3-1-ARCH. After that my VPN access to our
> corporate network was broken.
> 
> The connection is established and I can use UDP (i.e. DNS) and ICMP. All TCP
> connections I tried (ssh, smb, http...) failed.

Is this with UDP encapsulation?

If so, you could try this patch:

Subject: [PATCH v4.11] esp4: Fix udpencap for local TCP packets.

Locally generated TCP packets are usually cloned, so we
do skb_cow_data() on this packets. After that we need to
reload the pointer to the esp header. On udpencap this
header has an offset to skb_transport_header, so take this
offset into account.

This is a backport of:
commit 0e78a87306a ("esp4: Fix udpencap for local TCP packets.")

Fixes: 67d349ed603 ("net/esp4: Fix invalid esph pointer crash")
Fixes: fca11ebde3f0 ("esp4: Reorganize esp_output")
Reported-by: Don Bowman <db@donbowman.ca>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/esp4.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index b1e2444..9708a32 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -212,6 +212,7 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	u8 *iv;
 	u8 *tail;
 	u8 *vaddr;
+	int esph_offset;
 	int blksize;
 	int clen;
 	int alen;
@@ -392,12 +393,14 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	}
 
 cow:
+	esph_offset = (unsigned char *)esph - skb_transport_header(skb);
+
 	err = skb_cow_data(skb, tailen, &trailer);
 	if (err < 0)
 		goto error;
 	nfrags = err;
 	tail = skb_tail_pointer(trailer);
-	esph = ip_esp_hdr(skb);
+	esph = (struct ip_esp_hdr *)(skb_transport_header(skb) + esph_offset);
 
 skip_cow:
 	esp_output_fill_trailer(tail, tfclen, plen, proto);
-- 
2.7.4
