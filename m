From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: Re: [PATCH] ehea: Add some info messages and fix an issue
Date: Fri, 07 Jan 2011 10:14:49 -0200
Message-ID: <4D2703B9.3080800@linux.vnet.ibm.com>
References: <1290790908.11971.303.camel@Joe-Laptop> <1290792387-12331-1-git-send-email-leitao@linux.vnet.ibm.com> <20110107142430.42fda498@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org, davem@davemloft.net
To: Anton Blanchard <anton@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp01.br.ibm.com ([32.104.18.85]:35420 "EHLO
	e24smtp01.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751686Ab1AGMOy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jan 2011 07:14:54 -0500
Received: from mailhub3.br.ibm.com (mailhub3.br.ibm.com [9.18.232.110])
	by e24smtp01.br.ibm.com (8.14.4/8.13.1) with ESMTP id p07CeGAX003683
	for <netdev@vger.kernel.org>; Fri, 7 Jan 2011 10:40:16 -0200
Received: from d24av03.br.ibm.com (d24av03.br.ibm.com [9.8.31.95])
	by mailhub3.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p07CMTjd1872048
	for <netdev@vger.kernel.org>; Fri, 7 Jan 2011 10:22:29 -0200
Received: from d24av03.br.ibm.com (loopback [127.0.0.1])
	by d24av03.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p07CEoKv014439
	for <netdev@vger.kernel.org>; Fri, 7 Jan 2011 10:14:51 -0200
In-Reply-To: <20110107142430.42fda498@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Anton,

On 01/07/2011 01:24 AM, Anton Blanchard wrote:
> It looks like you are now only initialising half the ring, but still
>  telling the hardware to use the whole ring. Once you get through the
>  entire ring once the errors go away.
You are correct. The problem in the past ehea_init_fill_rq1() wasn't
respecting the nr_rq1a parameter. So, every time ehea_init_fill_rqX()
was trying to allocated the entire skb arrary, and assume that the
entire array was allocated, which wasn't correct.

My patch just allocate the requested number of skbs (described in
nr_rq1a) in skb array, and tell hea that only that amount of skb were
allocated (via doorbell).

On the other side, ehea_proc_rwqes() tries to maximize the array usage,
meaning that if the array is not completely used, it'd try to allocate
an skb "on-the-fly", and this is expected (For example, when you
initialize the system on memory pressure)

That is why I sent another patch that turns this message a netif_info()
instead of a netif_error() (as it was in the past). The commit id for
this patch is 782615aea84e57dc7f2f922cea823df3de635a78

So, although this behaviour is completely expected, this code path
should only being executed on memory pressure. But I am suspecting this
code path is execute more often than I'd expect. Let me investigate this.

Thanks
Breno
