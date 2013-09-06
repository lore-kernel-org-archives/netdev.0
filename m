From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [net-next v4] vxlan: Notify drivers for listening UDP port changes
Date: Sat, 07 Sep 2013 01:05:13 +0200
Message-ID: <522A5FA9.7000001@redhat.com>
References: <1378286019-8719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	John Fastabend <john.r.fastabend@intel.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33521 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751070Ab3IFXFX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Sep 2013 19:05:23 -0400
In-Reply-To: <1378286019-8719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/04/2013 11:13 AM, Jeff Kirsher wrote:
> From: Joseph Gasparakis <joseph.gasparakis@intel.com>
>
> This patch adds two more ndo ops: ndo_add_rx_vxlan_port() and
> ndo_del_rx_vxlan_port().
>
> Drivers can get notifications through the above functions about changes
> of the UDP listening port of VXLAN. Also, when physical ports come up,
> now they can call vxlan_get_rx_port() in order to obtain the port number(s)
> of the existing VXLAN interface in case they already up before them.
>
> This information about the listening UDP port would be used for VXLAN
> related offloads.
>
> A big thank you to John Fastabend (john.r.fastabend@intel.com) for his
> input and his suggestions on this patch set.
>
> CC: John Fastabend <john.r.fastabend@intel.com>
> CC: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Joseph Gasparakis <joseph.gasparakis@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   drivers/net/vxlan.c       | 68 ++++++++++++++++++++++++++++++++++++++++++++++-
>   include/linux/netdevice.h | 19 +++++++++++++
>   include/net/vxlan.h       |  1 +
>   3 files changed, 87 insertions(+), 1 deletion(-)
[...]
> +/* Calls the ndo_add_vxlan_port of the caller in order to
> + * supply the listening VXLAN udp ports.
> + */
> +void vxlan_get_rx_port(struct net_device *dev)
> +{
> +	struct vxlan_sock *vs;
> +	struct net *net = dev_net(dev);
> +	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
> +	sa_family_t sa_family;
> +	u16 port;
> +	int i;
> +
> +	if (!dev || !dev->netdev_ops || !dev->netdev_ops->ndo_add_vxlan_port)
> +		return;

Here, either parts of this if statement are unnecessary, or in case they are
necessary then vars 'net' and 'vn' should have been assigned after that I think
as we would first get an offset and then dereference it before actually checking
if dev is NULL.

> +	spin_lock(&vn->sock_lock);
> +	for (i = 0; i < PORT_HASH_SIZE; ++i) {
> +		hlist_for_each_entry_rcu(vs, vs_head(net, i), hlist) {
> +			port = htons(inet_sk(vs->sock->sk)->inet_sport);
> +			sa_family = vs->sock->sk->sk_family;
> +			dev->netdev_ops->ndo_add_vxlan_port(dev, sa_family,
> +							    port);
> +		}
> +	}
> +	spin_unlock(&vn->sock_lock);
> +}
> +EXPORT_SYMBOL_GPL(vxlan_get_rx_port);
