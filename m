From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/6] PKT_SCHED: Extended Matches API
Date: Mon, 24 Jan 2005 01:49:29 +0100
Message-ID: <20050124004929.GK23931@postel.suug.ch>
References: <20050123230012.GB23931@postel.suug.ch> <20050123230132.GC23931@postel.suug.ch> <41F43D6D.30502@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <41F43D6D.30502@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Patrick McHardy <41F43D6D.30502@trash.net> 2005-01-24 01:12
> Thomas Graf wrote:
> >+struct tcf_ematch
> >+{
> >+	u16			matchid;
> >+	u16			flags;
> >+	struct tcf_ematch_ops * ops;
> >+	unsigned int		datalen;
> >+	unsigned long		data;
> >+};
> >
> This layout leaves two holes on 64 bit, how about:
> 
> {
>    struct tcf_ematch_ops *ops;
>    unsigned long data;
>    unsigned int datalen;
>    u16 matchid;
>    u16 flags;
> };

Good point.

> >+	read_lock(&ematch_mod_lock);
> >+	list_for_each_entry(e, &ematch_ops, link) {
> >+		if (kind == e->kind) {
> >+			if (!try_module_get(e->owner))
> >+				e = NULL;
> >+			break;
> >+		}
> >+	}
> >
> e is the iterator, if nothing matched it will contain the last element now

Damn, yes. Still used to have the iterator being NULL in loops. Probably
made this mistake in other spots too, will check this.

> >+	tree->hdr.nmatches = 0;
> >+	kfree(xchg(&tree->matches, NULL));
> > 
> >
> xchg is not necessary here. Setting tree->matches to NULL also doesn't look
> necessary. As the comment above indicates, the caller needs to ensure the
> tree is unsused, so it should be easy for him to ensure he won't destroy the
> same tree twice.

It's not necessary but I do call tcf_em_tree_destroy internally and I
want to provide a consistent interface to the outside world. It's
argueable for sure. The xchg doesn't have any locking purposes and I can
understand if it confuses readers so I'll remove it.


> >+static inline int tcf_em_match(struct sk_buff *skb, struct tcf_ematch *em,
> >+			       struct tcf_pkt_info *info)
> >+{
> >+	int r;
> >+
> >+	if (likely(em->ops->match))
> > 
> >
> gcc assumes likely for ptr != NULL by default. Is there a reason why a match
> wouldn't have a match function ?

There is no reason but ematches might get written by unexperienced people
forgeting to register it. I know, the if partly hides the failure, it's
one of theses case where I have the same arguments for both ways.
