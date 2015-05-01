From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH 0/3] Stop using dev_kfree_skb_any in NAPI Tx clean-up
Date: Fri, 01 May 2015 09:45:55 -0700
Message-ID: <5543ADC3.8010400@redhat.com>
References: <20150430205423.1512.13487.stgit@ahduyck-vm-fedora22> <20150501.114223.1837223121502998313.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	Dept-HSGLinuxNICDev@qlogic.com, sony.chacko@qlogic.com,
	intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34389 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751415AbbEAQp6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 May 2015 12:45:58 -0400
In-Reply-To: <20150501.114223.1837223121502998313.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/01/2015 08:42 AM, David Miller wrote:
> From: Alexander Duyck <alexander.h.duyck@redhat.com>
> Date: Thu, 30 Apr 2015 13:58:12 -0700
>
>> This change replaces the call to dev_kfree_skb_any in several NAPI based Tx
>> clean-up paths with dev_kfree_skb.  Where I made the replacement the
>> function appeared to always be in softirq context so we can avoid the
>> unnecessary time spent determining if we are in a hardirq context or not.
> It isn't always in softirq context.
>
> We can do a netconsole transmit from any context, and that code
> can and will invoke ->poll().

I knew ndo_start_xmit was affected by that, I didn't realize that the 
napi poll routine was as well.

> As Francois noted, netpoll_send_skb_on_dev() loops trying to transmit,
> and if the TX does nto give NETDEV_TX_OK it will try to execute TX
> reclaim by invoking ->poll().
>
> It's hard to trigger this, but if you do... the dev_kfree_skb_any()
> really is necessary.

Ugh, if anything it points out that there are probably a number of bugs 
in the various drivers out there since I think there were assumptions 
made on both sides about how all the NAPI and netpoll stuff works.  I'll 
probably be submitting fixes today for a number of drivers to address 
all the spots that have been missed and little things that need to be 
addressed.

- Alex
