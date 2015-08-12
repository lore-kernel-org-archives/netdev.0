From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: ipv6_mc_check_mld - kernel BUG at net/core/skbuff.c:1128
Date: Tue, 11 Aug 2015 17:51:10 -0700
Message-ID: <20150812005107.GA58159@Alexeis-MacBook-Pro.local>
References: <CAMUH3-WBobHryNpxYUzuAr4bPBFkd=QFkWgOoLyGiVf6Qvx0Ww@mail.gmail.com>
 <20150811205140.GD4402@odroid>
 <20150811214725.GE4402@odroid>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Brenden Blanco <bblanco@plumgrid.com>, netdev@vger.kernel.org
To: Linus =?iso-8859-1?Q?L=FCssing?= <linus.luessing@c0d3.blue>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:35169 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932485AbbHLAvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 20:51:13 -0400
Received: by igbjg10 with SMTP id jg10so33485069igb.0
        for <netdev@vger.kernel.org>; Tue, 11 Aug 2015 17:51:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150811214725.GE4402@odroid>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 11, 2015 at 11:47:25PM +0200, Linus L=FCssing wrote:
> On Tue, Aug 11, 2015 at 10:51:40PM +0200, Linus L=FCssing wrote:
> > On Mon, Aug 10, 2015 at 02:56:12PM -0700, Brenden Blanco wrote:
> > > Doing some code reading with Alexei, we found a suspect commit, w=
hich
> > > introduces an skb_get and skb_may_pull of the same skb, which lea=
ds to the BUG
> > > when skb->len =3D=3D len.
> >=20
> > Urgh, didn't know that pskb_may_pull() doesn't like an skb with a
> > reference count greater than one... But yes, the BUG() call in
> > skbuff.c:1128 / pskb_expand_head() says that (though in this case
> > the BUG() in skbuff.c call actually seems kinda weird (/"wrong"?), =
as
> > it isn't shared between different code paths).
>=20
> The more I think about it, I'm tending to remove the BUG() call in
> pskb_expand_head() as in this case it obviously isn't a bug.
>=20
> The skb_get() allows a simple and in my opinion easy to read cleanup
> part of skb_trimmed for any caller of ip{v6,}_mc_check_mld(). No need
> to check whether skb =3D=3D skb_trimmed for a caller for instance,
> simply checking whether skb_trimmed exists is enough.
>=20
>=20
> Any objections to remove the "if (skb_shared(skb)) BUG()" part in
> pskb_expand_head()? Or would there be any other undesired side
> effects in utilising skb_get() like that?

That fundamental check was there for 10+ years and cannot be removed.
bridge already did skb_share_check() before reaching this
__ipv6_mc_check_mld() path.
There is no reason to do skb_get() there.
It wasn't there before commit 9afd85c9e4552 which claims to do:
'Some small refactoring was done to enhance readibility',
but doing skb_get()+pskb_may_pull() which is incorrect.
Avoiding unnecessary skb_clone() is a good thing, but it should be
done without messing with skb->users, since this code path
already owns skb.
