From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IB/ipoib: move back the IB LL address into the hard
 header,Re: [PATCH] IB/ipoib: move back the IB LL address into the hard
 header
Date: Thu, 13 Oct 2016 10:43:14 -0400 (EDT)
Message-ID: <20161013.104314.1842951254979604965.davem@davemloft.net>
References: <1dbd83dfe7f435eecc5bc460e901b47758280f30.1476206016.git.pabeni@redhat.com>
        <20161013.102432.1450901395774429343.davem@davemloft.net>
        <20ace6ee-b9e4-073c-56e7-29b2c50ae2d5@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pabeni@redhat.com, linux-rdma@vger.kernel.org,
        sean.hefty@intel.com, hal.rosenstock@gmail.com,
        netdev@vger.kernel.org
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33540 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752362AbcJMOpT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 10:45:19 -0400
In-Reply-To: <20ace6ee-b9e4-073c-56e7-29b2c50ae2d5@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Doug Ledford <dledford@redhat.com>
Date: Thu, 13 Oct 2016 10:35:35 -0400

> On 10/13/2016 10:24 AM, David Miller wrote:
>> From: Paolo Abeni <pabeni@redhat.com>
>> Date: Tue, 11 Oct 2016 19:15:44 +0200
>> 
>>> After the commit 9207f9d45b0a ("net: preserve IP control block
>>> during GSO segmentation"), the GSO CB and the IPoIB CB conflict.
>>> That destroy the IPoIB address information cached there,
>>> causing a severe performance regression, as better described here:
>>>
>>> http://marc.info/?l=linux-kernel&m=146787279825501&w=2
>>>
>>> This change moves the data cached by the IPoIB driver from the
>>> skb control lock into the IPoIB hard header, as done before
>>> the commit 936d7de3d736 ("IPoIB: Stop lying about hard_header_len
>>> and use skb->cb to stash LL addresses").
>>> In order to avoid GRO issue, on packet reception, the IPoIB driver
>>> stash into the skb a dummy pseudo header, so that the received
>>> packets have actually a hard header matching the declared length.
>>> Also the connected mode maximum mtu is reduced by 16 bytes to
>>> cope with the increased hard header len.
>>>
>>> After this commit, IPoIB performances are back to pre-regression
>>> value.
>>>
>>> Fixes: 9207f9d45b0a ("net: preserve IP control block during GSO segmentation")
>>> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
>> 
>> Not providing an accurate hard_header_len causes many problems.
>> 
>> In fact we recently fixed the mlxsw driver to stop doing this.
>> 
> 
> Sure, but there are too many users of the cb struct, and whatever
> problems you are saying there are by lying about the hard header len are
> dwarfed by the problems caused by the inability to store the ll address
> anywhere between hard_header and send time.

IB wants to pass addressing information between layers, it needs to
find a safe way to do that.  The currently propsoed patch does not
meet this criteria.

Pushing metadata before the head of the SKB data pointer is illegal,
as the layers in between might want to push protocol headers, mirror
the packet to another interface, etc.

So this "metadata in SKB data" approach is buggy too.
