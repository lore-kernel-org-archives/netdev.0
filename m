From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/sctp: recursive locking in sctp_do_peeloff
Date: Wed, 15 Mar 2017 11:19:38 -0700
Message-ID: <CAM_iQpVY3QOdvCOsinJ=v2CF1M0c+XV2o80ec=qDyithuqeACw@mail.gmail.com>
References: <CACT4Y+ZHGC6VNJUANgSdZnCfLQrRKtsQ-Dbn6goHScj=pq7xog@mail.gmail.com>
 <CAFSqH7xrmH2Bgq3Xckgb3mkj7j1qkApemEYOq3jbQEtj+TTEpQ@mail.gmail.com>
 <CACT4Y+b1Uu9nGqX=LdJ_nEWxbeCswMOsSpvnW=OLdDKYC5EjDw@mail.gmail.com>
 <CAM_iQpUEWDVHx5+VBB4=r=y_vVbXq32a2QfqY=OU5ri-yyJPaA@mail.gmail.com> <20170315125247.GB23553@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Vladislav Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        David Miller <davem@davemloft.net>, linux-sctp@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:36550 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752844AbdCOSUB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 14:20:01 -0400
In-Reply-To: <20170315125247.GB23553@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 15, 2017 at 5:52 AM, Marcelo Ricardo Leitner
<marcelo.leitner@gmail.com> wrote:
> On Tue, Mar 14, 2017 at 09:52:15PM -0700, Cong Wang wrote:
>> Instead of checking for the status of the sock, I believe the following
>> one-line fix should do the trick too. Can you give it a try?
>>
>> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
>> index 0f378ea..4de62d4 100644
>> --- a/net/sctp/socket.c
>> +++ b/net/sctp/socket.c
>> @@ -1494,7 +1494,7 @@ static void sctp_close(struct sock *sk, long timeout)
>>
>>         pr_debug("%s: sk:%p, timeout:%ld\n", __func__, sk, timeout);
>>
>> -       lock_sock(sk);
>> +       lock_sock_nested(sk, SINGLE_DEPTH_NESTING);
>>         sk->sk_shutdown = SHUTDOWN_MASK;
>>         sk->sk_state = SCTP_SS_CLOSING;
>
> I refrained on doing this just because it will change the lock signature
> for the first level too, as sctp_close() can be called directly, and
> might avoid some other lockdep detections.

I knew, but for the first level it is fine to use a different class,
it is merely to make lockdep happy. There is no real deadlock here
since they are two different socks anyway.

>
> Then you probably also need:
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 465a9c8464f9..02506b4406d2 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -1543,7 +1543,7 @@ static void sctp_close(struct sock *sk, long timeout)
>          * held and that should be grabbed before socket lock.
>          */
>         spin_lock_bh(&net->sctp.addr_wq_lock);
> -       bh_lock_sock(sk);
> +       bh_lock_sock_nested(sk);
>
>         /* Hold the sock, since sk_common_release() will put sock_put()
>          * and we have just a little more cleanup.
>
> because sctp_close will re-lock the socket a little later (for backlog
> processing).
>

Ah, of course I missed the re-lock. Dmitry, please add this piece too.

Thanks.
