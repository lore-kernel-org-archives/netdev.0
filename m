From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [RFC 3/3] tc: cleanup tc_classify
Date: Wed, 22 Apr 2015 15:27:33 -0700
Message-ID: <55382055.1090207@plumgrid.com>
References: <1429644476-8914-1-git-send-email-ast@plumgrid.com>	<1429644476-8914-4-git-send-email-ast@plumgrid.com> <CAHA+R7OSVs1rYcXkOM=FYoDMHGM30iWRRAVtdiJmU7jz9GRdYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34389 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932301AbbDVW1f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 18:27:35 -0400
Received: by pacyx8 with SMTP id yx8so508252pac.1
        for <netdev@vger.kernel.org>; Wed, 22 Apr 2015 15:27:35 -0700 (PDT)
In-Reply-To: <CAHA+R7OSVs1rYcXkOM=FYoDMHGM30iWRRAVtdiJmU7jz9GRdYw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/21/15 10:05 PM, Cong Wang wrote:
> On Tue, Apr 21, 2015 at 12:27 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>> introduce tc_classify_act() and qdisc_drop_bypass() helper functions to reduce
>> copy-paste among different qdiscs
>
>
> I don't think qdisc_drop_bypass() is more readable than without it,
> maybe you need a better name, or just leave the code as it is.

what would be a better name? I'm open to suggestions.

We already have qdisc_drop() that does:
         kfree_skb(skb);
         qdisc_qstats_drop(sch);

my proposed qdisc_drop_bypass() does stats math conditionally:
         if (err & __NET_XMIT_BYPASS)
                 qdisc_qstats_drop(sch);
         kfree_skb(skb);

So together I think they fit nicely. With this helper the sch_choke.c
looks like:
congestion_drop:
         qdisc_drop(skb, sch);
         return NET_XMIT_CN;
other_drop:
         qdisc_drop_bypass(skb, sch, ret);
         return ret;

and in the next set of cleanups I'm planning to combine these two
helpers into one, but I need to cleanup __NET_XMIT_BYPASS flag first.
