From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH 3/4 v2 net-next] net: make GRO aware of skb->head_frag
Date: Tue, 01 May 2012 15:58:28 -0700
Message-ID: <4FA06A94.8050704@intel.com>
References: <1335523026.2775.236.camel@edumazet-glaptop>  <1335809434.2296.9.camel@edumazet-glaptop> <4F9F21E2.3080407@intel.com>  <1335835677.11396.5.camel@edumazet-glaptop>  <CAKgT0UdeVvJe6k5OitkKgujSw3SQSOvtQ84KrPch8xdd=5ub1A@mail.gmail.com>  <1335854378.11396.26.camel@edumazet-glaptop>  <4FA00C9F.8080409@intel.com> <1335891892.22133.23.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Ben Hutchings <bhutchings@solarflare.com>,
	=?UTF-8?B?SWxwbyBKw6RydmluZW4=?= <ilpo.jarvinen@helsinki.fi>,
	=?UTF-8?B?TWFjaWVqIMW7ZW5jenlrb3dza2k=?= <maze@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:39535 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756176Ab2EAW6t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2012 18:58:49 -0400
In-Reply-To: <1335891892.22133.23.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/01/2012 10:04 AM, Eric Dumazet wrote:
> On Tue, 2012-05-01 at 09:17 -0700, Alexander Duyck wrote:
>> On 04/30/2012 11:39 PM, Eric Dumazet wrote:
>>> On Mon, 2012-04-30 at 22:33 -0700, Alexander Duyck wrote:
>>>
>>>> The question I had was more specific to GRO.  As long as we have
>>>> skb->users =3D=3D 1 and the skb isn't cloned we should be fine.   =
It just
>>>> hadn't occurred to me before that napi_gro_receive had the extra
>>>> requirement that the skb couldn't be cloned.
>>>>
>>> OK
>>>
>>> By the way, even if skb was cloned, we would be allowed to steal
>>> skb->head.
>>>
>>> When we clone an oskb we :
>>>
>>> 1) allocate a struct nskb sk_buff (or use the shadow in case of TCP=
)
>>> 2) increment dataref
>> The problem I have is with this piece right here.  So you increment
>> dataref.  Now you have an skb that is still pointing to the shared i=
nfo
>> on this page and dataref is 2.  What about the side that is stealing=
 the
>> head?  Is it going to be tracking the dataref as well and decrementi=
ng
>> it before put_page or does it just assume that dataref is 1 and call
>> put_page directly?  I am guessing the latter since I didn't see anyt=
hing
>> that allowed for tracking the dataref of stolen heads.
> The only changed thing is the kfree() replaced by put_page()
>
> This kfree() was done when last reference to dataref was released.
>
> If we had a problem before, we have same problem after my patch.
>
> Truth is : In TCP (coalesce and splice()) and GRO, we owns skbs.
>
> (See the various __kfree_skb(skb) calls in net/ipv4/tcp_input.c
> There is one exception in ipv6 / treq->pktopts ) but its for SYN pack=
et
> and this wont be merged with a previous packet.
Eric,

I think I have found a bug, although it is not specific to this patch
but it is related.  It looks like the TCP coalesce code is causing
tcpdump to fail when using frags.  Based on the comments in the patch I
am assuming you have an ixgbe adapter to test with as that is what I
reproduced this on.  To reproduce the issue all you need to do is run
"tcpdump -i ethX > /dev/null" on one console, and on a second console
run a netperf TCP_MAERTS test to some other server.  Tcpdump will exit
out with a message about bad address like this:

tcpdump: verbose output suppressed, use -v or -vv for full protocol dec=
ode
listening on eth1, link-type EN10MB (Ethernet), capture size 96 bytes
tcpdump: pcap_loop: recvfrom: Bad address
682 packets captured
2357 packets received by filter
1543 packets dropped by kernel


A bisect of the issue tracked it down to:

1402d366019fedaa2b024f2bac06b7cc9a8782e1 is first bad commit
commit 1402d366019fedaa2b024f2bac06b7cc9a8782e1
Author: Eric Dumazet <edumazet@google.com>
Date:   Mon Apr 23 07:11:42 2012 +0000

    tcp: introduce tcp_try_coalesce
   =20
    commit c8628155ece3 (tcp: reduce out_of_order memory use) took care=
 of
    coalescing tcp segments provided by legacy devices (linear skbs)
   =20
    We extend this idea to fragged skbs, as their truesize can be heavy=
=2E
   =20
    ixgbe for example uses 256+1024+PAGE_SIZE/2 =3D 3328 bytes per segm=
ent.
   =20
    Use this coalescing strategy for receive queue too.
   =20
    This contributes to reduce number of tcp collapses, at minimal cost=
, and
    reduces memory overhead and packets drops.
   =20
    Signed-off-by: Eric Dumazet <edumazet@google.com>
    Cc: Neal Cardwell <ncardwell@google.com>
    Cc: Tom Herbert <therbert@google.com>
    Cc: Maciej =C3=85=C2=BBenczykowski <maze@google.com>
    Cc: Ilpo J=C3=83=C2=A4rvinen <ilpo.jarvinen@helsinki.fi>
    Acked-by: Neal Cardwell <ncardwell@google.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

:040000 040000 8ca3e0b4e6c6a8f375fd800069d24203880623f3 2576d34c5c9cfc7=
17a11e2ebe054143956716b93 M	net

I suspect we are dealing with either a shared or cloned skb in this
case, though I haven't verified which it is yet.

Thanks,

Alex
