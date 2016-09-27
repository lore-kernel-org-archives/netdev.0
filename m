From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v7 5/8] thunderbolt: Networking state machine
Date: Tue, 27 Sep 2016 16:13:42 +0200
Message-ID: <20160927141342.GC21133@kroah.com>
References: <1474983821-2313-1-git-send-email-amir.jer.levy@intel.com>
 <1474983821-2313-6-git-send-email-amir.jer.levy@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andreas.noever@gmail.com, bhelgaas@google.com, corbet@lwn.net,
        linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
        netdev@vger.kernel.org, linux-doc@vger.kernel.org,
        mario_limonciello@dell.com, thunderbolt-linux@intel.com,
        mika.westerberg@intel.com, tomas.winkler@intel.com,
        xiong.y.zhang@intel.com
To: Amir Levy <amir.jer.levy@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:37119 "EHLO
        mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753835AbcI0ONw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 10:13:52 -0400
Content-Disposition: inline
In-Reply-To: <1474983821-2313-6-git-send-email-amir.jer.levy@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 27, 2016 at 04:43:38PM +0300, Amir Levy wrote:
> This patch builds the peer to peer communication path.
> Communication is established by a negotiation process whereby messages are
> sent back and forth between the peers until a connection is established.
> This includes the Thunderbolt Network driver communication with the second
> peer via Intel Connection Manager(ICM) firmware.
>   +--------------------+            +--------------------+
>   |Host 1              |            |Host 2              |
>   |                    |            |                    |
>   |     +-----------+  |            |     +-----------+  |
>   |     |Thunderbolt|  |            |     |Thunderbolt|  |
>   |     |Networking |  |            |     |Networking |  |
>   |     |Driver     |  |            |     |Driver     |  |
>   |     +-----------+  |            |     +-----------+  |
>   |              ^     |            |              ^     |
>   |              |     |            |              |     |
>   | +------------+---+ |            | +------------+---+ |
>   | |Thunderbolt |   | |            | |Thunderbolt |   | |
>   | |Controller  v   | |            | |Controller  v   | |
>   | |         +---+  | |            | |         +---+  | |
>   | |         |ICM|<-+-+------------+-+-------->|ICM|  | |
>   | |         +---+  | |            | |         +---+  | |
>   | +----------------+ |            | +----------------+ |
>   +--------------------+            +--------------------+
> Note that this patch only establishes the link between the two hosts and
> not Network Packet handling - this is dealt with in the next patch.
> 
> Signed-off-by: Amir Levy <amir.jer.levy@intel.com>
> ---
>  drivers/thunderbolt/icm/Makefile  |   2 +-
>  drivers/thunderbolt/icm/icm_nhi.c | 303 ++++++++++++++-
>  drivers/thunderbolt/icm/net.c     | 793 ++++++++++++++++++++++++++++++++++++++
>  drivers/thunderbolt/icm/net.h     |  70 ++++
>  4 files changed, 1157 insertions(+), 11 deletions(-)
>  create mode 100644 drivers/thunderbolt/icm/net.c
> 
> diff --git a/drivers/thunderbolt/icm/Makefile b/drivers/thunderbolt/icm/Makefile
> index f0d0fbb..94a2797 100644
> --- a/drivers/thunderbolt/icm/Makefile
> +++ b/drivers/thunderbolt/icm/Makefile
> @@ -1,2 +1,2 @@
>  obj-${CONFIG_THUNDERBOLT_ICM} += thunderbolt-icm.o
> -thunderbolt-icm-objs := icm_nhi.o
> +thunderbolt-icm-objs := icm_nhi.o net.o
> diff --git a/drivers/thunderbolt/icm/icm_nhi.c b/drivers/thunderbolt/icm/icm_nhi.c
> index 984aa7c..578eb14 100644
> --- a/drivers/thunderbolt/icm/icm_nhi.c
> +++ b/drivers/thunderbolt/icm/icm_nhi.c
> @@ -74,6 +74,12 @@ static const struct nla_policy nhi_genl_policy[NHI_ATTR_MAX + 1] = {
>  					.len = TBT_ICM_RING_MAX_FRAME_SIZE },
>  	[NHI_ATTR_MSG_FROM_ICM]		= { .type = NLA_BINARY,
>  					.len = TBT_ICM_RING_MAX_FRAME_SIZE },
> +	[NHI_ATTR_LOCAL_ROUTE_STRING]	= {.len = sizeof(struct route_string)},
> +	[NHI_ATTR_LOCAL_UUID]		= { .len = sizeof(uuid_be) },
> +	[NHI_ATTR_REMOTE_UUID]		= { .len = sizeof(uuid_be) },

Be consistent in your choice of whitespace please.
