From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] ematch API, u32 ematch, nbyte ematch, basic classifier
Date: Thu, 6 Jan 2005 20:41:02 +0100
Message-ID: <20050106194102.GW26856@postel.suug.ch>
References: <20050103125635.GB26856@postel.suug.ch> <20050104223612.GN26856@postel.suug.ch> <1104894728.1117.56.camel@jzny.localdomain> <20050105110048.GO26856@postel.suug.ch> <1104931991.1117.152.camel@jzny.localdomain> <20050105144514.GQ26856@postel.suug.ch> <1105019225.2312.7.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1105019225.2312.7.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1105019225.2312.7.camel@jzny.localdomain> 2005-01-06 08:47
> So the issue is whether its by ref or copy? Maybe thats what the flag is
> for then. My view is that _everything_ for ematches should be by copy
> for simplicty.

If we do everything as ref we'll be allocating 4 byte chunks or we
introduce a storage u32 which pollutes the structure. I don't
like that given that the transfer of a single u32 is probably the
most common for all those smallish ematches for a specific thing.
For simplicity, you don't even notice if you're not aware of that
it can be of help so I don't think we're losing any simplicity here.

> Oh, yes;->  the one check in the datapath comes with a _huge_ advantage
> even all that you had was old style matches because now you have embeded
> logical operations which are more than just the old AND. But more
> importantly you can use ematches as well to influence the existing u32
> tree path.

Missunderstanding here, I meant is there any advantage in having
multiple ematch trees (interleaved) over just making the existing
u32 key an ematch and have the selector (with the hashing bits
extracted) with one ematch tree.

> What i am reading is you see more work involved. Is this correct?

Well, given we can agree on moving the u32 key to an ematch and
have the selector replaced with an ematch tree the following
modifications would be required in u32:

1) extract hashing bits out of selector and move it into a new
   TLV.
2) Replace the foreach key match loop with an ematch_tree match
3) Fill out a pkt_info struct with ptr and off2 so we don't lose
   hashing capabilities
4) Add backward compat code. Old selector must be transformed
   into a flat ematch tree and the hashing bits must be extracted
   and stored in the new struct.

> There is one issue which i think is the big source of our lack of sync:
> You conclude people are gonna want to use the logical tree building
> scheme you are putting in to put together matches and ematches. U32
> _already_ has a tree building scheme which is very very flexible.

I know and I'm not gonna break it but rather replace the ANDed
u32 key chains with an ematch tree. I'm fully aware of what u32
can do and I will in no way remove anything.

To make it clear, I'm only gonna change about 10 lines in classify:

for (i = n->sel.nkeys; i>0; i--, key++) {

	if ((*(u32*)(ptr+key->off+(off2&key->offmask))^key->val)&key->mask) {
		n = n->next;
		goto next_knode;
	}
}

will be replaced with:

info.nexthdr = off2;
info.ptr = ptr;

if (!tcf_em_tree_match(..., &info)) {
	n = n->next;
	goto next_knode;
}

That's all, nothing else is changed. I think this is exactly the part were
we're out of sync.

The most difficult part is to do the Kconfig dependencies in a smart way ;->

> Again, u32 classifier is not just matches; the more interesting thing
> is  the layout of the rules that it can be taught to do.
> I think the ematch which emulates the std u32 match is of course
> valuable to have but it _doesnt_ deserve the same name.

Stupid terms, em_u32.c is a replacement for the u32 key and it has exactly
the same behaviour. I'll be happy to rename it but as you know I really
suck at naming things ;->

> Thinking more about it; not sure why you would even bother managing
> them. Everything runs at the same kernel privilege level. I am not sure
> you want to have certain things that can only be built when recompiling
> the kernel

Well, we have exactly the same issues as with TLV types. I don't see
why one would need to recompile things. The enumeration is for ematches
included in the kernel tree.
