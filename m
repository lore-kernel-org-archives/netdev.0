From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: Questions about the sh_eth driver and hardware
Date: Wed, 21 Jan 2015 17:24:38 +0000
Message-ID: <1421861078.1222.271.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	ct-linux-kernel <linux-kernel@codethink.co.uk>
To: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Hisashi Nakamura <hisashi.nakamura.ak@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:49462 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751713AbbAURYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 12:24:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I found several more bugs in the sh_eth driver, but for some of them I'm
really unsure what to do.  I only have a manual for the R8A7790 (R-Car
H2) and I don't know how all the other supported chips will behave.
Maybe you can answer some of these questions.

1. When freeing packet buffers, we currently try to stop the DMA engines
by clearing EDRRR and EDTRR but we *don't* wait after that.  This seems
unsafe because in general register writes are not serialised with DMA.

The R8A7790 (R-Car H2) manual specifically says that the R bit of EDTRR
(aka CXR2) cannot be cleared by writing to it.  I think that we could
stop TX DMA by clearing the active flags of all the descriptors and then
polling the R bit until it clears.  What do you think?

As for RX DMA, I think we should wait some time after clearing the R bit
that we can be sure is long enough to transfer one packet.  Do you know
how long that could be?

2. In case of a Receive Descriptor Empty error (RDE), we currently read
the RDFAR register to find the next descriptor the DMA engine will use.
But this register is not documented for the R8A7790 and the driver does
not define an offset for it on R-Car chips.  The manual doesn't say how
to set the address of the next descriptor to use.  Maybe we should
assume that R-Car chips will never skip descriptors after RDE?

Ben.
