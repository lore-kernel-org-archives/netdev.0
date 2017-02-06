From: Florian Westphal <fw@strlen.de>
Subject: Re: net/icmp: null-ptr-deref in ping_v4_push_pending_frames
Date: Tue, 7 Feb 2017 00:00:41 +0100
Message-ID: <20170206230041.GB28402@breakpoint.cc>
References: <CAAeHK+w0hoTCrBcPiS84OJ8Lc7N4s+0YD2U6ey_+Gygzmc66=Q@mail.gmail.com>
 <CAM_iQpXD-+PSsVTTiWENwt80iBZNvVeAZi0WeZxkhVg-3ueiZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrey Konovalov <andreyknvl@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAM_iQpXD-+PSsVTTiWENwt80iBZNvVeAZi0WeZxkhVg-3ueiZQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Mon, Feb 6, 2017 at 11:39 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
> > Hi,
> >
> > I've got the following error report while running the syzkaller fuzzer.
> >
> > The null-ptr-deref is caused by sendto() on a socket(PF_INET,
> > SOCK_DGRAM, PROT_ICMP).
> > Note, that this requires the ability to create such sockets, which can
> > be configured by net.ipv4.ping_group_range
> > (https://lwn.net/Articles/422330/).
> >
> > A reproducer and .config are attached.
> >
> > On commit a572a1b999489efb591287632279c6c9eca3e4ed.
> >
> > general protection fault: 0000 [#1] SMP KASAN
> > Dumping ftrace buffer:
> >    (ftrace buffer empty)
> > Modules linked in:
> > CPU: 2 PID: 3880 Comm: syz-executor1 Not tainted 4.10.0-rc6+ #124
[..]
> 
> This fixes it for me:
> 
> diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
> index 86cca61..68d77b1 100644
> --- a/net/ipv4/ping.c
> +++ b/net/ipv4/ping.c
> @@ -642,6 +642,8 @@ static int ping_v4_push_pending_frames(struct sock
> *sk, struct pingfakehdr *pfh,
>  {
>         struct sk_buff *skb = skb_peek(&sk->sk_write_queue);
> 
> +       if (!skb)
> +               return 0;
>         pfh->wcheck = csum_partial((char *)&pfh->icmph,
>                 sizeof(struct icmphdr), pfh->wcheck);
>         pfh->icmph.checksum = csum_fold(pfh->wcheck);

Sigh.  I wonder if we can remove ping sockets.

IIRC they were born out of a 'no suid' requirement in combination
with 'suid is insecure' but, alas, placing it in kernel evidently
doesn't make things any more secure either.

Those that don't want a suid ping binary could probably convince systemd
developers to provide systemd-icmpd instead with ping dbus interface
(ok, I'll shut up now ;)
