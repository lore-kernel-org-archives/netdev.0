From: Dave Jones <davej@redhat.com>
Subject: Re: net/tg3: Fix kernel crash
Date: Tue, 6 Aug 2013 10:46:10 -0400
Message-ID: <20130806144610.GA2889@redhat.com>
References: <20130731204019.059F66609B7@gitolite.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>,
	Gavin Shan <shangw@linux.vnet.ibm.com>,
	Nithin Nayak Sujir <nsujir@broadcom.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3379 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754962Ab3HFOq0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 10:46:26 -0400
Content-Disposition: inline
In-Reply-To: <20130731204019.059F66609B7@gitolite.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 31, 2013 at 08:40:18PM +0000, Linux Kernel wrote:
 > Gitweb:     http://git.kernel.org/linus/;a=commit;h=d8af4dfd84329015e18ea3d83a84c46e92f21020
 > Commit:     d8af4dfd84329015e18ea3d83a84c46e92f21020
 > Parent:     d738ce8fdc05ebf5b1475f8ae26d908c8c50970b
 > Author:     Gavin Shan <shangw@linux.vnet.ibm.com>
 > AuthorDate: Wed Jul 24 17:25:08 2013 +0800
 > 
 >     net/tg3: Fix kernel crash
 >     
 >     While EEH error happens, we might not have network device instance
 >     (struct net_device) yet. So we can't access the instance safely and
 >     check its link state, which causes kernel crash. The patch fixes it.
 >     Reported-by: Wei Yang <weiyang@linux.vnet.ibm.com>
 >     Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
 >     Acked-by: Nithin Nayak Sujir <nsujir@broadcom.com>
 >     Signed-off-by: David S. Miller <davem@davemloft.net>
 > 
 > diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
 > index d964f30..aee1b9a 100644
 > --- a/drivers/net/ethernet/broadcom/tg3.c
 > +++ b/drivers/net/ethernet/broadcom/tg3.c
 > @@ -17773,7 +17773,8 @@ static pci_ers_result_t tg3_io_error_detected(struct pci_dev *pdev,
 >  
 >  	rtnl_lock();
 >  
 > -	if (!netif_running(netdev))
 > +	/* We probably don't have netdev yet */
 > +	if (!netdev || !netif_running(netdev))
 >  		goto done;
 
This looks incomplete.  'done' does this..

done:
  if (state == pci_channel_io_perm_failure) {
          tg3_napi_enable(tp);
          dev_close(netdev);


If netdev is null, we'll deref it in dev_close.

	Dave
