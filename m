From: Samir Bellabes <sam@synack.fr>
Subject: Re: [RFC 5/9] snet: introduce snet_event.c and snet_event.h
Date: Fri, 08 Jan 2010 18:44:09 +0100
Message-ID: <m2vdfcjxue.fsf@ssh.synack.fr>
References: <1262437456-24476-1-git-send-email-sam@synack.fr>
	<1262437456-24476-6-git-send-email-sam@synack.fr>
	<20100104190854.GD6034@us.ibm.com> <m2iqbdkqnm.fsf@ssh.synack.fr>
	<20100108153443.GA8117@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100108153443.GA8117@us.ibm.com> (Serge E. Hallyn's message of
	"Fri, 8 Jan 2010 09:34:43 -0600")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Serge E. Hallyn" <serue@us.ibm.com> writes:

> Quoting Samir Bellabes (sam@synack.fr):
>> "Serge E. Hallyn" <serue@us.ibm.com> writes:
>> 
>> > Quoting Samir Bellabes (sam@synack.fr):
>> >> +int snet_event_fill_info(struct sk_buff *skb, struct netlink_callback *cb)
>> >> +{
>> >> +	unsigned int i = 0, n = 0;
>> >> +	int ret = -1;
>> >> +	unsigned hashs_to_skip = cb->args[0];
>> >> +	unsigned events_to_skip = cb->args[1];
>> >> +	struct list_head *l;
>> >> +	struct snet_event_entry *s;
>> >> +
>> >> +	read_lock_bh(&event_hash_lock);
>> >> +
>> >> +	if (!event_hash)
>> >> +		goto errout;
>> >> +
>> >> +	for (i = 0; i < event_hash_size; i++) {
>> >> +		if (i < hashs_to_skip)
>> >> +			continue;
>> >
>> > What is this?
>> 
>> code was duplicated from ctrl_dumpfamily() at net/netlink/genetlink.c
>> this can be optimized by:
>>         for (i = hashs_to_skip; i < event_hash_size; i++) {
>
> Sure, but my question was more general (more naive?) - what are the
> hashs_to_skip?
>
> sounds like i should be able to go read the genetlink code for an
> answer, thanks.

if it's not too late.
snet_nl_list(), in snet_netlink.c, is defined as a dumpit() genetlink
operation. A dumpit() operations is called when NLM_DUMP message flag is
set.

the genetlink dumpit() operation receives, as a argument, a
pre-allocated sk_buff buffer, so the purpose of snet_nl_list() is to
fill this buffer. snet_nl_list() is calling snet_event_fill_info() for
this job.

as long as snet_event_fill_info() is not returning 0, it means that it
fills data in the sk_buff, and the dumpit() operations is called again.

the behaviour of sending event list informations is to send a netlink
message by event - remember a event is [syscall, protocol]. so we are
iterate other the hashtable snet_evh:

  [0]               -> list_head: [sys0, proto1], [sys1, proto1]
  [1]               -> list_head: .. 
  [2]               -> list_head: ..
  ...
  [snet_evh_size-1] -> list_head: ..

in order to fill each the pre-allocated sk_buff.

so at each time the snet_event_fill_info() is called again, because of
returning values different from 0, we need to skip previous events which
were already filled in the buffer.
this is the purpose of 

	unsigned hashs_to_skip = cb->args[0];
	unsigned events_to_skip = cb->args[1];

to get the last event filled, and the purpose of :

        cb->args[0] = i;
        cb->args[1] = n;

to store the last event filled, at each call of dumpit()

at this point you may understand the purpose to skip the previous values
in the hashtables, and after the events values at each list.

>> I will made a patch for ctrl_dumpfamily() right now.
>> 
>> >> +		l = &event_hash[i];
>> >> +		n = 0;
>> >> +		list_for_each_entry(s, l, list) {
>> >> +			if (++n < events_to_skip)
>> >> +				continue;
>> >> +			ret = snet_nl_list_fill_info(skb,
>> >> +						     NETLINK_CB(cb->skb).pid,
>> >> +						     cb->nlh->nlmsg_seq,
>> >> +						     NLM_F_MULTI,
>> >> +						     s->se.protocol,
>> >> +						     s->se.syscall);
>> >> +			if (ret < 0)
>> >> +				goto errout;
>> >
>> > So if it returns 0, presumably meaning successfully handled, you
>> > want to go on processing any duplicates?
>> 
>> first, I found a bug in snet_nl_list_fill_info() which was returning 0
>> instead of -EMSGSIZE in case there was not enough space to put data.
>> 
>> I'm not sure to understand what may have duplicates, but if you are
>> talking about the events (struct snet_event_entry), that is not possible
>> as the insert function checks if the event is already in the hashtable
>> snet_evh before insertion.
>
> Ok, but the way your loop is constructed, if snet_nl_list_fill_info()
> returns 0 (success, presumably) you won't break.  Sounds like you want
> to.

No I don't, if it returns 0, we proceed the next event in the current
list.
once the list is empty, we proceed the next hashtable entry.
once the index running other the hashtable is egal to the hashtable size,
it's done.

sam

