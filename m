From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/2] ipv6: do not disable temp_address when reaching max_address
Date: Tue, 13 Aug 2013 18:31:11 +0400
Message-ID: <520A432F.4000308@cogentembedded.com>
References: <5209CEE2.70908@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:54087 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757021Ab3HMObI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 10:31:08 -0400
Received: by mail-la0-f48.google.com with SMTP id hi8so2246247lab.21
        for <netdev@vger.kernel.org>; Tue, 13 Aug 2013 07:31:06 -0700 (PDT)
In-Reply-To: <5209CEE2.70908@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08/13/2013 10:14 AM, Ding Tianhong wrote:

> A LAN user can remotely disable temporary address which may lead
> to privacy violatins and information disclosure.

> The reason is that the linux kernel uses the 'ipv6.max_addresses'
> option to specify how many ipv6 addresses and interface may have.
> The 'ipv6.regen_max_retry' (default value 3) option specifies
> how many times the kernel will try to create a new address.

> But the kernel is not distinguish between the event of reaching
> max_addresses for an interface and failing to generate a new address.
> the kernel disable the temporary address after regenerate a new
> address 'regen_max_retry' times.

> According RFC4941 3.3.7:

> ---------------------------------------

> If DAD indicates the address is already in use,
> the node must generate a new randomized interface
> identifier as described in section 3.2 above, and
> repeat the previous steps as appropriate up to
> TEMP_IDGEN_RETRIES times.

> If after TEMP_IDGEN_RETRIES consecutive attempts no
> non-unique address was generated, the node must log
> a system error and must not attempt to generate
> temporary address for that interface.

> ------------------------------------------

> RFC4941 3.3.7 specifies that disabling the temp_address must happen
> upon the address is already in use, not reach the max_address,
> So we have to check the return err and distinguish the correct retry path.

> This fixes CVE-2013-0343

> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> Tested-by: Wang Weidong <wangweidong1@huawei.com>
> Cc: David S. Miller <davem@davemloft.net>
> ---
>   net/ipv6/addrconf.c | 25 +++++++++++++++++++++----
>   1 file changed, 21 insertions(+), 4 deletions(-)

> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index da4241c..99f9fd5 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -1134,10 +1134,27 @@ retry:
[...]
> +		if (PTR_ERR(ift) == -EEXIST) {
> +			pr_info("%s: retry temporary address regeneration\n", __func__);
> +			tmpaddr = &addr;
> +			write_lock(&idev->lock);
> +			goto retry;
> +		} else
> +			goto out;

    According to CodingStyle, both arms of the *if* statement should have {} 
if one has it.

WBR, Sergei
