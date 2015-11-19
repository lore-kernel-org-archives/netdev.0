From: Aaron Conole <aconole@redhat.com>
Subject: Re: [PATCH net-next] net: remove useless check in napi_gro_frags()
Date: Thu, 19 Nov 2015 16:06:40 -0500
Message-ID: <f7tfv01pulb.fsf@aconole.bos.csb>
References: <1447962170.22599.240.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151119195419.GA6728@ast-mbp.thefacebook.com>
	<1447964139.22599.246.camel@edumazet-glaptop2.roam.corp.google.com>
	<87oaepzqq2.fsf@nemi.mork.no>
	<1447965199.22599.252.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?Q?Bj=C3=B8rn?= Mork <bjorn@mork.no>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48020 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030227AbbKSVGl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 16:06:41 -0500
In-Reply-To: <1447965199.22599.252.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Thu, 19 Nov 2015 12:33:19 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Thu, 2015-11-19 at 21:20 +0100, Bj=C3=B8rn Mork wrote:
>> Eric Dumazet <eric.dumazet@gmail.com> writes:
>>=20
>> > How many times should we crash before napi_frags_skb() returns NUL=
L ?
>> ..
>> >                         return NULL;
>>=20
>> Huh?  Now I'm lost here, too.
>
>
> Well, Ethernet drivers should not feed GRO with frames with less than=
 14 bytes.
>
> ( eth_type_trans() would crash the same )
>
> Lets fix buggy drivers instead of adding defensive code all over the =
stack.
>
> napi_gro_frags() is used by exactly 10 drivers, and I am pretty sure
> they are OK.
>

Would the following be an appropriate change in addition to the one
you've posted, then? If so I can repost as a formal patch, if you'd
like. At present, there's only one user of napi_frags_skb(), and your
patch removes the NULL check. If this can really only be the result of
buggy driver, then perhaps we should just call out the bug?

diff --git a/net/core/dev.c b/net/core/dev.c
index 41cef3e..b71c8b4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4440,10 +4440,7 @@ static struct sk_buff *napi_frags_skb(struct nap=
i_struct *napi)
 	eth =3D skb_gro_header_fast(skb, 0);
 	if (unlikely(skb_gro_header_hard(skb, hlen))) {
 		eth =3D skb_gro_header_slow(skb, hlen, 0);
-		if (unlikely(!eth)) {
-			napi_reuse_skb(napi, skb);
-			return NULL;
-		}
+		BUG_ON(!eth);
 	} else {
 		gro_pull_from_frag0(skb, hlen);
 		NAPI_GRO_CB(skb)->frag0 +=3D hlen;
