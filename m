From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PKT_SCHED]: Allow using nfmark as key in U32 classifier.
Date: Tue, 28 Dec 2004 23:10:21 +0100
Message-ID: <20041228221021.GF32419@postel.suug.ch>
References: <1104252710.1090.171.camel@jzny.localdomain> <200412270715.iBR7Fffe026855@hera.kernel.org> <20041227121658.GI7884@postel.suug.ch> <1104240053.1100.53.camel@jzny.localdomain> <20041228134022.GA32419@postel.suug.ch> <1104242397.1090.94.camel@jzny.localdomain> <20041228161117.GD32419@postel.suug.ch> <1104251817.1090.164.camel@jzny.localdomain> <20041228192603.GE32419@postel.suug.ch> <1104268498.1090.254.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1104268498.1090.254.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1104268498.1090.254.camel@jzny.localdomain> 2004-12-28 16:14
> Whatever you had before is fine for action/policer - with intent to kill
> policer eventually.

I left it in for now but I see no reason why to do so actually. Old
iproute2 binaries should do just fine with the action backward
compatibility code?

> What i objected to is the indev and any other thing that has to do with
> classification helping - thats not where it should fit.
> Take u32 for example: The fit for match extensions is really at the key
> level not at a layer above.
> We need a sel2 which has new keys (which is easy because thats
> transported in a TLV).

Take a look at http://people.suug.ch/~tgr/patches/queue/03_tcf_exts_u32.diff

The extensions are on the same level as the selector. The patchset still
has errors in the patches for route and tcindex since it's non-trivial
to adapt them to allow changing parameter on-the-fly. The rest is tested
and works perfectly fine. I can create a subset or we can just take the
first few patches for now and do the development on u32/fw and port it
later.

> Why not reuse what already exists in terms of classifier/filter return
> codes? They are pretty sufficient and cover all the cases.

I do reuse them. TC_ACT_* from include/linux/pkt_cls.h

> Hrm, so someone writting the one page extension now has to fill in all
> these functions?

No, that's just how the classifier accesses the extensions API.

> [ematch api]

Exactly, this would be API visible to the matches.

> If what you describe above is internal - accessible via classifier then
> fine (other than tcf_exts_match) - lathough it looks excessive.

The validate/change split is needed to implement consistent changes
in classifiers. The current way causes corruption in classifer data
whenever an action configuration fails.

> I dont see these things calling actions. They are interleaved between
> matches. At completion of matches/filtering then you call the action
> code.

Right, tcf_exts_match calls the generic matches and at the very end
the action.

> Whats wrong with extended TLVs you mentioned earlier?
> 
> match u32 ..
> ematch indev ...
> match u32 ...
> ematch meta tcindex ..
> 
> the ematches are essentially TLVs on their own and are owned by
> the classifier. The classifier doesnt know whats in them. It just
> calls generic code to execute them.

They should go into TCA_XXX_EXTS as embeded TLVs. The problem is
not how to do it but rather how far to go. Do we want userspace
to be able to delete a single generic match? Do we want to only
allow replacing all matches? We will hit the limit of skbs at
some point if we keep on encapsulating. ;->

> I think you are only refering to one ematch kind above --> for metadata.

Correct. This would be the generic match for metadata.

> What i talked about is arbitrary (example i could put a quick hack to
> grep strings without writting a full classifier). Essentially what you
> have fits just fine - you may need two ids; one for IDing as meta match
> and other as tcindex etc. The second one can be hidden.

I don't get this.
