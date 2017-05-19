From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net 1/3] vlan: Fix tcp checksums offloads for Q-in-Q vlan.
Date: Fri, 19 May 2017 11:13:25 +0900
Message-ID: <7593b180-9355-2c14-6cd8-b1e4f47a0ae6@lab.ntt.co.jp>
References: <1495114265-23368-1-git-send-email-vyasevic@redhat.com>
 <1495114265-23368-2-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Vladislav Yasevich <vyasevic@redhat.com>, mkubecek@suse.cz
To: Vladislav Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:49508 "EHLO
        tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933072AbdESCOH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 22:14:07 -0400
In-Reply-To: <1495114265-23368-2-git-send-email-vyasevic@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017/05/18 22:31, Vladislav Yasevich wrote:
> It appears that since commit 8cb65d000, Q-in-Q vlans have been
> broken.  The series that commit is part of enabled TSO and checksum
> offloading on Q-in-Q vlans.  However, most HW we support can't handle
> it.  To work around the issue, the above commit added a function that
> turns off offloads on Q-in-Q devices, but it left the checksum offload.
> That will cause issues with most older devices that supprort very basic
> checksum offload capabilities as well as some newer devices (we've
> reproduced te problem with both be2net and bnx).
> 
> To solve this for everyone, turn off checksum offloading feature
> by default when sending Q-in-Q traffic.  Devices that are proven to
> work can provided a corrected ndo_features_check implemetation.
> 
> Fixes: 8cb65d000 ("net: Move check for multiple vlans to drivers")
> CC: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> ---
>  include/linux/if_vlan.h | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
> index 8d5fcd6..ae537f0 100644
> --- a/include/linux/if_vlan.h
> +++ b/include/linux/if_vlan.h
> @@ -619,7 +619,6 @@ static inline netdev_features_t vlan_features_check(const struct sk_buff *skb,
>  						     NETIF_F_SG |
>  						     NETIF_F_HIGHDMA |
>  						     NETIF_F_FRAGLIST |
> -						     NETIF_F_HW_CSUM |
>  						     NETIF_F_HW_VLAN_CTAG_TX |
>  						     NETIF_F_HW_VLAN_STAG_TX);
>  

I guess HW_CSUM theoretically can handle Q-in-Q packets and the problem
is IP_CSUM and IPV6_CSUM.
So wouldn't it be better to leave HW_CSUM and drop IP_CSUM/IPV6_CSUM,
i.e. change intersection into bitwise AND?

The intersection was introduced in db115037bb57 ("net: fix checksum
features handling in netif_skb_features()"), but I guess for this
particular check the intersection was not needed.

-- 
Toshiaki Makita
