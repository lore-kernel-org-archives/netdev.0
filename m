From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] skbuff: Fix skb checksum flag on skb pull
Date: Wed, 30 Dec 2015 13:05:45 -0500
Message-ID: <1451498745.8255.35.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1442951873-4803-1-git-send-email-pshelar@nicira.com>
	 <20150924.140931.1967362456389755405.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org,
	Willem de Bruijn <willemdebruijn.kernel@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33019 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276AbbL3SFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 13:05:47 -0500
Received: by mail-pa0-f44.google.com with SMTP id cy9so141301435pac.0
        for <netdev@vger.kernel.org>; Wed, 30 Dec 2015 10:05:47 -0800 (PST)
In-Reply-To: <20150924.140931.1967362456389755405.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-09-24 at 14:09 -0700, David Miller wrote:
> From: Pravin B Shelar <pshelar@nicira.com>
> Date: Tue, 22 Sep 2015 12:57:53 -0700
> 
> > VXLAN device can receive skb with checksum partial. But the checksum
> > offset could be in outer header which is pulled on receive. This results
> > in negative checksum offset for the skb. Such skb can cause the assert
> > failure in skb_checksum_help(). Following patch fixes the bug by setting
> > checksum-none while pulling outer header.
> > 
> > Following is the kernel panic msg from old kernel hitting the bug.
>  ...
> > Reported-by: Anupam Chanda <achanda@vmware.com>
> > Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> 
> Applied, thanks.


It looks like we also should clear skb->csum ?

__skb_checksum_complete() definitely would be confused by garbage in
skb->csum

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 6b6bd42d6134..43e6f6163e07 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2799,8 +2799,10 @@ static inline void skb_postpull_rcsum(struct sk_buff *skb,
 	if (skb->ip_summed == CHECKSUM_COMPLETE)
 		skb->csum = csum_sub(skb->csum, csum_partial(start, len, 0));
 	else if (skb->ip_summed == CHECKSUM_PARTIAL &&
-		 skb_checksum_start_offset(skb) < 0)
+		 skb_checksum_start_offset(skb) < 0) {
 		skb->ip_summed = CHECKSUM_NONE;
+		skb->csum = 0;
+	}
 }
 
 unsigned char *skb_pull_rcsum(struct sk_buff *skb, unsigned int len);
