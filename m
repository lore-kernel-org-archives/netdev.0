From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 1/7] bridge: Turn flag change macro into a
	function.
Date: Wed, 26 Feb 2014 17:29:26 +0200
Message-ID: <20140226152926.GB15330@redhat.com>
References: <1393427905-6811-1-git-send-email-vyasevic@redhat.com>
	<1393427905-6811-2-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org, shemminger@vyatta.com,
	bridge@lists.linux-foundation.org, jhs@mojatatu.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1393427905-6811-2-git-send-email-vyasevic@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 26, 2014 at 10:18:19AM -0500, Vlad Yasevich wrote:
> Turn the flag change macro into a function to allow
> easier updates and to reduce space.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>  net/bridge/br_sysfs_if.c | 29 +++++++++++++++++++----------
>  1 file changed, 19 insertions(+), 10 deletions(-)
> 
> diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
> index dd595bd..7f66aa4 100644
> --- a/net/bridge/br_sysfs_if.c
> +++ b/net/bridge/br_sysfs_if.c
> @@ -25,6 +25,8 @@ struct brport_attribute {
>  	ssize_t (*show)(struct net_bridge_port *, char *);
>  	int (*store)(struct net_bridge_port *, unsigned long);
>  };
> +static int store_flag(struct net_bridge_port *p, unsigned long v,
> +		     unsigned long mask);
>  
>  #define BRPORT_ATTR(_name, _mode, _show, _store)		\
>  const struct brport_attribute brport_attr_##_name = { 	        \

nitpicking:
Do we have to have forward declarations like this?
They make it harder to find where the code is.

Also, pls add an empty line between struct and function.


> @@ -41,20 +43,27 @@ static ssize_t show_##_name(struct net_bridge_port *p, char *buf) \
>  }								\
>  static int store_##_name(struct net_bridge_port *p, unsigned long v) \
>  {								\
> -	unsigned long flags = p->flags;				\
> -	if (v)							\
> -		flags |= _mask;					\
> -	else							\
> -		flags &= ~_mask;				\
> -	if (flags != p->flags) {				\
> -		p->flags = flags;				\
> -		br_ifinfo_notify(RTM_NEWLINK, p);		\
> -	}							\
> -	return 0;						\
> +	return store_flag(p, v, _mask);				\
>  }								\
>  static BRPORT_ATTR(_name, S_IRUGO | S_IWUSR,			\
>  		   show_##_name, store_##_name)
>  
> +static int store_flag(struct net_bridge_port *p, unsigned long v,
> +		     unsigned long mask)
> +{
> +	unsigned long flags = p->flags;
> +
> +	if (v)
> +		flags |= mask;
> +	else
> +		flags &= ~mask;
> +
> +	if (flags != p->flags) {
> +		p->flags = flags;
> +		br_ifinfo_notify(RTM_NEWLINK, p);
> +	}
> +	return 0;
> +}
>  
>  static ssize_t show_path_cost(struct net_bridge_port *p, char *buf)
>  {
> -- 
> 1.8.5.3
