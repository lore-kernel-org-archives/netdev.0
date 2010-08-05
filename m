From: Usha Srinivasan <usha.srinivasan@qlogic.com>
Subject: RE: Receive processing stops when dev->poll returns 1
Date: Thu, 5 Aug 2010 11:36:26 -0500
Message-ID: <7866DA1F8D2D4541B87FEE88E633ABAA2B72081FE6@MNEXMB1.qlogic.org>
References: <7866DA1F8D2D4541B87FEE88E633ABAA2B72081FB6@MNEXMB1.qlogic.org>
	<20100805090447.3f67d990@nehalam>
	<7866DA1F8D2D4541B87FEE88E633ABAA2B72081FDF@MNEXMB1.qlogic.org>
 <20100805092243.41671259@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:38105 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933289Ab0HEQg3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 12:36:29 -0400
In-Reply-To: <20100805092243.41671259@nehalam>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have compared the code in my driver to code in other drivers and they are quite similar. Here is my code:

int vnic_napi_poll(struct napi_struct *napi, int budget)
{
    done = 0;
poll_more:
    while (done < budget) {
        int max = (budget - done);
        t = min(<max-supported-by-driver>, max);
        n = get-completions(comp_list);
        for (i = 0; i < n; i++, done++)
            handle_completions(<complist[i]);
        if (n != t)
            break;
    }
    if (done < budget) {
        netif_rx_complete(dev, napi);
        /* check again just to be sure */
        if (more-completions()) { 
            If netif_rx_reschedule(dev, napi))
                goto poll_more;
        }
    }
    return done;
}

***********************
BACKPORTED version:
***********************
int vnic_poll(struct net_device *dev, int *budget)
{
    int max = min(*budget, dev->quota);

    done = 0;
poll_more:
    while (max) {
        t = min(<max-supported-by-driver>, max);
        n = get-completions(comp_list);
        for (i = 0; i < n; i++, --max, done++)
            handle_completions(<complist[i]);
        if (n != t)
            break;
    }
    if (max) {
        netif_rx_complete(dev);
        /* check again just to be sure */
        if (more-completions()) { 
            If netif_rx_reschedule(dev, napi))
                goto poll_more;
        }
        ret = 0;
    } else
        ret = 1;

    dev->quota  -= done;
    *budget     -= done;

    return ret;
}

***********************
-----Original Message-----
From: Stephen Hemminger [mailto:shemminger@vyatta.com] 
Sent: Thursday, August 05, 2010 12:23 PM
To: Usha Srinivasan
Cc: netdev@vger.kernel.org
Subject: Re: Receive processing stops when dev->poll returns 1

On Thu, 5 Aug 2010 11:11:51 -0500
Usha Srinivasan <usha.srinivasan@qlogic.com> wrote:

> Thanks for your response. What you said is exactly what my driver is doing:
> 
> 
> <= 2.6.23 
> Calls netif_rx_complete if done < budget; decrements quota & *budget by done; returns 0 if done < budget and 1 otherwise.
> 
> When 1 is returned, I encounter the problem I described)
> 
> > 2.6.23
> Calls napi-complete if done < budget; returns done.
> 
> When done==budget, I encounter the problem I described.
> 
> Any ideas?

Ignore last mail...

If you done == budget, the poll will be recalled (after other drivers).
If quantum exhausts, then it gets called it gets deferred to ksoftirq
thread.

One possibility is that the driver is looking at wrong parameter
for budget and is exceeding the requested value. Please post your code.

