From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] asix: Fix offset calculation in asix_rx_fixup()
 causing slow transmissions
Date: Tue, 17 May 2016 14:03:11 -0400 (EDT)
Message-ID: <20160517.140311.1099406541254675401.davem@davemloft.net>
References: <1463456175-6674-1-git-send-email-john.stultz@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Dean_Jenkins@mentor.com,
	linux@davidrobins.net, Mark_Craske@mentor.com, emilgoode@gmail.com,
	yongqin.liu@linaro.org, guodong.xu@linaro.org, ivecera@redhat.com,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	stable@vger.kernel.org
To: john.stultz@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49115 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752087AbcEQSDY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 14:03:24 -0400
In-Reply-To: <1463456175-6674-1-git-send-email-john.stultz@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Stultz <john.stultz@linaro.org>
Date: Mon, 16 May 2016 20:36:15 -0700

> In testing with HiKey, we found that since
> commit 3f30b158eba5 ("asix: On RX avoid creating bad Ethernet
> frames"),
> we're seeing lots of noise during network transfers:
 ...
> And network throughput ends up being pretty bursty and slow with
> a overall throughput of at best ~30kB/s (where as previously we
> got 1.1MB/s with the slower USB1.1 "full speed" host).
> 
> We found the issue also was reproducible on a x86_64 system,
> using a "high-speed" USB2.0 port but the throughput did not
> measurably drop (possibly due to the scp transfer being cpu
> bound on my slow test hardware).
> 
> After lots of debugging, I found the check added in the
> problematic commit seems to be calculating the offset
> incorrectly.
> 
> In the normal case, in the main loop of the function, we do:
> (where offset is zero, or set to "offset += (copy_length + 1) &
> 0xfffe" in the previous loop)
>     rx->header = get_unaligned_le32(skb->data +
>                                     offset);
>     offset += sizeof(u32);
> 
> But the problematic patch calculates:
>     offset = ((rx->remaining + 1) & 0xfffe) + sizeof(u32);
>     rx->header = get_unaligned_le32(skb->data + offset);
> 
> Adding some debug logic to check those offset calculation used
> to find rx->header, the one in problematic code is always too
> large by sizeof(u32).
> 
> Thus, this patch removes the incorrect " + sizeof(u32)" addition
> in the problematic calculation, and resolves the issue.
...
> Reported-by: Yongqin Liu <yongqin.liu@linaro.org>
> Signed-off-by: John Stultz <john.stultz@linaro.org>

Applied.
