From: Alexey Zaytsev <alexey.zaytsev@gmail.com>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison overwritten
Date: Mon, 4 Jul 2011 15:48:31 +0400
Message-ID: <CAB9v_DG7e8vDE+4PDwuOR2DYG1FEvUM1fxa+e4a=swwTYGJ9nQ@mail.gmail.com>
References: <bug-38102-10286@https.bugzilla.kernel.org/>
	<20110629145135.5179fb0c.akpm@linux-foundation.org>
	<BANLkTi=PxH8V58k-VycsM=1ZiE9hPqCN4Q@mail.gmail.com>
	<CAB9v_DHXB6n07sEY_=HZ8S4zMO01Vs8B78dGyEWrm-hyRP82XA@mail.gmail.com>
	<1309707971.2523.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	Gary Zambrano <zambrano@broadcom.com>,
	bugme-daemon@bugzilla.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Pekka Pietikainen <pp@ee.oulu.fi>,
	Florian Schirmer <jolt@tuxbox.org>,
	Felix Fietkau <nbd@openwrt.org>, Michael Buesch <mb@bu3sch.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:42676 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750778Ab1GDLsc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2011 07:48:32 -0400
Received: by vws1 with SMTP id 1so3563144vws.19
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2011 04:48:32 -0700 (PDT)
In-Reply-To: <1309707971.2523.20.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 3, 2011 at 19:46, Eric Dumazet <eric.dumazet@gmail.com> wro=
te:
> Le dimanche 03 juillet 2011 =C3=A0 01:25 +0400, Alexey Zaytsev a =C3=A9=
crit :
>> On Fri, Jul 1, 2011 at 10:01, Alexey Zaytsev <alexey.zaytsev@gmail.c=
om> wrote:
>> > On Thu, Jun 30, 2011 at 01:51, Andrew Morton <akpm@linux-foundatio=
n.org> wrote:
>> >>
>> >> (switched to email. =C2=A0Please respond via emailed reply-to-all=
, not via the
>> >> bugzilla web interface).
>> >>
>> >> On Thu, 23 Jun 2011 17:33:54 GMT
>> >> bugzilla-daemon@bugzilla.kernel.org wrote:
>> >>
>> >>> https://bugzilla.kernel.org/show_bug.cgi?id=3D38102
>> >>>
>> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Summary: BUG kmalloc-20=
48: Poison overwritten
>> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Product: Drivers
>> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Version: 2.5
>> >>> =C2=A0 =C2=A0 Kernel Version: 3.0.0-rc4
>> >>
>> >> Looks like a 2.6.38->2.6.39 regression, perhaps a memory scribble=
 in b44.
>> >
>> > Actually, not sure about the version. 39 was the first one I've be=
en
>> > using in the scenario. Checking older versions now.
>> > And git-log does not show a lot of changes to the b44 driver, so i=
t
>> > might be something unrelated.
>> >
>>
>> I've checked back as far as 2.6.27, and the problem is still there.
>> I've also looked through the allocation-related code, and it seemed
>> sane. I'm not sure I understand the 1GB dma workaround, but this pat=
h
>> is never hit in my case. So adding the driver authors to CC. This
>> could be something different, but I've been unable to reproduce usin=
g
>> an other machine with an rtl8139 nic.
>
> Hmm, looking at b44 code, I believe there is a race there.
>
> Could you try following patch ?
>

This might fix a potential problem, but unfortunately did not help here=
=2E

There is an other place that looks suspicious to me:

 812                         struct sk_buff *copy_skb;
 813
 814                         b44_recycle_rx(bp, cons, bp->rx_prod);
 815                         copy_skb =3D netdev_alloc_skb(bp->dev, len=
 + 2);
 816                         if (copy_skb =3D=3D NULL)
 817                                 goto drop_it_no_recycle;
 818
 819                         skb_reserve(copy_skb, 2);
 820                         skb_put(copy_skb, len);
 821                         /* DMA sync done above, copy just the
actual packet */
 822                         skb_copy_from_linear_data_offset(skb,
RX_PKT_OFFSET,
 823
copy_skb->data, len);
 824                         skb =3D copy_skb;


The skb is reinserted into the ring before its data is copied, it
seems. But this can't be the cause of my problem, as it would lead to
data corruption at most, not a write-after-free.

And an other question. Why so we have the logic to work-around the 1Gb
DMA limit instead of just setting the dma mask?
