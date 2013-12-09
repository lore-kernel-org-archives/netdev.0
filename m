From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net-gro: Prepare GRO stack for the upcoming
 tunneling support
Date: Sun, 08 Dec 2013 19:04:23 -0800
Message-ID: <1386558263.30495.311.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386518682-30488-1-git-send-email-hkchu@google.com>
	 <1386531839.30495.296.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAPshTCiv1HxL9pRg3vp7pAOtdOOKoMVRQ4w8acq3aMga07NRig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:43820 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760097Ab3LIDEZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 22:04:25 -0500
Received: by mail-pd0-f175.google.com with SMTP id w10so4304182pde.6
        for <netdev@vger.kernel.org>; Sun, 08 Dec 2013 19:04:24 -0800 (PST)
In-Reply-To: <CAPshTCiv1HxL9pRg3vp7pAOtdOOKoMVRQ4w8acq3aMga07NRig@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-12-09 at 10:48 +0800, Jerry Chu wrote:

> Not sure why ingress qdisc - it seems that qdisc_pkt_len_init() is only called
> by the egress path (__dev_xmit_skb())
> .

Yeah, Qdisc was meant to be used for egress.

Then to get qdisc for ingress, we use IFB to reinject packets through
the qdisc layer.

Sample of script :

ETH=eth0
IFB=ifb0
RTT_HALF=50ms
REORDER=1500us

modprobe ifb
ip link set dev $IFB up

tc qdisc add dev $ETH ingress 2>/dev/null

tc filter add dev $ETH parent ffff: \
   protocol ip u32 match u32 0 0 flowid 1:1 action mirred egress \
   redirect dev $IFB

tc qdisc del dev $IFB root 2>/dev/null
tc qdisc add dev $IFB root netem limit 100000 delay $RTT_HALF $REORDER 



> Strange why is it the business of *netif_receive_skb*() to set the
> transport header
> before IP has a chance to parse the IP hdr?
> 

Maybe you should use git blame ;)
