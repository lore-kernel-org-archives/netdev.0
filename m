From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: r8169: panic on 2.6.11
Date: Fri, 4 Mar 2005 23:03:50 -0600
Message-ID: <200503042303.50055.jdmason@us.ibm.com>
References: <20050304132804.270cf05b@dxpl.pdx.osdl.net> <20050304154903.7b7e0fb1@dxpl.pdx.osdl.net> <20050305003735.GE1148@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050305003735.GE1148@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I tested the patch below on amd64, and have found a problem.  My adapter 
always has the FOVF bit set, so the adapter never pings.  

After looking at the opts1 register output of my adapter and Steven's, I 
noticed something weird.  For every packet, I am getting opts1 = 0x3481c040.  
Now, compare this to opts=803ff0 from Steven's last test.  It appears that 
the upper 8 bits have been lost.  These are the FirstSegment and LastSegment 
indicators (which should always be True for < 8191).  This looks alot like 
some of the funky behavior that I was seeing with my > 8191 jumbo frames 
patch.  

What size packets are being sent accross the wire?

On Friday 04 March 2005 06:37 pm, Francois Romieu wrote:
> Stephen Hemminger <shemminger@osdl.org> :
> [...]
>
> > Added this and took out "too much work at interrupt message"
>
> Ok (leaks but see below).
>
> > And got this (before it died):
> >
> > eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:106ad012
>
>                            ^^^^^^
> 3ff0 would be a ~16k packet. The high weight byte is
> missing: the descriptor would be strictly somewhere between
> the first descriptor and the last descriptor for the packet.
>
> opts=80xxxx -> FIFO overflow (*bulb flashes*)
>
> The code does not look pretty there.
>
> Can you add something like the patch below on top of your
> current patch (untested but you get the idea):
>
> diff -puN drivers/net/r8169.c~r8169-480 drivers/net/r8169.c
> --- linux-2.6.11/drivers/net/r8169.c~r8169-480 2005-03-05
> 00:16:58.575516900 +0100 +++ linux-2.6.11-fr/drivers/net/r8169.c 2005-03-05
> 01:32:20.122261946 +0100 @@ -240,6 +241,7 @@ enum RTL8169_register_content
> {
>   RxOK = 0x01,
>
>   /* RxStatusDesc */
> + RxOVF = 0x00800000,
>   RxRES = 0x00200000,
>   RxCRC = 0x00080000,
>   RxRUNT = 0x00100000,
> @@ -2181,13 +2183,14 @@ rtl8169_rx_interrupt(struct net_device *
>
>    if (status & DescOwn)
>     break;
> -  if (status & RxRES) {
> +  if (status & (RxRES | RxOVF)) {
>     printk(KERN_INFO "%s: Rx ERROR!!!\n", dev->name);
>     tp->stats.rx_errors++;
>     if (status & (RxRWT | RxRUNT))
>      tp->stats.rx_length_errors++;
>     if (status & RxCRC)
>      tp->stats.rx_crc_errors++;
> +   rtl8169_return_to_asic(tp->RxDescArray + entry, tp->rx_buf_sz);
>    } else {
>     struct RxDesc *desc = tp->RxDescArray + entry;
>     struct sk_buff *skb = tp->Rx_skbuff[entry];
>
> _
>
> /me goes to bed.
>
> Out of curiosity it would be interesting to see how non-PREEMPT and NAPI
> behaves (the rings are surely too small).
>
> --
> Ueimor
