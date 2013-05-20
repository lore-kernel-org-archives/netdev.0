From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH v3 net-next 3/4] ixgbe: Add support for
	ndo_ll_poll
Date: Mon, 20 May 2013 23:20:03 +0300
Message-ID: <CAJZOPZJx8vpSWqOhmN65gn=vi7hWXQO_J01+hAwGY9RwetX3DA@mail.gmail.com>
References: <20130520101552.14133.45953.stgit@ladj378.jer.intel.com>
	<20130520101622.14133.21998.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, HPA <hpa@zytor.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>,
	Eliezer Tamir <eliezer@tamir.org.il>, Dave Miller <davem@davemloft.net>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130520101622.14133.21998.stgit@ladj378.jer.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, May 20, 2013 at 1:16 PM, Eliezer Tamir
<eliezer.tamir@linux.intel.com> wrote:
> Add the ixgbe driver code implementing ndo_ll_poll.
> It should be easy for other drivers to do something similar
> in order to enable support for CONFIG_INET_LL_RX_POLL

I am not sure,


> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
[...]
> @@ -144,6 +145,14 @@ static int debug = -1;
>  module_param(debug, int, 0);
>  MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
>
> +#ifdef CONFIG_INET_LL_RX_POLL
> +static int allow_unsafe_removal;
> +static int unsafe_to_remove;
> +module_param(allow_unsafe_removal, int, 0);
> +MODULE_PARM_DESC(allow_unsafe_removal,
> +       "Allow removal of module after low latency receive was used");
> +#endif

what?!

[...]

> +#ifdef CONFIG_INET_LL_RX_POLL
> +/* must be called with local_bh_disable()d */
> +static int ixgbe_low_latency_recv(struct napi_struct *napi)
> +{
> +       struct ixgbe_q_vector *q_vector =
> +                       container_of(napi, struct ixgbe_q_vector, napi);
> +       struct ixgbe_adapter *adapter = q_vector->adapter;
> +       struct ixgbe_ring  *ring;
> +       int found;
> +
> +       if (unlikely(!unsafe_to_remove)) {
> +               unsafe_to_remove = 1;
> +               if (!allow_unsafe_removal) {
> +                       pr_info("module may no longer be removed\n");
> +                       try_module_get(THIS_MODULE);
> +               }
> +       }

guys, so what is going here, you were asking to put this series in
net-next, and you expect each other driver implementing this ndo to
follow this undocumented hack? or maybe this code was just left here
by mistake from previous implementations and just needed to be
removed?  please clarify.

Or.

------------------------------------------------------------------------------
AlienVault Unified Security Management (USM) platform delivers complete
security visibility with the essential security capabilities. Easily and
efficiently configure, manage, and operate all of your security controls
from a single console and one unified framework. Download a free trial.
http://p.sf.net/sfu/alienvault_d2d
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
