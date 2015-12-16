From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: net: heap-out-of-bounds in sock_setsockopt
Date: Wed, 16 Dec 2015 17:58:35 -0500
Message-ID: <CAF=yD-LA5ciR7XJdr-d=1WH7FHYNNvwZhHoB1u9h8Fd5SuK6Sg@mail.gmail.com>
References: <CACT4Y+Y5jtsfn4U8C-iBT4njrjXH+fFmvajuyhA-VpEchjLKFw@mail.gmail.com>
 <CAHA+R7PCNuyW7RhbzxPJvnrX0NA1bxDXR8cL58STXrWkwMXXyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
	Willem de Bruijn <willemb@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Craig Gallek <kraig@google.com>,
	Ying Xue <ying.xue@windriver.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Edward Jee <edjee@google.com>,
	Julia Lawall <julia.lawall@lip6.fr>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHA+R7PCNuyW7RhbzxPJvnrX0NA1bxDXR8cL58STXrWkwMXXyA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>
> Hmm, we should exclude the raw socket case, something like the
> following, but I am not sure if the check is too strict or not, also
> not sure if we should return an error for this raw socket case.

No, SOF_TIMESTAMPING_OPT_ID with SOCK_RAW/IPPROTO_TCP
is legitimate. It should fall through to initializing sk->sk_tskey to zero.
Only stream sockets should use the special case where numbering
is bytestream and computed by subtracting the seqno from the seqno
at the time that the option is enabled.

>
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 765be83..c26e80a 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -872,7 +872,7 @@ int sock_setsockopt(struct socket *sock, int
> level, int optname,
>
>                 if (val & SOF_TIMESTAMPING_OPT_ID &&
>                     !(sk->sk_tsflags & SOF_TIMESTAMPING_OPT_ID)) {
> -                       if (sk->sk_protocol == IPPROTO_TCP) {
> +                       if (sk->sk_protocol == IPPROTO_TCP &&
> sk->sk_type == SOCK_STREAM) {
>                                 if (sk->sk_state != TCP_ESTABLISHED) {
>                                         ret = -EINVAL;
>                                         break;

I made the same error when later returning the tskey in
__skb_tstamp_tx:

        if (sk->sk_tsflags & SOF_TIMESTAMPING_OPT_ID) {
                serr->ee.ee_data = skb_shinfo(skb)->tskey;
                if (sk->sk_protocol == IPPROTO_TCP)
                        serr->ee.ee_data -= sk->sk_tskey;
        }

This has no effect if sk->sk_tskey is initialized to 0 with your patch. Still,
it should not treat SOCK_RAW as a TCP sock here, either. Please
add this if you're about to send the patch. Or I can send it separately,
if you prefer. Thanks for the quick fix.
