From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v1 00/11] A flow API
Date: Wed, 31 Dec 2014 11:45:19 -0800
Message-ID: <20141231194057.31070.5244.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net
To: tgraf@suug.ch, sfeldma@gmail.com, jiri@resnulli.us,
	jhs@mojatatu.com, simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:63364 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751362AbaLaTpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 14:45:39 -0500
Received: by mail-oi0-f51.google.com with SMTP id h136so3072525oig.10
        for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 11:45:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So... I could continue to mull over this and tweak bits and pieces
here and there but I decided its best to get a wider group of folks
looking at it and hopefulyl with any luck using it so here it is.

This set creates a new netlink family and set of messages to configure
flow tables in hardware. I tried to make the commit messages
reasonably verbose at least in the flow_table patches.

What we get at the end of this series is a working API to get device
capabilities and program flows using the rocker switch.

I created a user space tool 'flow' that I use to configure and query
the devices it is posted here,

	https://github.com/jrfastab/iprotue2-flow-tool

For now it is a stand-alone tool but once the kernel bits get sorted
out (I'm guessing there will need to be a few versions of this series
to get it right) I would like to port it into the iproute2 package.
This way we can keep all of our tooling in one package see 'bridge'
for example.

As far as testing, I've tested various combinations of tables and
rules on the rocker switch and it seems to work. I have not tested
100% of the rocker code paths though. It would be great to get some
sort of automated framework around the API to do this. I don't
think should gate the inclusion of the API though.

I could use some help reviewing,

  (a) error paths and netlink validation code paths

  (b) Break down of structures vs netlink attributes. I
      am trying to balance flexibility given by having
      netlinnk TLV attributes vs conciseness. So some
      things are passed as structures.

  (c) are there any devices that have pipelines that we
      can't represent with this API? It would be good to
      know about these so we can design it in probably
      in a future series.

For some examples and maybe a bit more illustrative description I
posted a quickly typed up set of notes on github io pages. Here we
can show the description along with images produced by the flow tool
showing the pipeline. Once we settle a bit more on the API we should
probably do a clean up of this and other threads happening and commit
something to the Documentation directory.

 http://jrfastab.github.io/jekyll/update/2014/12/21/flow-api.html

Finally I have more patches to add support for creating and destroying
tables. This allows users to define the pipeline at runtime rather
than statically as rocker does now. After this set gets some traction
I'll look at pushing them in a next round. However it likely requires
adding another "world" to rocker. Another piece that I want to add is
a description of the actions and metadata. This way user space can
"learn" what an action is and how metadata interacts with the system.
This work is under development.

Thanks! Any comments/feedback always welcome.

And also thanks to everyone who helped with this flow API so far. All
the folks at Dusseldorf LPC, OVS summit Santa Clara, P4 authors for
some inspiration, the collection of IETF FoRCES documents I mulled
over, Netfilter workshop where I started to realize fixing ethtool
was most likely not going to work, etc.

---

John Fastabend (11):
      net: flow_table: create interface for hw match/action tables
      net: flow_table: add flow, delete flow
      net: flow_table: add apply action argument to tables
      rocker: add pipeline model for rocker switch
      net: rocker: add set flow rules
      net: rocker: add group_id slices and drop explicit goto
      net: rocker: add multicast path to bridging
      net: rocker: add get flow API operation
      net: rocker: add cookie to group acls and use flow_id to set cookie
      net: rocker: have flow api calls set cookie value
      net: rocker: implement delete flow routine


 drivers/net/ethernet/rocker/rocker.c          | 1641 +++++++++++++++++++++++++
 drivers/net/ethernet/rocker/rocker_pipeline.h |  793 ++++++++++++
 include/linux/if_flow.h                       |  115 ++
 include/linux/netdevice.h                     |   20 
 include/uapi/linux/if_flow.h                  |  413 ++++++
 net/Kconfig                                   |    7 
 net/core/Makefile                             |    1 
 net/core/flow_table.c                         | 1339 ++++++++++++++++++++
 8 files changed, 4312 insertions(+), 17 deletions(-)
 create mode 100644 drivers/net/ethernet/rocker/rocker_pipeline.h
 create mode 100644 include/linux/if_flow.h
 create mode 100644 include/uapi/linux/if_flow.h
 create mode 100644 net/core/flow_table.c

-- 
Signature
