From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PKT_SCHED]: Allow using nfmark as key in U32 classifier.
Date: Mon, 3 Jan 2005 17:26:35 +0100
Message-ID: <20050103162635.GD26856@postel.suug.ch>
References: <20041231153930.GN32419@postel.suug.ch> <1104511494.1048.303.camel@jzny.localdomain> <20041231181153.GP32419@postel.suug.ch> <1104526311.1047.379.camel@jzny.localdomain> <20050101121041.GR32419@postel.suug.ch> <1104622164.1048.444.camel@jzny.localdomain> <20050102000612.GU32419@postel.suug.ch> <1104763012.1047.524.camel@jzny.localdomain> <20050103150230.GC26856@postel.suug.ch> <1104767726.1049.591.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1104767726.1049.591.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1104767726.1049.591.camel@jzny.localdomain> 2005-01-03 10:55
> Sorry, havent looked at the code yet. Is the patch you posted the same
> as you have on the url earlier?

Yes, with a few minor fixes and I made it depend on
CONFIG_NET_CLS_EMATCH and added nil macros when it's not defined.
Those macros need some more work though.

TODO:
 - KConfig doc
 - make change optional
 - dump m->data if no dump implementation is provided

The question I'm yet unsure is whether to strictly return 1/0 or
allow classifier return codes.

Given I'm done with the above, a minimal ematch will look  like:

static int sec_match(struct sk_buff *skb, struct tcf_ematch *m)
{
	return *(u32 *) m->data == skb->security;
}

static struct tcf_ematch_ops sec_ops = {
	.kind = 11,
	.match = sec_match,
	.owner = THIS_MODULE
}

... init/exit calling tcf_em_(un_register ...

What do you think about checking RTA_PAYLOAD of the ematch data
for < sizeof(unsigned long) and assign it to m->data without
allocation? Would save us nonse allocations. The yet unused 8bit
in tcf_ematch_hdr would hold a flag to indicate that m->data
contains the data directly.

> I relaized that - but should the user know anything about this?

Actually no but initializing it in tcf_em_register wouldn't serve
any purpose so we can either remove it or leave it there.
