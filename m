From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH 2/5] tcp: add TCP support for low
 latency receive poll.
Date: Tue, 5 Mar 2013 17:13:13 +0000
Message-ID: <1362503593.2791.36.camel@bwh-desktop.uk.solarflarecom.com>
References: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com>
	<20130227175601.10611.99536.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>,
	HPA <hpa@zytor.com>, Eliezer Tamir <eliezer@tamir.org.il>,
	Dave Miller <davem@davemloft.net>
To: Eliezer Tamir <eliezer.tamir@linux.jf.intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130227175601.10611.99536.stgit@gitlad.jf.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, 2013-02-27 at 09:56 -0800, Eliezer Tamir wrote:
> an example of how one could add support for ndo_ll_poll to TCP.
[...]
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -279,6 +279,7 @@
>  
>  #include <asm/uaccess.h>
>  #include <asm/ioctls.h>
> +#include <net/ll_poll.h>
>  
>  int sysctl_tcp_fin_timeout __read_mostly = TCP_FIN_TIMEOUT;
>  
> @@ -1475,6 +1476,17 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
>  
>  	if (sk->sk_state == TCP_LISTEN)
>  		return -ENOTCONN;
> +
> +#ifdef CONFIG_INET_LL_TCP_POLL
> +/* TODO: what do we do if the state changes after sk_poll_ll()? */

Maybe this bit should be a separate function that the callers can use
(or not) before calling tcp_read_sock().  Then they must take care of
re-locking and revalidating if it decides to poll.

Ben.

> +	if (sk_valid_ll(sk) && skb_queue_empty(&sk->sk_receive_queue)
> +		&& (sk->sk_state == TCP_ESTABLISHED)) {
> +
> +		release_sock(sk);
> +		sk_poll_ll(sk);
> +		lock_sock(sk);
> +	}
> +#endif
>  	while ((skb = tcp_recv_skb(sk, seq, &offset)) != NULL) {
>  		if (offset < skb->len) {
>  			int used;
[...]

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


------------------------------------------------------------------------------
Everyone hates slow websites. So do we.
Make your web apps faster with AppDynamics
Download AppDynamics Lite for free today:
http://p.sf.net/sfu/appdyn_d2d_feb
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
