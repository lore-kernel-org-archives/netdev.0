From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH 2/2] xen-netback: cancel the credit timer
 when taking the vif down
Date: Thu, 14 Feb 2013 13:56:24 +0000
Message-ID: <511CED08.9080902@citrix.com>
References: <1360847938-11185-1-git-send-email-david.vrabel@citrix.com>	 <1360847938-11185-3-git-send-email-david.vrabel@citrix.com> <1360849999.16636.135.camel@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jan Beulich <jbeulich@suse.com>,
	"Wei Liu (3P)" <wei.liu@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:8982 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757748Ab3BNN41 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2013 08:56:27 -0500
In-Reply-To: <1360849999.16636.135.camel@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/02/13 13:53, Wei Liu wrote:
> On Thu, 2013-02-14 at 13:18 +0000, David Vrabel wrote:
>> From: David Vrabel <david.vrabel@citrix.com>
>>
>> If the credit timer is left armed after calling
>> xen_netbk_remove_xenvif(), then it may fire and attempt to schedule
>> the vif which will then oops as vif->netbk == NULL.
>>
>> This may happen both in the fatal error path and during normal
>> disconnection from the front end.
>>
>> The sequencing during shutdown is critical to ensure that: a)
>> vif->netbk doesn't become unexpectedly NULL; and b) the net device/vif
>> is not freed.
>>
>> 1. Mark as unschedulable (netif_carrier_off()).
>> 2. Synchronously cancel the timer.
>> 3. Remove the vif from the schedule list.
>> 4. Remove it from it netback thread group.
>> 5. Wait for vif->refcnt to become 0.
>>
>> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> 
> You would need to reinitialize the timer in xenvif_up, given that user
> might `ifconfig vifX.X down; ifconfig vifX.X up`.

No.  Deleted timers do not need to be reinitialized.  The timer will be
armed as usual with mod_timer() when credit is next exhausted.

David
