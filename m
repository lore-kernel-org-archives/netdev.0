From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 10/10] tipc: refactor accept() code for improved
 readability
Date: Fri, 7 Dec 2012 14:42:26 -0500
Message-ID: <20121207194226.GB30339@hmsreliant.think-freely.org>
References: <1354890498-6448-1-git-send-email-paul.gortmaker@windriver.com>
 <1354890498-6448-11-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jon Maloy <jon.maloy@ericsson.com>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42875 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753157Ab2LGTmc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 14:42:32 -0500
Content-Disposition: inline
In-Reply-To: <1354890498-6448-11-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 07, 2012 at 09:28:18AM -0500, Paul Gortmaker wrote:
> In TIPC's accept() routine, there is a large block of code relating
> to initialization of a new socket, all within an if condition checking
> if the allocation succeeded.
> 
> Here, we simply factor out that init code within the accept() function
> to its own separate function, which improves readability, and makes
> it easier to track which lock_sock() calls are operating on existing
> vs. new sockets.
> 
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> ---
>  net/tipc/socket.c | 93 +++++++++++++++++++++++++++++--------------------------
>  1 file changed, 49 insertions(+), 44 deletions(-)
> 
> diff --git a/net/tipc/socket.c b/net/tipc/socket.c
> index 38613cf..56661c8 100644
> --- a/net/tipc/socket.c
> +++ b/net/tipc/socket.c
> @@ -1507,6 +1507,53 @@ static int listen(struct socket *sock, int len)
>  	return res;
>  }
>  
> +static void tipc_init_socket(struct sock *sk, struct socket *new_sock,
> +			     struct sk_buff *buf)
> +{
Can you rename this to something more specific to its purpose?  tipc_init_socket
makes me wonder why you're not calling it internally from tipc_create.  This
seems more like a tipc_init_accept_sock, or some such.  Alternatively, since
you're ony using it from your accept call, you might consider not factoring it
out at all, and just reversing the logic in your accept function so that you do:

 res = tipc_create(...)
 if (res)
	goto exit;
 <rest of tipc_init_socket goes here>

That gives you the same level of readability, without the additional potential
call instruction, plus you put the unlikely case inside the if conditional.

Neil
