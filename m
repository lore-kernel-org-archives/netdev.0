From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH 1/2] ax25: integer overflows in ax25_setsockopt()
Date: Wed, 23 Nov 2011 17:09:30 +0000
Message-ID: <20111123170930.GA7260@linux-mips.org>
References: <7187C142-99F1-4A96-9BE6-650B10C9B22D@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Joerg Reuter <jreuter@yaina.de>,
	David Miller <davem@davemloft.net>, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org, Thomas Osterried <thomas@osterried.de>
To: Xi Wang <xi.wang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <7187C142-99F1-4A96-9BE6-650B10C9B22D@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 22, 2011 at 11:28:24PM -0500, Xi Wang wrote:

> ax25_setsockopt() misses several upper-bound checks on the
> user-controlled value.
> 
> 
> Reported-by: Fan Long <longfancn@gmail.com>
> Signed-off-by: Xi Wang <xi.wang@gmail.com>
> ---
>  net/ax25/af_ax25.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
> index e7c69f4..be6a8cf 100644
> --- a/net/ax25/af_ax25.c
> +++ b/net/ax25/af_ax25.c
> @@ -571,7 +571,7 @@ static int ax25_setsockopt(struct socket *sock, int level, int optname,
>  		break;
>  
>  	case AX25_T1:
> -		if (opt < 1) {
> +		if (opt < 1 || opt > 30) {
>  			res = -EINVAL;
>  			break;
>  		}

30 seconds is definitively too low.  The TCP spec assumes that a RTT
of up to 120s is possible.  In slow packet radio networks 15 minutes are
easily possible in HF networks.

How about AX.25 to the P5A mars mission?

A silly value for T1 will be caught further down the road, so no damage
but an application really should receive a sensible return value when
trying something stupid.

If an apps wants to shoot itself into the foot there is nothing wrong with
being the arms dealer so an error check should be something like

	if (val > ULONG_MAX / HZ)
		bail_out;

which will do the right thing even on a 64-bit system and prevent an
overflow in the multiplication further down.

> @@ -580,7 +580,7 @@ static int ax25_setsockopt(struct socket *sock, int level, int optname,
>  		break;
>  
>  	case AX25_T2:
> -		if (opt < 1) {
> +		if (opt < 1 || opt > 20) {
>  			res = -EINVAL;
>  			break;
>  		}

An excessive value here could result in a timer being set to expire in
the past similar in effect to setting a very low value.  Again it's ok
if a user tries to shoot himself into the other foot as well.

> @@ -596,7 +596,7 @@ static int ax25_setsockopt(struct socket *sock, int level, int optname,
>  		break;
>  
>  	case AX25_T3:
> -		if (opt < 1) {
> +		if (opt < 0 || opt > 3600) {
>  			res = -EINVAL;
>  			break;
>  		}

For a stable link it should be possible to set a very high T3 value,
potencially high enough to effectively disable the T3 functionality.

> @@ -604,7 +604,7 @@ static int ax25_setsockopt(struct socket *sock, int level, int optname,
>  		break;
>  
>  	case AX25_IDLE:
> -		if (opt < 0) {
> +		if (opt < 0 || opt > 65535) {
>  			res = -EINVAL;
>  			break;
>  		}

I have an updated patch which I'm testing right now.

  Ralf
