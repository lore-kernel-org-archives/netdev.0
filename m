From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] pkt_sched: act_xt support new Xtables interface
Date: Mon, 24 Dec 2012 19:19:43 +0100
Message-ID: <20121224181943.GA16068@1984>
References: <50D46060.2070308@gmail.com>
 <50D46928.9070809@mojatatu.com>
 <50D46EC1.2040608@gmail.com>
 <50D5B366.30005@mojatatu.com>
 <50D5BC96.9010602@gmail.com>
 <50D5BF00.7050304@mojatatu.com>
 <50D83DDB.102@mojatatu.com>
 <50D8413C.8050508@openwrt.org>
 <20121224131233.GA29307@1984>
 <50D86136.6070006@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Felix Fietkau <nbd@openwrt.org>,
	Yury Stankevich <urykhy@gmail.com>,
	Hasan Chowdhury <shemonc@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jan Engelhardt <jengelh@inai.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <50D86136.6070006@mojatatu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jamal,

On Mon, Dec 24, 2012 at 09:05:42AM -0500, Jamal Hadi Salim wrote:
> On 12-12-24 08:12 AM, Pablo Neira Ayuso wrote:
> >
> >conntrack needs to see defragmented packets, you have to call
> >nf_defrag_ipv4 / _ipv6 respectively before that.
> >
> 
> This should not be too hard to do - although my thinking says this
> should be a separate action.
> 
> >This also changes the semantics of the raw table in iptables since it
> >will now see packet with conntrack already attached. So this would
> >also break -j CT --notrack.
> 
> Is there a flag we can check which says a flow is not to be tracked?
> Doesnt nf_conntrack_in() fail if --no track is set?

The notrack dummy conntrack (consider it a flag) is attached in
prerouting raw table. By attaching conntracks at ingress, the notrack
flag will be ignored. Note that this also breaks conntrack templates
via -j CT, that allows us to set custom conntrack timeouts, zones and
helpers at prerouting raw.

Basically, ct templates are attached via -j CT, this template is
munched by nf_conntrack_in, which adds the corresponding ct features
based on the template information.

> >This needs more thinking. I can appreciate the value of calling
> >conntrack from different points of the packet traversal, but there are
> >a couple of thing we have to resolve before allowing that.
> 
> There is user need for this Pablo - as you can see from what Felix
> deployed it seems to be used a lot more wider audience dependency.
> What do we need to do to get this to work properly?

The conntrack code needs to be generalized to allow creating conntrack
with features all at once (so we can remove the template
infrastructure). Even after that, we'll still have that -j CT rules
will be ignored if you're using, let's name it, act_ct from ingress to
attach the conntrack to it.

With the current approach you're using, people will see conntracks in
the iptables raw table, that breaks the current semantics.

We'll have the netfilter workshop by Q1/Q2 2013 (still TBA), I think
this is material for discussion in it.

cheers,
Pablo
