From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] ip_fragment:kernel may panic when replay big packet with
 RST flag
Date: Sat, 26 Mar 2011 21:36:15 +0800
Message-ID: <AANLkTimOzYG4Weh7wanYfU_qBM4tJDPz+zJZQx_H-vn0@mail.gmail.com>
References: <AANLkTikoSxVd3kTggsCGpjXz-5CFuVNxjnpuZNgWd3eV@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Feng Gao <kernel.goter@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTikoSxVd3kTggsCGpjXz-5CFuVNxjnpuZNgWd3eV@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 23, 2011 at 6:49 PM, Feng Gao <kernel.goter@gmail.com> wrot=
e:
> Hello everyone:
>
> PC(A)-linux(B)-PC(C)
> computer(linux B) with two net interface,eth0 and eth1.
> PC(A) send syn to PC(C) =A0though linux B.
> then PC(C) replay a big packet =A0with RST flag(use tcpsic or other t=
ools).
>
> This RST packet(1480) come in from eth0(mtu 1500) and go out from
> eth1(mtu 700), so this RST packet should fragment.
>
> BUT in tcp_packet func: if the connection has no reply packet,and
> receive the RST packet.ip_conntrack should =A0destroy.
> =A0if (!test_bit(IPS_SEEN_REPLY_BIT, &ct->status)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* If only reply is a RST, we can cons=
ider ourselves not to
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 have an established connection: t=
his is a fairly common
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 problem case, so we can delete th=
e conntrack
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 immediately. =A0--RR */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (th->rst) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nf_ct_kill_acct(ct, ct=
info, skb);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NF_ACCEPT;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
>
> BUT the skb->nfct is not set NULL in func nf_ct_kill_acct.
> so when this RST packet goto ip_fragment,ip_fragment call nf_copy, in
> __nf_copy func
> the fragment skb->nfct point to the destory mem.
> dst->nfct =3D src->nfct;
> nf_conntrack_get(src->nfct);
>
> SO finally.kfree_skb call destroy_conntrack again. this may result in
> LINUX B kernel panic.
>
>

Have you ever tested that? I am afraid no panic will happen.
nf_ct_kill_acct() just drops the reference owned by the corresponding
timeout timer to the ct if the timer is installed, so the skb still
has the reference to the ct after nf_ct_kill_acct() returns. Thanks.

BTW: all the patches related to netfilter should be sent to the
netfilter developer mailing list.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
