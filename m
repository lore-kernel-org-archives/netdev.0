From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] net: sctp: bug-fixing: retran_path not set properly after
 transports recovering (v3)
Date: Wed, 13 Nov 2013 20:42:20 -0500
Message-ID: <52842A7C.7060908@gmail.com>
References: <1384387106-8105-1-git-send-email-changxiangzhong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, davem@davemloft.net,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Chang Xiangzhong <changxiangzhong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f176.google.com ([209.85.216.176]:39912 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751462Ab3KNBmY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 20:42:24 -0500
In-Reply-To: <1384387106-8105-1-git-send-email-changxiangzhong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/13/2013 06:58 PM, Chang Xiangzhong wrote:
> When a transport recovers due to the new coming sack, SCTP should
> iterate all of its transport_list to locate the __two__ most recently used
> transport and set to active_path and retran_path respectively. The exising
> code does not find the two properly - In case of the following list:
>
> [most-recent] -> [2nd-most-recent] -> ...
>
> Both active_path and retran_path would be set to the 1st element.
>
> The bug happens when:
> 1) multi-homing
> 2) failure/partial_failure transport recovers
> Both active_path and retran_path would be set to the same most-recent one, in
> other words, retran_path would not take its role - an end user might not even
> notice this issue.
>
> Signed-off-by: Chang Xiangzhong <changxiangzhong@gmail.com>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

> ---
>   net/sctp/associola.c |    6 ++++--
>   1 file changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index ab67efc..8f26276 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -913,8 +913,8 @@ void sctp_assoc_control_transport(struct sctp_association *asoc,
>   		if (!first || t->last_time_heard > first->last_time_heard) {
>   			second = first;
>   			first = t;
> -		}
> -		if (!second || t->last_time_heard > second->last_time_heard)
> +		} else if (!second ||
> +			   t->last_time_heard > second->last_time_heard)
>   			second = t;
>   	}
>
> @@ -935,6 +935,8 @@ void sctp_assoc_control_transport(struct sctp_association *asoc,
>   		first = asoc->peer.primary_path;
>   	}
>
> +	if (!second)
> +		second = first;
>   	/* If we failed to find a usable transport, just camp on the
>   	 * primary, even if it is inactive.
>   	 */
>
