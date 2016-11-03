From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net/sctp: use-after-free in __sctp_connect
Date: Thu, 3 Nov 2016 19:02:47 +0100
Message-ID: <CAAeHK+yHVYmyA4hNKNKyVrZQXkUmMNDF=WFz3F1VWMAA0gqwZA@mail.gmail.com>
References: <CAAeHK+wX8yxVTpmg-Ps7MKTD-x_HS3GgpzX6yfGh51cQE0oPjA@mail.gmail.com>
 <20161019165754.GD2958@localhost.localdomain> <CAAeHK+xaBVcZp7PfH-tYWaxs6rCiaNAivZj4xZLcawFShi6C1Q@mail.gmail.com>
 <CAAeHK+xxcV8XV1Pc2_eBrQWTDSp3ooc1LLX81jhCTCvk7hhaVg@mail.gmail.com> <20161103175220.GG8514@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-sctp@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>,
        Kostya Serebryany <kcc@google.com>,
        Alexander Potapenko <glider@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Dmitry Vyukov <dvyukov@google.com>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161103175220.GG8514@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 3, 2016 at 6:52 PM, Marcelo Ricardo Leitner
<marcelo.leitner@gmail.com> wrote:
> On Thu, Nov 03, 2016 at 06:11:01PM +0100, Andrey Konovalov wrote:
>> On Wed, Nov 2, 2016 at 11:42 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
>> > On Wed, Oct 19, 2016 at 6:57 PM, Marcelo Ricardo Leitner
>> > <marcelo.leitner@gmail.com> wrote:
>> >> On Wed, Oct 19, 2016 at 02:25:24PM +0200, Andrey Konovalov wrote:
>> >>> Hi,
>> >>>
>> >>> I've got the following error report while running the syzkaller fuzzer:
>> >>>
>> >>> ==================================================================
>> >>> BUG: KASAN: use-after-free in __sctp_connect+0xabe/0xbf0 at addr
>> >>> ffff88006b1dc610
>> >>
>> >> Seems this is the same that Dmitry Vyukov had reported back in Jan 13th.
>> >> So far I couldn't identify the reason.
>> >> "Good" to know it's still there, thanks for reporting it.
>>
>> Hi Marcelo,
>>
>
> Hi
>
>> So I've looked at the code.
>> As far as I understand, the problem is a race condition between
>> setsockopt(SCTP_SOCKOPT_CONNECTX) and shutdown on an sctp socket.
>> setsockopt() calls sctp_wait_for_connect(), which exits the for loop
>> on the sk->sk_shutdown & RCV_SHUTDOWN if clause, and then frees asoc
>> with sctp_association_put() and returns err = 0.
>> Then __sctp_connect() checks that err == 0 and reads asoc->assoc_id
>> from the freed asoc.
>
> Suddenly this seems familiar. Your description makes sense, thanks for
> looking deeper into this, Andrey.
>
> This fix should do it, can you please try it? I'll post it properly
> if it works.

Yes, it fixes the issue.

Tested-by: Andrey Konovalov <andreyknvl@google.com>

Thanks for the fix!

>
> wait_for_connect is only used in two places, we can move the ref to a
> broader scope and cover that read too, instead of holding another ref.
>
> sendmsg path won't read anything from the asoc after waiting, so this
> should be enough for it too.
>
> ---8<---
>
> commit 7f7ba9b4fb834a61ab097dfd7c1f267e6a6d70a8
> Author: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Date:   Thu Nov 3 15:47:45 2016 -0200
>
>     sctp: hold the asoc longer when associating
>
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 9fbb6feb8c27..aac271571930 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -1214,9 +1214,11 @@ static int __sctp_connect(struct sock *sk,
>
>         timeo = sock_sndtimeo(sk, f_flags & O_NONBLOCK);
>
> +       sctp_association_hold(asoc);
>         err = sctp_wait_for_connect(asoc, &timeo);
>         if ((err == 0 || err == -EINPROGRESS) && assoc_id)
>                 *assoc_id = asoc->assoc_id;
> +       sctp_association_put(asoc);
>
>         /* Don't free association on exit. */
>         asoc = NULL;
> @@ -1985,7 +1987,9 @@ static int sctp_sendmsg(struct sock *sk, struct msghdr *msg, size_t msg_len)
>
>         if (unlikely(wait_connect)) {
>                 timeo = sock_sndtimeo(sk, msg_flags & MSG_DONTWAIT);
> +               sctp_association_hold(asoc);
>                 sctp_wait_for_connect(asoc, &timeo);
> +               sctp_association_put(asoc);
>         }
>
>         /* If we are already past ASSOCIATE, the lower
> @@ -7501,6 +7505,7 @@ static int sctp_writeable(struct sock *sk)
>
>  /* Wait for an association to go into ESTABLISHED state. If timeout is 0,
>   * returns immediately with EINPROGRESS.
> + * Note: caller must hold a ref on asoc before calling this function.
>   */
>  static int sctp_wait_for_connect(struct sctp_association *asoc, long *timeo_p)
>  {
> @@ -7511,9 +7516,6 @@ static int sctp_wait_for_connect(struct sctp_association *asoc, long *timeo_p)
>
>         pr_debug("%s: asoc:%p, timeo:%ld\n", __func__, asoc, *timeo_p);
>
> -       /* Increment the association's refcnt.  */
> -       sctp_association_hold(asoc);
> -
>         for (;;) {
>                 prepare_to_wait_exclusive(&asoc->wait, &wait,
>                                           TASK_INTERRUPTIBLE);
> @@ -7543,9 +7545,6 @@ static int sctp_wait_for_connect(struct sctp_association *asoc, long *timeo_p)
>  out:
>         finish_wait(&asoc->wait, &wait);
>
> -       /* Release the association's refcnt.  */
> -       sctp_association_put(asoc);
> -
>         return err;
>
>  do_error:
