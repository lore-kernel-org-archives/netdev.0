From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: Re: [patch 1/5] [PATCH] qeth: HiperSockets SIGA retry support on
 CC=2.
Date: Thu, 27 Aug 2009 10:05:34 +0200
Message-ID: <4A963E4E.4020405@linux.vnet.ibm.com>
References: <20090826120105.727838000@de.ibm.com> <20090826120135.998746000@de.ibm.com> <20090827070547.GA32106@wavehammer.waldi.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Bastian Blank <bastian@waldi.eu.org>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Klaus-Dieter Wacker <kdwacker@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.17.164]:48839 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751604AbZH0IFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2009 04:05:35 -0400
In-Reply-To: <20090827070547.GA32106@wavehammer.waldi.eu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bastian Blank schrieb:
> On Wed, Aug 26, 2009 at 02:01:06PM +0200, frank.blaschka@de.ibm.com wrote:
>> Qeth HiperSockets support now retries sending of packets when the
>> IBM System z signals a temporary resource shortage (e.g. target
>> buffer full). The packet is enqueued into the device queue.
>> After 3 times of unsuccessful send the packet is dropped.
> 
> What is the reason for that? How large is the timeout for each retry?
> Usually the upper layers should already handle dropped packages fine and
> adding another retry below can produce retry multiplication.
>

HiperSocket is very different from usual network hardware. Microcode can
notify the driver the target of an xmit can not receive the packet because of
a target buffer full condition (this is the queue->sync_iqdio_error == 2 error
code). The buffer full condition is only for the target of the xmit not the
senders hardware. There is no timeout for the retry. The retry is more or less
immediately. If the target buffer full is only a temporary(short) condition we
can stay at a higher throughput level because TCP congestion does not kick in.

>> @@ -3178,6 +3203,25 @@ int qeth_do_send_packet_fast(struct qeth
>>  	atomic_set(&queue->state, QETH_OUT_Q_UNLOCKED);
>>  	qeth_fill_buffer(queue, buffer, skb, hdr, offset, hd_len);
>>  	qeth_flush_buffers(queue, index, 1);
>> +	if (queue->sync_iqdio_error == 2) {
> 
> Is this a magic constant?
> 
> Bastian
> 


