From: Mark Lord <mlord@pobox.com>
Subject: Re: [PATCH] drivers/net/usb/r8152 fix broken rx checksums
Date: Wed, 26 Oct 2016 18:54:26 -0400
Message-ID: <ada8c79f-06df-97e3-2b29-9867bf473ea2@pobox.com>
References: <987cfbab-2b48-e28c-1706-967cb2051d63@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stable@vger.kernel.org
To: nic_swsd@realtek.com, netdev@vger.kernel.org,
        Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <987cfbab-2b48-e28c-1706-967cb2051d63@pobox.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-10-26 06:36 PM, Mark Lord wrote:
> The r8152 driver has been broken since (approx) 3.6.16,

Correction:  broken since 3.16.xx.

> when support was added for hardware rx checksum on newer chip versions.
> Symptoms include random segfaults and silent data corruption over NFS.
>
> This does not work on the VER_02 dongle I have here
> when used with a slow embedded system CPU.
> Google reveals others reporting similar issues on Raspberry Pi.
>
> So, disable hardware rx checksum for VER_02, and fix
> an obvious coding error for IPV6 checksums in the same function.
>
> Because this bug results in silent data corruption,
> it is a good candidate for back-porting to -stable >= 3.16.xx.
> Patch attached (to deal with buggy mailer) and also below for review.
>
> Signed-off-by: Mark Lord <mlord@pobox.com>
>
> --- old/drivers/net/usb/r8152.c    2016-09-30 04:20:43.000000000 -0400
> +++ linux/drivers/net/usb/r8152.c    2016-10-26 14:15:44.932517676 -0400
> @@ -1645,7 +1645,7 @@
>      u8 checksum = CHECKSUM_NONE;
>      u32 opts2, opts3;
>
> -    if (tp->version == RTL_VER_01)
> +    if (tp->version == RTL_VER_01 || tp->version == RTL_VER_02)
>          goto return_result;
>
>      opts2 = le32_to_cpu(rx_desc->opts2);
> @@ -1660,7 +1660,7 @@
>              checksum = CHECKSUM_NONE;
>          else
>              checksum = CHECKSUM_UNNECESSARY;
> -    } else if (RD_IPV6_CS) {
> +    } else if (opts2 & RD_IPV6_CS) {
>          if ((opts2 & RD_UDP_CS) && !(opts3 & UDPF))
>              checksum = CHECKSUM_UNNECESSARY;
>          else if ((opts2 & RD_TCP_CS) && !(opts3 & TCPF))


-- 
Mark Lord
Real-Time Remedies Inc.
mlord@pobox.com
