From: "Aubrey Li" <aubreylee@gmail.com>
Subject: udp checksum issue in netpoll mode.
Date: Thu, 12 Apr 2007 18:31:30 +0800
Message-ID: <6d6a94c50704120331m36957148iae111ab7324c88c2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Linux Kernel" <linux-kernel@vger.kernel.org>
To: "Stephen Hemminger" <shemminger@osdl.org>,
	"Herbert Xu" <herbert@gondor.apana.org.au>,
	"Matt Mackall" <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.226]:8850 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945960AbXDLKbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2007 06:31:31 -0400
Received: by wr-out-0506.google.com with SMTP id 76so414922wra
        for <netdev@vger.kernel.org>; Thu, 12 Apr 2007 03:31:31 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I think we discussed this issue before.

The current checksum function doesn't consider the kind of packet
which is padded to reach a specific minimum length. I believe that's
the problem caused my test case failed. Is this issue fixed? Or is it
acceptable if I make a patch not calculating this kind of packet?

Thanks,
-Aubrey
===============================================
static __sum16 checksum_udp(struct sk_buff *skb, struct udphdr *uh,
                            unsigned short ulen, __be32 saddr, __be32 daddr)
{
        __wsum psum;

        if (uh->check == 0 || skb->ip_summed == CHECKSUM_UNNECESSARY)
                return 0;

        psum = csum_tcpudp_nofold(saddr, daddr, ulen, IPPROTO_UDP, 0);
        if (skb->ip_summed == CHECKSUM_COMPLETE &&
            !csum_fold(csum_add(psum, skb->csum)))
                return 0;

        skb->csum = psum;

        return __skb_checksum_complete(skb);
}
===============================================
