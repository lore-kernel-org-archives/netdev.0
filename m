From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: Passive OS fingerprint xtables match.
Date: Thu, 12 Feb 2009 21:12:05 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0902122045080.670@fbirervta.pbzchgretzou.qr>
References: <20090212171245.GA15025@ioremap.net> <alpine.LSU.2.00.0902121900520.20367@fbirervta.pbzchgretzou.qr> <20090212185729.GA17896@ioremap.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:36742 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751110AbZBLUMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 15:12:07 -0500
In-Reply-To: <20090212185729.GA17896@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thursday 2009-02-12 19:57, Evgeniy Polyakov wrote:
>>  +/**
>> >+ * Wildcard MSS (kind of).
>>    * @wc:	wild card what(?)
>>    * @val:	some value?
>> >+ */
>> >+struct ipt_osf_wc {
>> >+	__u32			wc;
>> >+	__u32			val;
>> >+};
>> 
>
>This is a weird wildcards implementation for the MSS value.
>They can be pure wildcards and several subtypes which form the window
>size and MSS state machine.

Good to know. Please add this explanation as a comment
in the next iteration.

>> >+	int opt_num;
>> >+
>> >+	char genre[MAXGENRELEN];
>> >+	char version[MAXGENRELEN];
>> >+	char subtype[MAXGENRELEN];
>> >+
>> >+	/* MAX_IPOPTLEN is maximum if all options are NOPs or EOLs */
>> >+	struct ipt_osf_opt opt[MAX_IPOPTLEN];
>> >+};
>> 
>> Are you sure it is safe to use arch-dependent types like 'int'?
>
>I would be very surprised if Linux will ever run on weird arch where int
>is not 32 bits.

If GCC had a switch to compile with I16 or I64, I could test,
but it does not. 'long', as used in the netfilter includes,
already bit people in pre-2.6.19, and nowadays we have that compat
crap thing in place.. Just don't take any chance, and go the safe
route with uint32_t.

>> >+config IP_NF_MATCH_OSF
>> >+	tristate '"osf" match support'
>> >+	depends on NETFILTER_ADVANCED && CONNECTOR
>> >+	help
>> >+	  Passive OS fingerprint matching module.
>> >+	  You should download and install rule loading software from
>> >+	  http://www.ioremap.net/projects/osf
>> >+
>> >+	  To compile it as a module, choose M here.  If unsure, say N.
>> >+
>> 
>> Please do use NETFILTER_XT_ and its section.
>
>What's this? It does not exist in the net/ipv4/netfilter/Kconfig

net/netfilter/Kconfig: (e.g.)

config NETFILTER_XT_MATCH_COMMENT
        tristate  '"comment" match support'
        depends on NETFILTER_ADVANCED
        ---help---

>> >+static bool ipt_osf_match_packet(const struct sk_buff *skb,
>> >+		const struct xt_match_param *p)
>> >+{
>> >+	struct ipt_osf_info *info = (struct ipt_osf_info *)p->matchinfo;
>> >+	struct iphdr *ip;
>> >+	struct tcphdr _tcph, *tcp;
>> >+	int fmatch = FMATCH_WRONG, fcount = 0;
>> >+	unsigned int optsize = 0, check_WSS = 0;
>> >+	u16 window, totlen, mss = 0;
>> >+	unsigned char df, *optp = NULL, *_optp = NULL;
>> 
>> Maybe this should be 'bool df'?
>
>Although it is a bit, it is not really a boolean type.

The underlying implementation is not of importance here.
It behaves like a bool, and that's all what is needed.

>
>> >+			for (optnum = 0; optnum < f->opt_num; ++optnum) {
>> >+				if (f->opt[optnum].kind == (*optp)) {
>> >+					__u32 len = f->opt[optnum].length;
>> >+					__u8 *optend = optp + len;
>> >+					int loop_cont = 0;
>> >+					
>> >+					fmatch = FMATCH_OK;
>> >+
>> >+					switch (*optp) {
>> >+					case OSFOPT_MSS:
>> >+						mss = ntohs(*(u16 *)(optp + 2));
>> 
>> This needs get_unaligned(), in case someone sends a malicious packet.
>
>Hmmm, why is this needed? We dereference linear kernel pointer at
>proper offset (modulo of the option size).

What if optp is odd?

>> Do this function via
>> 	.proto = IPPROTO_TCP,
>> in the osf_match struct instead:
>
>Hmm, it is not used in the existing net/ipv4/netfilter modules.

net/ipv4/netfilter/ is about the most dusted place in Netfilter-land.
Take a grep in net/netfilter/ ;-)
