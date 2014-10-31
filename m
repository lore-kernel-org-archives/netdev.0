From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 2/3] r8152: clear the flag of
 SCHEDULE_TASKLET in tasklet
Date: Fri, 31 Oct 2014 16:15:20 -0400 (EDT)
Message-ID: <20141031.161520.3547230591227504.davem@davemloft.net>
References: <1394712342-15778-75-Taiwan-albertk@realtek.com>
	<1394712342-15778-79-Taiwan-albertk@realtek.com>
	<1394712342-15778-81-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-81-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Fri, 31 Oct 2014 17:56:41 +0800

> Clear the flag of SCHEDULE_TASKLET in bottom_half() to avoid
> re-schedule the tasklet again by workqueue.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> ---
>  drivers/net/usb/r8152.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
> index ff54098..670279a 100644
> --- a/drivers/net/usb/r8152.c
> +++ b/drivers/net/usb/r8152.c
> @@ -1798,6 +1798,9 @@ static void bottom_half(unsigned long data)
>  	if (!netif_carrier_ok(tp->netdev))
>  		return;
>  
> +	if (test_bit(SCHEDULE_TASKLET, &tp->flags))
> +		clear_bit(SCHEDULE_TASKLET, &tp->flags);

This is racey.

If another thread of control sets the bit between the test and the
clear, you will lose an event.

It really never makes sense to work with atomic bitops in a non-atomic
test-and-whatever manner like this, it's always a red flag and
indicates you're doing something very wrong.
