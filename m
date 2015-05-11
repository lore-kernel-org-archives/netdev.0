From: Tejun Heo <tj@kernel.org>
Subject: [PATCHSET v3] netconsole: implement extended console support
Date: Mon, 11 May 2015 12:41:30 -0400
Message-ID: <1431362494-9874-1-git-send-email-tj@kernel.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, penguin-kernel@I-love.SAKURA.ne.jp,
	sd@queasysnail.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:36473 "EHLO
	mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751483AbbEKQlm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 12:41:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is v3 of netconsole extended console support.  v1 was
part of "printk, netconsole: implement reliable netconsole"
patchset[1].  The printk part is broken off to a separate patchset[2]
"printk: implement extended console support" which this patchset is
dependent upon.

Changes from the last version[3] are

* 0001-netconsole-remove-unnecessary-netconsole_target_get-.patch
  added so that we don't end up adding unnecessary get/put to
  write_ext_msg() for consistency.

* In 0004-netconsole-implement-extended-console-support.patch,
  send_ext_msg_udp() restructured to address Tetsuo and Sabrina's
  review points.

netconsole emits one or more udp messages per each log message and
only transmits the body, which works fine when it's used as a
debugging tool on local network; however, netconsole, due to its
advantages for troubleshooting kernel issues, is also used as a
mechanism to collect kernel messages at larger scale where the packets
may have to travel across congested networks or networks with multiple
paths.

Of the handful large cluster setups that I've seen, two were using
netconsole for fleet-wide kernel logging and having problem with lost
messages.  One was a HPC cluster which had a dedicated slower
management network which was used for all management traffic where
packet losses were fairly common for several different reasons - the
network itself could get fairly overloaded at times and IPMI sharing
the interface didn't seem to help either.  The other is a large web
service cluster where the aggregator is some hops away and packet
losses do happen from time to time.

Because netconsole packets don't carry any metadata, it's impossible
to tell what happened to the messages during transit and even
combining it with messages transmitted via a separate reliable
mechanism is challenging as it boils down to matching message content
textually.

The "printk, netconsole: implement reliable netconsole" patchset[1]
implements extended console support.  If a console driver sets
CON_EXTENDED, printk formats each message in the same way /dev/kmsg
messages are formatted which includes all metadata and, for structured
log messages, KEY=VALUE dictionary.

This patchset implements extended console support for netconsole,
which allows log consumers access to complete log information and to
tell which messages are missing and/or reordered, which can be used to
implement reliable kernel message logging when combined with userland
helpers.

Changes to netconsole are straight-forward.  It optionally registers a
separate extended console driver.  printk passes in extended format
messages which are transmitted the same way.  The only complication is
when the message is longer than the maximum payload size (1k).  As
each message should have proper header and the log receiver should be
able to tell which part the fragment is, netconsole duplicates full
header on each fragment and also adds an extra ncfrag=OFF/LEN header.

 0001-netconsole-remove-unnecessary-netconsole_target_get-.patch
 0002-netconsole-make-netconsole_target-enabled-a-bool.patch
 0003-netconsole-make-all-dynamic-netconsoles-share-a-mute.patch
 0004-netconsole-implement-extended-console-support.patch

diffstat follows.  Thanks.

 Documentation/networking/netconsole.txt |   35 ++++++
 drivers/net/netconsole.c                |  169 ++++++++++++++++++++++++++++----
 2 files changed, 185 insertions(+), 19 deletions(-)

--
tejun

[1] http://lkml.kernel.org/g/1429225433-11946-1-git-send-email-tj@kernel.org
[2] http://lkml.kernel.org/g/1430318704-32374-1-git-send-email-tj@kernel.org
[3] http://lkml.kernel.org/g/1430505220-25160-1-git-send-email-tj@kernel.org
