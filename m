From: Ricardo Ribalda Delgado <ricardo.ribalda@gmail.com>
Subject: Re: [PATCH] ll_temac: Reset dma descriptors on ndo_open
Date: Tue, 1 Oct 2013 07:46:31 +0200
Message-ID: <CAPybu_0OrwTo7CkuauRpu_ohQRY80U6BJDXQ6=KC0caOFiFCQA@mail.gmail.com>
References: <1380281068-13269-1-git-send-email-ricardo.ribalda@gmail.com> <20130930.212153.531876068589922786.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: joe@perches.com, jg1.han@samsung.com,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	wfp5p@virginia.edu, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:43460 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751079Ab3JAFqw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 01:46:52 -0400
In-Reply-To: <20130930.212153.531876068589922786.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David

lp->tx_bd_ci, lp->tx_bd_next...  are only initialized to zero on
temac_of_probe (inside  alloc_etherdev).  Those vars are used to index
the dma descriptors.

The initialization of  lp->tx_bd_v[i].app0 = 0; is redundant, because
it is already done on dma_zalloc_coherent in temac_dma_bd_init called
on open.

What if I move
       lp->tx_bd_ci = 0;
       lp->tx_bd_next = 0;
       lp->tx_bd_tail = 0;
       lp->rx_bd_ci = 0;

to temac_dma_bd_init? Will this be more correct?

Without this patch a script like these kills the card in 1-10 iterations:


ifdown eth0
ifdown eth1
while true

do
ifconfig eth1 10.100.10.100
udhcpc -i eth0
ping 192.168.2.1 -c 5 || break
ifconfig eth0 down


ifconfig eth0 10.100.10.100
udhcpc -i eth1
ping 192.168.2.1 -c 5 || break
ifconfig eth1 down

done


Regards

On Tue, Oct 1, 2013 at 6:21 AM, David Miller <davem@davemloft.net> wrote:
> From: Ricardo Ribalda Delgado <ricardo.ribalda@gmail.com>
> Date: Fri, 27 Sep 2013 13:24:28 +0200
>
>> The dma descriptors are only initialized on the probe function.
>>
>> If a packet is on the buffer when temac_stop is called, the dma
>> descriptors can be left on a incorrect status where no other package can
>> be sent.
>>
>> So an interface could be left in an usable state after ifdow/ifup.
>>
>> This patch makes sure that the descriptors are in a proper status when
>> the device is started.
>>
>> Signed-off-by: Ricardo Ribalda Delgado <ricardo.ribalda@gmail.com>
>
> This analysis is not correct.
>
> In the current driver, the descriptors are allocated and initialized
> in the open function, not the probe function.
>
> I'm not applying this patch.



-- 
Ricardo Ribalda
