From: Harald Welte <laforge@gnumonks.org>
Subject: loosing netdevices with namespaces and unshare?
Date: Wed, 31 May 2017 00:07:41 +0200
Message-ID: <20170530220741.ldmhwj3bsvdoaofc@nataraja>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:54189 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751140AbdE3WYb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 18:24:31 -0400
Received: from uucp by ganesha.gnumonks.org with local-bsmtp (Exim 4.84_2)
        (envelope-from <laforge@gnumonks.org>)
        id 1dFpIt-0003ie-FG
        for netdev@vger.kernel.org; Wed, 31 May 2017 00:07:51 +0200
Received: from laforge by localhost.localdomain with local (Exim 4.89)
        (envelope-from <laforge@gnumonks.org>)
        id 1dFpIj-0001I6-TN
        for netdev@vger.kernel.org; Wed, 31 May 2017 00:07:41 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I know I'm kind of late to the party in terms of deeper exploration of
Linux network namespaces.  Also, I'm not sure if the netdev list is the
riight place to ask, but a moderate amount of web searching didn't bring
up a solution in multiple hours, and it seems like I could trigger the
kernel (4.11.0) to loose netdevices, which I think is a serious issue.

What I'm doing:
* start a process using the 'unshare' command line tool provided with
  util-linux, e.g. "unshare -nUr bash". I do this as a non-privileged
  user but now that is mapped to uid '0' inside the new
  process/namespace, so I can adjust interface configuration.
* I use "echo $$" to get the PID of that bash process.
* On another terminal in a root shell, I use "ip link set eth0 netns $PID"
  in order to move a given physical device into that namespace.
* I then "exit" that bash, which should - to my knowledge - return the
  "eth0" netdev back to the root namespace, as the bash process was the
  only one using that network namespace

But, to the contrary, this doesn't happen.  The unshare-created netns is
gone, but the netdevice did not get moved back to the root namespace
either.  The only hack to get back to the "eth0" device is to unload the
driver and re-load it.

I can reproduce the above without starting any other process inside that
namespace.  I have verified that there are no /proc/*/ns/net symlinks
left pointing to the ID of that namespace.  What am I missing here?  Is
this the intended behavior?

Of course I know I could simply do something like "ip link set eth0
netns 1" from within the namespace before leaving.  But what if the
process is not bash and the process exits abnormally?   I'd consider
that explicit reassignment more like a hack than a proper solution...

Regards,
	Harald

p.s.: In case you're wondering what I'm actually trying to achieve: Find
an easy way to run a single program in an isolated namespace that only
has one physical (usb) ethernet device.  I would like to execute that
program as unprivileged user but still be able to bind to privileged
ports.  And I want to do this using simple command-line tools without
all the bloat and overhead of "container" solutions that have 99% of
features I don't need.  But let that not distract you, I think the
mysteriously disappearing netdevices are a more general and important
issue.

-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
