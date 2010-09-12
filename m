From: Plamen Petrov <pvp-lsts-s6OjJRe3oxUfI6EYonfoRA@public.gmane.org>
Subject: Re: [Bug #16626] Machine hangs with EIP at skb_copy_and_csum_dev
Date: Sun, 12 Sep 2010 09:55:19 +0300
Message-ID: <4C8C7957.7080207@fs.uni-ruse.bg>
References: <1283672983.3402.38.camel@edumazet-laptop> <20100908062004.GA6280@ff.dom.local> <20100908.103256.112592448.davem@davemloft.net> <201009082221.16356.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org,
	kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201009082221.16356.rjw-KKrjLPT3xs0@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=D0=9D=D0=B0 08.9.2010 =D0=B3. 23:21, Rafael J. Wysocki =D0=BD=D0=B0=D0=
=BF=D0=B8=D1=81=D0=B0:
> On Wednesday, September 08, 2010, David Miller wrote:
>> From: Jarek Poplawski<jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> Date: Wed, 8 Sep 2010 06:20:04 +0000
>>
>>> We need both of them. I hope David could add this too:
>>>
>>> Tested-by: Plamen Petrov<pvp-lsts-s6OjJRe3oxUfI6EYonfoRA@public.gmane.org>
>>
>> Done, and applied, thanks :-)
>
> Please kindly let me know when Linus gets them, so that I can close t=
he bug.
>
> Rafael

Now that both commits that fix my problems are in Linus' tree, the
bug can be closed, but these fixes should go in 2.6.35.y, too.
So, CCing -stable.

=46ix 1:
> commit	3d3be4333fdf6faa080947b331a6a19bce1a4f57
>
> gro: fix different skb headrooms
>
> Packets entering GRO might have different headrooms, even for a given
> flow (because of implementation details in drivers, like copybreak).
> We cant force drivers to deliver packets with a fixed headroom.
>
> 1) fix skb_segment()
>
> skb_segment() makes the false assumption headrooms of fragments are s=
ame
> than the head. When CHECKSUM_PARTIAL is used, this can give csum_star=
t
> errors, and crash later in skb_copy_and_csum_dev()
>
> 2) allocate a minimal skb for head of frag_list
>
> skb_gro_receive() uses netdev_alloc_skb(headroom + skb_gro_offset(p))=
 to
> allocate a fresh skb. This adds NET_SKB_PAD to a padding already
> provided by netdevice, depending on various things, like copybreak.
>
> Use alloc_skb() to allocate an exact padding, to reduce cache line
> needs:
> NET_SKB_PAD + NET_IP_ALIGN
>
> bugzilla : https://bugzilla.kernel.org/show_bug.cgi?id=3D16626
>
> Many thanks to Plamen Petrov, testing many debugging patches !
> With help of Jarek Poplawski.
>
> Reported-by: Plamen Petrov <pvp-lsts-s6OjJRe3oxUfI6EYonfoRA@public.gmane.org>
> Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> CC: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

=46ix 2:
> commit	64289c8e6851bca0e589e064c9a5c9fbd6ae5dd4
>
> gro: Re-fix different skb headrooms
>
> The patch: "gro: fix different skb headrooms" in its part:
> "2) allocate a minimal skb for head of frag_list" is buggy. The copie=
d
> skb has p->data set at the ip header at the moment, and skb_gro_offse=
t
> is the length of ip + tcp headers. So, after the change the length of
> mac header is skipped. Later skb_set_mac_header() sets it into the
> NET_SKB_PAD area (if it's long enough) and ip header is misaligned at
> NET_SKB_PAD + NET_IP_ALIGN offset. There is no reason to assume the
> original skb was wrongly allocated, so let's copy it as it was.
>
> bugzilla : https://bugzilla.kernel.org/show_bug.cgi?id=3D16626
> fixes commit: 3d3be4333fdf6faa080947b331a6a19bce1a4f57
>
> Reported-by: Plamen Petrov <pvp-lsts-s6OjJRe3oxUfI6EYonfoRA@public.gmane.org>
> Signed-off-by: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> CC: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Acked-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Tested-by: Plamen Petrov <pvp-lsts-s6OjJRe3oxUfI6EYonfoRA@public.gmane.org>
> Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

Thanks,
Plamen
