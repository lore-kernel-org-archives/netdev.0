From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH v2] macvlan: validate flags
Date: Thu, 01 Aug 2013 10:24:19 -0700
Message-ID: <51FA99C3.8020508@intel.com>
References: <1375373227-17986-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:31683 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751855Ab3HARYU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Aug 2013 13:24:20 -0400
In-Reply-To: <1375373227-17986-1-git-send-email-mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/1/2013 9:09 AM, Michael S. Tsirkin wrote:
> commit df8ef8f3aaa6692970a436204c4429210addb23a
>      macvlan: add FDB bridge ops and macvlan flags
> added a flags field to macvlan, which can be
> controlled from userspace.
> The idea is to make the interface future-proof
> so we can add flags and not new fields.
>
> However, flags value isn't validated, as a result,
> userspace can't detect which flags are supported.
>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>
> Changes from v1:
> 	tweaked commit message
> 	no code changes
>
> Please consider this patch for -stable.
>
> The idea is by the time we add more flags,
> everyone has updated to a kernel that
> detects errors, so userspace will be able
> to detect supported flags cleanly.
>

Agreed and because we haven't added more flags yet this shouldn't
break uapi. Thanks for catching this.

>
>   drivers/net/macvlan.c | 7 +++++++
>   1 file changed, 7 insertions(+)
>

By the same logic should we also add the check to macvlan_changelink()?

> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index 18373b6..8445a94 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -736,6 +736,10 @@ static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
>   			return -EADDRNOTAVAIL;
>   	}
>
> +	if (data && data[IFLA_MACVLAN_FLAGS] &&
> +	    nla_get_u16(data[IFLA_MACVLAN_FLAGS]) & ~MACVLAN_FLAG_NOPROMISC)
> +		return -EINVAL;
> +
>   	if (data && data[IFLA_MACVLAN_MODE]) {
>   		switch (nla_get_u32(data[IFLA_MACVLAN_MODE])) {
>   		case MACVLAN_MODE_PRIVATE:
> @@ -809,6 +813,9 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
>   	if (data && data[IFLA_MACVLAN_FLAGS])
>   		vlan->flags = nla_get_u16(data[IFLA_MACVLAN_FLAGS]);
>
> +	if (vlan->flags & ~MACVLAN_FLAG_NOPROMISC)
> +		return -EINVAL;
> +

Is there really a case where newlink is called without first calling
validate? I don't think there is so the snippet here in newlink could
be dropped.

Thanks,
John
