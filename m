From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [PATCH net-next v3 07/15] bpf: Add setsockopt helper function to bpf
Date: Wed, 21 Jun 2017 13:13:43 -0400
Message-ID: <CAEfhGizMrrAnjHwa8LFGxZWnkBT=dJKKUqL7Q7i71eTPjDjAQw@mail.gmail.com>
References: <20170620030048.3275347-1-brakmo@fb.com> <20170620030048.3275347-8-brakmo@fb.com>
 <CAEfhGiyi4xb6HmfUJmXxgvCUGmW6p37yoqVio=PcUn091hBUsA@mail.gmail.com> <02369759-BBB8-4B16-835A-D12A58526DFF@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>,
        Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>
To: Lawrence Brakmo <brakmo@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:34593 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751106AbdFURNw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 13:13:52 -0400
Received: by mail-qt0-f195.google.com with SMTP id o21so28213657qtb.1
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2017 10:13:51 -0700 (PDT)
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com. [209.85.220.182])
        by smtp.gmail.com with ESMTPSA id 51sm11724928qtq.20.2017.06.21.10.13.44
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 10:13:45 -0700 (PDT)
Received: by mail-qk0-f182.google.com with SMTP id d14so87818063qkb.1
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2017 10:13:44 -0700 (PDT)
In-Reply-To: <02369759-BBB8-4B16-835A-D12A58526DFF@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 21, 2017 at 12:51 PM, Lawrence Brakmo <brakmo@fb.com> wrote:
>
> On 6/20/17, 2:25 PM, "Craig Gallek" <kraigatgoog@gmail.com> wrote:
>
>     On Mon, Jun 19, 2017 at 11:00 PM, Lawrence Brakmo <brakmo@fb.com> wro=
te:
>     > Added support for calling a subset of socket setsockopts from
>     > BPF_PROG_TYPE_SOCK_OPS programs. The code was duplicated rather
>     > than making the changes to call the socket setsockopt function beca=
use
>     > the changes required would have been larger.
>     >
>     > @@ -2671,6 +2672,69 @@ static const struct bpf_func_proto bpf_get_s=
ocket_uid_proto =3D {
>     >         .arg1_type      =3D ARG_PTR_TO_CTX,
>     >  };
>     >
>     > +BPF_CALL_5(bpf_setsockopt, struct bpf_sock_ops_kern *, bpf_sock,
>     > +          int, level, int, optname, char *, optval, int, optlen)
>     > +{
>     > +       struct sock *sk =3D bpf_sock->sk;
>     > +       int ret =3D 0;
>     > +       int val;
>     > +
>     > +       if (bpf_sock->is_req_sock)
>     > +               return -EINVAL;
>     > +
>     > +       if (level =3D=3D SOL_SOCKET) {
>     > +               /* Only some socketops are supported */
>     > +               val =3D *((int *)optval);
>     > +
>     > +               switch (optname) {
>     > +               case SO_RCVBUF:
>     > +                       sk->sk_userlocks |=3D SOCK_RCVBUF_LOCK;
>     > +                       sk->sk_rcvbuf =3D max_t(int, val * 2, SOCK_=
MIN_RCVBUF);
>     > +                       break;
>     > +               case SO_SNDBUF:
>     > +                       sk->sk_userlocks |=3D SOCK_SNDBUF_LOCK;
>     > +                       sk->sk_sndbuf =3D max_t(int, val * 2, SOCK_=
MIN_SNDBUF);
>     > +                       break;
>     > +               case SO_MAX_PACING_RATE:
>     > +                       sk->sk_max_pacing_rate =3D val;
>     > +                       sk->sk_pacing_rate =3D min(sk->sk_pacing_ra=
te,
>     > +                                                sk->sk_max_pacing_=
rate);
>     > +                       break;
>     > +               case SO_PRIORITY:
>     > +                       sk->sk_priority =3D val;
>     > +                       break;
>     > +               case SO_RCVLOWAT:
>     > +                       if (val < 0)
>     > +                               val =3D INT_MAX;
>     > +                       sk->sk_rcvlowat =3D val ? : 1;
>     > +                       break;
>     > +               case SO_MARK:
>     > +                       sk->sk_mark =3D val;
>     > +                       break;
>
>     Isn't the socket lock required when manipulating these fields?  It's
>     not obvious that the lock is held from every bpf hook point that coul=
d
>     trigger this function...
>
> The sock_ops BPF programs are being called from within the network
> stack and my understanding is that  lock has already been taken.
> Currently they are only called:
> (1) after a packet is received, where there is the call to
> bh_lock_sock_nested() in tcp_v4_rcv() before calling
> tcp_v4_do_rcv().
> (2) in tcp_connect(), where there should be no issue
Someone who understands the TCP stack better than I should verify
this, but even if it's OK to do in these specific spots, it's not
unreasonable to believe that someone will add another socket-context
bpf hook in the future where it would not be safe.  Without some
additional check to prevent this setsockopt function from being called
in those spots, we could run into trouble.  The only other
socket-context point currently is the cgroup one, which happens during
socket creation and should also be safe.

> Just in case I added a check =E2=80=9Csock_owned_by_me(sk)=E2=80=9D in tc=
p_call_bpf()
> Do you think this is enough, or should I explicitly add a bh_lock_sock_ne=
sted
> in the bpf_setsockopt function?
Adding the check is certainly a way to test the behavior as
implemented, but this bpf function could be called by any
socket-context bpf (not just the tcp_call_bpf ones).  I believe the
current bpf hook points only guarantee RCU read-side lock.  Adding an
additional lock guarantee may have undesirable performance
implications.  If this is just for socket creation or other rare
events it's probably not a big deal, but if it's for a hook in the
fast path it's probably a non-starter.

I guess the higher level question is what should the locking
guarantees for socket-context bpf programs be?
