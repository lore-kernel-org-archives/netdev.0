From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [PATCH 2/3] r8169: Large Send enablement
Date: Wed, 3 Nov 2004 18:16:11 -0600
Message-ID: <200411031816.11675.jdmason@us.ibm.com>
References: <200411021203.22003.jdmason@us.ibm.com> <20041102191103.GA24860@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20041102191103.GA24860@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tuesday 02 November 2004 01:11 pm, Francois Romieu wrote:
[...]
> - If rtl8169_open() fails [*] when the device was previously up, the driver
>   could/should try to recover.

I disagree.  It should fail, complain loudly, and let the user try and fix it 
(or return it to the previous state).  The code provided below will act like 
it is successful in changing the MTU, even if it hits an error and is in the 
process of recovering.  This will cause more difficult to diagnose problems.


> Untested example below to clarify.
>
> [*] page allocation failure, bigger mtu/rx buffers -> I feel moderately
>     confortable.
>
>
> diff -puN drivers/net/r8169.c~r8169-240 drivers/net/r8169.c
> --- linux-2.6.9/drivers/net/r8169.c~r8169-240 2004-10-21 21:55:45.000000000
> +0200 +++ linux-2.6.9-fr/drivers/net/r8169.c 2004-11-01 23:10:25.000000000
> +0100 @@ -120,6 +120,8 @@ static int multicast_filter_limit = 32;
>  #define RX_BUF_SIZE 1536 /* Rx Buffer size */
>  #define R8169_TX_RING_BYTES (NUM_TX_DESC * sizeof(struct TxDesc))
>  #define R8169_RX_RING_BYTES (NUM_RX_DESC * sizeof(struct RxDesc))
> +#define R8169_MIN_MTU  8
> +#define R8169_MAX_MTU  ((2 << 14) - 1)
[...]
> @@ -2223,6 +2247,72 @@ out:
>   return IRQ_RETVAL(handled);
>  }
>
> +static int rtl8169_set_rxbufsize(struct rtl8169_private *tp, int mtu)
> +{
> + if (mtu < R8169_MIN_MTU || mtu > R8169_MAX_MTU)

Is 8 really a valid MTU?  

-- 
Jon Mason
jdmason@us.ibm.com
