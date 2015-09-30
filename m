From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 2/4] cxgb4: For T4, don't read the Firmware
 Mailbox Control register
Date: Wed, 30 Sep 2015 17:50:55 +0300
Message-ID: <560BF6CF.8050208@cogentembedded.com>
References: <1443623089-10039-1-git-send-email-hariprasad@chelsio.com>
 <1443623089-10039-3-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com
To: Hariprasad Shenai <hariprasad@chelsio.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:32786 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753699AbbI3Ou6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 10:50:58 -0400
Received: by lahh2 with SMTP id h2so49375498lah.0
        for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 07:50:56 -0700 (PDT)
In-Reply-To: <1443623089-10039-3-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 09/30/2015 05:24 PM, Hariprasad Shenai wrote:

> T4 doesn't have the Shadow copy of the register which we can read without
> side effect. So don't read mbox control register for T4 adapter
>
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
> ---
>   drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c | 18 +++++++++++++-----
>   1 file changed, 13 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
> index 0a87a32..c20b41c 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
> @@ -1134,12 +1134,20 @@ static int mbox_show(struct seq_file *seq, void *v)
>   	unsigned int mbox = (uintptr_t)seq->private & 7;
>   	struct adapter *adap = seq->private - mbox;
>   	void __iomem *addr = adap->regs + PF_REG(mbox, CIM_PF_MAILBOX_DATA_A);
> -	unsigned int ctrl_reg = (is_t4(adap->params.chip)
> -				 ? CIM_PF_MAILBOX_CTRL_A
> -				 : CIM_PF_MAILBOX_CTRL_SHADOW_COPY_A);
> -	void __iomem *ctrl = adap->regs + PF_REG(mbox, ctrl_reg);
>
> -	i = MBOWNER_G(readl(ctrl));
> +	/* For T4 we don't have a shadow copy of the Mailbox Control register.
> +	 * And since reading that real register causes a side effect of
> +	 * granting ownership, we're best of simply not reading it at all.
> +	 */
> +	if (is_t4(adap->params.chip))
> +		i = 4; /* index of "<unread>" */

    The kernel CodingStyle dictates that you should enclose all branches in {} 
if at least one branch has it.

> +	else {
> +		unsigned int ctrl_reg = CIM_PF_MAILBOX_CTRL_SHADOW_COPY_A;
> +		void __iomem *ctrl = adap->regs + PF_REG(mbox, ctrl_reg);
> +
> +		i = MBOWNER_G(readl(ctrl));
> +	}
> +
>   	seq_printf(seq, "mailbox owned by %s\n\n", owner[i]);
>
>   	for (i = 0; i < MBOX_LEN; i += 8)

MBR, Sergei
