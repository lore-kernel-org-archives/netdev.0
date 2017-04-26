From: Alexander Potapenko <glider@google.com>
Subject: Re: [PATCH] ipv6: ensure message length for raw socket is at least sizeof(ipv6hdr)
Date: Wed, 26 Apr 2017 10:54:30 +0200
Message-ID: <CAG_fn=Xw-WTn4AsyNaaLMRaW1xqo1QOyp7JpYOW=z+hqpWdwLQ@mail.gmail.com>
References: <20170425131827.66498-1-glider@google.com> <20170425.135543.1706004185593424024.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Dmitriy Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        LKML <linux-kernel@vger.kernel.org>,
        Networking <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:36029 "EHLO
        mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1957246AbdDZIyc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 04:54:32 -0400
Received: by mail-qk0-f178.google.com with SMTP id u75so69035647qka.3
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 01:54:32 -0700 (PDT)
In-Reply-To: <20170425.135543.1706004185593424024.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 25, 2017 at 7:55 PM, David Miller <davem@davemloft.net> wrote:
> From: Alexander Potapenko <glider@google.com>
> Date: Tue, 25 Apr 2017 15:18:27 +0200
>
>> rawv6_send_hdrinc() expects that the buffer copied from the userspace
>> contains the IPv6 header, so if too few bytes are copied parts of the
>> header may remain uninitialized.
>>
>> This bug has been detected with KMSAN.
>>
>> Signed-off-by: Alexander Potapenko <glider@google.com>
>
> Hmmm, ipv4 seems to lack this check as well.
>
> I think we need to be careful here and fully understand why KMSAN doesn't
> seem to be triggering in the ipv4 case but for ipv6 it is before I apply
> this.
Maybe I just couldn't come up with a decent test case for ipv4 yet.
syzkaller generated the equivalent of the following program for ipv6:

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
#define _GNU_SOURCE

#include <netinet/in.h>
#include <string.h>
#include <sys/socket.h>
#include <error.h>

int main()
{
  int sock =3D socket(PF_INET6, SOCK_RAW, IPPROTO_RAW);
  struct sockaddr_in6 dest_addr;
  memset(&dest_addr, 0, sizeof(dest_addr));
  dest_addr.sin6_family =3D AF_INET6;
  inet_pton(AF_INET6, "ff00::", &dest_addr.sin6_addr);
  int err =3D sendto(sock, 0, 0, 0, &dest_addr, sizeof(dest_addr));
  if (err =3D=3D -1)
    perror("sendto");
  return 0;
}
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

I attempted to replace INET6 and such with INET and provide a legal
IPv4 address to inet_pton(), but couldn't trigger the warning.
> Thanks.



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
