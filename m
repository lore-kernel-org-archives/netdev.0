From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PKT_SCHED]: Allow using nfmark as key in U32 classifier.
Date: Tue, 28 Dec 2004 20:26:03 +0100
Message-ID: <20041228192603.GE32419@postel.suug.ch>
References: <20041228161117.GD32419@postel.suug.ch> <1104251817.1090.164.camel@jzny.localdomain> <1104252710.1090.171.camel@jzny.localdomain> <200412270715.iBR7Fffe026855@hera.kernel.org> <20041227121658.GI7884@postel.suug.ch> <1104240053.1100.53.camel@jzny.localdomain> <20041228134022.GA32419@postel.suug.ch> <1104242397.1090.94.camel@jzny.localdomain> <20041228161117.GD32419@postel.suug.ch> <1104251817.1090.164.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1104252710.1090.171.camel@jzny.localdomain> <1104251817.1090.164.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1104251817.1090.164.camel@jzny.localdomain> 2004-12-28 11:36
> I think this sounds cleaner but is major surgery. The other issue i have
> with it is semantically i see classification followed by actions.
> Classification may have extended classification within it. Actions may
> also have extended actions within them.

Hmm... right, let's just leave the action as-is, we don't gain much
anyway. Nevertheless, actions should be part of the extensions API
but we can safely put them at the end of the extensions match routine
so it always comes last. So basically we end up with

1) cls specific matches
2) generic matches including logical expressions
3) action

We can always change it later without touching a single classifier.

> The classifier is blind while executing those actions.
> Data that needs to be embeded within the classifier is:
> struct {extmatch type:extmatch void_data}.

No, I'd really like to avoid having this but instead put a tcf_exts
struct into it which holds all the data needed by the generic part.
This also includes the tc_action pointer. This way we can get rid
of all action/policer related ifdefs in the classifiers, reduce the
chances of mistakes and don't need to touch classifier when changing
something in the generic part.

> extmatch_classify(extmatchdatastruct,skb) is a generic call which does a
> lookup on the type and calls the proper callback. Callbacks return
> standard classifier ret codes.

Exactly, I called it tcf_exts_match with the following return definition:
<0: error/unmatched filter, classifier must stop matching and move on to
    next filter or return mismatch if at the end.
 0: Normal match, classifier must do whathever it would to if a filter matches
>0: Classifier return code (TC_ACT_*), classifier must stop immediately
    and pass on the return code.

So basically I export this API:

tcf_exts_validate
  validates the input data and initalizes the action, it must not
  change any attributes. Validated data is stored in a temporary
  tcf_exts structure provided by the classifier (local variable)

tcf_exts_change
  Applies the changes from tcf_exts_validate to the classifier, must
  not fail under any circumstance. Classifier provides both, the
  destination pointer (hold in classifier data) and the temporary
  buffer from tcf_exts_valiate.

tcf_exts_match
  Runs all the matches and applies action.

tcf_exts_destroy
  Destroys a complete extensions configuration

tcf_exts_dump
  Dumps extensions into given skb.

tcf_exts_dump_stats
  Dumps statistics into given skb.

tcf_exts_is_predicative
  Returns 1 if a predicative extension is present, i.e. an extension
  which might cause further actions and thus overrule the regular
  tcf_result. In other words, returns 1 if a TC_ACT_* my be returned.

tcf_exts_available
  Returns 1 if at least 1 extension is present.

How does the exntesions API know about the classifier specifc TLV
types? Every classifier maintains a map which holds the types, this
is used in _validate, _dump and _dump_stats.

> - initialization happens like you said with extended matches TLV which
> result in building one of those extended match datastruct bound on the
> filter.

This is the part I'm unsure about. I want to keep it simple but also
powerful. The action part is clear and will be untouched. The generic
match part is more difficult, we either make userspace transfer the
complete tree every time or we introduce commands like in the
classifier. Second is probably better but a little bit more work.

The binding part is easy, the hard part is how you interleaf u32
> matches for example vs indev. 

Value TLV:
 TCA_META_VALUE_TYPE, struct tcf_meta_type
 TCA_META_VALUE_DATA, variable

struct tcf_meta_type
{
	__u16 kind;
	__u16 len;
};

Where kind:

enum
{
	/* numberic types */
	TCF_META_I_NUMBER = 0x100,
	TCF_META_I_NFMARK = 0x101,
	TCF_META_I_TCINDEX = 0x102,

	/* variable length types */
	TCF_META_V_PATTERN = 0x200,
	TCF_META_V_INDEV = 0x201,
};

A matching of the upper 4 bits means the values can be
compared. Of course userspace should check for this so
we only have to put in a BUG_ON assertion.

> ** Also i see your point that changing all the classifiers is painful,
> but doing it this once so the next written classifier is easy is worth
> the effort in my opinion.

Truly agreed, I did this work already and I'm now testing it. We can
easly put the generic match on top of it and all we have to do is add
TCA_XXX_EXTS for every classifier and add it to the map.
