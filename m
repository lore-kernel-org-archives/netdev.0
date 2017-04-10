From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: move padding in struct skb_shared_info
Date: Mon, 10 Apr 2017 07:43:26 -0700
Message-ID: <1491835406.10587.12.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170410080755.GA24514@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, steffen.klassert@secunet.com,
        edumazet@google.com, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33277 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752841AbdDJOn3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 10:43:29 -0400
Received: by mail-pg0-f68.google.com with SMTP id 79so25961318pgf.0
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 07:43:29 -0700 (PDT)
In-Reply-To: <20170410080755.GA24514@avx2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-04-10 at 11:07 +0300, Alexey Dobriyan wrote:
> commit 7f564528a480084e2318cd48caba7aef4a54a77f
> ("skbuff: Extend gso_type to unsigned int.") created padding as first
> field of struct skb_shared_info requiring [R64+imm8] addressing mode
> for all fields.
> 
> Patch bubbles up padding brinding code size down to original levels and
> even smaller:
> 
> 	add/remove: 0/0 grow/shrink: 4/304 up/down: 20/-720 (-700)
> 	function                                     old     new   delta
> 	iwl_trans_pcie_tx                           3994    4006     +12
> 	tap_do_read                                 1070    1074      +4
> 	packet_recvmsg                              1155    1157      +2
> 	be_xmit                                     2038    2040      +2
> 	zerocopy_sg_from_iter                        455     454      -1
> 		...
> 	__ef4_rx_packet                             1358    1349      -9
> 	hix5hd2_poll                                1787    1777     -10
> 	e1000_clean_jumbo_rx_irq                    3599    3587     -12
> 	skb_try_coalesce                            1118    1105     -13
> 	xenvif_tx_build_gops                        5057    5043     -14
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> ---
> 
>  include/linux/skbuff.h |    1 -
>  1 file changed, 1 deletion(-)
> 
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -413,7 +413,6 @@ struct ubuf_info {
>   * the end of the header data, ie. at skb->end.
>   */
>  struct skb_shared_info {
> -	unsigned short	_unused;
>  	unsigned char	nr_frags;
>  	__u8		tx_flags;
>  	unsigned short	gso_size;

Nack

This exact placement was discussed at Netconf and Netdev.

We had off-by-one errors in the past leading to nr_frags being mangled,
and some exploits were quite happy to use these bugs.

Some shuffling in shared_info might help us to find other bugs, and give
more work to security researchers
