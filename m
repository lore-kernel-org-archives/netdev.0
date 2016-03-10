From: Sunil Kovvuri <sunil.kovvuri@gmail.com>
Subject: Re: [PATCH 1/2] net: thunderx: Set recevie buffer page usage count in bulk
Date: Thu, 10 Mar 2016 16:13:28 +0530
Message-ID: <CA+sq2Cc44v_ggy=QLOX_FGt6uTv3Qo1KmqCeZ8=3G1COuWxAHw@mail.gmail.com>
References: <1457336157-31508-2-git-send-email-sunil.kovvuri@gmail.com>
	<20160307.111534.235286977900488968.davem@davemloft.net>
	<CA+sq2CewOQGSiRC5m64ioYS36-WO0C5XzykZRZd+OLE1tJ-sSQ@mail.gmail.com>
	<20160307.120410.1851177945150642006.davem@davemloft.net>
	<CA+sq2CcyOV3FbpUvSkX4ZhjC+fJuHk9cUpjdiJtkFNaEXOWu6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	LAKML <linux-arm-kernel@lists.infradead.org>,
	Sunil Goutham <sgoutham@cavium.com>,
	Robert Richter <robert.richter@caviumnetworks.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33181 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965356AbcCJKna (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 05:43:30 -0500
In-Reply-To: <CA+sq2CcyOV3FbpUvSkX4ZhjC+fJuHk9cUpjdiJtkFNaEXOWu6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,


>> So if you know ahead of time how the page will be split up, just
>> calculate that when you get the page and increment the page count
>> appropriately.
>>
>> That's what we do in the NIU driver.
>
> Thanks for the suggestion, will check and get back.
>

I looked at the NIU driver and in fn() niu_rbr_refill()
static void niu_rbr_refill(struct niu *np, struct rx_ring_info *rp, gfp_t mask)
{
        int index = rp->rbr_index;

        rp->rbr_pending++;
        if ((rp->rbr_pending % rp->rbr_blocks_per_page) == 0) {

Here it's been checked whether rbr_pending is a exact multiple of page
split count.
And hence updating page count based on fixed calculation is right.

On my platform driver receives a interrupt when free buffer count
falls below a threshold
and by the time SW reads count of buffers to be refilled it can be any
number i.e
may or may not be a exact multiple of page split count.

When interface is being brought down and while freeing unused receive
buffers one
page's count will go wrong and hence will disappear completely. In the
patch i am
updating page->count before issuing doorbell to HW irrespective of
full page utilised
or not. So there is no mismatch while doing put_page(unused buffer).

Thanks,
Sunil.
