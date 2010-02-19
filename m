From: Brian Haley <brian.haley@hp.com>
Subject: Re: BNX2: Kernel crashes with 2.6.31 and 2.6.31.9
Date: Fri, 19 Feb 2010 16:03:34 -0500
Message-ID: <4B7EFCA6.7050709@hp.com>
References: <20091229084929.54912c0c@pluto.restena.lu> <1262077540.12520.4.camel@localhost> <20091229145403.39f82773@pluto.restena.lu> <1262149691.2788.63.camel@localhost> <20100219091034.5fbb0165@pluto.restena.lu> <1266609426.2610.36.camel@dhcp-10-12-137-130.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Bruno_Pr=E9mont?= <bonbons@linux-vserver.org>,
	NetDEV <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Linux-Kernel <linux-kernel@vger.kernel.org>
To: Benjamin Li <benli@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1266609426.2610.36.camel@dhcp-10-12-137-130.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ben,

Benjamin Li wrote:
> Hi Bruno,
> 
> No problems.  Thanks for following up with this problem, I really
> appreciate all your help.
> 
>>From your logs it looks like the device came up using MSI, but in the
> MSI-X poll routine was being called:
> 
> [    9.836673] bnx2: eth0: using MSI
> ...
> 
> [  134.643459]  [<ffffffffa004019e>] bnx2_poll_msix+0x3e/0xd0 [bnx2]
> [  134.643465]  [<ffffffff8135bcd1>] netpoll_poll+0xe1/0x3c0
> 
> which is incorrect.  If we are in MSI mode, the bnx2_poll() routine
> should be used.
> 
> I think what is going on here is that during the bnx2x driver
> initialization the current bnx2 driver adds all possible NAPI structures
> that map to all the hardware vectors (BNX2_MAX_MSIX_VEC=9) to the NAPI
> list in the net_device structure regardless if they are used or not
> (Seen in drivers/net/bnx2.c:bnx2_init_napi()).  This can cause
> uninitialized NAPI structures to be placed on the napi_list.  Because
> this device is in MSI mode, only 1 vector is initialized.   Now, the
> problem is triggered when net/core/netpoll.c:poll_napi() is called.
> This is because this routine will run through the entire napi_list
> calling all the poll routines.  In your particular case, it is calling
> the poll routine on an uninitialized vector causing the kernel panic.
...
> @@ -8201,7 +8204,7 @@ bnx2_init_napi(struct bnx2 *bp)
>  {
>  	int i;
>  
> -	for (i = 0; i < BNX2_MAX_MSIX_VEC; i++) {
> +	for (i = 0; i < bp->irq_nvecs; i++) {
>  		struct bnx2_napi *bnapi = &bp->bnx2_napi[i];
>  		int (*poll)(struct napi_struct *, int);

Would this same change need to be made in other places, like bnx2_init_chip()
or bnx2_clear_ring_states() ?

-Brian
