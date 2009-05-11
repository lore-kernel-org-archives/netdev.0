From: Frans Pop <elendil@planet.nl>
Subject: Re: [PATCH v2] tcp: fix MSG_PEEK race check
Date: Mon, 11 May 2009 14:50:05 +0200
Message-ID: <200905111450.06749.elendil@planet.nl>
References: <200902262310.12791.elendil@planet.nl> <200905092014.35642.elendil@planet.nl> <Pine.LNX.4.64.0905110926520.10047@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matthias Andree <matthias.andree@gmx.de>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: "Ilpo =?utf-8?q?J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpsmtpm-eml101.kpnxchange.com ([195.121.3.5]:49456 "EHLO
	CPSMTPM-EML101.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757976AbZEKMuH convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 May 2009 08:50:07 -0400
In-Reply-To: <Pine.LNX.4.64.0905110926520.10047@wrl-59.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 11 May 2009, Ilpo J=C3=A4rvinen wrote:
> I took my time to fix the urg_hole madness too. The patch below.

Hmm. I wonder if it wouldn't be better to keep the two issues separate.=
=20
The initial patch is a clear regression fix (4 people have reported it=20
against fetchmail for Debian). The URG part is IMO a separate issue whi=
ch=20
I at least have never seen in practice.
And my Tested-by doesn't cover the additional change either.

That said, I have added the URG change (as an incremental patch) in my=20
local git repo and will give it a go when I next build a kernel (may ta=
ke=20
a week). I don't expect to be able to confirm it fixes the URG race, bu=
t=20
I can at least check that it doesn't cause any false messages with my=20
(spectacularly unspectacular) network traffic. I'll report the result.

> --
> [PATCH v2] tcp: fix MSG_PEEK race check
>
> Commit 518a09ef11 (tcp: Fix recvmsg MSG_PEEK influence of
> blocking behavior) lets the loop run longer than the race check
> did previously expect, so we need to be more careful with this
> check and consider the work we have been doing.
>
> I tried my best to deal with urg hole madness too which happens
> here:
> 	if (!sock_flag(sk, SOCK_URGINLINE)) {
> 		++*seq;
> 		...
> by using additional offset by one but I certainly have very
> little interest in testing that part.
>
> Signed-off-by: Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi>
> Tested-by: Frans Pop <elendil@planet.nl>
> ---
>  net/ipv4/tcp.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
>
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 1d7f49c..7a0f0b2 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -1321,6 +1321,7 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock
> *sk, struct msghdr *msg, struct task_struct *user_recv =3D NULL;
>  	int copied_early =3D 0;
>  	struct sk_buff *skb;
> +	u32 urg_hole =3D 0;
>
>  	lock_sock(sk);
>
> @@ -1532,7 +1533,8 @@ do_prequeue:
>  				}
>  			}
>  		}
> -		if ((flags & MSG_PEEK) && peek_seq !=3D tp->copied_seq) {
> +		if ((flags & MSG_PEEK) &&
> +		    (peek_seq - copied - urg_hole !=3D tp->copied_seq)) {
>  			if (net_ratelimit())
>  				printk(KERN_DEBUG "TCP(%s:%d): Application bug, race in
> MSG_PEEK.\n", current->comm, task_pid_nr(current));
> @@ -1553,6 +1555,7 @@ do_prequeue:
>  				if (!urg_offset) {
>  					if (!sock_flag(sk, SOCK_URGINLINE)) {
>  						++*seq;
> +						urg_hole++;
>  						offset++;
>  						used--;
>  						if (!used)

