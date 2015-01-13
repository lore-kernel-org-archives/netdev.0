From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v2 00/12] Flow API
Date: Tue, 13 Jan 2015 13:35:00 -0800
Message-ID: <20150113212941.13874.48692.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gerlitz.or@gmail.com, jhs@mojatatu.com,
	andy@greyhouse.net, davem@davemloft.net
To: tgraf@suug.ch, simon.horman@netronome.com, sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:54686 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751262AbbAMVfX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 16:35:23 -0500
Received: by mail-oi0-f49.google.com with SMTP id a141so4439398oig.8
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 13:35:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I tried to roll in all the feedback from v1 into this series annotated
here,

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

Thanks for the initial feedback here is a v2 to take a look at I
hope I addressed all the comments so far except for the integrate
with 'tc'. I plan to work on the integration pieces next.

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

I could use some help reviewing,

  (a) error paths and netlink validation code paths
  (b) are there any devices that have pipelines that we
      can't represent with this API? It would be good to
      know about these so we can design it in probably
      in a future series.

For some examples and maybe a bit more illustrative description I
posted a quickly typed up set of notes on github io pages.

  http://jrfastab.github.io/jekyll/update/2014/12/21/flow-api.html

After this initial work to expose the API is complete the next task
is to integrate with existing subsystems 'tc' and OVS for example.

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
      net: flow_table: add flow, delete flow
      net: flow: implement flow cache for get routines
      net: flow_table: create a set of common headers and actions
      net: flow_table: add validation functions for flows
      net: rocker: add pipeline model for rocker switch
      net: rocker: add set flow rules
      net: rocker: add group_id slices and drop explicit goto
      net: rocker: add multicast path to bridging
      net: rocker: add cookie to group acls and use flow_id to set cookie
      net: rocker: have flow api calls set cookie value
      net: rocker: implement delete flow routine


 drivers/net/ethernet/rocker/rocker.c          |  757 ++++++++++
 drivers/net/ethernet/rocker/rocker_pipeline.h |  595 ++++++++
 include/linux/if_flow.h                       |  228 +++
 include/linux/if_flow_common.h                |  257 +++
 include/linux/netdevice.h                     |   48 +
 include/uapi/linux/if_flow.h                  |  440 ++++++
 net/Kconfig                                   |    7 
 net/core/Makefile                             |    1 
 net/core/flow_table.c                         | 1909 +++++++++++++++++++++++++
 9 files changed, 4225 insertions(+), 17 deletions(-)
 create mode 100644 drivers/net/ethernet/rocker/rocker_pipeline.h
 create mode 100644 include/linux/if_flow.h
 create mode 100644 include/linux/if_flow_common.h
 create mode 100644 include/uapi/linux/if_flow.h
 create mode 100644 net/core/flow_table.c

-- 
Signature
