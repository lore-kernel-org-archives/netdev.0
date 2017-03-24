From: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: Linux kernel ping socket / AF_LLC connect()
 sin_family race
Date: Fri, 24 Mar 2017 15:21:06 -0700
Message-ID: <CANn89iK-7r3KozC4K1rmWpJ1jM-bhBqessUrkg8HoftnjOks5g@mail.gmail.com>
References: <20170324202714.GA29241@openwall.com> <CAAeHK+yrE7+BZztHVn-2jKgLqgzgbBEa4VWCO8SL45oD0nRxEw@mail.gmail.com>
Reply-To: oss-security-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary=001a1147bfd0f331f0054b816841
Cc: oss-security-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>, James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>, Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Vasily Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
To: Andrey Konovalov <andreyknvl-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <oss-security-return-21992-gcsos-oss-security=m.gmane.org-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org>
List-Post: <mailto:oss-security-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org>
List-Help: <mailto:oss-security-help-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <mailto:oss-security-unsubscribe-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org>
List-Subscribe: <mailto:oss-security-subscribe-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org>
In-Reply-To: <CAAeHK+yrE7+BZztHVn-2jKgLqgzgbBEa4VWCO8SL45oD0nRxEw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Id: netdev.vger.kernel.org

--001a1147bfd0f331f0054b816841
Content-Type: text/plain; charset=UTF-8

On Fri, Mar 24, 2017 at 1:43 PM, Andrey Konovalov <andreyknvl-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
wrote:

> On Fri, Mar 24, 2017 at 9:27 PM, Solar Designer <solar-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
> wrote:
> > Hi,
> >
> > I haven't fully investigated this issue, and the Subject is provisional
> > (but will probably get stuck).  I am not yet sure which kernel
> > subsystem(s) to blame here (ping sockets? LLC sockets? other/more?), and
> > there might be other ways to trigger the issue.
>
> Reproduced the crash on current upstream
> (ebe64824e9de4b3ab3bd3928312b4b2bc57b4b7e).
>
> Adding kernel maintainers.
>

Looks easy enough to fix ?

diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index
2af6244b83e27ae384e96cf071c10c5a89674804..ccfbce13a6333a65dab64e4847dd510dfafb1b43
100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -156,17 +156,18 @@ int ping_hash(struct sock *sk)
 void ping_unhash(struct sock *sk)
 {
        struct inet_sock *isk = inet_sk(sk);
+
        pr_debug("ping_unhash(isk=%p,isk->num=%u)\n", isk, isk->inet_num);
+       write_lock_bh(&ping_table.lock);
        if (sk_hashed(sk)) {
-               write_lock_bh(&ping_table.lock);
                hlist_nulls_del(&sk->sk_nulls_node);
                sk_nulls_node_init(&sk->sk_nulls_node);
                sock_put(sk);
                isk->inet_num = 0;
                isk->inet_sport = 0;
                sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
-               write_unlock_bh(&ping_table.lock);
        }
+       write_unlock_bh(&ping_table.lock);
 }
 EXPORT_SYMBOL_GPL(ping_unhash);

--001a1147bfd0f331f0054b816841--
