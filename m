From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [Bug #14301] WARNING: at net/ipv4/af_inet.c:154
Date: Wed, 07 Oct 2009 17:41:50 +0200
Message-ID: <4ACCB6BE.5040602@gmail.com>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <COE24pZSBH.A.mdH.sMTxKB@chimera> <4AC70D20.4060009@gmail.com> <4AC710DF.5070705@gmail.com> <4AC78F7C.40908@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Ralf Hildebrandt <Ralf.Hildebrandt-jq1tPX9l7E6ELgA04lAiVw@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Wei Yongjun <yjwei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Takahiro Yasui <tyasui-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Hideo Aoki <haoki-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4AC78F7C.40908-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Eric Dumazet a =C3=A9crit :
> Eric Dumazet a =C3=A9crit :
>> Eric Dumazet a =C3=A9crit :
>>> Rafael J. Wysocki a =C3=A9crit :
>>>> This message has been generated automatically as a part of a repor=
t
>>>> of regressions introduced between 2.6.30 and 2.6.31.
>>>>
>>>> The following bug entry is on the current list of known regression=
s
>>>> introduced between 2.6.30 and 2.6.31.  Please verify if it still s=
hould
>>>> be listed and let me know (either way).
>>>>
>>>>
>>>> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14301
>>>> Subject		: WARNING: at net/ipv4/af_inet.c:154
>>>> Submitter	: Ralf Hildebrandt <Ralf.Hildebrandt-jq1tPX9l7E6ELgA04lAiVw@public.gmane.org>
>>>> Date		: 2009-09-30 12:24 (2 days old)
>>>> References	: http://marc.info/?l=3Dlinux-kernel&m=3D12543135021813=
7&w=3D4
>>>>
>=20
> Investigation still needed...
>=20

OK, my last (buggy ???) feeling is about commit 95766fff6b9a78d1

[UDP]: Add memory accounting.

(Its a two years old patch, oh well...)

Problem is the udp_poll() :

We check the first frame to be dequeued from sk_receive_queue has a goo=
d checksum.

If it doesnt, we drop the frame ( calling kfree_skb(skb); )

Problem is now we perform memory accounting on UDP, this kfree_skb()
should be done with socket locked, but we are allowed to
call lock_sock() from this udp_poll() context

unsigned int udp_poll(struct file *file, struct socket *sock, poll_tabl=
e *wait)
{
        unsigned int mask =3D datagram_poll(file, sock, wait);
        struct sock *sk =3D sock->sk;
        int     is_lite =3D IS_UDPLITE(sk);

        /* Check for false positives due to checksum errors */
        if ((mask & POLLRDNORM) &&
            !(file->f_flags & O_NONBLOCK) &&
            !(sk->sk_shutdown & RCV_SHUTDOWN)) {
                struct sk_buff_head *rcvq =3D &sk->sk_receive_queue;
                struct sk_buff *skb;

                spin_lock_bh(&rcvq->lock);
                while ((skb =3D skb_peek(rcvq)) !=3D NULL &&
                       udp_lib_checksum_complete(skb)) {
                        UDP_INC_STATS_BH(sock_net(sk),
                                        UDP_MIB_INERRORS, is_lite);
                        __skb_unlink(skb, rcvq);
<<HERE>>                kfree_skb(skb);
                }
                spin_unlock_bh(&rcvq->lock);



David, Herbert, any idea how to solve this problem ?

1) Allow false positives

Or

2) Maybe we should finally convert sk_forward_alloc to an atomic_t afte=
r all...
   This would make things easier, and speedup UDP (no more need to lock=
_sock())

Or=20

3) ???
