From: Jason Wessel <jason.wessel@windriver.com>
Subject: Re: [PATCHv3 1/3] NETPOLL: Extend rx_hook support.
Date: Mon, 27 Feb 2012 17:17:12 -0600
Message-ID: <4F4C0EF8.8010405@windriver.com>
References: <1330137851-4716-1-git-send-email-andrey.warkentin@gmail.com>
	<1330313411-845-1-git-send-email-andrey.warkentin@gmail.com>
	<1330313411-845-2-git-send-email-andrey.warkentin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Matt Mackall <mpm@selenic.com>,
	Andrei Warkentin <andreiw@vmware.com>, linux-kernel@vger.kernel.org,
	kgdb-bugreport@lists.sourceforge.net
To: Andrei Warkentin <andrey.warkentin@gmail.com>
Return-path: <kgdb-bugreport-bounces@lists.sourceforge.net>
In-Reply-To: <1330313411-845-2-git-send-email-andrey.warkentin@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kgdb-bugreport>,
	<mailto:kgdb-bugreport-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=kgdb-bugreport>
List-Post: <mailto:kgdb-bugreport@lists.sourceforge.net>
List-Help: <mailto:kgdb-bugreport-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kgdb-bugreport>,
	<mailto:kgdb-bugreport-request@lists.sourceforge.net?subject=subscribe>
Errors-To: kgdb-bugreport-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 02/26/2012 09:30 PM, Andrei Warkentin wrote:
> From: Andrei Warkentin <andreiw@vmware.com>
> 
> Pass down source information to rx_hook, useful
> for accepting connections from unspecified clients.
> 
> Cc: kgdb-bugreport@lists.sourceforge.net
> Cc: Jason Wessel <jason.wessel@windriver.com>
> Cc: Matt Mackall <mpm@selenic.com>
> Signed-off-by: Andrei Warkentin <andrey.warkentin@gmail.com>
> Signed-off-by: Andrei Warkentin <andreiw@vmware.com>
> ---
>  include/linux/netpoll.h |   10 +++++++++-
>  net/core/netpoll.c      |   10 ++++------
>  2 files changed, 13 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
> index 5dfa091..9a9cfa1 100644
> --- a/include/linux/netpoll.h
> +++ b/include/linux/netpoll.h
> @@ -11,12 +11,19 @@
>  #include <linux/interrupt.h>
>  #include <linux/rcupdate.h>
>  #include <linux/list.h>
> +#include <linux/if_ether.h>
> +#include <net/tcp.h>
> +#include <net/udp.h>
>  
>  struct netpoll {
>  	struct net_device *dev;
>  	char dev_name[IFNAMSIZ];
>  	const char *name;
> -	void (*rx_hook)(struct netpoll *, int, char *, int);
> +	void (*rx_hook)(struct netpoll *,
> +			u8 *h_source,
> +			__be32 saddr,
> +			struct udphdr *,
> +			char *, int);


I am just now starting to look how this patch set compares to kgdboe.  For the kgdboe the patch is a bit different.  The kgdboe opted to just pass the skb so as to cut down on the number of arguments to the function call.

>From the kgdboe patch:

-       void (*rx_hook)(struct netpoll *, int, char *, int);
+       void (*rx_hook)(struct netpoll *, int, char *, int, struct sk_buff *);


>  
>  	__be32 local_ip, remote_ip;
>  	u16 local_port, remote_port;
> @@ -40,6 +47,7 @@ struct netpoll_info {
>  	struct netpoll *netpoll;
>  };
>  
> +void netpoll_poll_dev(struct net_device *dev);
>  void netpoll_send_udp(struct netpoll *np, const char *msg, int len);
>  void netpoll_print_options(struct netpoll *np);
>  int netpoll_parse_options(struct netpoll *np, char *opt);
> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index 3d84fb9..c182bb2 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -26,8 +26,6 @@
>  #include <linux/workqueue.h>
>  #include <linux/slab.h>
>  #include <linux/export.h>
> -#include <net/tcp.h>
> -#include <net/udp.h>
>  #include <asm/unaligned.h>
>  #include <trace/events/napi.h>
>  
> @@ -189,7 +187,7 @@ static void service_arp_queue(struct netpoll_info *npi)
>  	}
>  }
>  
> -static void netpoll_poll_dev(struct net_device *dev)
> +void netpoll_poll_dev(struct net_device *dev)


This is interesting and I will have to look into this further...  A large part of the reason kgdboe never went anywhere was all around the locking problems the ability to safely use the network hardware and restore the state when it was done.  It appears you made this change so as to make a lockless call directly instead of going through netpoll_poll().  I am not entirely sure you could safely do this.

In kgdboe we always had:

+static int eth_get_char(void)
+{
+	int chr;
+
+	while (atomic_read(&in_count) == 0)
+		netpoll_poll(&np);


If it is the case that you really can safely call the netpoll_poll_dev() without the locks then the horrible sync irq state etc... could go away in kgdboe, and then it would be worth considering digging up all the ethernet polling errata fixes that live of out the mainline and perhaps submit some for review.

Jason.

------------------------------------------------------------------------------
Try before you buy = See our experts in action!
The most comprehensive online learning library for Microsoft developers
is just $99.99! Visual Studio, SharePoint, SQL - plus HTML5, CSS3, MVC3,
Metro Style Apps, more. Free future releases when you subscribe now!
http://p.sf.net/sfu/learndevnow-dev2
