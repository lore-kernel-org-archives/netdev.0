From: Eric Dumazet <edumazet@google.com>
Subject: Re: net: heap-out-of-bounds in sock_setsockopt
Date: Wed, 16 Dec 2015 13:07:30 -0800
Message-ID: <CANn89iLWOkR3odzkdoYbXCwNEkiQsM7MeONX5GVd0OMJZSBOYA@mail.gmail.com>
References: <CACT4Y+Y5jtsfn4U8C-iBT4njrjXH+fFmvajuyhA-VpEchjLKFw@mail.gmail.com>
	<CAHA+R7PCNuyW7RhbzxPJvnrX0NA1bxDXR8cL58STXrWkwMXXyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
	Willem de Bruijn <willemb@google.com>,
	"David S. Miller" <davem@davemloft.net>,
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

On Wed, Dec 16, 2015 at 12:22 PM, Cong Wang <cwang@twopensource.com> wrote:

> Hmm, we should exclude the raw socket case, something like the
> following, but I am not sure if the check is too strict or not, also
> not sure if we should return an error for this raw socket case.
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

This looks right, please post this officially ;)

tcp_sk(sk) only works for TCP sockets , and the test must include
sk->sk_type == SOCK_STREAM
