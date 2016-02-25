From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH RFC 0/3] intermediate representation for jit and cls_u32 conversion
Date: Thu, 25 Feb 2016 18:37:21 +0100
Message-ID: <1456421844-5901-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, jiri@resnulli.us, horms@verge.net.au,
	john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36274 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933419AbcBYRhe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Feb 2016 12:37:34 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 87F047406
	for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 18:37:31 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 697E7DA388
	for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 18:37:31 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 3DC39DA383
	for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 18:37:29 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patchset contains the core infrastructure for the generic
intermediate representation that I presented during NetDev 1.1's
nftables switchdev talk. This includes the basic infrastructure to
convert the tc cls_u32 based on John's parser.

The main goals of this patchset are:

* Provide an unified abstract syntax tree (ast) that can be passed to
  the backend driver for translation to internal representation. Then,
  based on the backend description, generate the internal
  representation. This should reduce the amount of code to maintain
  in the driver since every frontend, via parser, generates the ast
  that is consumed by the driver through one single ndo indirection.

* Avoid exposing low-level frontend details to the backend, such as
  structure layouts. If the frontend needs to be updated to support a
  new software feature, it is desiderable that such changes don't
  trigger large updates to every driver supporting offloads.

* Having a common parser for every frontend, instead of allowing each
  backend driver to re-invent the wheel with its own parser, this is
  just spreading out complexity all over the place.

A summary picture of the infrastructure looks like this:

                parser
        tc-u32 -------
                       \            jit
     tc-flower -------------- ast ------> Backend driver
                       /
           nft -------

So the idea is that every frontend implements a parser that builds the
ast, then this ast is passed via ndo to the driver. The parser is common
to everyone, is part of the common core infrastructure.

The tc-u32 parser is a bit complicated because of having the matching
spread out in different rules through links, but John already came up a
basic parser than should be placed in the frontend so everyone can
improve it to generate more expressive ast.

Note: I don't have access to ixgbe hardware, so I have validated this
patchset by splicing main parts of the ixgbe backend jit code in simple
debugging patches that I have here. Quite rudimentary but it has passed
some basic tests, may still have gotten anything broken. Anyway, the
main goal is to generate debate on this.

Comments welcome, thanks.

Pablo Neira Ayuso (3):
  net: ixgbe: add struct igxbe_filter
  net: intermediate representation for jit translation
  net: convert tc_u32 to use the intermediate representation

 drivers/net/ethernet/intel/ixgbe/ixgbe.h       |   4 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 249 +++++++++---------
 drivers/net/ethernet/intel/ixgbe/ixgbe_model.h | 112 --------
 include/net/ir.h                               | 173 +++++++++++++
 include/net/pkt_cls.h                          |   3 +
 net/core/Makefile                              |   2 +-
 net/core/ir.c                                  | 219 ++++++++++++++++
 net/sched/cls_u32.c                            | 344 +++++++++++++++++++++++++
 8 files changed, 866 insertions(+), 240 deletions(-)
 delete mode 100644 drivers/net/ethernet/intel/ixgbe/ixgbe_model.h
 create mode 100644 include/net/ir.h
 create mode 100644 net/core/ir.c

-- 
2.1.4
