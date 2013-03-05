From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH 3/5] ixgbe: Add support for ndo_ll_poll
Date: Tue, 5 Mar 2013 17:26:50 +0000
Message-ID: <1362504410.2791.44.camel@bwh-desktop.uk.solarflarecom.com>
References: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com>
	<20130227175606.10611.55498.stgit@gitlad.jf.intel.com>
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
In-Reply-To: <20130227175606.10611.55498.stgit@gitlad.jf.intel.com>
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
> Add the ixgbe driver code implementing ndo_ll_poll.
> It should be easy for other drivers to do something similar
> in order to enable support for CONFIG_INET_LL_RX_POLL

Yes... in fact I wonder whether the lock and state couldn't be added to
napi_struct instead of being driver-specific.

[...]
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
[...]
>  static void ixgbe_napi_disable_all(struct ixgbe_adapter *adapter)
>  {
>  	int q_idx;
>  
> -	for (q_idx = 0; q_idx < adapter->num_q_vectors; q_idx++)
> +	local_bh_disable(); /* for ixgbe_qv_lock_napi() */
> +	for (q_idx = 0; q_idx < adapter->num_q_vectors; q_idx++) {
>  		napi_disable(&adapter->q_vector[q_idx]->napi);
> +		while (!ixgbe_qv_lock_napi(adapter->q_vector[q_idx])) {
> +			pr_info("QV %d locked\n", q_idx);
> +			msleep(1);
> +		}
> +	}
> +	local_bh_enable();
>  }

Sleeping with preemption disabled?

Ben.

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
