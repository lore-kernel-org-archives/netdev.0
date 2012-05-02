From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [v12 PATCH 2/3] NETFILTER module xt_hmark, new target for HASH based fwmark
Date: Wed, 2 May 2012 09:55:00 +0200
Message-ID: <201205020955.01498.hans.schillstrom@ericsson.com>
References: <1335188128-23645-1-git-send-email-hans.schillstrom@ericsson.com> <1335188128-23645-3-git-send-email-hans.schillstrom@ericsson.com> <20120502003414.GA14940@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "kaber@trash.net" <kaber@trash.net>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hans@schillstrom.com" <hans@schillstrom.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120502003414.GA14940@1984>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Pablo
(Sorry for spamming some of you, kmail started to send HTML mail)

On Wednesday 02 May 2012 02:34:14 Pablo Neira Ayuso wrote:
> Hi Hans,
> 
> I have decided to take your patch and give it one spin today.
> 
> Please, find it attached. The main things I've done are:
> 
> * splitting the code into smaller functions, thus, it becomes more
>   maintainable.
> 
> * try to put common code into functions, eg. the layer 4 protocol
>   parsing to obtain the ports is the same for both IPv4 and IPv6.
> 
> * adding the hmark_tuple abstraction, cleaner than using several
>   variables to set the address, ports, and so on. Thus, we only pass
>   one single pointer to it.
> 
> * I have removed most of the comments, they bloat the file and most
>   information can be extracted by reading the code. I only left the
>   comments that clarify "strange" things.
> 
> Regarding ICMP traffic, I think we can use the ID field for the
> hashing as well. Thus, we handle ICMP like other protocols.

Yes why not, I can give it a try.

> 
> Please, I'd appreciate if you can test and spot issues after my
> rework. I have slightly tested here.

OK I found some minor things, I'll send an updated version back later today.
I will run all my tests it will take a couple of hours.

This is what I have founf so far (before testing)

+	t->dst = (__force u32)
+		(otuple->src.u3.in6.s6_addr32[0] &
+			info->dst_mask.in6.s6_addr32[0]) ^
+		(otuple->src.u3.in6.s6_addr32[1] &
+			info->dst_mask.in6.s6_addr32[1]) ^
+		(otuple->src.u3.in6.s6_addr32[2] &
+			info->dst_mask.in6.s6_addr32[2]) ^
+		(otuple->src.u3.in6.s6_addr32[3] &
+			info->dst_mask.in6.s6_addr32[3]);

Should be rtuple 

+	if (t->proto != IPPROTO_ICMP) {
+		t->uports.p16.src = (otuple->src.u.all & info->port_mask.v32) |
+					info->port_set.v32;
+		t->uports.p16.dst = (rtuple->src.u.all & info->port_mask.v32) |
+					info->port_set.v32;
+	}

in hmark_ct_set_htuple_ipv4() and hmark_ct_set_htuple_ipv6()
Wrong port_mask and port_set, this will work better..

		if (t->proto != IPPROTO_ICMP) {
                t->uports.p16.src = otuple->src.u.all;
                t->uports.p16.dst = rtuple->src.u.all;
                t->uports.v32 = (t->uports.v32 & info->port_mask.v32) |
                                info->port_set.v32;


> 
> I may make some minor cleanup on it before submission but, in that
> case, in that case, I'll post the patch. I would not expect more major
> changes in it.
> 
> Let me know.
Thanks Pablo
I realized that I sent wrong version as v12 (v11 with updated comments only), sorry for the confusion.
Basically the changes are the same but you have split it up a little bit more.

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
