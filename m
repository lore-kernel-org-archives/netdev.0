From: Dave Taht <dave.taht@gmail.com>
Subject: Re: tc filter mask for ACK packets off?
Date: Tue, 3 Jan 2012 10:36:41 +0100
Message-ID: <CAA93jw5NYChp+hKWjOWiw7SnGhNe+REofr2KM-85GnKNVpkw6w@mail.gmail.com>
References: <1325385056.4174.51.camel@denise.theartistscloset.com>
	<21734335.uCtjXOcSpA@alaris>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"John A. Sullivan III" <jsullivan@opensourcedevel.com>
To: =?UTF-8?Q?Michal_Kube=C4=8Dek?= <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:52111 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752082Ab2ACJgm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 04:36:42 -0500
Received: by iaeh11 with SMTP id h11so30624703iae.19
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2012 01:36:42 -0800 (PST)
In-Reply-To: <21734335.uCtjXOcSpA@alaris>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 3, 2012 at 8:31 AM, Michal Kube=C4=8Dek <mkubecek@suse.cz> =
wrote:
> On Saturday 31 of December 2011 21:30EN, John A. Sullivan III wrote:
>> Hello, all. =C2=A0I've been noticing that virtually all the document=
ation
>> says we should prioritize ACK only packets and that they can be
>> identified with match u8 0x10 0xff. =C2=A0However, isn't the actual =
flag

Most of that invalid documentation was derived from the original
'wondershaper' effort, and became 'canon', elsewhere.

I'm hoping that we get a chance to correct the documentation
on the new wiki and remove the old, incorrect info from the web...

wshaper's (2001) assumptions were gradually invalidated over the
years. It was a suitable shaper for a 200k-800k download link
at the time, when web sites were 70k in size, and people still
used things like ssh heavily, men were men, and javascript
scarce....

Good follow on work was the esfq and adsl-shaper efforts,
but these publications have also been obsoleted by events.

ESFQ's core features got incorporated in sfq, and adsl-shaper
sort of made it in, genericaly.

The stories of those two shaping efforts are useful bits of history
worth reading about, to gain context about the problems they
were trying to solve.

>> field only 6 bits longs and the first two belong to a previous 6 bit
>> reserved field?
>i
> It's even worse, those two bits are in fact used for ECN (RFC 3168).

I had submitted a patch to openwrt to fix this issue with wondershaper
a while back. I don't know if it got taken up or not...

and either way, wshaper's approach doesn't work well on
modern bandwidths. The core idea (prioritizing small acks
somewhat) retains some value, but the implementation is
unworkable.

>> If that is true, if ever those bits are set, our filters will
>> unnecessarily break. =C2=A0Shouldn't it be match u8 0x10 0x3f?
>
> I think so.

Yes, the old-style, 'canonical', filters break ECN, and have
been breaking it everywhere for a decade.

Also: most, TCP's timestamp so the ack size is larger.

And alas... none of the shapers mentioned above do ipv6 properly.

There are innumerable other limitations... notably prioritizing
dns, syn, synack also can help. They are unable to detect or
prioritize voip packets (sip or skype), either.

> However, by a "ACK only" packet (worth prioritizing), I would rather
> understand a packet with ACK flag without any payload, not a packet w=
ith
> ACK as the only flag. For many TCP connections, all packets except
> initial SYN and SYN-ACK and two FIN packets have ACK as the only flag=
=2E
> So my guess is you should rather prioritize all TCP packets with no
> application layer data.

No. :)

I'd go into more detail, but after what I hope are the final two
fixes to sfq and qfq land in the net-next kernel (after some more
testing), I like to think I have a more valid approach than this
in the works, but that too will require some more development
and testing.

http://www.teklibre.com/~d/bloat/pfifo_fast_vs_sfq_qfq_linear.png

If you are interested in seeing that work in progress

git clone git://github.com/dtaht/deBloat.git

see the src/staqfq.lua script for a start at a general purpose new
age shaper...

and src/qmodels/*4mbit* for some prototypes of a 'soft bandwidth'
one.

(regrettably net-next + some patches is required at present)

I note that (as of yesterday) sfq is performing as well as qfq did
under most workloads, and is considerably simpler than qfq, but
what I have in mind for shaping in a asymmetric scenario
*may* involve 'weighting' - rather than strictly prioritizing -
small acks... and it may not - I'd like to be able to benchmark
the various AQM approaches against a variety of workloads
before declaring victory. Could use some help with all that....

>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Michal Kubecek
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml



--=20
Dave T=C3=A4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
