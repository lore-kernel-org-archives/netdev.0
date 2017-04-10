From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] ipv6: Fix idev->addr_list corruption
Date: Mon, 10 Apr 2017 10:24:11 -0600
Message-ID: <590b8abc-93e3-f05e-bf63-5245a9860be1@cumulusnetworks.com>
References: <1491806199-26115-1-git-send-email-rabin.vincent@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Rabin Vincent <rabinv@axis.com>,
        Mike Manning <mmanning@brocade.com>
To: Rabin Vincent <rabin.vincent@axis.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:36265 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752515AbdDJQYO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 12:24:14 -0400
Received: by mail-pf0-f178.google.com with SMTP id o126so35692277pfb.3
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 09:24:14 -0700 (PDT)
In-Reply-To: <1491806199-26115-1-git-send-email-rabin.vincent@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/10/17 12:36 AM, Rabin Vincent wrote:
> From: Rabin Vincent <rabinv@axis.com>
> 
> addrconf_ifdown() removes elements from the idev->addr_list without
> holding the idev->lock.
> 
> If this happens while the loop in __ipv6_dev_get_saddr() is handling the
> same element, that function ends up in an infinite loop:
> 
>   NMI watchdog: BUG: soft lockup - CPU#1 stuck for 23s! [test:1719]
>   Call Trace:
>    ipv6_get_saddr_eval+0x13c/0x3a0
>    __ipv6_dev_get_saddr+0xe4/0x1f0
>    ipv6_dev_get_saddr+0x1b4/0x204
>    ip6_dst_lookup_tail+0xcc/0x27c
>    ip6_dst_lookup_flow+0x38/0x80
>    udpv6_sendmsg+0x708/0xba8
>    sock_sendmsg+0x18/0x30
>    SyS_sendto+0xb8/0xf8
>    syscall_common+0x34/0x58
> 
> Fixes: 6a923934c33 (Revert "ipv6: Revert optional address flusing on ifdown.")
> Signed-off-by: Rabin Vincent <rabinv@axis.com>
> ---
>  net/ipv6/addrconf.c | 11 +++++++----
>  1 file changed, 7 insertions(+), 4 deletions(-)
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 3631725..80ce478 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -3626,14 +3626,19 @@ static int addrconf_ifdown(struct net_device *dev, int how)
>  	INIT_LIST_HEAD(&del_list);
>  	list_for_each_entry_safe(ifa, tmp, &idev->addr_list, if_list) {
>  		struct rt6_info *rt = NULL;
> +		bool keep;
>  
>  		addrconf_del_dad_work(ifa);
>  
> +		keep = keep_addr && (ifa->flags & IFA_F_PERMANENT) &&
> +			!addr_is_local(&ifa->addr);
> +		if (!keep)
> +			list_move(&ifa->if_list, &del_list);
> +
>  		write_unlock_bh(&idev->lock);

yes, the list manipulation should be done under the idev->lock. thanks
for fixing.

Acked-by: David Ahern <dsa@cumulusnetworks.com>
