From: =?ISO-8859-1?Q?Cl=E9ment_Lecigne?= <clemun@gmail.com>
Subject: Re: [PATCH] netrom: fix info leak via getsockname()
Date: Mon, 15 Oct 2012 09:46:59 +0200
Message-ID: <CAKSJdAD-hFwHOnpWkCaW5bz68p-iK3nsA8FZEVFu5a9tog4cQg@mail.gmail.com>
References: <CAKSJdACRs5r9bbr=VS25YoQGYyhZDCyejftC+tg6yeeaNMnErg@mail.gmail.com>
	<1350256293.26833.28.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:42173 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750722Ab2JOHrA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2012 03:47:00 -0400
Received: by mail-wi0-f178.google.com with SMTP id hr7so1705290wib.1
        for <netdev@vger.kernel.org>; Mon, 15 Oct 2012 00:46:59 -0700 (PDT)
In-Reply-To: <1350256293.26833.28.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben, thanks for your reply, I fixed the indentation and I addressed
the possible leak in nr_listen() too. Here is the patch.

Signed-off-by: Clement Lecigne <clemun@gmail.com>
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -408,7 +408,7 @@ static int nr_listen(struct socket *sock, int backl=
og)

        lock_sock(sk);
        if (sk->sk_state !=3D TCP_LISTEN) {
-               memset(&nr_sk(sk)->user_addr, 0, AX25_ADDR_LEN);
+               memset(&nr_sk(sk)->user_addr, 0, sizeof(nr_sk(sk)->user=
_addr));
                sk->sk_max_ack_backlog =3D backlog;
                sk->sk_state           =3D TCP_LISTEN;
                release_sock(sk);
@@ -838,6 +838,8 @@ static int nr_getname(struct socket *sock, struct
sockaddr *uaddr,
        struct sock *sk =3D sock->sk;
        struct nr_sock *nr =3D nr_sk(sk);

+       memset(sax, 0, sizeof(struct sockaddr_ax25));
+
        lock_sock(sk);
        if (peer !=3D 0) {
                if (sk->sk_state !=3D TCP_ESTABLISHED) {

2012/10/15 Ben Hutchings <bhutchings@solarflare.com>:
> On Sun, 2012-10-14 at 20:23 +0200, Cl=E9ment Lecigne wrote:
>> The following patch fixes a 3 bytes info leak via getsockname() on
>> AF_NETROM socket.
>>
>> Details:
>>
>> typedef struct {
>>       char            ax25_call[7];   /* 6 call + SSID (shifted asci=
i!) */
>> } ax25_address;
>>
>> struct sockaddr_ax25 {
>>       __kernel_sa_family_t sax25_family;
>>       ax25_address    sax25_call;
>>       int             sax25_ndigis;
>>       /* Digipeater ax25_address sets follow */
>> };
>>
>> After compilation, gcc will add 3 padding bytes after sax25_call to
>> align sax25_ndigis and nr_getname does not clear these padding bytes
>> before returning to userland, poc attached.
>>
>> Signed-off-by: Clement Lecigne <clemun@gmail.com>
>>
>> --- a/net/netrom/af_netrom.c
>> +++ b/net/netrom/af_netrom.c
>> @@ -838,6 +838,8 @@ static int nr_getname(struct socket *sock, struc=
t
>> sockaddr *uaddr,
>>         struct sock *sk =3D sock->sk;
>>         struct nr_sock *nr =3D nr_sk(sk);
>>
>> +    memset(sax, 0, sizeof(struct sockaddr_ax25));
>
> This is not indented correctly.
>
>>         lock_sock(sk);
>>         if (peer !=3D 0) {
>>                 if (sk->sk_state !=3D TCP_ESTABLISHED) {
>
> On some architectures, structures have a minimum alignment of 4, so
> there are 2 bytes of padding before sax25_call and 1 byte within it.
> nr_getname() copies complete ax25_address structures, but nr_listen()
> does not initialise the 1 byte of padding in user_addr:
>
>                 memset(&nr_sk(sk)->user_addr, 0, AX25_ADDR_LEN);
>
> So I think you should address that too.  It appears that other
> ax25_address structures are originally copied from userland and
> therefore don't leak information, but I'm not sure.
>
> Ben.
>
> --
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
