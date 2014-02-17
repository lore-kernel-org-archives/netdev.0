From: Dan Williams <dcbw@redhat.com>
Subject: Re: [RFC v2 2/4] net: enables interface option to skip IP
Date: Mon, 17 Feb 2014 14:23:58 -0600
Message-ID: <1392668638.21106.5.camel@dcbw.local>
References: <1392433180-16052-1-git-send-email-mcgrof@do-not-panic.com>
	 <1392433180-16052-3-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Luis R. Rodriguez" <mcgrof@suse.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392433180-16052-3-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-02-14 at 18:59 -0800, Luis R. Rodriguez wrote:
> From: "Luis R. Rodriguez" <mcgrof@suse.com>
> 
> Some interfaces do not need to have any IPv4 or IPv6
> addresses, so enable an option to specify this. One
> example where this is observed are virtualization
> backend interfaces which just use the net_device
> constructs to help with their respective frontends.
> 
> This should optimize boot time and complexity on
> virtualization environments for each backend interface
> while also avoiding triggering SLAAC and DAD, which is
> simply pointless for these type of interfaces.

Would it not be better/cleaner to use disable_ipv6 and then add a
disable_ipv4 sysctl, then use those with that interface?  The
IFF_SKIP_IP seems to duplicate at least part of what disable_ipv6 is
already doing.

Dan

> Cc: "David S. Miller" <davem@davemloft.net>
> cC: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: James Morris <jmorris@namei.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
> ---
>  include/uapi/linux/if.h | 1 +
>  net/ipv4/devinet.c      | 3 +++
>  net/ipv6/addrconf.c     | 6 ++++++
>  3 files changed, 10 insertions(+)
> 
> diff --git a/include/uapi/linux/if.h b/include/uapi/linux/if.h
> index 8d10382..566d856 100644
> --- a/include/uapi/linux/if.h
> +++ b/include/uapi/linux/if.h
> @@ -85,6 +85,7 @@
>  					 * change when it's running */
>  #define IFF_MACVLAN 0x200000		/* Macvlan device */
>  #define IFF_BRIDGE_NON_ROOT 0x400000    /* Don't consider for root bridge */
> +#define IFF_SKIP_IP	0x800000	/* Skip IPv4, IPv6 */
>  
> 
>  #define IF_GET_IFACE	0x0001		/* for querying only */
> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> index a1b5bcb..8e9ef07 100644
> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c
> @@ -1342,6 +1342,9 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
>  
>  	ASSERT_RTNL();
>  
> +	if (dev->priv_flags & IFF_SKIP_IP)
> +		goto out;
> +
>  	if (!in_dev) {
>  		if (event == NETDEV_REGISTER) {
>  			in_dev = inetdev_init(dev);
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 4b6b720..57f58e3 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -314,6 +314,9 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
>  
>  	ASSERT_RTNL();
>  
> +	if (dev->priv_flags & IFF_SKIP_IP)
> +		return NULL;
> +
>  	if (dev->mtu < IPV6_MIN_MTU)
>  		return NULL;
>  
> @@ -2749,6 +2752,9 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
>  	int run_pending = 0;
>  	int err;
>  
> +	if (dev->priv_flags & IFF_SKIP_IP)
> +		return NOTIFY_OK;
> +
>  	switch (event) {
>  	case NETDEV_REGISTER:
>  		if (!idev && dev->mtu >= IPV6_MIN_MTU) {
