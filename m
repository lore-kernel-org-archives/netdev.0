From: Greg Rose <gvrose8192@gmail.com>
Subject: Re: [PATCH net] netvsc: fix calculation of available send sections
Date: Mon, 24 Apr 2017 20:20:57 -0700
Message-ID: <1493090457.17866.15.camel@gmail.com>
References: <20170425013338.2653-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        Stephen Hemminger <sthemmin@microsoft.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35031 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S980254AbdDYDVC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 23:21:02 -0400
Received: by mail-it0-f66.google.com with SMTP id 70so1383628ita.2
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 20:21:01 -0700 (PDT)
In-Reply-To: <20170425013338.2653-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-04-24 at 18:33 -0700, Stephen Hemminger wrote:
> My change (introduced in 4.11) to use find_first_clear_bit
> incorrectly assumed that the size argument was words, not bits.

Oops...

> The effect was only a small limited number of the available send
> sections were being actually used. This can cause performance loss
> with some workloads.
> 
> Since map_words is now used only during initialization, it can
> be on stack instead of in per-device data.
> 
> Fixes: b58a185801da ("netvsc: simplify get next send section")
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

Looks good to me.

Reviewed by Greg Rose <gvrose8192@gmail.com>

> ---
>  drivers/net/hyperv/hyperv_net.h | 1 -
>  drivers/net/hyperv/netvsc.c     | 9 ++++-----
>  2 files changed, 4 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
> index f9f3dba7a588..db23cb36ae5c 100644
> --- a/drivers/net/hyperv/hyperv_net.h
> +++ b/drivers/net/hyperv/hyperv_net.h
> @@ -751,7 +751,6 @@ struct netvsc_device {
>  	u32 send_section_cnt;
>  	u32 send_section_size;
>  	unsigned long *send_section_map;
> -	int map_words;
>  
>  	/* Used for NetVSP initialization protocol */
>  	struct completion channel_init_wait;
> diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
> index 8dd0b8770328..15ef713d96c0 100644
> --- a/drivers/net/hyperv/netvsc.c
> +++ b/drivers/net/hyperv/netvsc.c
> @@ -236,6 +236,7 @@ static int netvsc_init_buf(struct hv_device *device)
>  	struct netvsc_device *net_device;
>  	struct nvsp_message *init_packet;
>  	struct net_device *ndev;
> +	size_t map_words;
>  	int node;
>  
>  	net_device = get_outbound_net_device(device);
> @@ -401,11 +402,9 @@ static int netvsc_init_buf(struct hv_device *device)
>  		   net_device->send_section_size, net_device->send_section_cnt);
>  
>  	/* Setup state for managing the send buffer. */
> -	net_device->map_words = DIV_ROUND_UP(net_device->send_section_cnt,
> -					     BITS_PER_LONG);
> +	map_words = DIV_ROUND_UP(net_device->send_section_cnt, BITS_PER_LONG);
>  
> -	net_device->send_section_map = kcalloc(net_device->map_words,
> -					       sizeof(ulong), GFP_KERNEL);
> +	net_device->send_section_map = kcalloc(map_words, sizeof(ulong), GFP_KERNEL);
>  	if (net_device->send_section_map == NULL) {
>  		ret = -ENOMEM;
>  		goto cleanup;
> @@ -683,7 +682,7 @@ static u32 netvsc_get_next_send_section(struct netvsc_device *net_device)
>  	unsigned long *map_addr = net_device->send_section_map;
>  	unsigned int i;
>  
> -	for_each_clear_bit(i, map_addr, net_device->map_words) {
> +	for_each_clear_bit(i, map_addr, net_device->send_section_cnt) {
>  		if (sync_test_and_set_bit(i, map_addr) == 0)
>  			return i;
>  	}
