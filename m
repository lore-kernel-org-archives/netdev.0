From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net/ipv4: division by 0 in tcp_select_window
Date: Fri, 03 Mar 2017 12:56:01 -0800
Message-ID: <1488574561.9415.336.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CACT4Y+Y+dL6EzkfDahjQUyyT4YMhDin7UPY5RQYbNH0n0DJ5xA@mail.gmail.com>
         <CANn89iLNQKyywwLAdJsQDOpGDtEs6S-4BZkZYmwT39ENZyqLTg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANn89iLNQKyywwLAdJsQDOpGDtEs6S-4BZkZYmwT39ENZyqLTg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-03-03 at 10:25 -0800, Eric Dumazet wrote:
> On Fri, Mar 3, 2017 at 10:10 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> > Hello,
> >
> > The following program triggers division by 0 in tcp_select_window:
> >
> > https://gist.githubusercontent.com/dvyukov/ef28c0fd2ab57a655508ef7621b12e6c/raw/079011e2a9523a390b0621cbc1e5d9d5e637fd6d/gistfile1.txt
> 
> Yeah, tcp_disconnect() should never have existed in the first place.
> 
> We'll send a patch, unless you take care of this before us .

Could you try this first patch ?

Probably others will also be needed.

diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 40d893556e6701ace6a02903e53c45822d6fa56d..2187ebf1f270d19e6dd019b8f9df5eef8d018e03 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -552,7 +552,8 @@ void tcp_write_timer_handler(struct sock *sk)
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	int event;
 
-	if (sk->sk_state == TCP_CLOSE || !icsk->icsk_pending)
+	if (((1 << sk->sk_state) & (TCPF_CLOSE | TCPF_LISTEN)) ||
+	    !icsk->icsk_pending)
 		goto out;
 
 	if (time_after(icsk->icsk_timeout, jiffies)) {
