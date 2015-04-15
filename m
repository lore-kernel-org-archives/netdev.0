From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: ip_tunnel: Remove gratuitous skb scrubbing
Date: Wed, 15 Apr 2015 12:20:42 +0200
Message-ID: <552E3B7A.2040701@6wind.com>
References: <20150415100107.GA3655@gondor.apana.org.au>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:36193 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753817AbbDOKUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 06:20:46 -0400
Received: by wizk4 with SMTP id k4so148485409wiz.1
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2015 03:20:45 -0700 (PDT)
In-Reply-To: <20150415100107.GA3655@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/04/2015 12:01, Herbert Xu a =E9crit :
> The commit ea23192e8e577dfc51e0f4fc5ca113af334edff9 ("tunnels:
> harmonize cleanup done on skb on rx path") broke anyone trying to
> use netfilter marking across IPv4 tunnels.  As the commit message
> did not give any justification for this (in fact it shouldn't
> even be touching the tx path), I can only assume that it was a typo.
If I remember well, this was discussed on netdev (CC Eric). The goal of=
 this
patch was, like the title said, to hamonize packets processing in tunne=
ls.
I'm not against to keep the mark, but I think patching skb_scrub_packet=
 is
better. With your patch, ip6tnl, gre6, etc. still drops the mark. And a=
t the
end, it's not consistant.

What about something like this:

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3b6e5830256e..1d5f6bd0e383 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4124,14 +4124,15 @@ EXPORT_SYMBOL(skb_try_coalesce);
   */
  void skb_scrub_packet(struct sk_buff *skb, bool xnet)
  {
-	if (xnet)
+	if (xnet) {
  		skb_orphan(skb);
+		skb->mark =3D 0;
+	}
  	skb->tstamp.tv64 =3D 0;
  	skb->pkt_type =3D PACKET_HOST;
  	skb->skb_iif =3D 0;
  	skb->ignore_df =3D 0;
  	skb_dst_drop(skb);
-	skb->mark =3D 0;
  	skb_sender_cpu_clear(skb);
  	skb_init_secmark(skb);
  	secpath_reset(skb);
