From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next v4 5/6] lib: Ensure EWMA does not store wrong
	intermediate values
Date: Thu, 16 Jan 2014 22:25:22 +0200
Message-ID: <20140116202522.GJ29522@redhat.com>
References: <1389901950-3854-1-git-send-email-mwdalton@google.com>
	<1389901950-3854-5-git-send-email-mwdalton@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>
To: Michael Dalton <mwdalton@google.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1389901950-3854-5-git-send-email-mwdalton@google.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 16, 2014 at 11:52:29AM -0800, Michael Dalton wrote:
> To ensure ewma_read() without a lock returns a valid but possibly
> out of date average, modify ewma_add() by using ACCESS_ONCE to prevent
> intermediate wrong values from being written to avg->internal.
> 
> Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Michael Dalton <mwdalton@google.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  lib/average.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/lib/average.c b/lib/average.c
> index 99a67e6..114d1be 100644
> --- a/lib/average.c
> +++ b/lib/average.c
> @@ -53,8 +53,10 @@ EXPORT_SYMBOL(ewma_init);
>   */
>  struct ewma *ewma_add(struct ewma *avg, unsigned long val)
>  {
> -	avg->internal = avg->internal  ?
> -		(((avg->internal << avg->weight) - avg->internal) +
> +	unsigned long internal = ACCESS_ONCE(avg->internal);
> +
> +	ACCESS_ONCE(avg->internal) = internal ?
> +		(((internal << avg->weight) - internal) +
>  			(val << avg->factor)) >> avg->weight :
>  		(val << avg->factor);
>  	return avg;
> -- 
> 1.8.5.2
