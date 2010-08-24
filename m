From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 16626] New: Machine hangs with EIP at
 skb_copy_and_csum_dev
Date: Tue, 24 Aug 2010 21:19:59 +0200
Message-ID: <1282677599.2467.54.camel@edumazet-laptop>
References: <20100820193835.GA6025@del.dom.local>
	 <20100821074742.GA2367@del.dom.local>
	 <1282377058.2636.12.camel@edumazet-laptop>
	 <20100821080735.GA2409@del.dom.local> <4C725FCB.2000304@fs.uni-ruse.bg>
	 <20100823124736.GA16966@ff.dom.local>
	 <1282568443.2486.34.camel@edumazet-laptop>
	 <20100823131056.GA19160@ff.dom.local> <4C727B06.2060002@fs.uni-ruse.bg>
	 <4C72802D.8090405@fs.uni-ruse.bg> <20100823141437.GA2282@del.dom.local>
	 <4C734FB5.1090702@fs.uni-ruse.bg>
	 <1282626102.2378.1351.camel@edumazet-laptop>
	 <4C738636.4000107@fs.uni-ruse.bg> <4C73C8DF.4060601@fs.uni-ruse.bg>
	 <1282662532.2477.248.camel@edumazet-laptop>
	 <courier.4C74007C.00000EE4@fs.ru.acad.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:53669 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752376Ab0HXTUE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 15:20:04 -0400
Received: by wwe15 with SMTP id 15so2316490wwe.1
        for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 12:20:03 -0700 (PDT)
In-Reply-To: <courier.4C74007C.00000EE4@fs.ru.acad.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 24 ao=C3=BBt 2010 =C3=A0 20:25 +0300, Plamen Petrov a =C3=A9cr=
it :
> Above patch applied, and happy to report the machine now spits data
> in the logs instead of oopsing. Here is what we have now:=20
> [  707.276981] ---[ end trace 75e4f8534893c910 ]---
> [  707.376998] 100: csum_start 306, offset 16, headroom 390, headlen =
70,=20
> len 70
> [  707.477015] nr_frags=3D0 gso_size=3D0
> [  707.577031]
> [ 1021.032794] ---[ end trace 75e4f8534893c911 ]---
> [ 1021.132812] 100: csum_start 306, offset 16, headroom 390, headlen =
153,=20
> len 153
> [ 1021.232828] nr_frags=3D0 gso_size=3D0
> [ 1021.332844]=20
>=20

Thanks !

csum_offset =3D 16.

so its offsetof(struct tcphdr, check)

maybe a bug in net/ipv4/netfilter/nf_nat_helper.c ?

We should trace all spots where we set csum_start/csum_offset

Or/And trace the skb content.

Please add a :

print_hex_dump(KERN_ERR, "skb data:", DUMP_PREFIX_OFFSET,=20
               16, 1, skb->head, skb_end_pointer(skb)-skb->head,true);


call in skb_csum_start_bug(), right after the pr_err("\n") and before
the "return 1;"


int skb_csum_start_bug(const struct sk_buff *skb, int pos)
{

        if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL) {
                long csstart;

                csstart =3D skb->csum_start - skb_headroom(skb);
                if (WARN_ON(csstart > skb_headlen(skb))) {
                        int i;

                        pr_err("%d: csum_start %u, offset %u, headroom =
%d, headlen %d, len %d\n",
                                   pos, skb->csum_start, skb->csum_offs=
et, skb_headroom(skb),
                                   skb_headlen(skb), skb->len);
                        pr_err("nr_frags=3D%u gso_size=3D%u ",
                                        skb_shinfo(skb)->nr_frags,
                                        skb_shinfo(skb)->gso_size);
                        for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i+=
+) {
                                pr_err("frag_size=3D%u ", skb_shinfo(sk=
b)->frags[i].size);
                        }
                        pr_err("\n");
                        print_hex_dump(KERN_ERR, "skb data:", DUMP_PREF=
IX_OFFSET,
                                16, 1, skb->head, skb_end_pointer(skb) =
- skb->head, true);
                        return 1;
                }
        }
        return 0;
}


