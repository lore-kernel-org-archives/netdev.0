From: Aubrey <aubreylee@gmail.com>
Subject: Re: Netpoll checksum issue
Date: Mon, 24 Apr 2006 15:46:38 +0800
Message-ID: <6d6a94c50604240046gcdcefev1c9c390c83ee5f7@mail.gmail.com>
References: <6d6a94c50604190922m189b9d99gdd428a870e12c2c3@mail.gmail.com>
	 <20060419103153.64ef0054@localhost.localdomain>
	 <6d6a94c50604191854m73b241e3v104d713b7bb93674@mail.gmail.com>
	 <20060423113432.GA16424@gondor.apana.org.au>
	 <6d6a94c50604232242hd091922q8a2a0c78f1163b3c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Stephen Hemminger" <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.187]:34938 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751019AbWDXHqj convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Apr 2006 03:46:39 -0400
Received: by nproxy.gmail.com with SMTP id n29so694673nfc
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2006 00:46:38 -0700 (PDT)
To: "Herbert Xu" <herbert@gondor.apana.org.au>
In-Reply-To: <6d6a94c50604232242hd091922q8a2a0c78f1163b3c@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Herbert,

Things seem to be more clear for me.

When not in netpoll mode, before an udp package passed to "udp_rcv",
the ip layer will call the routine  "__skb_checksum_complete(skb);" 
to do the checksum. After ip checksum, "skb->ip_summed" will be
assigned to CHECKSUM_UNNECESSARY.
============================================================
unsigned int __skb_checksum_complete(struct sk_buff *skb)
{
        unsigned int sum;

        sum = (u16)csum_fold(skb_checksum(skb, 0, skb->len, skb->csum));
        if (likely(!sum)) {
                if (unlikely(skb->ip_summed == CHECKSUM_HW))
                        netdev_rx_csum_fault(skb->dev);
                skb->ip_summed = CHECKSUM_UNNECESSARY;
        }
        return sum;
}
============================================================
So, in the routine "udp_rcv", actually, the csum is not checked.
Consequently, udp has no problem in the non-netpoll mode.

When in the netpoll mode, ip checksum is implemented by the routine
"ip_fast_csum", which does not assgin CHECKSUM_UNNECESSARY to
"skb->ip_summed", so udp has to  check sum. Although checksum_udp in
the netpoll mode uses the same method  as non-netpoll mode(see below),
it failed still.
============================
       skb->csum = csum_tcpudp_nofold(saddr, daddr, ulen, IPPROTO_UDP, 0);
       return __skb_checksum_complete(skb);
============================
So, Is the udp checksum algorithm wrong? or should we add one line
------------------------------
skb->ip_summed = CHECKSUM_UNNECESSARY;
------------------------------
after/into the routine "ip_fast_csum"?

Regards,
-Aubrey
