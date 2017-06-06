From: Marcin Nowakowski <marcin.nowakowski@imgtec.com>
Subject: Re: [PATCH v3 6/7] net: pch_gbe: Allow longer for resets
Date: Tue, 6 Jun 2017 16:10:14 +0200
Message-ID: <bb3deb9d-26b5-af4b-455f-a94155adc472@imgtec.com>
References: <20170602234042.22782-1-paul.burton@imgtec.com>
 <20170602234042.22782-7-paul.burton@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tobias Klauser <tklauser@distanz.ch>,
        "David S . Miller" <davem@davemloft.net>,
        Jarod Wilson <jarod@redhat.com>, <linux-mips@linux-mips.org>,
        Eric Dumazet <edumazet@google.com>
To: Paul Burton <paul.burton@imgtec.com>, <netdev@vger.kernel.org>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <20170602234042.22782-7-paul.burton@imgtec.com>
Content-Language: en-US
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

Hi Paul,

On 03.06.2017 01:40, Paul Burton wrote:
> Resets of the EG20T MAC on the MIPS Boston development board take longer
> than the 1000 loops that pch_gbe_wait_clr_bit was performing. Rather
> than simply increasing the number of loops, switch to using
> readl_poll_timeout_atomic() from linux/iopoll.h in order to provide some
> independence from the speed of the CPU.
> 
>   #define DRV_VERSION     "1.01"
> @@ -318,13 +319,11 @@ s32 pch_gbe_mac_read_mac_addr(struct pch_gbe_hw *hw)
>    */
>   static void pch_gbe_wait_clr_bit(void *reg, u32 bit)
>   {
> +	int err;
>   	u32 tmp;
>   
> -	/* wait busy */
> -	tmp = 1000;
> -	while ((ioread32(reg) & bit) && --tmp)
> -		cpu_relax();
> -	if (!tmp)
> +	err = readl_poll_timeout_atomic(reg, tmp, !(tmp & bit), 10, 500);
> +	if (err)
>   		pr_err("Error: busy bit is not cleared\n");
>   }

This new timeout value appears to be too low - I'm seeing plenty of 
timeout warnings now and ultimately the device fails to initialise:

[    7.541876] pch_gbe: EG20T PCH Gigabit Ethernet Driver - version 1.01
[    7.566451] pch_gbe: Error: busy bit is not cleared
[    7.572654] pch_gbe: Error: busy bit is not cleared
[    7.578727] pch_gbe: Error: busy bit is not cleared
[    7.587814] pch_gbe 0000:02:00.1: Invalid MAC address, interface 
disabled.
[    7.595605] pch_gbe 0000:02:00.1: MAC address : 00:00:00:00:00:00
[    7.606451] pch_gbe: Error: busy bit is not cleared
[    7.612572] pch_gbe: Error: busy bit is not cleared
[    7.618618] pch_gbe: Error: busy bit is not cleared
<...>
[   10.063351] pch_gbe 0000:02:00.1 eth0: Error: Invalid MAC address
[   10.074713] pch_gbe: Error: busy bit is not cleared
[   10.081030] pch_gbe: Error: busy bit is not cleared
[   10.087178] pch_gbe: Error: busy bit is not cleared
[   10.093328] pch_gbe: Error: busy bit is not cleared
[   10.100883] pch_gbe 0000:02:00.1 eth0: Error End
[   10.106272] IP-Config: Failed to open eth0

My tests show that a timeout value as big as 20000 may be required to 
make it work reliably ...

Marcin
