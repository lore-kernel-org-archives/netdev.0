From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [REGRESSION, bisect]cxgb4 port failure with TSO traffic after
 commit 10d3be569243def8("tcp-tso: do not split TSO packets at retransmit
 time")
Date: Fri, 24 Jun 2016 09:25:07 -0700
Message-ID: <1466785507.6850.105.camel@edumazet-glaptop3.roam.corp.google.com>
References: <6DE8042992C3D3488ACEF3F2607097E3C4A81CA5@nice.asicdesigners.com>
	 <CANn89iLpBC5tUqpdSE4jCMKFgUi=mg=2kPZtMaRh-cnBhvauNg@mail.gmail.com>
	 <6DE8042992C3D3488ACEF3F2607097E3C4A82805@nice.asicdesigners.com>
	 <CANn89i+ePpSDYPtQeZa=fdN84=4WKdDb88P-dOVyPyY_DMK02g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hariprasad S <hariprasad@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>,
	Kumar A S <kumaras@chelsio.com>,
	Santosh Rastapur <santosh@chelsio.com>,
	Nirranjan Kirubaharan <nirranjan@chelsio.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"ycheng@google.com" <ycheng@google.com>
To: Eric Dumazet <edumazet@google.com>, "Arjun V." <arjun@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36848 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751585AbcFXQZL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 12:25:11 -0400
Received: by mail-wm0-f66.google.com with SMTP id c82so6290918wme.3
        for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 09:25:10 -0700 (PDT)
In-Reply-To: <CANn89i+ePpSDYPtQeZa=fdN84=4WKdDb88P-dOVyPyY_DMK02g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-06-24 at 07:25 -0700, Eric Dumazet wrote:
> Please do not top post on netdev mailing list
> 
> On Fri, Jun 24, 2016 at 4:38 AM, Arjun V. <arjun@chelsio.com> wrote:
> > Eric,
> > We are seeing skb's with length(skb->len) greater than 65536 coming into our ndo_start_xmit() callback routine.
> > We can add a check in our eth_xmit() routine to skip those packets, but it will be better if you fix this in kernel.
> >
> >
> > I have attached pcap file obtained from tcpdump. In the pcap file there are 2 such packets(I used tcpdump filter to extract out those packets).
> >
> > Let us know if you need anything else.
> >
> 
> Beats me really.
> 
> At retransmit time, we only can eventually reduce packet sizes
> (assuming GSO is used, because we might coalesce sub-mss packets in
> tcp_retrans_try_collapse())
> 
> So why are you seeing too big packets at retransmit, I really have no idea.
> 
> MIght be some bug related to MSS computation, overflowing somehow ?

Could you try this ?

Thanks !

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index d39e9e47a26e55ad2b8f775bf9ea9dfb5b12aee5..27013056bcfb9aa49601806bb3aa55a1ac664873 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1177,6 +1177,7 @@ int inet_sk_rebuild_header(struct sock *sk)
 
 		/* Routing failed... */
 		sk->sk_route_caps = 0;
+		sk->sk_gso_max_segs = 1;
 		/*
 		 * Other protocols have to map its equivalent state to TCP_SYN_SENT.
 		 * DCCP maps its DCCP_REQUESTING state to TCP_SYN_SENT. -acme
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 2076c21107d07e4e78a0a29f1d374c3414b8e1bd..ecc0281acfb702b138c68ac51e3a0518052785b0 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -685,6 +685,7 @@ int inet6_sk_rebuild_header(struct sock *sk)
 		dst = ip6_dst_lookup_flow(sk, &fl6, final_p);
 		if (IS_ERR(dst)) {
 			sk->sk_route_caps = 0;
+			sk->sk_gso_max_segs = 1;
 			sk->sk_err_soft = -PTR_ERR(dst);
 			return PTR_ERR(dst);
 		}
