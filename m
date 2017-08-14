From: Matthew Dawson <matthew@mjdsystems.ca>
Subject: Re: [PATCH net] datagram: When peeking datagrams with offset < 0 don't skip empty skbs
Date: Mon, 14 Aug 2017 10:05:08 -0400
Message-ID: <1846443.VTclhqQinN@ring00>
References: <20170814055259.31078-1-matthew@mjdsystems.ca> <1502702846.8411.25.camel@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart2336031.vSe0iiDFav"; micalg="pgp-sha256"; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org,
        "Macieira, Thiago" <thiago.macieira@intel.com>,
        willemdebruijn.kernel@gmail.com
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from scadrial.mjdsystems.ca ([198.100.154.185]:40199 "EHLO
        scadrial.mjdsystems.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751389AbdHNOFR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 10:05:17 -0400
In-Reply-To: <1502702846.8411.25.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart2336031.vSe0iiDFav
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="UTF-8"

On Monday, August 14, 2017 5:27:26 AM EDT Paolo Abeni wrote:
> On Mon, 2017-08-14 at 01:52 -0400, Matthew Dawson wrote:
> > Due to commit e6afc8ace6dd5cef5e812f26c72579da8806f5ac ("udp: remove
> > headers from UDP packets before queueing"), when udp packets are being
> > peeked the requested extra offset is always 0 as there is no need to skip
> > the udp header.  However, when the offset is 0 and the next skb is
> > of length 0, it is only returned once.  The behaviour can be seen with
> > the following python script:
> > 
> > #!/usr/bin/env python3
> > from socket import *;
> > f=socket(AF_INET6, SOCK_DGRAM | SOCK_NONBLOCK, 0);
> > g=socket(AF_INET6, SOCK_DGRAM | SOCK_NONBLOCK, 0);
> > f.bind(('::', 0));
> > addr=('::1', f.getsockname()[1]);
> > g.sendto(b'', addr)
> > g.sendto(b'b', addr)
> > print(f.recvfrom(10, MSG_PEEK));
> > print(f.recvfrom(10, MSG_PEEK));
> > 
> > Where the expected output should be the empty string twice.
> > 
> > Instead, make sk_peek_offset return negative values, and pass those values
> > to __skb_try_recv_datagram/__skb_try_recv_from_queue.  If the passed
> > offset
> > to __skb_try_recv_from_queue is negative, the checked skb is never
> > skipped.
> > After the call, the offset is set to 0 if negative to ensure all further
> > calculations are correct.
> > 
> > Also simplify the if condition in __skb_try_recv_from_queue.  If _off is
> > greater then 0, and off is greater then or equal to skb->len, then (_off
> > ||
> > skb->len) must always be true assuming skb->len >= 0 is always true.
> > 
> > Also remove a redundant check around a call to sk_peek_offset in
> > af_unix.c,
> > as it double checked if MSG_PEEK was set in the flags.
> > 
> > Signed-off-by: Matthew Dawson <matthew@mjdsystems.ca>
> > ---
> > 
> >  include/net/sock.h  | 4 +---
> >  net/core/datagram.c | 4 ++--
> >  net/ipv4/udp.c      | 4 ++++
> >  net/ipv6/udp.c      | 4 ++++
> >  net/unix/af_unix.c  | 8 +++++---
> >  5 files changed, 16 insertions(+), 8 deletions(-)
> > 
> > diff --git a/include/net/sock.h b/include/net/sock.h
> > index 7c0632c7e870..aeeec62992ca 100644
> > --- a/include/net/sock.h
> > +++ b/include/net/sock.h
> > @@ -507,9 +507,7 @@ int sk_set_peek_off(struct sock *sk, int val);
> > 
> >  static inline int sk_peek_offset(struct sock *sk, int flags)
> >  {
> >  
> >  	if (unlikely(flags & MSG_PEEK)) {
> > 
> > -		s32 off = READ_ONCE(sk->sk_peek_off);
> > -		if (off >= 0)
> > -			return off;
> > +		return READ_ONCE(sk->sk_peek_off);
> > 
> >  	}
> >  	
> >  	return 0;
> 
> You probably want/must also update sk_set_peek_off() to allow negative
> values, elsewhere this will break as soon as the user will do
> SOL_SOCKET/SO_PEEK_OFF.
I'm happy to do this either in this patch or as a second patch and make this a 
series, whatever the networking community prefers.

I'm actually surprised that only unix sockets can have negative values.  Is 
there a reason for that?  I had assumed that sk_set_peek_off would allow 
negative values as the code already has to support negative values due to what 
the initial value is.

> I'm wondering adding an explicit SOCK_PEEK_OFF/MSG_PEEK_OFF socket flag
> would help simplyifing the code: no need for negative offset; set such
> flag when SOL_SOCKET/SO_PEEK_OFF with a non negative value is called
> (and clear it when a negative value is used), forward such flag to
> __skb_try_recv_datagram/__skb_try_recv_from_queue and use it to select
> the proper peek behaviour.
The negative value is documented and supported for unix sockets, so I don't 
think we can just reject all negative values.  However, I do see a way to 
implement that while supporting user space sending negative values.  If that 
is preferred let me know and I'll see what I can make.

I assume that would make this patch target net-next?  Would it be possible to 
pull this into net so it can fix this regression for the next kernel release, 
while I work on getting the better solution finished?  I'm happy to to make 
__skb_try_recv_datagram/__skb_try_recv_from_queue accept the extra parameter 
so they don't see an offset less then 0 in this patch.

-- 
Matthew
--nextPart2336031.vSe0iiDFav
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEkRWwpe7qWxgM14Ep+0kv31Jtww0FAlmRrhQACgkQ+0kv31Jt
ww2z8A//WNPyp81tjLdhKtOnbCmq5E64zgaDFF5ySI17iJ+D0H6Bjo7vRtujSdkG
HOIRLt27j7sv11QNx4byNJxTmmodH22Gmixttf1+8RhIrAyUr8MaMnL/uy83obWU
wlgQYFToLzRKu03EsqFGAMpb1uLs61c5HKO5PyQMVHxcPrTEaZ56Xvwt9LVL2PtC
7++bdoQWjLeGe22I4l0VS2dQfxj5OufFbHpIkxforn4KXA1e35sA2kjaAywHuQSx
MHzjrxEHMGA63J4RtP1/HJig5mWamzKDUHaqjbFm/fwsF8+Q1wnJ9iPZdkdapwPu
G+ARU2qSGvXAOQLamjajCqOSbNO6llFea8WzCc76m3u64VW0y6Qn5R52NrLmqdaL
d5ZQvo84h6Y64hLVLYcPjMmdcXPv1odE0ns88H8Mnuw0YAd0BnkH2hfZm3gVipqi
xt+XUKcpJJ9fe/syY4vV+kTNjloZduzE6f5E+j3dEpQ+5bfUdRvGb1hVvZwFO1Dr
K84S78rp/fVY/x4pJOgIazpUaCUbqVfH1NASkwbPGRKKRXcIjqhASKI0Qf0T83KS
sKnV6Wd1f/m8PLnRi36vA+mVJv9vRjAJoab0QSjUoRJzmbYMU+3Y4Ph9L/g01E6E
+gp5jsEvIjV5wNTAlV50VcsfRGzWKNote1feGQNhBGI945DVqTc=
=tPyP
-----END PGP SIGNATURE-----

--nextPart2336031.vSe0iiDFav--
