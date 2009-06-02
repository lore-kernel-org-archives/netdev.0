From: Patrick McHardy <kaber@trash.net>
Subject: Re: [resend] Passive OS fingerprint xtables match.
Date: Tue, 02 Jun 2009 14:40:01 +0200
Message-ID: <4A251DA1.4060404@trash.net>
References: <20090511095343.GA30778@ioremap.net> <4A1D6A20.8050404@trash.net> <20090529085918.GA11887@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Jan Engelhardt <jengelh@medozas.de>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090529085918.GA11887@ioremap.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> Hi Patrick.
> 
> Thanks for your comments.
> 
> On Wed, May 27, 2009 at 06:28:16PM +0200, Patrick McHardy (kaber@trash.net) wrote:
>>> +#define XT_OSF_TTL_TRUE		0	/* True ip and fingerprint 
>>> TTL comparison */
>>> +#define XT_OSF_TTL_LESS		1	/* Check if ip TTL is less 
>>> than fingerprint one */
>>> +#define XT_OSF_TTL_NOCHECK	2	/* Do not compare ip and fingerprint 
>>> TTL at all */
>> These seem redundant - having neither of TRUE or LESS seems
>> equivalent to NOCHECK. Perhaps thats the reason why its not
>> used at all :) Looking at the code, "TRUE" would be better
>> named as "EQUAL".
> 
> There are only three types of TTL check - equal (for true), less than
> fingerprint one and when no check is performed at all. NOCHECK is
> actually used, but LESS one does not have a special check, but a default
> clause when neither TRUE or NOCHECK is specified.

OK, thanks for the explanation.

>>> +struct xt_osf_user_finger {
>>> +	struct xt_osf_wc	wss;
>>> +
>>> +	__u8			ttl, df;
>>> +	__u16			ss, mss;
>>> +	__u16			opt_num;
>>> +
>>> +	char			genre[MAXGENRELEN];
>>> +	char			version[MAXGENRELEN];
>>> +	char			subtype[MAXGENRELEN];
>>> +
>>> +	/* MAX_IPOPTLEN is maximum if all options are NOPs or EOLs */
>>> +	struct xt_osf_opt	opt[MAX_IPOPTLEN];
>> This really looks like you should use nested attributes.
> 
> This will be an unneded complication - we should provide an option
> sequence, and maximum number of options is strickly determined by
> the protocol specification. How does having separate attributes for each
> option simplify the process?

It doesn't, but it provides more flexibility which might make things
easier in case someone decides to add IPv6 support.

>>> +/* Defines for IANA option kinds */
>>> +
>>> +enum iana_options {
>>> +	OSFOPT_EOL = 0,		/* End of options */
>>> +	OSFOPT_NOP, 		/* NOP */
>>> +	OSFOPT_MSS, 		/* Maximum segment size */
>>> +	OSFOPT_WSO, 		/* Window scale option */
>>> +	OSFOPT_SACKP,		/* SACK permitted */
>>> +	OSFOPT_SACK,		/* SACK */
>>> +	OSFOPT_ECHO,
>>> +	OSFOPT_ECHOREPLY,
>>> +	OSFOPT_TS,		/* Timestamp option */
>>> +	OSFOPT_POCP,		/* Partial Order Connection Permitted */
>>> +	OSFOPT_POSP,		/* Partial Order Service Profile */
>>> +
>>> +	/* Others are not used in the current OSF */
>>> +	OSFOPT_EMPTY = 255,
>>> +};
>> Why do we need to duplicate these?
> 
> Why duplicate? It is the only place of the constants describing used
> option numbers. include/net/tcp.h does not have 'partial order' options
> in particular.

Indeed, I noticed this after sending my mail.

>>> +struct xt_osf_finger_storage
>>> +{
>> Please place the opening bracket consistently with the other
>> structure definitions.
> 
> I.e. always on the new line? :)

Just keep it consistent within your file, though I personally
prefer to keep it inconsistent with some of the other netfilter
files and not use a new line :)

>>> +static int xt_osf_setup_callback(struct sock *ctnl, struct sk_buff *skb,
>>> +			struct nlmsghdr *nlh, struct nlattr *osf_attrs[])
>>> +{
>>> +	struct xt_osf_user_finger *f;
>>> +	struct nfgenmsg *nfmsg = NLMSG_DATA(nlh);
>>> +	u16 delete = ntohs(nfmsg->res_id);
>> This looks like abuse, we use message types to distinguish between
>> additions and deletions, alternative NLM_F_REPLACE.
> 
> Why to introduce the whole new callback function and attribute when the
> only difference is to add or remove a processed entry?

Sticking to the defined semantics avoids the need for special-casing
in generic code like libnl. A new function also doesn't seem like a
loss at all, the only common part between addition and removal appears
to be the iteration.

>>> +		if (totlen == f->ss && xt_osf_ttl(skb, info, f->ttl)) {
>>> +			int foptsize, optnum;
>>> +
>>> +			check_WSS = 0;
>>> +
>>> +			switch (f->wss.wc) {
>>> +			case 0:
>>> +				check_WSS = 0;
>>> +				break;
>>> +			case 'S':
>>> +				check_WSS = 1;
>>> +				break;
>>> +			case 'T':
>>> +				check_WSS = 2;
>>> +				break;
>>> +			case '%':
>>> +				check_WSS = 3;
>>> +				break;
>>> +			default:
>>> +				check_WSS = 4;
>>> +				break;
>>> +			}
>> This is really pushing my taste-buds. Whatever this does, please at
>> use symbolic constants so the reader at least has a chance to understand
>> it.
> 
> That's a bit unlcear window size processing state machine.
> It links together knowledge about window-size, mss, mtu dependancy on
> plain size numbers and modulo operations (like window size is multiple
> of x bytes).

It very much reminds me of iptables userspace option parsing :|
Please at least use symbolic names for the different cases.
Why does it have to be mapped in the kernel at all? The raw value
of f->wss.wc doesn't seem to be used anywhere else.

>>> +#define SMART_MSS_1	1460
>>> +#define SMART_MSS_2	1448
>> Sigh. This entire function is completely unreadable and full of
>> unexplained magic. I'll stop here, please clean this before
>> resubmitting.
> 
> This is a special hack for special modems, which can decrease mss, and
> since there is no common knowledge on how to differentiate them, there
> is a check against different types.

Please explain what exactly it does in a comment. Would it make
sense to have the exact values supplied by userspace?
