From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] net: limit a number of namespaces which can be cleaned up
	concurrently
Date: Thu, 13 Oct 2016 10:49:38 -0500
Message-ID: <871szk9rl9.fsf@x220.int.ebiederm.org>
References: <1476293579-28582-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1476293579-28582-1-git-send-email-avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> (Andrei
	Vagin's message of "Wed, 12 Oct 2016 10:32:59 -0700")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> writes:

> From: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
>
> The operation of destroying netns is heavy and it is executed under
> net_mutex. If many namespaces are destroyed concurrently, net_mutex can
> be locked for a long time. It is impossible to create a new netns during
> this period of time.

This may be the right approach or at least the right approach to bound
net_mutex hold times but I have to take exception to calling network
namespace cleanup heavy.

The only particularly time consuming operation I have ever found are calls to
synchronize_rcu/sycrhonize_sched/synchronize_net.

Ideally we can search those out calls in the network namespace cleanup
operations and figuroue out how to eliminate those operations or how to
stack them.

> In our days when userns allows to create network namespaces to
> unprivilaged users, it may be a real problem.

Sorting out syncrhonize_rcu calls will be a much larger
and much more effective improvement than your patch here.

> On my laptop (fedora 24, i5-5200U, 12GB) 1000 namespaces requires about
> 300MB of RAM and are being destroyed for 8 seconds.
>
> In this patch, a number of namespaces which can be cleaned up
> concurrently is limited by 32. net_mutex is released after handling each
> portion of net namespaces and then it is locked again to handle the next
> one. It allows other users to lock it without waiting for a long
> time.
>
> I am not sure whether we need to add a sysctl to costomize this limit.
> Let me know if you think it's required.

We definitely don't need an extra sysctl.

Eric


> Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> ---
>  net/core/net_namespace.c | 12 +++++++++++-
>  1 file changed, 11 insertions(+), 1 deletion(-)
>
> diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
> index 989434f..33dd3b7 100644
> --- a/net/core/net_namespace.c
> +++ b/net/core/net_namespace.c
> @@ -406,10 +406,20 @@ static void cleanup_net(struct work_struct *work)
>  	struct net *net, *tmp;
>  	struct list_head net_kill_list;
>  	LIST_HEAD(net_exit_list);
> +	int i = 0;
>  
>  	/* Atomically snapshot the list of namespaces to cleanup */
>  	spin_lock_irq(&cleanup_list_lock);
> -	list_replace_init(&cleanup_list, &net_kill_list);
> +	list_for_each_entry_safe(net, tmp, &cleanup_list, cleanup_list)
> +		if (++i == 32)
> +			break;
> +	if (i == 32) {
> +		list_cut_position(&net_kill_list,
> +				  &cleanup_list, &net->cleanup_list);
> +		queue_work(netns_wq, work);
> +	} else {
> +		list_replace_init(&cleanup_list, &net_kill_list);
> +	}
>  	spin_unlock_irq(&cleanup_list_lock);
>  
>  	mutex_lock(&net_mutex);
