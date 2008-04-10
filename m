From: "Daniel Hokka Zakrisson" <daniel-nym3zxDgnZcAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 6/14][RTNL]: Introduce the rtnl_kill_links call.
Date: Fri, 11 Apr 2008 00:09:55 +0200 (CEST)
Message-ID: <37533.192.168.101.12.1207865395.squirrel@intranet>
References: <47FE2AD4.9080609@openvz.org> <47FE2E01.6030000@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
        Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>, Denis Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
To: "Pavel Emelyanov" <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47FE2E01.6030000-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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

Pavel Emelyanov wrote:
> ... which will kill all the devices in the given net with
> the given rtnl_link_ops. Will be used in VLAN patches later.
>
> Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
>
> ---
>  include/net/rtnetlink.h |    1 +
>  net/core/rtnetlink.c    |   29 +++++++++++++++++++++--------
>  2 files changed, 22 insertions(+), 8 deletions(-)
>
> diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
> index 793863e..3c1895e 100644
> --- a/include/net/rtnetlink.h
> +++ b/include/net/rtnetlink.h
> @@ -74,6 +74,7 @@ struct rtnl_link_ops {
>
>  extern int	__rtnl_link_register(struct rtnl_link_ops *ops);
>  extern void	__rtnl_link_unregister(struct rtnl_link_ops *ops);
> +extern void	rtnl_kill_links(struct net *net, struct rtnl_link_ops *ops);
>
>  extern int	rtnl_link_register(struct rtnl_link_ops *ops);
>  extern void	rtnl_link_unregister(struct rtnl_link_ops *ops);
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index da99ac0..bc39e41 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -269,6 +269,26 @@ int rtnl_link_register(struct rtnl_link_ops *ops)
>
>  EXPORT_SYMBOL_GPL(rtnl_link_register);
>
> +static void __rtnl_kill_links(struct net *net, struct rtnl_link_ops *ops)
> +{
> +	struct net_device *dev;
> +restart:
> +	for_each_netdev(net, dev) {
> +		if (dev->rtnl_link_ops == ops) {
> +			ops->dellink(dev);
> +			goto restart;
> +		}
> +	}
> +}
> +
> +void rtnl_kill_links(struct net *net, struct rtnl_link_ops *ops)
> +{
> +	rtnl_lock();
> +	__rtnl_kill_links(net, ops);
> +	rtnl_unlock();
> +}
> +EXPORT_SYMBOL_GPL(rtnl_kill_links);
> +
>  /**
>   * __rtnl_link_unregister - Unregister rtnl_link_ops from rtnetlink.
>   * @ops: struct rtnl_link_ops * to unregister
> @@ -277,17 +297,10 @@ EXPORT_SYMBOL_GPL(rtnl_link_register);
>   */
>  void __rtnl_link_unregister(struct rtnl_link_ops *ops)
>  {
> -	struct net_device *dev, *n;
>  	struct net *net;
>
>  	for_each_net(net) {
> -restart:
> -		for_each_netdev_safe(net, dev, n) {
> -			if (dev->rtnl_link_ops == ops) {
> -				ops->dellink(dev);
> -				goto restart;
> -			}
> -		}
> +		__rtnl_kill_links(net, ops);

This was _safe, and now it's not. Is that intentional?

>  	}
>  	list_del(&ops->list);
>  }
> --
> 1.5.3.4

-- 
Daniel Hokka Zakrisson
