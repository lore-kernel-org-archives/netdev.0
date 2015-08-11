From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: Re: ipv6_mc_check_mld - kernel BUG at net/core/skbuff.c:1128
Date: Tue, 11 Aug 2015 23:47:25 +0200
Message-ID: <20150811214725.GE4402@odroid>
References: <CAMUH3-WBobHryNpxYUzuAr4bPBFkd=QFkWgOoLyGiVf6Qvx0Ww@mail.gmail.com>
 <20150811205140.GD4402@odroid>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.passe0815.de ([188.40.49.9]:47267 "EHLO mail.passe0815.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753292AbbHKVr2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Aug 2015 17:47:28 -0400
Received: from mail.passe0815.de (localhost [127.0.0.1])
	by mail.passe0815.de (Postfix) with ESMTP id C06FA586A15
	for <netdev@vger.kernel.org>; Tue, 11 Aug 2015 23:47:26 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20150811205140.GD4402@odroid>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 11, 2015 at 10:51:40PM +0200, Linus L=C3=BCssing wrote:
> On Mon, Aug 10, 2015 at 02:56:12PM -0700, Brenden Blanco wrote:
> > Doing some code reading with Alexei, we found a suspect commit, whi=
ch
> > introduces an skb_get and skb_may_pull of the same skb, which leads=
 to the BUG
> > when skb->len =3D=3D len.
>=20
> Urgh, didn't know that pskb_may_pull() doesn't like an skb with a
> reference count greater than one... But yes, the BUG() call in
> skbuff.c:1128 / pskb_expand_head() says that (though in this case
> the BUG() in skbuff.c call actually seems kinda weird (/"wrong"?), as
> it isn't shared between different code paths).

The more I think about it, I'm tending to remove the BUG() call in
pskb_expand_head() as in this case it obviously isn't a bug.

The skb_get() allows a simple and in my opinion easy to read cleanup
part of skb_trimmed for any caller of ip{v6,}_mc_check_mld(). No need
to check whether skb =3D=3D skb_trimmed for a caller for instance,
simply checking whether skb_trimmed exists is enough.


Any objections to remove the "if (skb_shared(skb)) BUG()" part in
pskb_expand_head()? Or would there be any other undesired side
effects in utilising skb_get() like that?

Cheers, Linus
