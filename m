From: Venkatesh Srinivas <venkateshs@google.com>
Subject: Re: [PATCH net] ixgbe: napi_poll must return the work done
Date: Wed, 15 Jun 2016 09:34:49 -0700
Message-ID: <CAHdzE-8V8o9sg9xmiJ9J0G3u=k6K-fHQssb5v09TPJvN2N=a1Q@mail.gmail.com>
References: <37ccedd746ed932b9d73eff592f324f2a3fc6c6f.1465995724.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	intel-wired-lan@lists.osuosl.org,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@redhat.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f169.google.com ([209.85.220.169]:36567 "EHLO
	mail-qk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751907AbcFOQeu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 12:34:50 -0400
Received: by mail-qk0-f169.google.com with SMTP id p10so26339391qke.3
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 09:34:50 -0700 (PDT)
In-Reply-To: <37ccedd746ed932b9d73eff592f324f2a3fc6c6f.1465995724.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 15, 2016 at 6:37 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> Currently the function ixgbe_poll() returns 0 when it clean completely
> the rx rings, but this foul budget accounting in core code.
> Fix this returning the actual work done, capped to weight - 1, since
> the core doesn't allow to return the full budget when the driver modifies
> the napi status
>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index 088c47c..8bebd86 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -2887,7 +2887,7 @@ int ixgbe_poll(struct napi_struct *napi, int budget)
>         if (!test_bit(__IXGBE_DOWN, &adapter->state))
>                 ixgbe_irq_enable_queues(adapter, BIT_ULL(q_vector->v_idx));
>
> -       return 0;
> +       return min(work_done, budget - 1);
>  }
>
>  /**

Reviewed-by: Venkatesh Srinivas <venkateshs@google.com>

The same bit of code appears in fm10k and i40e/i40evf. ixgb appears to
correctly return work_done.

ixgbe_poll also appears to return an (minor) incorrect work_done in
another case, BTW. It divides its
budget between Rx rings associated with a vector. If any ring exceeds
its share of the budget, ixgbe_poll
claims to have consumed the full budget, even if a full budget of
frames was not received in a single
pass.

-- vs;
