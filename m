From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] sctp: Fix sk_ack_backlog wrap-around problem
Date: Wed, 11 Jun 2014 08:55:59 -0400
Message-ID: <539851DF.3070808@gmail.com>
References: <1402454244-8427-1-git-send-email-xufeng.zhang@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Xufeng Zhang <xufeng.zhang@windriver.com>, nhorman@tuxdriver.com,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1402454244-8427-1-git-send-email-xufeng.zhang@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/10/2014 10:37 PM, Xufeng Zhang wrote:
> Consider the scenario:
> For a TCP-style socket, while processing the COOKIE_ECHO chunk in
> sctp_sf_do_5_1D_ce(), after it has passed a series of sanity check,
> a new association would be created in sctp_unpack_cookie(), but afterwards,
> some processing maybe failed, and sctp_association_free() will be called to
> free the previously allocated association, in sctp_association_free(),
> sk_ack_backlog value is decremented for this socket, since the initial
> value for sk_ack_backlog is 0, after the decrement, it will be 65535,
> a wrap-around problem happens, and if we want to establish new associations
> afterward in the same socket, ABORT would be triggered since sctp deem the
> accept queue as full.
> Fix this issue by only decrementing sk_ack_backlog for associations in
> the endpoint's list.
> 
> Fix-suggested-by: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: Xufeng Zhang <xufeng.zhang@windriver.com>
> ---
>  net/sctp/associola.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index 39579c3..60564f2 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -330,7 +330,7 @@ void sctp_association_free(struct sctp_association *asoc)
>  	/* Only real associations count against the endpoint, so
>  	 * don't bother for if this is a temporary association.
>  	 */
> -	if (!asoc->temp) {
> +	if (!asoc->temp && !list_empty(&asoc->asocs)) {
>  		list_del(&asoc->asocs);
>  
>  		/* Decrement the backlog value for a TCP-style listening
> 

I am not crazy about this patch.   It's been suggested before that may
be duplicate cookie processing should really be creating a temporary
association since that's is how that association is being used.  It
might be nice at that approach.  It actually benefits us as the
association destruction would happen immediately instead of being delayed.

-vlad
