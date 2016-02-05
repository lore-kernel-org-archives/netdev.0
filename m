From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 net-next 4/4] net: fib: avoid calling fib_flush for
 each device when doing batch close and unregister
Date: Fri, 5 Feb 2016 19:04:02 +0300
Message-ID: <56B4C7F2.1020109@cogentembedded.com>
References: <1454628956-4803-1-git-send-email-noureddine@arista.com>
 <1454628956-4803-5-git-send-email-noureddine@arista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Salam Noureddine <noureddine@arista.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:34070 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753967AbcBEQEH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 11:04:07 -0500
Received: by mail-lb0-f178.google.com with SMTP id cw1so52076700lbb.1
        for <netdev@vger.kernel.org>; Fri, 05 Feb 2016 08:04:05 -0800 (PST)
In-Reply-To: <1454628956-4803-5-git-send-email-noureddine@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/05/2016 02:35 AM, Salam Noureddine wrote:

> Call fib_flush at the end when closing or unregistering multiple
> devices. This can save walking the fib many times and greatly
> reduce rtnl_lock hold time when unregistering many devices with
> a fib having hundreds of thousands of routes.
>
> Signed-off-by: Salam Noureddine <noureddine@arista.com>
> ---
>   include/net/netns/ipv4.h |  1 +
>   net/ipv4/fib_frontend.c  | 16 ++++++++++++++--
>   2 files changed, 15 insertions(+), 2 deletions(-)
>
> diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
> index d75be32..d59a078 100644
> --- a/include/net/netns/ipv4.h
> +++ b/include/net/netns/ipv4.h
[...]
> diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
> index 4734475..808426e 100644
> --- a/net/ipv4/fib_frontend.c
> +++ b/net/ipv4/fib_frontend.c
> @@ -1161,11 +1161,22 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
>   	unsigned int flags;
>
>   	if (event == NETDEV_UNREGISTER) {
> -		fib_disable_ip(dev, event, true);
> +		if (fib_sync_down_dev(dev, event, true))
> +			net->ipv4.needs_fib_flush = true;
>   		rt_flush_dev(dev);
>   		return NOTIFY_DONE;
>   	}
>
> +	if (event == NETDEV_UNREGISTER_BATCH || event == NETDEV_DOWN_BATCH) {
> +		if (net->ipv4.needs_fib_flush) {
> +			fib_flush(net);
> +			net->ipv4.needs_fib_flush = false;
> +		}
> +		rt_cache_flush(net);
> +		arp_ifdown_all();
> +		return NOTIFY_DONE;
> +	}
> +

    I'd convert to *switch* the above 2 *if*'s...

[...]

MBR, Sergei
