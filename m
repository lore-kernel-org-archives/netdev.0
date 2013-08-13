From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] macvtap: Correctly set tap features when IFF_VNET_HDR
 is disabled.
Date: Tue, 13 Aug 2013 22:05:45 +0400
Message-ID: <520A7579.10601@cogentembedded.com>
References: <1376416558-25015-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:58685 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759057Ab3HMSFk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 14:05:40 -0400
Received: by mail-la0-f46.google.com with SMTP id eh20so6028783lab.5
        for <netdev@vger.kernel.org>; Tue, 13 Aug 2013 11:05:39 -0700 (PDT)
In-Reply-To: <1376416558-25015-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08/13/2013 09:55 PM, Vlad Yasevich wrote:

> When the user turns off IFF_VNET_HDR flag, attempts to change
> offload features via TUNSETOFFLOAD do not work.  This could cause
> GSO packets to be delivered to the user when the user is
> not prepared to handle them.

> To solve, allow processing of TUNSETOFFLOAD when IFF_VNET_HDR is
> disabled and make sure to turn off all offloads in this case.
> Also, when IFF_VNET_HDR is disabled, run throught the offload change
> as well to make sure that the functionality is not dependent on
> the order of the ioclt() calls.

> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>   drivers/net/macvtap.c | 27 +++++++++++++++++++--------
>   1 file changed, 19 insertions(+), 8 deletions(-)

> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index a98fb0e..076b9e7 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
[...]
> @@ -1092,8 +1097,18 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
>   		if ((u & ~(IFF_VNET_HDR | IFF_MULTI_QUEUE)) !=
>   		    (IFF_NO_PI | IFF_TAP))
>   			ret = -EINVAL;
> -		else
> +		else {
> +			if ((q->flags ^ u) & IFF_VNET_HDR) {
> +				/* vnet_hdr support impacts the offloads,
> +				 * so we need to run throught the offload
> +				 * change.
> +				 */
> +				rtnl_lock();
> +				ret = set_offload(q, 0);
> +				rtnl_unlock();
> +			}
>   			q->flags = u;
> +		}

    According to Documentation/CodingStyle, both arms of the *if* statement 
should have {} if one arm has it.

WBR, Sergei
