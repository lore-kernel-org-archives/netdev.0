From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [RFC] unix: fix use-after-free in unix_dgram_poll()/ 4.2.5
Date: Mon, 02 Nov 2015 21:55:42 +0000
Message-ID: <874mh4gj6p.fsf@doppelsaurus.mobileactivedefense.com>
References: <cover.1443817522.git.jbaron@akamai.com>
	<f4e283269e7063317956ea1de6fdc58449ee75cd.1443817522.git.jbaron@akamai.com>
	<87bncdxool.fsf@doppelsaurus.mobileactivedefense.com>
	<5612B9A9.8050301@akamai.com>
	<87lhb7sttz.fsf@doppelsaurus.mobileactivedefense.com>
	<561DCFA4.3010300@akamai.com>
	<87d1wh8hqh.fsf@doppelsaurus.mobileactivedefense.com>
	<561F156E.9050905@akamai.com>
	<87fv17x59w.fsf@doppelsaurus.mobileactivedefense.com>
	<5625073C.5010809@akamai.com>
	<87vba1i383.fsf@doppelsaurus.mobileactivedefense.com>
	<874mhbx7o1.fsf_-_@doppelsaurus.mobileactivedefense.com>
	<877fm43wqv.fsf_-_@doppelsaurus.mobileactivedefense.com>
	<57d2f5b6aae251957bff7a1a52b8bf2c@core-hosting.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Jason Baron <jbaron@akamai.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<minipli@googlemail.com>, <normalperson@yhbt.net>,
	<eric.dumazet@gmail.com>, <viro@zeniv.linux.org.uk>,
	<davidel@xmailserver.org>, <dave@stgolabs.net>,
	<pageexec@freemail.hu>, <torvalds@linux-foundation.org>,
	<peterz@infradead.org>
To: <olivier@mauras.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <57d2f5b6aae251957bff7a1a52b8bf2c@core-hosting.net> (Olivier
	Mauras's message of "Mon, 02 Nov 2015 11:01:08 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Olivier Mauras <olivier@mauras.ch> writes:

[...]

> I've encountered  issues with Jason's patch ported to 3.14.x which would break
> openldap, rendering it unable to answer any query - Here's a strace of the
> slapd process in this state http://pastebin.ca/3226383
> Just ported Rainer's patch to 3.14 and so far I can't reproduce the issue -

I may be missing something here but the final state according to the
trace it that thread 775 of the process blocks in epoll_wait with a
descriptor set containing only a listening TCP socket (8) and waiting
for new connections. I don't think this can execute any code
changed by my patch and I'm fairly certain for this for Jason's, too:
Both are about AF_UNIX datagram sockets and the specific case where
either a write couldn't complete because the backlog of the receive
queue of the 1 side of a n:1 datagram socket arrangement was considered
too large or where a 'poll for write' check returned 'not writeable' for
the same reason.

Judging from the 2.4.42 sources, OpenLDAP doesn't use AF_UNIX datagram
sockets at all so it shouldn't ever be affected by any changes to the
code handling them.
