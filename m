From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC 0/3] net: unft: Add Userspace hairpin network flow table device
Date: Wed, 18 Feb 2015 14:25:56 -0500
Message-ID: <1424287559-25700-1-git-send-email-simon.horman@netronome.com>
Cc: Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f47.google.com ([209.85.213.47]:40668 "EHLO
	mail-yh0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753709AbbBRT0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2015 14:26:21 -0500
Received: by yhot59 with SMTP id t59so2213086yho.7
        for <netdev@vger.kernel.org>; Wed, 18 Feb 2015 11:26:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

*** Not for Upstream Merge
*** For informational purposes only

As discussed at netconf we have been working on hairpinning Flow API
messages back to user-space as a mechanism for exercising that API.

And as promised at netconf I am releasing our code.

What this can do:
* Allow the implementation of the NDO's proposed by John Fastabend's API
  to be implemented in user-space. This is done using netlink messages.

What this cannot do:
* Anything else

Limitations:
* Both the design and the implementation are slow

I have also written user-space code. There are two portions:

1. flow-table

   This may be used to send and receive messages from the Flow API.
   It a command-line utility which may be used to exercise the flow API.
   And a library to help achieve this. An interesting portion
   of the library is a small framework for converting between
   netlink and JSON.

   It is available here: https://github.com/horms/flow-table
   The licence is GPLv2

   It overlaps to some extent with user-space code by John Fastabend.
   I was not aware of that work which he was doing concurrently.

2. flow-table-hairpin

   This is a daemon that listens for messages hairpined back
   to user-space and responds accordingly. That is, the user-space
   backing of the NDOs of the Flow API.

   It includes a simple flow table backend (ftbe) abstraction
   and a dummy implementation that stores flows in a local list
   ** and does nothing else with them ***

   It is available here: https://github.com/horms/flow-table-hairpin
   The licence is GPLv2


Usage example:

# Create unft netdev
ip link add type unft

# Start haripind. The tables, headers, etc... are provided as JSON
flow-table-hairpind \
        --tables tables.json \
        --headers headers.json \
        --actions actions.json \
        --header-graph header-graph.json \
        --table-graph table-graph.json &

# Get the tables of unft using the Flow API
flow-table-ctl get-tables unft0


Base:

These patches are based on v2 of the Flow API.
"[net-next PATCH v2 00/12] Flow API"
http://www.spinics.net/lists/netdev/msg311961.html


Simon Horman (3):
  net: flow: export net_flow_{put_rule,get_{field,action}}
  net: flow: Introduce flow table hairpin API
  net: unft: Add Userspace hairpin network flow table device

 drivers/net/Kconfig                  |    9 +
 drivers/net/Makefile                 |    1 +
 drivers/net/unft.c                   | 1520 ++++++++++++++++++++++++++++++++++
 include/linux/if_flow.h              |    6 +
 include/linux/if_flow_hairpin.h      |    6 +
 include/uapi/linux/if_flow_hairpin.h |  159 ++++
 net/core/flow_table.c                |   10 +-
 7 files changed, 1707 insertions(+), 4 deletions(-)
 create mode 100644 drivers/net/unft.c
 create mode 100644 include/linux/if_flow_hairpin.h
 create mode 100644 include/uapi/linux/if_flow_hairpin.h

-- 
2.1.4
