From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 3/4] bonding: arp_ip_count and arp_targets can be wrong
Date: Sun, 19 May 2013 01:28:38 +0400
Message-ID: <5197F286.1070505@cogentembedded.com>
References: <1368875911-4952-1-git-send-email-nikolay@redhat.com> <1368875911-4952-4-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:36912 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752988Ab3ERV2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 May 2013 17:28:30 -0400
Received: by mail-lb0-f175.google.com with SMTP id v10so5419023lbd.20
        for <netdev@vger.kernel.org>; Sat, 18 May 2013 14:28:29 -0700 (PDT)
In-Reply-To: <1368875911-4952-4-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 18-05-2013 15:18, Nikolay Aleksandrov wrote:

> When getting arp_ip_targets if we encounter a bad IP, arp_ip_count still
> gets increased and all the targets after the wrong one will not be probed
> if arp_interval is enabled after that (unless a new IP target is added
> through sysfs) because of the zero entry, in this case reading
> arp_ip_target through sysfs will show valid targets even if there's a
> zero entry.
> Example: 1.2.3.4,4.5.6.7,blah,5.6.7.8
> When retrieving the list from arp_ip_target the output would be:
> 1.2.3.4,4.5.6.7,5.6.7.8
> but there will be a 0 entry between 4.5.6.7 and 5.6.7.8. If arp_interval
> is enabled after that 5.6.7.8 will never be checked because of that.

> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> ---
>   drivers/net/bonding/bond_main.c | 19 ++++++++-----------
>   1 file changed, 8 insertions(+), 11 deletions(-)

> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 1a0cc13..d6a96cb 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
[...]
> @@ -4650,19 +4650,18 @@ static int bond_check_params(struct bond_params *params)
>   		arp_interval = BOND_LINK_ARP_INTERV;
>   	}
>
> -	for (arp_ip_count = 0;
> -	     (arp_ip_count < BOND_MAX_ARP_TARGETS) && arp_ip_target[arp_ip_count];
> -	     arp_ip_count++) {
> +	for (arp_ip_count = 0, i = 0;
> +	     (arp_ip_count < BOND_MAX_ARP_TARGETS) && arp_ip_target[i]; i++) {
>   		/* not complete check, but should be good enough to
>   		   catch mistakes */
> -		__be32 ip = in_aton(arp_ip_target[arp_ip_count]);
> -		if (!isdigit(arp_ip_target[arp_ip_count][0]) ||
> -		    ip == 0 || ip == htonl(INADDR_BROADCAST)) {
> +		__be32 ip = in_aton(arp_ip_target[i]);

    Empty line wouldn't hurt here, after declaration.

> +		if (!isdigit(arp_ip_target[i][0]) || ip == 0 ||
> +		    ip == htonl(INADDR_BROADCAST)) {
