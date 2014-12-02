From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] rtnetlink: delay RTM_DELLINK notification until
 after ndo_uninit()
Date: Tue, 02 Dec 2014 08:41:16 -0800
Message-ID: <547DEBAC.5000005@cumulusnetworks.com>
References: <1417499650-29176-1-git-send-email-maheshb@google.com>  <547DE418.9000309@cumulusnetworks.com> <1417537150.5303.67.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mahesh Bandewar <maheshb@google.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:55899 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932236AbaLBQlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 11:41:21 -0500
In-Reply-To: <1417537150.5303.67.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/2/14, 8:19 AM, Eric Dumazet wrote:
> On Tue, 2014-12-02 at 08:08 -0800, Roopa Prabhu wrote:
>
>> interestingly I have never seen this. We use this heavily with most
>> other logical devices.
>> Which tells me most logical devices do have checks in their fill_info.
>> The patch idea is good. My only concern is stale information
>> in the DELLINK notification. Because,  ndo_uninit() does do a lot of
>> cleanup, sending
>> newlink's for some of these cleanup changes. And now with your patch the
>> dellink notification
>> skb probably  contains information that has been already deleted by
>> ndo_uninit ?
> What do you mean ? We send a message and device is deleted.
>
> Its an asynchronous message.
>
> At the time you read it, lot of things might already have changed, no
> matter how careful you are.
>
> This patch permits to get a precise snapshot of device info right before
> dismantle (like stats counters for accounting purpose)

fair point. But the commit that moved things around was done to handle 
cases where,
the ndo_uninit() already sends some notifications to userspace for the 
changes
during uninit (example bond driver).

The only point i was making was that the dellink after the ndo_uninit in 
your
case now contains state that was prior to uninit for these drivers.

For the bug being discussed, i was thinking fill_info in ipvlan should 
be fixed to handle this correctly.
  ie fill_info could be fixed to not barf if the private information is 
not present and just return nothing.
But understand that this will not give you the state prior to uninit for 
some drivers.
