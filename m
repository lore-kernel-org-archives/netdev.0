From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] netfilter: xt_condition: add security capability
 support
Date: Tue, 24 Aug 2010 09:32:35 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1008240921230.24349@obet.zrqbmnf.qr>
References: <1282567801-2673-1-git-send-email-luciano.coelho@nokia.com>  <AANLkTi=2H+ytOQU9nC_dRp_GB5Sy1831VY14oW=YSOrG@mail.gmail.com>  <1282570935.7198.5.camel@powerslave>  <alpine.LNX.2.01.1008231628010.21000@obet.zrqbmnf.qr>  <1282589101.7198.28.camel@powerslave>
  <alpine.LNX.2.01.1008232052170.31619@obet.zrqbmnf.qr> <1282633220.7198.123.camel@powerslave>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ext Changli Gao <xiaosuo@gmail.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	James Morris <jmorris@namei.org>,
	"linux-security-module@vger.kernel.org"
	<linux-security-module@vger.kernel.org>
To: Luciano Coelho <luciano.coelho@nokia.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1282633220.7198.123.camel@powerslave>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tuesday 2010-08-24 09:00, Luciano Coelho wrote:
>>
>>It is strange that you check this capability from a module focused
>>on packet handling. For lack of a better example, it's as if you
>>tried to check the uid of the file, the latter of which is better
>>left to the routines in fs/.
>
>What I don't understand is that I see lots of components, which have
>nothing to do with security, making this kind of checks. Most of
>them (if not all) are checking for input from userspace where they
>provide their own interfaces (eg. ioctl calls, netlink messages).
>[..] Now, with the xt_condition, we're opening a new route from
>userspace to the kernel and I think it might be a good idea to
>protect that too.

Indeed so. But you did not invent any new interface. You are reusing
files, which can be protected by DAC modes, or LSMs doing
funky-stuff. xt_{condition,recent,..} already implement file modes,
but does it check for it? Well no, because fs/namei.c does it for
them. As for LSMs, well, I hope they do cater for testing for
capability bits.

>It's kind of useless to protect someone without CAP_NET_ADMIN from
>creating a condition rule if it is possible to change the condition from
>userspace without any capability protection.

Certainly not. An administrator may create a condition rule and thus
procfs entry, but the rule may be sufficiently safe and/or integrated
that a subordinate may be given permission to control things in a
limited fashion on a per-need basis. One I use personally is

	-A FORWARD -m condition --condition windows -s
	192.168.100.0/25 -i eth1 -o eth0 -j ACCEPT
	-P FORWARD DROP

	chown jengelh /proc/net/nf_condition/windows;

The presence of such rule would indicate that the administrator
generally allows Windows machines out; but personal paranoia defaults
to rejecting that unless explicitly enabled. (Gives the reassurance
that they won't succeed talking home unless Internet connectivity is
explicitly needed by the user.)
