From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [PATCH net-next 5/5] gianfar: Fix and cleanup Rx FCB handling
Date: Wed, 13 Feb 2013 13:34:43 +0200
Message-ID: <511B7A53.3060800@freescale.com>
References: <1360673237-349-1-git-send-email-claudiu.manoil@freescale.com> <1360673237-349-2-git-send-email-claudiu.manoil@freescale.com> <1360673237-349-3-git-send-email-claudiu.manoil@freescale.com> <1360673237-349-4-git-send-email-claudiu.manoil@freescale.com> <1360673237-349-5-git-send-email-claudiu.manoil@freescale.com> <511A799C.4020105@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe006.messaging.microsoft.com ([216.32.181.186]:37622
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933818Ab3BMLew (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2013 06:34:52 -0500
In-Reply-To: <511A799C.4020105@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/12/2013 7:19 PM, Paul Gortmaker wrote:
> On 13-02-12 07:47 AM, Claudiu Manoil wrote:
>> NETIF_F_HW_VLAN_TX flag must not condition RxFCB usage.
>
> The above statement isn't 100% clear to me.  Is this the intent?

The above statement is a rule, if you wish. The existing code breaks
that rule by saying: RxFCB is enabled if NETIF_F_HW_VLAN_TX; which is
a false statement. This patch corrects this error, according to the
rule above.
So, primarily, this patch is a fix (as expressed in <subj.>). I'll
resend the patch with additional comments to make this point clearer.

>
>    Currently, gfar_uses_fcb() calls gfar_is_vlan_on() which in turn
>    checks NETIF_F_HW_VLAN_TX.  However there is no relation between
>    whether FCBs are used and the VLAN transmit state.
>
>> In the case of RxBD rings, FCBs (Frame Control Block) are inserted by
>> the eTSEC whenever RCTRL[PRSDEP] is set to a non-zero value. Only one
>> FCB is inserted per frame (in the buffer pointed to by the RxBD with
>> bit F set). TOE acceleration for receive is enabled for all rx frames
>> in this case.
>> Indroduce the uses_rxfcb field to signal RxFCB insertion in accordance
>> with the specification above (leading to cleaner, less confusing code).
>
> The is_vlan_on() and uses_fcb() calls were more self documenting than
> setting/clearing a new single use variable added to priv, I think.
> Even if they get changed/simplified, perhaps it is worth keeping them?

gfar_uses_fcb() generates confusion around the FCB concept, this maybe
explains how it came to the error above. First, there are 2 types of
FCBs with different meaning, covering different use cases: Rx (receive
side) FCB and TxFCB. uses_fcb() was intended to signal RxFCB insertion,
which is not obvious from its name, and it became (subtly) erroneous
after incorporating is_vlan_on().
is_vlan_on() is also misleading because we need to differentiate b/w
hw VLAN extraction/VLEX (marked by VLAN_RX flag) and hw VLAN
insertion/VLINS (VLAN_TX flag), which are different mechanisms using
different types of FCBs.

>
> Rather than a specific priv->uses_rxfcb field, perhaps it makes sense
> to make it more future proof with priv->rctrl field, that is a cached
> value of the register, and then you keep gfar_uses_fcb() and it in
> turn checks for RCTRL_PRSDEP_INIT bit in rctrl?
>

The main purpose of the priv->uses_rxfcb field is to quickly signal, on
the hot path, that the incoming frame has a *Rx* FCB block inserted
which needs to be pulled out before passing the skb to the stack.
This is a performance critical operation, it needs to happen fast,
that's why uses_rxfcb is placed in the first cacheline of gfar_private.
This is also why I cannot use a cached rctrl instead: 1) because I
don't have 32 bits available in the first cacheline of gfar_probe
(but only 16); 2) no time for bit operations on the hot path.

> Also, the dependency/conditional on FSL_GIANFAR_DEV_HAS_TIMER seems
> to simply vanish with this patch, and it isn't clear to me if that
> was 100% intentional or not...
>

The dependency on FSL_GIANFAR_DEV_HAS_TIMER is another source of
confusion. The dependency is actually to priv->hwts_rx_en.
Upon changing priv->hwts_rx_en via IOCTL, the gfar device is being
restarted and on init_mac() the priv->hwts_rx_en conditions the RxFCB
insertion, and rctrl is programmed accordingly. The patch takes care
of this case too.

So, I'll re-spin this patch with enhanced comments.

Thanks,
Claudiu
