From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net 2/2] net: core: explicitly select a txq before doing
 l2 forwarding
Date: Mon, 6 Jan 2014 07:42:48 -0500
Message-ID: <20140106124248.GB24280@hmsreliant.think-freely.org>
References: <1388978467-2075-1-git-send-email-jasowang@redhat.com>
 <1388978467-2075-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com,
	John Fastabend <john.r.fastabend@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1388978467-2075-2-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 06, 2014 at 11:21:07AM +0800, Jason Wang wrote:
> Currently, the tx queue were selected implicitly in ndo_dfwd_start_xmit(). The
> will cause several issues:
> 
> - NETIF_F_LLTX was forced for macvlan device in this case which lead extra lock
>   contention.
> - dev_hard_start_xmit() was called with NULL txq which bypasses the net device
>   watchdog
> - dev_hard_start_xmit() does not check txq everywhere which will lead a crash
>   when tso is disabled for lower device.
> 
> Fix this by explicitly introducing a select queue method just for l2 forwarding
> offload (ndo_dfwd_select_queue), and introducing dfwd_direct_xmit() to do the
> queue selecting and transmitting for l2 forwarding.
> 
> With this fixes, NETIF_F_LLTX could be preserved for macvlan and there's no need
> to check txq against NULL in dev_hard_start_xmit().
> 
> In the future, it was also required for macvtap l2 forwarding support since it
> provides a necessary synchronization method.
> 
> Cc: John Fastabend <john.r.fastabend@intel.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Cc: e1000-devel@lists.sourceforge.net
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Instead of creating another operation here to do special queue selection, why
not just have ndo_dfwd_start_xmit include a pointer to a pointer in its argument
list, so it can pass the txq it used back to the caller (dev_hard_start_xmit)?
ndo_dfwd_start_xmit already knows which queue set to pick from (since their
reserved for the device doing the transmitting).  It seems more clear to me than
creating a new netdevice operation.  

As for the crash issue, I'm not sure what you mean.  Where in
dev_hard_start_xmit would we need to check txq that we're not currently, and
what crash results?

Also, can you elaborate on what you mean by additional lock contention?  What
contention do you see that goes above and beyond the normal locking required by
txq access?  I suppose its extra locking above and beyond in the macvtap case,
where you would otherwise never hit hardware, but that not the only use case,
and I think the solution there is likely to add some code in the macvlan feature
set handler so that NETIF_F_LLTX is cleared if you disable the hardware
forwarding acceleration via ethtool.

Regards
Neil

> 
