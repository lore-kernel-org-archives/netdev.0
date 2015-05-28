From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next 01/14] ethtool: Add helper routines to pass vf to rx_flow_spec
Date: Thu, 28 May 2015 16:18:03 +0300
Message-ID: <CAJ3xEMhfzvhq-Y==LUTFg9Be9oWZZzKHEaTODeqphowpY8XLGw@mail.gmail.com>
References: <1432812339-17129-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1432812339-17129-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	Alex Duyck <alexander.h.duyck@redhat.com>,
	Matan Barak <matanb@mellanox.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:36701 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751466AbbE1NSE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 09:18:04 -0400
Received: by obbea2 with SMTP id ea2so32276587obb.3
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 06:18:03 -0700 (PDT)
In-Reply-To: <1432812339-17129-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 28, 2015 at 2:25 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: John Fastabend <john.r.fastabend@intel.com>
>
> The ring_cookie is 64 bits wide which is much larger than can be used
> for actual queue index values. So provide some helper routines to
> pack a VF index into the cookie. This is useful to steer packets to
> a VF ring without having to know the queue layout of the device.

So this patch comes  to generalize the proprietary solution introduced
in the below commit?

commit e7c8c60bc5d48994a67e4b1c7bfb01d6979dbc54
Author: Anjali Singhai Jain <anjali.singhai@intel.com>
Date:   Tue Apr 7 19:45:31 2015 -0400

    i40e: Add support to program FDir SB rules for VF from PF through ethtool

    With this patch we can now add Flow director Sideband rules for a VF from
    it's PF. Here is an example on how it can be done when VF id = 5 and
    queue = 2:

    "ethtool -N ethx flow-type udp4 src-ip x.x.x.x dst-ip y.y.y.y
src-port p1 dst-port p2 action 2 user-def 5"

    User-def specifies VF id and action specifies queue.


>  include/uapi/linux/ethtool.h | 25 +++++++++++++++++++++++++
>  1 file changed, 25 insertions(+)
>
> diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
> index ae832b4..0594933 100644
> --- a/include/uapi/linux/ethtool.h
> +++ b/include/uapi/linux/ethtool.h
> @@ -796,6 +796,31 @@ struct ethtool_rx_flow_spec {
>         __u32           location;
>  };
>
> +/* How rings are layed out when accessing virtual functions or
> + * offloaded queues is device specific. To allow users to do flow
> + * steering and specify these queues the ring cookie is partitioned
> + * into a 32bit queue index with an 8 bit virtual function id.
> + * This also leaves the 3bytes for further specifiers. It is possible
> + * future devices may support more than 256 virtual functions if
> + * devices start supporting PCIe w/ARI. However at the moment I
> + * do not know of any devices that support this so I do not reserve
> + * space for this at this time. If a future patch consumes the next
> + * byte it should be aware of this possiblity.
> + */
> +#define ETHTOOL_RX_FLOW_SPEC_RING      0x00000000FFFFFFFFLL
> +#define ETHTOOL_RX_FLOW_SPEC_RING_VF   0x000000FF00000000LL
> +#define ETHTOOL_RX_FLOW_SPEC_RING_VF_OFF 32
> +static inline __u64 ethtool_get_flow_spec_ring(__u64 ring_cookie)
> +{
> +       return ETHTOOL_RX_FLOW_SPEC_RING & ring_cookie;
> +};
> +
> +static inline __u64 ethtool_get_flow_spec_ring_vf(__u64 ring_cookie)
> +{
> +       return (ETHTOOL_RX_FLOW_SPEC_RING_VF & ring_cookie) >>
> +                               ETHTOOL_RX_FLOW_SPEC_RING_VF_OFF;
> +};
> +
>  /**
>   * struct ethtool_rxnfc - command to get or set RX flow classification rules
>   * @cmd: Specific command number - %ETHTOOL_GRXFH, %ETHTOOL_SRXFH,
> --
