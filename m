From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net/dccp: warning in dccp_feat_clone_sp_val/__might_sleep
Date: Sun, 30 Oct 2016 05:41:39 +0100
Message-ID: <CAAeHK+z2mqZCsZpPP_hNY2-bt_-WEU9rFmOd=jcWSBmVPDS_rA@mail.gmail.com>
References: <CAAeHK+z-SAq-YhHarfc94dguyXCJ_tv8n=ZVdLTRsYEy0cK-pQ@mail.gmail.com>
 <CAM_iQpX_xw35MUyd9aON5U=HmUoRafeoOF+_vSTHGYnrXd-CHg@mail.gmail.com>
 <CAAeHK+y9ENvGzJEQtRy_5DEzCfhGEYXR5CPpgwXy_FoOtFUf3Q@mail.gmail.com>
 <1477762981.7065.272.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAAeHK+x6+CU+1KJNOpnoyyZoqH7_dcrWFVGU1KrJYVwJSzdxPg@mail.gmail.com> <1477764328.7065.284.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Gerrit Renker <gerrit@erg.abdn.ac.uk>,
        "David S. Miller" <davem@davemloft.net>, dccp@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:34312 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750867AbcJ3Elm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2016 00:41:42 -0400
Received: by mail-lf0-f47.google.com with SMTP id b81so82243281lfe.1
        for <netdev@vger.kernel.org>; Sat, 29 Oct 2016 21:41:42 -0700 (PDT)
In-Reply-To: <1477764328.7065.284.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, the warning is still there.

I'm not sure adding sched_annotate_sleep() does anything, since it's
defined as (in case CONFIG_DEBUG_ATOMIC_SLEEP is not set):
# define sched_annotate_sleep() do { } while (0)

On Sat, Oct 29, 2016 at 8:05 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sat, 2016-10-29 at 19:59 +0200, Andrey Konovalov wrote:
>> Hi Eric,
>>
>> Tested with both patches applied, still seeing the warning.
>>
>> Thanks!
>
> Arg, sorry, this was at the wrong place.
>
> Thanks for testing !
>
> diff --git a/net/dccp/output.c b/net/dccp/output.c
> index b66c84db0766..2548edff86ff 100644
> --- a/net/dccp/output.c
> +++ b/net/dccp/output.c
> @@ -224,6 +224,11 @@ static int dccp_wait_for_ccid(struct sock *sk, unsigned long delay)
>
>         prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
>         sk->sk_write_pending++;
> +
> +       /* release_sock()/lock_sock() will process socket backlog
> +        * from process context. Be prepared to sleep !
> +        */
> +       sched_annotate_sleep();
>         release_sock(sk);
>
>         remaining = schedule_timeout(delay);
>
>
