From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 1/1] net: sock: Use double send/recv buff value to
 compare with max value
Date: Thu, 09 Feb 2017 06:34:07 -0800
Message-ID: <1486650847.7793.93.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1486559235-13633-1-git-send-email-fgao@ikuai8.com>
         <1486569601.7793.83.camel@edumazet-glaptop3.roam.corp.google.com>
         <CA+6hz4q+S5_LyVMp9OSD24U=REymv+ciur9ZaT9wH0mhSvo_cw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Gao Feng <fgao@ikuai8.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35683 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752177AbdBIOfC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 09:35:02 -0500
Received: by mail-it0-f66.google.com with SMTP id 203so2397648ith.2
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 06:34:08 -0800 (PST)
In-Reply-To: <CA+6hz4q+S5_LyVMp9OSD24U=REymv+ciur9ZaT9wH0mhSvo_cw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-02-09 at 17:08 +0800, Gao Feng wrote:
> On Thu, Feb 9, 2017 at 12:00 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Wed, 2017-02-08 at 21:07 +0800, fgao@ikuai8.com wrote:
> >> From: Gao Feng <fgao@ikuai8.com>
> >>
> >> Because the value of SO_SNDBUF and SO_RCVBUF is doubled before
> >> assignment, so the real value of send and recv buffer could be more
> >> than the max sysctl config sysctl_wmem_max and sysctl_rmem_max.
> >>
> >> Now use doulbe send/recv buffer value to compare with sysctl_wmem_max
> >> and sysctl_rmem_max, and it keeps consistence with SOCK_MIN_SNDBUF
> >> and SOCK_MIN_RCVBUF.
> >>
> >> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> >> ---
> >
> > Looks completely bogus, based on your comprehension of this code.
> 
> It is a config param, user could config any value.
> So why give it one bogus?
> If need more, user could config it by himself.
> 
> >
> > If you need to, fix the doc, not this code.
> 
> The current codes mean the buffer could exceed the sysctl max value.
> It seems inconsistent.


Well, after your patch, we end up doubling what the user requested.

Say user used val = 20000

val = min_t(u32, val * 2, sysctl_wmem_max);

Now val is 40000.

sk->sk_sndbuf = max_t(int, val * 2, SOCK_MIN_SNDBUF);

Now sk_sndbuf is 80000, or am I missing something ?

Before your patch, sk_sndbuf was 40000. See the difference ?

Some applications carefully tuned this, some people care about
bufferbloat.

This is too late now to change this behavior, especially the way you did
it, breaking some applications.

Unless you can show me a real application that hit an issue, I will not
accept your patch.
