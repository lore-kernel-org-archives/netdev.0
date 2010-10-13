From: "Masayuki Ohtake" <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Subject: Re: [MeeGo-Dev][PATCH v3] Topcliff: Update PCH_CAN driver to 2.6.35
Date: Wed, 13 Oct 2010 19:09:42 +0900
Message-ID: <004a01cb6abe$c41a9cc0$66f8800a@maildom.okisemi.com>
References: <4C9C7C6F.1000003@dsn.okisemi.com>
	<4CA4541F.5040804@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>,
	Tomoya MORINAGA <morinaga526-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
To: "Wolfgang Grandegger" <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday, September 30, 2010 6:10 PM, Wolfgang Grandegger wrote:

>
> + iowrite32(num, &(priv->regs)->if2_creq);
> + while (counter) {
>> + if2_creq = (ioread32(&(priv->regs)->if2_creq)) &
>> +      CAN_IF_CREQ_BUSY;
>> + if (!if2_creq)
>> + break;
>> + counter--;
>> + }
>> + if (!counter)
>> + dev_err(&priv->ndev->dev, "IF2 BUSY Flag is set forever.\n");
>> +}
>
>Duplicated code!

No.
These are not the same.

Though it is possible to integrate to one function by adding parameter,
I think, current two function method is more easily to read.

>
>
>
>> + if (status & PCH_STUF_ERR)
>> + cf->data[2] |= CAN_ERR_PROT_STUFF;
>> +
>> + if (status & PCH_FORM_ERR)
>> + cf->data[2] |= CAN_ERR_PROT_FORM;
> +
> + if (status & PCH_ACK_ERR)
> + cf->data[2] |= CAN_ERR_PROT_LOC_ACK | CAN_ERR_PROT_LOC_ACK_DEL;
> +
> + if ((status & PCH_BIT1_ERR) || (status & PCH_BIT0_ERR))
> + cf->data[2] |= CAN_ERR_PROT_BIT;
> +
> + if (status & PCH_CRC_ERR)
> + cf->data[2] |= CAN_ERR_PROT_LOC_CRC_SEQ |
> + CAN_ERR_PROT_LOC_CRC_DEL;
> +
> + if (status & PCH_LEC_ALL)
> + iowrite32(status | PCH_LEC_ALL,
> +   &(priv->regs)->stat);
>
>A bit-wise test of the above values is wrong, I believe. Please use the
>switch statement instead.

The above conditions are not only one time.
I think "switch" is not suitable for the above.
Thus, current "if" processing is better.

>
>
> + u32 brp;
> +
> + pch_can_get_run_mode(priv, &curr_mode);
> + if (curr_mode == PCH_CAN_RUN)
> + pch_can_set_run_mode(priv, PCH_CAN_STOP);
>
>The device is stopped when this function is called. Please remove.

No.
The above is necessary.
Because this is our HW specification.
Before setting bitrate, run-mode must be "STOP".

>
>
> +static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
> +{
> + canid_t id;
> + u32 id1 = 0;
> + u32 id2 = 0;
>
>Need these values to be preset?

These values are not essential.
But these help a engineer to read this code.

>
>
> + /* Enable CAN Interrupts */
> + pch_can_set_int_custom(priv);
> +
> + /* Restore Run Mode */
> + pch_can_set_run_mode(priv, PCH_CAN_RUN);
> +
> + return retval;
> +}
>
>Are the suspend and resume functions tested?
>
Yes, we tested before.

=========================================

Except the above, we are modifying for your indications.

I will resubmit soon.

Thanks, Ohtake(OKISemi)
