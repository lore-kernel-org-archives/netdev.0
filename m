From: "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/3] netns: Fix icmp shutdown.
Date: Fri, 20 Feb 2009 18:57:02 +0300
Message-ID: <1235145422.9761.150.camel@iris.sw.ru>
References: <m1ocwxi00a.fsf@fess.ebiederm.org>
	<m1bpsxhzqz.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1bpsxhzqz.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Acked-by: Denis V. Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

On Fri, 2009-02-20 at 07:52 -0800, Eric W. Biederman wrote:
> Recently I had a kernel panic in icmp_send during a network namespace
> cleanup.  There were packets in the arp queue that failed to be sent
> and we attempted to generate an ICMP host unreachable message, but
> failed because icmp_sk_exit had already been called.
> 
> The network devices are removed from a network namespace and their
> arp queues are flushed before we do attempt to shutdown subsystems
> so this error should have been impossible.
> 
> It turns out icmp_init is using register_pernet_device instead
> of register_pernet_subsys.  Which resulted in icmp being shut down
> while we still had the possibility of packets in flight, making
> a nasty NULL pointer deference in interrupt context possible.
> 
> Changing this to register_pernet_subsys fixes the problem in
> my testing.
> 
> Signed-off-by: Eric W. Biederman <ebiederm-BGArkANP9klv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
> ---
>  net/ipv4/icmp.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
> index 382800a..3f50807 100644
> --- a/net/ipv4/icmp.c
> +++ b/net/ipv4/icmp.c
> @@ -1207,7 +1207,7 @@ static struct pernet_operations __net_initdata icmp_sk_ops = {
>  
>  int __init icmp_init(void)
>  {
> -	return register_pernet_device(&icmp_sk_ops);
> +	return register_pernet_subsys(&icmp_sk_ops);
>  }
>  
>  EXPORT_SYMBOL(icmp_err_convert);
