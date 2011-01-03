From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [net-next-2.6 PATCH v2 3/3] net_sched: implement a root
 container qdisc sch_mclass
Date: Mon, 3 Jan 2011 18:04:49 +0100
Message-ID: <20110103170449.GB1843@del.dom.local>
References: <20101231092543.GA7809@ff.dom.local>
 <4D2162A8.60305@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hadi@cyberus.ca" <hadi@cyberus.ca>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:43195 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751198Ab1ACRE4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 12:04:56 -0500
Received: by bwz15 with SMTP id 15so13874887bwz.19
        for <netdev@vger.kernel.org>; Mon, 03 Jan 2011 09:04:55 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4D2162A8.60305@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 02, 2011 at 09:46:16PM -0800, John Fastabend wrote:
> On 12/31/2010 1:25 AM, Jarek Poplawski wrote:
> > On 2010-12-21 20:29, John Fastabend wrote:
> >> +static int mclass_parse_opt(struct net_device *dev, struct tc_mclass_qopt *qopt)
> >> +{
> >> +	int i, j;
> >> +
> >> +	/* Verify TC offset and count are sane */
> > 
> > if (qopt->num_tc > TC_MAX_QUEUE) ?
> > 	return -EINVAL;
> 
> This would be caught later when netdev_set_num_tc() fails although probably best to catch all failures in this function as early as possible.

Plus reading beyond the table range wouldn't look nice.

> 
> > 
> >> +	for (i = 0; i < qopt->num_tc; i++) {
> >> +		int last = qopt->offset[i] + qopt->count[i];
> >> +		if (last > dev->num_tx_queues)
> > 
> > if (last >= dev->num_tx_queues) ?
> > 
> >> +			return -EINVAL;
> >> +		for (j = i + 1; j < qopt->num_tc; j++) {
> >> +			if (last > qopt->offset[j])
> > 
> > if (last >= qopt->offset[j]) ?
> 	
> I believe the below works as expected. The offset needs to be verified (this I missed) but offset+count can be equal to num_tx_queue indicating the last queue is in use. With 8 tx queues and num_tc=2 a valid configuration is, tc1 offset of 0 and a count of 7 with tc2 offset of 7 and count of 1.
> 
> 
>         /* Verify num_tc is in max range */
>         if (qopt->num_tc > TC_MAX_QUEUE)
>                 return -EINVAL;
> 
>         for (i = 0; i < qopt->num_tc; i++) {
>                 /* Verify the queue offset is in the num tx range */
>                 if (qopt->offset[i] >= dev->num_tx_queues)
>                         return -EINVAL;
>                 /* Verify the queue count is in tx range being equal to the
>                  * num_tx_queues indicates the last queue is in use.
>                  */
>                 else if (qopt->offset[i] + qopt->count[i] > dev->num_tx_queues)
>                         return -EINVAL;
> 
>                 /* Verify that the offset and counts do not overlap */
>                 for (j = i + 1; j < qopt->num_tc; j++) {
>                         if (last > qopt->offset[j])
>                                 return -EINVAL;
>                 }
>         }

Yes, after assigning the 'last' it should work OK ;-)

Thanks,
Jarek P.
