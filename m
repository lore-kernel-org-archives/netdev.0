From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] udp: must lock the socket in udp_disconnect()
Date: Thu, 20 Oct 2016 18:12:45 -0700
Message-ID: <CAM_iQpVG-L=ZCDnOpDjpyDWuyPFY378JbQ5qhu9_bhzOGc9BuQ@mail.gmail.com>
References: <31cb3583-5620-de3f-784d-300df3fda0a4@gmail.com>
 <CAM_iQpVExpqdOXZp0Lw+4Nr2_9W24P2dQFdM=EoYwBkHtwDoPw@mail.gmail.com>
 <05f766db-4a8c-933e-9d73-6daada21f491@gmail.com> <1476944754.7065.3.camel@edumazet-glaptop3.roam.corp.google.com>
 <1476981580.7065.15.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Baozeng Ding <sploving1@gmail.com>,
        David Miller <davem@davemloft.net>,
        network dev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33675 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752618AbcJUBNG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 21:13:06 -0400
Received: by mail-it0-f67.google.com with SMTP id k64so8851809itb.0
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 18:13:06 -0700 (PDT)
In-Reply-To: <1476981580.7065.15.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 20, 2016 at 9:39 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Baozeng Ding reported KASAN traces showing uses after free in
> udp_lib_get_port() and other related UDP functions.
>
> A CONFIG_DEBUG_PAGEALLOC=y kernel would eventually crash.
>
> I could write a reproducer with two threads doing :
>
> static int sock_fd;
> static void *thr1(void *arg)
> {
>         for (;;) {
>                 connect(sock_fd, (const struct sockaddr *)arg,
>                         sizeof(struct sockaddr_in));
>         }
> }
>
> static void *thr2(void *arg)
> {
>         struct sockaddr_in unspec;
>
>         for (;;) {
>                 memset(&unspec, 0, sizeof(unspec));
>                 connect(sock_fd, (const struct sockaddr *)&unspec,
>                         sizeof(unspec));
>         }
> }
>
> Problem is that udp_disconnect() could run without holding socket lock,
> and this was causing list corruptions.

If this is the cause of the hashlist corruption (I am still unsure about this),
then why only UDP? Don't all of those using ip4_datagram_connect()
as ->connect() and using udp_disconnect() as ->disconnect() need this fix?

For example, after your patch,

        .connect =      ip4_datagram_connect,
-       .disconnect =   udp_disconnect,
+       .disconnect =   __udp_disconnect,

Ping socket still doesn't have sock lock for ->disconnect() but has it for
->connect()? I must miss something...
