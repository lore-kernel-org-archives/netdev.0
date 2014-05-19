From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH 0/9] net: Introduce a software TSO helper API
Date: Mon, 19 May 2014 13:59:51 -0300
Message-ID: <1400518800-6111-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: Willy Tarreau <w@1wt.eu>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:53579 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751596AbaESRAv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 13:00:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here's a first proposal for a generic software TSO helper API, following
David's suggestion.

There are at least two drivers that currently implement some form of software
TSO: Solarflare network driver (drivers/net/ethernet/sfc) and Tilera GX
network driver (drivers/net/ethernet/tile/tilegx.c).

The rationale behind adding a generic API is to provide a boiler plate with the
segmentation and other common tasks, making this support easier to add in other
drivers.

When designing the API, I've considered mainly two design choices:

  1. Implement a series of callbacks that each driver would implement
     and the net core code would call to fill in descriptors and egress
     that data.

  2. Implement an API for drivers to use in a driver's specific tx_tso
     function. This functions would exhaust a sk_buff payload, and use the
     API as helper for building the headers and segmented data.

I've chosen (2), to avoid function pointers (which was Willy's concern) and
because it seemed less fragile. Of course, this is argueable.

The API is by no means complete, and lacks some features, however it allows
to support TSO in mv643xx_eth and mvneta network drivers with some very
good performance results. I've added this support as an example of the API
in action.

In particular the following needs some revisiting:

  1. IPv6 support is lacking.

  2. The required descriptor counting needs some verification. The current
     implementation might be too "sketchy". The tilegx one can be a good
     starting point.

  3. The implemenation assumes the hardware can compute the TCP and IP
     checksums for the built headers. However, some controllers may need
     some initial calculation (such as tilegx, for instance).

Despite this, I hope this proposal is good enough to trigger some discussion
and to check if I'm on the right track. Feedback is much appreciated!

Ezequiel Garcia (9):
  net: Add a software TSO helper API
  net: mvneta: Factorize feature setting
  net: mvneta: Clean mvneta_tx() sk_buff handling
  net: mvneta: Implement software TSO
  net: mv643xx_eth: Factorize initial checksum and command preparation
  net: mv643xx_eth: Avoid setting the initial TCP checksum
  net: mv643xx_eth: Factorize feature setting
  net: mv643xx_eth: Use dma_map_single() to map the skb fragments
  net: mv643xx_eth: Implement software TSO

 drivers/net/ethernet/marvell/mv643xx_eth.c | 304 ++++++++++++++++++++++-------
 drivers/net/ethernet/marvell/mvneta.c      | 172 ++++++++++++++--
 include/net/tso.h                          |  20 ++
 net/core/Makefile                          |   2 +-
 net/core/tso.c                             |  72 +++++++
 5 files changed, 492 insertions(+), 78 deletions(-)
 create mode 100644 include/net/tso.h
 create mode 100644 net/core/tso.c

-- 
1.9.1
