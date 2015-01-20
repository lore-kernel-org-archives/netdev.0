From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v3 00/12] Flow API
Date: Tue, 20 Jan 2015 12:26:13 -0800
Message-ID: <20150120202404.1741.8658.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, davem@davemloft.net,
	gerlitz.or@gmail.com, andy@greyhouse.net, ast@plumgrid.com
To: tgraf@suug.ch, simon.horman@netronome.com, sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:50254 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751664AbbATU0a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 15:26:30 -0500
Received: by mail-oi0-f46.google.com with SMTP id a141so8375486oig.5
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 12:26:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I believe I addressed all the comments so far except for the integrate
with 'tc'. I plan to work on the integration pieces next.

v3:
 - fixes from Simon Horman integrated see netdev mailing list
 - converted synch rcu to call_rcu
 - updated git commit messages to match code
 - updated flow-api.html document to match latest updates
 - also updated user space flow tool with a handful of fixes
v2:
 - Use a software rhashtable to store add/del flows so we can skip
   having to interrogate drivers for get_flow requests.

 - Removed structures from UAPI this should make it easier to evolve
   as needed.

 - Added net_flow_lock around set/del rule ops.

 - Alexei Starovoitov suggested renaming NET_FLOW -> NFL for
   brevity/clarity. Seems reasonable to me so went ahead and changed
   the UAPI enums. Also renamed flow types and calls  to *_rule. Core
   flow_table still using net_flow_* prefix.

 - various fixes/suggestion from Simon Horman, Jiri Pirko, Scot
   Feldman, Thomas Graf, et. al.
	* SimonH: sent patch series of fixes to netdev
	* JiriP: some naming issues, some helper funcs added, etc.
 	* ScottF: use ARRAY_SIZE, let compiler define array sizes, use
	          ETH_P_* macros. Various fixes.
	* ThomasG: various suggestions

 - fixed a few cases to catch invalid messages from user space
   and dev_put errors.

---

This set creates a new netlink family and set of messages to configure
flow tables in hardware. I tried to make the commit messages
reasonably verbose at least in the flow_table patches possibly too
verbose.

What we get at the end of this series is a working API to get device
capabilities and program flows using the rocker switch.

I created a user space tool 'flow' that I use to configure and query
the devices it is posted here,

	https://github.com/jrfastab/iprotue2-flow-tool

For now it is a stand-alone tool but once the kernel bits get sorted
out I would like to port it into the iproute2 package. This way we
can keep all of our tooling in one package.

As far as testing, I've tested various combinations of tables and
rules on the rocker switch and it seems to work.

For some examples and maybe a bit more illustrative description I
posted a  set of notes on github io pages. Here we can show the
description along with images produced by the flow tool showing
the pipeline.

http://jrfastab.github.io/jekyll/update/2014/12/21/flow-api.html

After this base work is complete the next task is to integrate with
existing subsystems 'tc' and OVS for example. And provide more
example setups in the notes.

Thanks! Any comments/feedback always welcome.

And also thanks to everyone who helped with this flow API so
far. All the folks at Dusseldorf LPC, OVS summit Santa Clara, P4
authors for some inspiration, the collection of IETF FoRCES
documents I mulled over, Netfilter workshop where I started
to realize fixing ethtool was most likely not going to work,
etc.

---

John Fastabend (12):
      net: flow_table: create interface for hw match/action tables
      net: flow_table: add rule, delete rule
      net: flow: implement flow cache for get routines
      net: flow_table: create a set of common headers and actions
      net: flow_table: add validation functions for rules
      net: rocker: add pipeline model for rocker switch
      net: rocker: add set rule ops
      net: rocker: add group_id slices and drop explicit goto
      net: rocker: add multicast path to bridging
      net: rocker: add cookie to group acls and use flow_id to set cookie
      net: rocker: have flow api calls set cookie value
      net: rocker: implement delete flow routine


 drivers/net/ethernet/rocker/rocker.c          |  754 ++++++++++
 drivers/net/ethernet/rocker/rocker_pipeline.h |  595 ++++++++
 include/linux/if_flow.h                       |  231 +++
 include/linux/if_flow_common.h                |  257 +++
 include/linux/netdevice.h                     |   48 +
 include/uapi/linux/if_flow.h                  |  440 ++++++
 net/Kconfig                                   |    7 
 net/core/Makefile                             |    1 
 net/core/flow_table.c                         | 1915 +++++++++++++++++++++++++
 9 files changed, 4231 insertions(+), 17 deletions(-)
 create mode 100644 drivers/net/ethernet/rocker/rocker_pipeline.h
 create mode 100644 include/linux/if_flow.h
 create mode 100644 include/linux/if_flow_common.h
 create mode 100644 include/uapi/linux/if_flow.h
 create mode 100644 net/core/flow_table.c

-- 
Signature
