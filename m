From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net-gro: restore frag0 optimization
Date: Mon, 31 Mar 2014 14:01:43 -0700
Message-ID: <1396299703.29410.71.camel@edumazet-glaptop2.roam.corp.google.com>
References: <53345A6C.5080008@redhat.com>
	 <1395940898.12610.307.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1396153701.29410.27.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140331.162747.1884094141150130320.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mschmidt@redhat.com, netdev@vger.kernel.org, edumazet@google.com,
	hkchu@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:59111 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751086AbaCaVBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 17:01:45 -0400
Received: by mail-pd0-f172.google.com with SMTP id p10so8503767pdj.17
        for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 14:01:45 -0700 (PDT)
In-Reply-To: <20140331.162747.1884094141150130320.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-31 at 16:27 -0400, David Miller wrote:

> Ok, applied, thanks for taking care of this Eric.
> 
> We can send to -stable after it's gotten a lot of testing and
> auditing.

Thanks David

BTW, I found a off-by-one error in skb_gro_header_hard()

TCP pure ACK packets always hit the 'slow' path, if I understand this
correctly.

I'll formally submit the following when I have tested it.


diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 775cc956ff78..7484d6f3d6cb 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1998,9 +1998,10 @@ static inline void *skb_gro_header_fast(struct sk_buff *skb,
 	return NAPI_GRO_CB(skb)->frag0 + offset;
 }
 
-static inline int skb_gro_header_hard(struct sk_buff *skb, unsigned int hlen)
+static inline bool skb_gro_header_hard(const struct sk_buff *skb,
+				       unsigned int hlen)
 {
-	return NAPI_GRO_CB(skb)->frag0_len < hlen;
+	return NAPI_GRO_CB(skb)->frag0_len <= hlen;
 }
 
 static inline void *skb_gro_header_slow(struct sk_buff *skb, unsigned int hlen,
