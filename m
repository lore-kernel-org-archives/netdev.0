From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC] Wireless extensions rethink
Date: Fri, 18 Jun 2004 18:54:56 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40D372C0.1020509@pobox.com>
References: <20040616204248.GA23617@bougret.hpl.hp.com>	<40D0BD5B.201@pobox.com>	<20040616223316.GA29618@bougret.hpl.hp.com>	<40D0D265.3070804@pobox.com>	<20040617174717.GA30460@bougret.hpl.hp.com>	<40D1E185.2010201@pobox.com>	<20040617185605.GA32216@bougret.hpl.hp.com>	<40D1EC54.8000904@pobox.com>	<20040617193154.GE32216@bougret.hpl.hp.com>	<40D1F687.6030307@pobox.com>	<20040617204644.GB3341@bougret.hpl.hp.com> <20040618151117.2f191d7f.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jt@hpl.hp.com, jt@bougret.hpl.hp.com, gwingerde@home.nl, sfeldma@pobox.com,
        netdev@oss.sgi.com, jkmaline@cc.hut.fi
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20040618151117.2f191d7f.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> Coming into this with my lateness exceeded only by my lack of context, I'd
> say that I share Jean's concern over making incompatible changes to the
> wireless user<->kernel interface at this time.  If we can retain _both_
> interfaces in 2.6, remove the old one in 2.7 then maybe that'll be OK.

Two points:
1) This is about the _driver_ API.  The userland interface is a 
different issue.  In Linux the userland ABI is a holy grail that 
shouldn't be broken without warnings across major kernel versions.  We 
can easily add netlink support (as Jean demonstrated) without

2) I won't break the stable kernel driver API, so you worries here are 
unfounded.


> But I do wonder whether this API is the uppermost issue with the wireless
> drivers.

The driver API has got to go.  Period.  Just look at what a sample 
driver exports:


> static const struct iw_handler_def      wavelan_handler_def =
> {
>         .num_standard   = sizeof(wavelan_handler)/sizeof(iw_handler),
>         .num_private    = sizeof(wavelan_private_handler)/sizeof(iw_handler),
>         .num_private_args = sizeof(wavelan_private_args)/sizeof(struct iw_priv_args),
>         .standard       = (iw_handler *) wavelan_handler,
>         .private        = (iw_handler *) wavelan_private_handler,
>         .private_args   = (struct iw_priv_args *) wavelan_private_args,
>         .spy_offset     = ((void *) (&((net_local *) NULL)->spy_data) -
>                            (void *) NULL),
> };


It flat out doesn't work with object lifetime rules, taking _offsets_ in 
driver-local structs into more generic code.

As for the wireless drivers themselves, they will change as the HostAP 
stuff gets integrated more closely into the kernel.


> There seem to be a lot of bug reports, and these drivers are
> *really* complex, and there are lots of out-of-tree drivers.  Aren't these
> the things which we should be devoting cycles to?

The driver API is one of the causes of complexity.  Lack of direct 
integration into the net stack (see 
http://www.kernel.org/pub/linux/kernel/people/jgarzik/patchkits/2.6/davem-p80211.tar.bz2 
for an example direction) another cause of the complexity.

As for out of tree drivers, just look at the web page.  Most either (a) 
have binary-only BLOBs associated or (b) duplicate existing drivers N 
times.  Outside the kernel tree there is no unification, but 3-4 drivers 
for _every_ wireless chipset.

	Jeff
