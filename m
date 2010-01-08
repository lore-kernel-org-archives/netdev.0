From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFC 5/9] snet: introduce snet_event.c and snet_event.h
Date: Fri, 8 Jan 2010 09:34:43 -0600
Message-ID: <20100108153443.GA8117@us.ibm.com>
References: <1262437456-24476-1-git-send-email-sam@synack.fr>
 <1262437456-24476-6-git-send-email-sam@synack.fr>
 <20100104190854.GD6034@us.ibm.com>
 <m2iqbdkqnm.fsf@ssh.synack.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Samir Bellabes <sam@synack.fr>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m2iqbdkqnm.fsf@ssh.synack.fr>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Samir Bellabes (sam@synack.fr):
> "Serge E. Hallyn" <serue@us.ibm.com> writes:
> 
> > Quoting Samir Bellabes (sam@synack.fr):
> >> +int snet_event_fill_info(struct sk_buff *skb, struct netlink_callback *cb)
> >> +{
> >> +	unsigned int i = 0, n = 0;
> >> +	int ret = -1;
> >> +	unsigned hashs_to_skip = cb->args[0];
> >> +	unsigned events_to_skip = cb->args[1];
> >> +	struct list_head *l;
> >> +	struct snet_event_entry *s;
> >> +
> >> +	read_lock_bh(&event_hash_lock);
> >> +
> >> +	if (!event_hash)
> >> +		goto errout;
> >> +
> >> +	for (i = 0; i < event_hash_size; i++) {
> >> +		if (i < hashs_to_skip)
> >> +			continue;
> >
> > What is this?
> 
> code was duplicated from ctrl_dumpfamily() at net/netlink/genetlink.c
> this can be optimized by:
>         for (i = hashs_to_skip; i < event_hash_size; i++) {

Sure, but my question was more general (more naive?) - what are the
hashs_to_skip?

sounds like i should be able to go read the genetlink code for an
answer, thanks.

> I will made a patch for ctrl_dumpfamily() right now.
> 
> >> +		l = &event_hash[i];
> >> +		n = 0;
> >> +		list_for_each_entry(s, l, list) {
> >> +			if (++n < events_to_skip)
> >> +				continue;
> >> +			ret = snet_nl_list_fill_info(skb,
> >> +						     NETLINK_CB(cb->skb).pid,
> >> +						     cb->nlh->nlmsg_seq,
> >> +						     NLM_F_MULTI,
> >> +						     s->se.protocol,
> >> +						     s->se.syscall);
> >> +			if (ret < 0)
> >> +				goto errout;
> >
> > So if it returns 0, presumably meaning successfully handled, you
> > want to go on processing any duplicates?
> 
> first, I found a bug in snet_nl_list_fill_info() which was returning 0
> instead of -EMSGSIZE in case there was not enough space to put data.
> 
> I'm not sure to understand what may have duplicates, but if you are
> talking about the events (struct snet_event_entry), that is not possible
> as the insert function checks if the event is already in the hashtable
> snet_evh before insertion.

Ok, but the way your loop is constructed, if snet_nl_list_fill_info()
returns 0 (success, presumably) you won't break.  Sounds like you want
to.

-serge
