From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Subject: RE: [patch 2.6.17] s2io driver irq fix
Date: Thu, 22 Jun 2006 14:50:56 -0700
Message-ID: <001f01c69645$f1762740$4110100a@pc.s2io.com>
References: <20060621211534.b740d0f8.akpm@osdl.org>
Reply-To: <ravinandan.arakali@neterion.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>, <dgc@sgi.com>,
	<balbir@in.ibm.com>, <viro@zeniv.linux.org.uk>, <neilb@suse.de>,
	<jblunck@suse.de>, <tglx@linutronix.de>,
	<ananda.raju@neterion.com>, <leonid.grossman@neterion.com>,
	<alicia.pena@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:46315 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S932668AbWFVWuF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 18:50:05 -0400
To: "'Andrew Morton'" <akpm@osdl.org>,
	"'Ananda Raju'" <Ananda.Raju@neterion.com>
In-Reply-To: <20060621211534.b740d0f8.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew,
My understanding is that MSI-X vectors are not usually shared. We don't want
to spend cycles checking if the interrupt was indeed from our card or
another device on same IRQ.
In fact, current driver shares IRQ for the MSI case which I think is a bug.
That should also be non-shared. Our MSI handler just runs thru' the Tx/Rx
completions and returns IRQ_HANDLED. In case of IRQ sharing, we could be
falsely claiming the interrupt as our own.

Ravi

-----Original Message-----
From: netdev-owner@vger.kernel.org
[mailto:netdev-owner@vger.kernel.org]On Behalf Of Andrew Morton
Sent: Wednesday, June 21, 2006 9:16 PM
To: Ananda Raju
Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
linux-fsdevel@vger.kernel.org; dgc@sgi.com; balbir@in.ibm.com;
viro@zeniv.linux.org.uk; neilb@suse.de; jblunck@suse.de;
tglx@linutronix.de; ananda.raju@neterion.com;
leonid.grossman@neterion.com; ravinandan.arakali@neterion.com;
alicia.pena@neterion.com
Subject: Re: [patch 2.6.17] s2io driver irq fix


On Wed, 21 Jun 2006 15:50:49 -0400 (EDT)
Ananda Raju <Ananda.Raju@neterion.com> wrote:

> +	if (sp->intr_type == MSI_X) {
> +		int i;
>
> -				free_irq(vector, arg);
> +		for (i=1; (sp->s2io_entries[i].in_use == MSIX_FLG); i++) {
> +			if (sp->s2io_entries[i].type == MSIX_FIFO_TYPE) {
> +				sprintf(sp->desc[i], "%s:MSI-X-%d-TX",
> +					dev->name, i);
> +				err = request_irq(sp->entries[i].vector,
> +					  s2io_msix_fifo_handle, 0, sp->desc[i],
> +						  sp->s2io_entries[i].arg);

Is it usual to prohibit IRQ sharing with msix?

-
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

