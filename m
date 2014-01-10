From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net V3 2/2] net: core: explicitly select a txq before
 doing l2 forwarding
Date: Fri, 10 Jan 2014 09:37:56 -0800
Message-ID: <52D02FF4.3020105@intel.com>
References: <1389341906-2367-1-git-send-email-jasowang@redhat.com> <1389341906-2367-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com,
	Neil Horman <nhorman@tuxdriver.com>,
	e1000-devel@lists.sourceforge.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389341906-2367-2-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/10/2014 12:18 AM, Jason Wang wrote:
> Currently, the tx queue were selected implicitly in ndo_dfwd_start_xmit(). The
> will cause several issues:
>
> - NETIF_F_LLTX were removed for macvlan, so txq lock were done for macvlan
>    instead of lower device which misses the necessary txq synchronization for
>    lower device such as txq stopping or frozen required by dev watchdog or
>    control path.
> - dev_hard_start_xmit() was called with NULL txq which bypasses the net device
>    watchdog.
> - dev_hard_start_xmit() does not check txq everywhere which will lead a crash
>    when tso is disabled for lower device.
>
> Fix this by explicitly introducing a new param for .ndo_select_queue() for just
> selecting queues in the case of l2 forwarding offload. netdev_pick_tx() was also
> extended to accept this parameter and dev_queue_xmit_accel() was used to do l2
> forwarding transmission.
>
> With this fixes, NETIF_F_LLTX could be preserved for macvlan and there's no need
> to check txq against NULL in dev_hard_start_xmit(). Also there's no need to keep
> a dedicated ndo_dfwd_start_xmit() and we can just reuse the code of
> dev_queue_xmit() to do the transmission.
>
> In the future, it was also required for macvtap l2 forwarding support since it
> provides a necessary synchronization method.
>
> Cc: John Fastabend <john.r.fastabend@intel.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Cc: e1000-devel@lists.sourceforge.net
> Signed-off-by: Jason Wang <jasowang@redhat.com>
>
> ---
> Changes from V2:
> - Reuse dev_queue_xmit() instead of re-inventing dfwd_direct_xmit()
> - remove the unnecessary braces
> Changes from V1:
> - Adding a new parameter to ndo_select_queue instead of a new method to select
>    queue for l2 forwarding.
> - Remove the unnecessary ndo_dfwd_start_xmit() since txq was selected
>    explicitly.
> - Keep NETIF_F_LLTX when netdev feature is changed.
> - Shape the commit log
> ---

Looks good to me thanks, I tested my macvlan use cases and everything
works as expected.

Acked-by: John Fastabend <john.r.fastabend@intel.com>
