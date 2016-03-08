From: Phil Sutter <phil@nwl.cc>
Subject: Re: [net-next PATCH iproute2 1/1] tc: introduce IFE action
Date: Tue, 8 Mar 2016 14:22:15 +0100
Message-ID: <20160308132215.GC6517@orbyte.nwl.cc>
References: <1457440783-8526-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	Jamal Hadi Salim <hadi@mojatatu.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:41312 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750819AbcCHNWR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2016 08:22:17 -0500
Content-Disposition: inline
In-Reply-To: <1457440783-8526-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 08, 2016 at 07:39:43AM -0500, Jamal Hadi Salim wrote:
>  tc/Makefile |   1 +
>  tc/m_ife.c  | 336 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 337 insertions(+)
>  create mode 100644 tc/m_ife.c

Seems like you forgot to add man/man8/tc-ife.8 before committing. ;)

> +static void ife_explain(void)
> +{
> +	fprintf(stderr,
> +		"Usage:... ife <decode|encode> [dst <DMAC>] [src <SMAC>] [type <TYPE> [CONTROL] [INDEX]\n");

Although there is no written style guide for help texts, I'd suggest
sticking more to how others look like:
- 'decode' and 'encode' are terminals, so lowercase is correct but the
  angled brackets should be curly ones (to emphasize them being
  mandatory).
- Angled brackets for DMAC, SMAC and TYPE are redundant. IMO written in
  all uppercase already points out they are non-terminal, like CONTROL
  and INDEX.
- Missing closing bracket after <TYPE>.
- INDEX alone is not allowed, that should read '[index INDEX]'.

> +		} else if (matches(*argv, "allow") == 0) {

Undocumented feature?

> +		} else if (matches(*argv, "use") == 0) {

Same here?!

> +	if (argc) {
> +		if (matches(*argv, "reclassify") == 0) {
> +			p.action = TC_ACT_RECLASSIFY;
> +			argc--;
> +			argv++;
> +		} else if (matches(*argv, "pipe") == 0) {
> +			p.action = TC_ACT_PIPE;
> +			argc--;
> +			argv++;
> +		} else if (matches(*argv, "drop") == 0 ||
> +			   matches(*argv, "shot") == 0) {
> +			p.action = TC_ACT_SHOT;
> +			argc--;
> +			argv++;
> +		} else if (matches(*argv, "continue") == 0) {
> +			p.action = TC_ACT_UNSPEC;
> +			argc--;
> +			argv++;
> +		} else if (matches(*argv, "pass") == 0) {
> +			p.action = TC_ACT_OK;
> +			argc--;
> +			argv++;
> +		}
> +	}

This should really be made generic at some point. Potentially every
action wants to support his, and tc/m_gact.c does the same.

> +	if (has_optional)
> +		fprintf(f, "\n ");

Is that space after newline intended? Because ...

> +	if (tb[TCA_IFE_METALST]) {
> +		struct rtattr *metalist[IFE_META_MAX + 1];
> +		int len = 0;
> +
> +		parse_rtattr_nested(metalist, IFE_META_MAX,
> +				    tb[TCA_IFE_METALST]);
> +
> +		fprintf(f, "\t Metadata: ");

... this then adds tab after space.

> +		if (metalist[IFE_META_SKBMARK]) {
> +			len = RTA_PAYLOAD(metalist[IFE_META_SKBMARK]);
> +			if (len) {
> +				__u32 *mmark = RTA_DATA(metalist[IFE_META_SKBMARK]);
> +				fprintf(f, "use mark %d ", *mmark);
> +			} else
> +				fprintf(f, "allow mark ");
> +		}
> +
> +		if (metalist[IFE_META_HASHID]) {
> +			len = RTA_PAYLOAD(metalist[IFE_META_HASHID]);
> +			if (len) {
> +				__u32 *mhash = RTA_DATA(metalist[IFE_META_HASHID]);
> +				fprintf(f, "use hash %d ", *mhash);
> +			} else
> +				fprintf(f, "allow hash ");
> +		}
> +
> +		if (metalist[IFE_META_PRIO]) {
> +			len = RTA_PAYLOAD(metalist[IFE_META_PRIO]);
> +			if (len) {
> +				__u32 *mprio = RTA_DATA(metalist[IFE_META_PRIO]);
> +				fprintf(f, "use prio %d ", *mprio);
> +			} else
> +				fprintf(f, "allow prio ");
> +		}

I would always go with "every optional part prints it's leading space".
Doing it the other way round has led to some confusion in ip/ already.

> +
> +	}
> +
> +	fprintf(f, "\n ");

Here again, whitespace after newline? Also, in case of TCA_IFE_METALST
not being part of the message, this leads to double linefeed at the end.
Not sure if intended or not.

Cheers, Phil
