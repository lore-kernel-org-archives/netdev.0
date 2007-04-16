From: "Aubrey Li" <aubreylee@gmail.com>
Subject: Re: udp checksum issue in netpoll mode.
Date: Mon, 16 Apr 2007 18:02:09 +0800
Message-ID: <6d6a94c50704160302n14f8bf14l3c9f2a380f74dd3f@mail.gmail.com>
References: <6d6a94c50704120331m36957148iae111ab7324c88c2@mail.gmail.com>
	 <461E470B.5060907@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>,
	"Matt Mackall" <mpm@selenic.com>, netdev@vger.kernel.org,
	"Linux Kernel" <linux-kernel@vger.kernel.org>
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.237]:10860 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751878AbXDPKCL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 06:02:11 -0400
Received: by wr-out-0506.google.com with SMTP id 76so1467074wra
        for <netdev@vger.kernel.org>; Mon, 16 Apr 2007 03:02:10 -0700 (PDT)
In-Reply-To: <461E470B.5060907@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/12/07, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> Aubrey Li wrote:
> > I think we discussed this issue before.
> >
> > The current checksum function doesn't consider the kind of packet
> > which is padded to reach a specific minimum length. I believe that's
> > the problem caused my test case failed. Is this issue fixed? Or is it
> > acceptable if I make a patch not calculating this kind of packet?
> >
> > Thanks,
> > -Aubrey
> The caller should be trimming the packet and updating the hardware checksum
> value (like the normal UDP path).
>
OK, the following patch fixed the problem.

Signed-off-by: Aubrey.Li <aubreylee@gmail.com>
---
 net/core/netpoll.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 823215d..522e441 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -471,6 +471,13 @@ int __netpoll_rx(struct sk_buff *skb)
 	if (skb->len < len || len < iph->ihl*4)
 		goto out;

+	/*
+	 * Our transport medium may have padded the buffer out.
+	 * Now We trim to the true length of the frame.
+	 */
+	if (pskb_trim_rcsum(skb, len))
+		goto out;
+
 	if (iph->protocol != IPPROTO_UDP)
 		goto out;

-- 
1.5.1
