From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: POHMELFS high performance network filesystem. Transactions, failover, performance.
Date: Wed, 14 May 2008 00:51:14 +0400
Message-ID: <20080513205114.GA16489@2ka.mipt.ru>
References: <20080513174523.GA1677@2ka.mipt.ru> <4829E752.8030104@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:57533 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762139AbYEMUvV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 16:51:21 -0400
Content-Disposition: inline
In-Reply-To: <4829E752.8030104@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Tue, May 13, 2008 at 03:09:06PM -0400, Jeff Garzik (jeff@garzik.org) wrote:
> This continues to be a neat and interesting project :)

Thanks :)

> Where is the best place to look at client<->server protocol?

Hmm, in sources I think, I need to kick myself to write a somewhat good
spec for the next release.

Basically protocol contains of fixed sized header (struct netfs_cmd) and
attached data, which size is embedded into above header. Simple commands
are finished here (essentially all except write/create commands), you
can check them in approrpiate address space/inode operations.
Transactions follow netlink (which is very ugly but exceptionally
extendible) protocol: there is main header (above structure), which
holds size of the embedded data, which can be dereferenced as header/data
parts, where each inner header corresponds to any command (except
transaction header). So one can pack (upto 90 pages of data or different
commands on x86, this is limit of the page size devoted to headers)
requested number of commands into single 'frame' and submit it to
system, which will care about atomicity of that request in regards of
being either fully processed by one of the servers or dropped.

> Are you planning to support the case where the server filesystem dataset 
> does not fit entirely on one server?

Sure. First by allowing whole object to be placed on different servers
(i.e. one subdir is on server1 and another on server2), probably in the
future there will be added support for the same object being distributed
to different servers (i.e. half of the big file on server1 and another
half on server2).

> What is your opinion of the Paxos algorithm?

It is slow. But it does solve failure cases.
So far POHMELFS does not work as distributed filesystem, so it should
not care about it at all, i.e. at most in the very nearest future it
will just have number of acceptors in paxos terminology (metadata
servers in others) without need for active dynamical reconfiguration,
so protocol will be greatly reduced, with addition of dynamical
metadata cluster extension protocol will have to be extended.

As practice shows, the smaller and simpler initial steps are, the better
results eventually become :)

-- 
	Evgeniy Polyakov
