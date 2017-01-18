From: Neal Cardwell <ncardwell@google.com>
Subject: Re: resend: tcp: performance issue with fastopen connections (mss > window)
Date: Wed, 18 Jan 2017 13:33:11 -0500
Message-ID: <CADVnQymkzN8+dC4CDuqxSv5-kfEpVxTjpG3D3M_6TgKkHS+gfA@mail.gmail.com>
References: <30f38b3c-8c5c-7fab-e424-985e63ad900a@oracle.com>
 <1484321734.13165.24.camel@edumazet-glaptop3.roam.corp.google.com>
 <22b07900-2151-a31f-34aa-7fb47c958423@oracle.com> <3dbbcda8-ce79-641c-cf3b-21f41c563939@oracle.com>
 <CANn89iJn+fC-mMCskczXupj=yhvDijYEn-_NeCphuG8roNCygA@mail.gmail.com>
 <CAK6E8=fL+Gf_uqxALxX8iT7Ew9sxZA_+Ncaa+nh2ZWMkej154w@mail.gmail.com> <CANn89i+5E0nXEox0EHU7s3me00KegXNA4ZeKQWxQoWRC4jNbHQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Yuchung Cheng <ycheng@google.com>,
        Alexey Kodanev <alexey.kodanev@oracle.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Vasily Isaenko <vasily.isaenko@oracle.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f181.google.com ([74.125.82.181]:33150 "EHLO
        mail-ot0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752832AbdARUiM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 15:38:12 -0500
Received: by mail-ot0-f181.google.com with SMTP id 73so17424324otj.0
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 12:38:12 -0800 (PST)
In-Reply-To: <CANn89i+5E0nXEox0EHU7s3me00KegXNA4ZeKQWxQoWRC4jNbHQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 18, 2017 at 1:16 PM, Eric Dumazet <edumazet@google.com> wrote:
>
> On Wed, Jan 18, 2017 at 10:13 AM, Yuchung Cheng <ycheng@google.com> wrote:
> > On Wed, Jan 18, 2017 at 9:35 AM, Eric Dumazet <edumazet@google.com> wrote:
> >>
> >> On Wed, Jan 18, 2017 at 9:32 AM, Alexey Kodanev
> >> <alexey.kodanev@oracle.com> wrote:
> >> > Hi Eric,
> >> >
> >> > On 01/13/2017 08:07 PM, Alexey Kodanev wrote:
> >> >
> >>
> >> > Looks like max_window not correctly initialized for tfo sockets.
> >> > On my test machine it has set to '5592320' in tcp_fastopen_create_child().
> >> >
> >> > This diff fixes the issue, the question: is this the right place to do it?
> >> >
> >> > diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
> >> > index 4e777a3..33ed508 100644
> >> > --- a/net/ipv4/tcp_fastopen.c
> >> > +++ b/net/ipv4/tcp_fastopen.c
> >> > @@ -206,6 +206,8 @@ static struct sock *tcp_fastopen_create_child(struct
> >> > sock *sk,
> >> >          */
> >> >         tp->snd_wnd = ntohs(tcp_hdr(skb)->window);
> >> >
> >> > +       tp->max_window = tp->snd_wnd;
> >> > +
> >>
> >> Excellent catch. Let me test our regression tests with this.
> > Indeed nice catch. Thanks for the investigative work!
> >
>
> We do have 2 failures, but tests might have depended on undocumented behavior
>
> (For googlers :
> Ran 211 tests: 209 passing, 0 flaky 2 failing
> Sponge: http://sponge/f1575065-6e1c-4514-bced-9167ce56d2ee
> )

Yes, exactly, those test failures look fine. Looks like the test was
implicitly expecting the old buggy behavior (and it wasn't noticed
because the 10*MSS output matches IW10, so it looked fine. But now
with the fix, I believe we are seeing the correct new behavior because
tcp_xmit_size_goal() is calling tcp_bound_to_half_wnd(), and now with
max_window fixed, the outgoing TSO skb is now the correct 5*MSS (half
of the rwin of 10000). So the test results look good to me.

Thanks, Alexey, for tracking this down! :-)

neal
