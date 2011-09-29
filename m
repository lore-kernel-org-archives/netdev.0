From: Xiao Jiang <jgq516@gmail.com>
Subject: Re: [PATCH] tg3: Dont dump registers if interface not ready.
Date: Thu, 29 Sep 2011 14:50:01 +0800
Message-ID: <4E841519.6040201@gmail.com>
References: <4E83D3B3.7090508@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Guru Anbalagane <guru.anbalagane@oracle.com>,
	Gurudas Pai <gurudas.pai@oracle.com>, <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Greg Marsden <greg.marsden@oracle.com>
To: Joe Jin <joe.jin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4E83D3B3.7090508@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Jin wrote:
> When bootup the server with BCM5704 Gigabit Ethernet get below warning:
>
> tg3 0000:03:01.0: eth0: DMA Status error.  Resetting chip.
> <Registers state of device>
> tg3 0000:03:01.0: eth0: 0: Host status block [00000007:00000002:(0000:0000:0000):(0000:0000)]
> tg3 0000:03:01.0: eth0: 0: NAPI info [00000001:00000002:(0000:0000:01ff):0000:(00c8:0000:0000:0000)]
> tg3 0000:03:01.0: eth0: Link is up at 1000 Mbps, full duplex
> tg3 0000:03:01.0: eth0: Flow control is on for TX and on for RX
> tg3 0000:03:01.0: tg3_stop_block timed out, ofs=4800 enable_bit=2
> tg3 0000:03:01.0: eth0: Link is down
> tg3 0000:03:01.0: eth0: Link is up at 1000 Mbps, full duplex
> tg3 0000:03:01.0: eth0: Flow control is on for TX and on for RX
>
> If device not ready, then would not dump registers info.
>
> Signed-off-by: Joe Jin <joe.jin@oracle.com>
> Signed-off-by: Guru Anbalagane <guru.anbalagane@oracle.com>
> Reported-by: Gurudas Pai <gurudas.pai@oracle.com>
> Cc: Matt Carlson <mcarlson@broadcom.com>
> Cc: Michael Chan <mchan@broadcom.com>
> ---
>  drivers/net/tg3.c |   11 +++++++++--
>   
Maybe this one should based on net-next tree too, the tg3.c
is lived below ./drivers/net/ethernet/broadcom/ in that tree.

Thanks,
Xiao Jiang
>  1 files changed, 9 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index 4a1374d..d79d344 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -5475,10 +5475,15 @@ static void tg3_process_error(struct tg3 *tp)
>  {
>  	u32 val;
>  	bool real_error = false;
> +	bool dump = true;
>  
>  	if (tg3_flag(tp, ERROR_PROCESSED))
>  		return;
>  
> +	/* If interface not ready then dont dump error */
> +	if (!netif_carrier_ok(tp->dev))
> +		dump = false;
> +
>  	/* Check Flow Attention register */
>  	val = tr32(HOSTCC_FLOW_ATTN);
>  	if (val & ~HOSTCC_FLOW_ATTN_MBUF_LWM) {
> @@ -5492,14 +5497,16 @@ static void tg3_process_error(struct tg3 *tp)
>  	}
>  
>  	if (tr32(RDMAC_STATUS) || tr32(WDMAC_STATUS)) {
> -		netdev_err(tp->dev, "DMA Status error.  Resetting chip.\n");
> +		if (dump)
> +			netdev_err(tp->dev, "DMA Status error.  Resetting chip.\n");
>  		real_error = true;
>  	}
>  
>  	if (!real_error)
>  		return;
>  
> -	tg3_dump_state(tp);
> +	if (dump)
> +		tg3_dump_state(tp);
>  
>  	tg3_flag_set(tp, ERROR_PROCESSED);
>  	schedule_work(&tp->reset_task);
>   
