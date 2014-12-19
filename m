From: "Chickles, Derek" <Derek.Chickles@caviumnetworks.com>
Subject: RE: [PATCH net-next v3] Add support of Cavium Liquidio ethernet
 adapters
Date: Fri, 19 Dec 2014 22:39:47 +0000
Message-ID: <BY2PR07MB486FCC30E2D888F074697C9FE6B0@BY2PR07MB486.namprd07.prod.outlook.com>
References: <feba8d6dd1904fc3936864ae332df6d8@CO2PR0701MB744.namprd07.prod.outlook.com>
 <1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>
 <54949D24.1040707@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Burla, Satananda" <Satananda.Burla@caviumnetworks.com>,
	"Manlunas, Felix" <Felix.Manlunas@caviumnetworks.com>,
	"Vatsavayi, Raghu" <Raghu.Vatsavayi@caviumnetworks.com>
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>,
	"Vatsavayi, Raghu" <Raghu.Vatsavayi@caviumnetworks.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0056.outbound.protection.outlook.com ([157.56.110.56]:26688
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751762AbaLSWju convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 17:39:50 -0500
In-Reply-To: <54949D24.1040707@gmx.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On 19.12.2014 04:25, Raghu Vatsavayi wrote:
> > +static int setup_nic_devices(struct octeon_device *octeon_dev)
> > +{
...
> > +
> > +	sc = kmalloc(sizeof(*sc), GFP_ATOMIC);
> > +	if (!sc)
> > +		return -ENOMEM;
> > +
> > +	resp = kmalloc(sizeof(*resp), GFP_KERNEL);
> > +	if (!resp) {
> > +		kfree(sc);
> > +		return -ENOMEM;
> > +	}
...
> > +		init_waitqueue_head(&resp->s.wc);
...
> > +
> > +		retval = octeon_send_soft_command(octeon_dev, sc);
> > +		if (retval) {
> > +			lio_dev_err(octeon_dev,
> > +				    "Link status instruction failed status: %x\n",
> > +				    retval);
> > +			/* Soft instr is freed by driver in case of failure. */
> > +			goto setup_nic_dev_fail;
> > +		}
> > +
> > +		/* Sleep on a wait queue till the cond flag indicates that the
> > +		 * response arrived or timed-out.
> > +		 */
> > +		sleep_cond(&resp->s.wc, &resp->s.cond);
...
> > +	kfree(sc);
> > +	kfree(resp);
> 
> I wonder if this is correct. AFAICS sc is the same memory that we put on
> the octeon_instr_queue (see send_soft_command() ->
> send_command()->add_to_nrlist()). Is that queue cleared before sc is
> freed?
> 
> 

Yes, it's correct. We wait for the response before exiting this loop with
that sleep_cond() call. This adds an entry to a wait_queue that is
serviced asynchronously and will return once it is complete.
