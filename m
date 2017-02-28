From: Alexander Potapenko <glider@google.com>
Subject: Re: [PATCH] net: don't call strlen() on the user buffer in packet_bind_spkt()
Date: Tue, 28 Feb 2017 14:47:37 +0100
Message-ID: <CAG_fn=V2J_dp+bASVdkLTnx1jQDHSda4pzQyVGBRHH-NBQHEgg@mail.gmail.com>
References: <20170228131759.110380-1-glider@google.com> <1488288789.9415.249.camel@edumazet-glaptop3.roam.corp.google.com>
 <1488289373.9415.251.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Dmitriy Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1488289373.9415.251.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 28, 2017 at 2:42 PM, Eric Dumazet <eric.dumazet@gmail.com> wrot=
e:
> On Tue, 2017-02-28 at 05:33 -0800, Eric Dumazet wrote:
>
>> It looks a bug in this implementation of strlcpy() then.
>>
>
> Apparently strlcpy(dest, src, size)  returns strlen(src), so we can not
> use it in this context.
Good point.
>> sizeof(name) is 15.
>>
>> If you use strncpy(X, uaddr->sa_data, 15) , then you might access
>> uaddr->sa_data[14] and this would still be wrong, since sa_data has 14
>> bytes only :
>>
>>
>> struct sockaddr {
>>   sa_family_t sa_family;
>>   char        sa_data[14];
>> };
>
>
> Maybe then :
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 2bd0d1949312c3d71c4b33529316dcfe76fa28f1..d2e7caa79d2604363316c7316=
864bed1f4971d29 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -3103,7 +3103,7 @@ static int packet_bind_spkt(struct socket *sock, st=
ruct sockaddr *uaddr,
>                             int addr_len)
>  {
>         struct sock *sk =3D sock->sk;
> -       char name[15];
> +       char name[sizeof(uaddr->sa_data) + 1];
>
>         /*
>          *      Check legality
> @@ -3111,7 +3111,8 @@ static int packet_bind_spkt(struct socket *sock, st=
ruct sockaddr *uaddr,
>
>         if (addr_len !=3D sizeof(struct sockaddr))
>                 return -EINVAL;
> -       strlcpy(name, uaddr->sa_data, sizeof(name));
> +       memcpy(name, uaddr->sa_data, sizeof(uaddr->sa_data));
> +       name[sizeof(uaddr->sa_data)] =3D 0;
>
>         return packet_do_bind(sk, name, 0, pkt_sk(sk)->num);
>  }
>
SGTM. Shall I send the updated patch? (Sorry for asking, the patch
culture is hard)
>



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
