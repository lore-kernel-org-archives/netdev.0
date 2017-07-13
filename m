From: Alexander Potapenko <glider@google.com>
Subject: Re: [PATCH] sctp: don't dereference ptr before leaving _sctp_walk_{params,errors}()
Date: Thu, 13 Jul 2017 21:28:39 +0200
Message-ID: <CAG_fn=VJQUG1RveUyXDVuZmMrBz3DZLrar3pEKKJegyi3mYbaA@mail.gmail.com>
References: <20170713181034.41123-1-glider@google.com> <20170713.113206.177363709000549854.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Dmitriy Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        lucien xin <lucien.xin@gmail.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Networking <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170713.113206.177363709000549854.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 13, 2017 at 8:32 PM, David Miller <davem@davemloft.net> wrote:
> From: Alexander Potapenko <glider@google.com>
> Date: Thu, 13 Jul 2017 20:10:34 +0200
>
>> diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
>> index a9519a06a23b..f13632ee33f0 100644
>> --- a/include/net/sctp/sctp.h
>> +++ b/include/net/sctp/sctp.h
>> @@ -469,6 +469,7 @@ _sctp_walk_params((pos), (chunk), ntohs((chunk)->chu=
nk_hdr.length), member)
>>
>>  #define _sctp_walk_params(pos, chunk, end, member)\
>>  for (pos.v =3D chunk->member;\
>> +     pos.v < (void *)chunk + end &&\
>>       pos.v <=3D (void *)chunk + end - ntohs(pos.p->length) &&\
>>       ntohs(pos.p->length) >=3D sizeof(struct sctp_paramhdr);\
>>       pos.v +=3D SCTP_PAD4(ntohs(pos.p->length)))
>> @@ -479,6 +480,7 @@ _sctp_walk_errors((err), (chunk_hdr), ntohs((chunk_h=
dr)->length))
>>  #define _sctp_walk_errors(err, chunk_hdr, end)\
>>  for (err =3D (sctp_errhdr_t *)((void *)chunk_hdr + \
>>           sizeof(struct sctp_chunkhdr));\
>> +     (void *)err <=3D (void *)chunk_hdr + end &&\
>>       (void *)err <=3D (void *)chunk_hdr + end - ntohs(err->length) &&\
>>       ntohs(err->length) >=3D sizeof(sctp_errhdr_t); \
>>       err =3D (sctp_errhdr_t *)((void *)err + SCTP_PAD4(ntohs(err->lengt=
h))))
>
> Even with the "err < ..." fixed in the second hunk, I still think you nee=
d
> to tweak these checks some more.
>
> What is necessary is that the first two members of sctp_paramhdr or
> sctp_errhdr are in the range ptr to end.
>
> struct sctp_paramhdr {
>         __be16 type;
>         __be16 length;
> };
>
> typedef struct sctp_errhdr {
>         __be16 cause;
>         __be16 length;
>         __u8  variable[0];
> } sctp_errhdr_t;
>
> so that we can legally dereference ->length.
>
> But that is not what your new check is doing.  Your new check is only
> making sure there is at least one byte there.
>
> I guess it's not easy to write a clean test that doesn't hardcode the
> offset of the length field and it's size.
>
> Something like:
>
>         pos.v + offsetof(pos.v, length) + sizeof(pos.v->length) <=3D (voi=
d *) chunk + end

Do we need to bother about truncated structures? Shouldn't it be
enough to check that there's at least sizeof(struct sctp_paramhdr)
bytes left then?
> and
>
>         (void *)err + offsetof(err, length) + sizeof(err->length) <=3D (v=
oid *) chunk_hdr + end
>
> And yeah, that isn't exactly concise nor pretty...



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
