From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH] IB/ipoib: move back the IB LL address into the hard
 header
Date: Thu, 13 Oct 2016 17:17:04 +0200
Message-ID: <1476371824.4690.32.camel@redhat.com>
References: <1dbd83dfe7f435eecc5bc460e901b47758280f30.1476206016.git.pabeni@redhat.com>
         <20161013.102432.1450901395774429343.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-rdma@vger.kernel.org, dledford@redhat.com,
        sean.hefty@intel.com, hal.rosenstock@gmail.com,
        netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60234 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756207AbcJMPRH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Oct 2016 11:17:07 -0400
In-Reply-To: <20161013.102432.1450901395774429343.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-10-13 at 10:24 -0400, David Miller wrote:
> From: Paolo Abeni <pabeni@redhat.com>
> Date: Tue, 11 Oct 2016 19:15:44 +0200
> 
> > After the commit 9207f9d45b0a ("net: preserve IP control block
> > during GSO segmentation"), the GSO CB and the IPoIB CB conflict.
> > That destroy the IPoIB address information cached there,
> > causing a severe performance regression, as better described here:
> > 
> > http://marc.info/?l=linux-kernel&m=146787279825501&w=2
> > 
> > This change moves the data cached by the IPoIB driver from the
> > skb control lock into the IPoIB hard header, as done before
> > the commit 936d7de3d736 ("IPoIB: Stop lying about hard_header_len
> > and use skb->cb to stash LL addresses").
> > In order to avoid GRO issue, on packet reception, the IPoIB driver
> > stash into the skb a dummy pseudo header, so that the received
> > packets have actually a hard header matching the declared length.
> > Also the connected mode maximum mtu is reduced by 16 bytes to
> > cope with the increased hard header len.
> > 
> > After this commit, IPoIB performances are back to pre-regression
> > value.
> > 
> > Fixes: 9207f9d45b0a ("net: preserve IP control block during GSO segmentation")
> > Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> 
> Not providing an accurate hard_header_len causes many problems.
> 
> In fact we recently fixed the mlxsw driver to stop doing this.

AFAICS the mlxsw did a different thing, adding an additional header in
the xmit function and pushing packets in the network stack with a mac
length different from the declared hard header length

The hard header specified by the IPoIB driver is build in the create()
header_ops and its length matches the mac header length of the packets
pushed into the network stack by such driver. GRO works correctly on top
of that. From the networking stack PoV the hard_header_len should be
'accurate'.

Can you please give more details on the problem that may arise from
this ?

thank you,

Paolo
