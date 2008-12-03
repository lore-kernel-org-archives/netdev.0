From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [PATCH 10/39] wimax: Generic messaging interface between user space and driver/device
Date: Tue, 2 Dec 2008 18:02:34 -0800
Message-ID: <200812021802.34863.inaky@linux.intel.com>
References: <cover.1227691434.git.inaky@linux.intel.com> <802197ab7fc27af2e6e36ab83039cad6569997e1.1227691434.git.inaky@linux.intel.com> <20081127123511.GP20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wimax@linuxwimax.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:39507 "EHLO
	azsmga101.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752809AbYLCCL1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2008 21:11:27 -0500
In-Reply-To: <20081127123511.GP20815@postel.suug.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 27 November 2008, Thomas Graf wrote:
> * Inaky Perez-Gonzalez <inaky@linux.intel.com> 2008-11-26 14:40
>
> > + * By default, all devices get one default pipe ("the messaging
> > + * pipe").
>
> I think this is fundamentally wrong by design. There should be one
> WiMAX genetlink family with a set of commands taking the interface
> index as attribute. The number of genetlink families is critical
> to its performance.

The number should not be a problem; the strange case is going to be the 
system that has more than one WiMAX interface.

So if the general case is going to be 1 interface, instead of making one
lookup for the family name and then another lookup for the attribute 
indicating the interface, making it one single lookup reduces the overhead.

> > + * GENERIC NETLINK ENCODING AND CAPACITY
> > + *
> > + * Messages are encoded as a binary netlink attribute using nla_put()
> > + * using type NLA_UNSPEC (as some versions of libnl still in
> > + * deployment don't yet understand NLA_BINARY).
>
> Not sure what you mean by that, the attribute policies are not shared
> between kernel and userspace. The attribute policy defines the semantics
> on what you receive, not what or how you send it.

the libnls I've seen don't define type NLA_BINARY -- I don't really know 
how they map onto each other, but using NLA_UNSPEC on both sides (kernel
and userspace) seems to work for transferring a buffer.

> > + * The maximum capacity of this transport is undetermined. Sending of
> > + * messages up to 4k has been tested with success. Bigger buffers
> > + * beware.
>
> All netlink messages are limited to the PAGESIZE.

Note taken, thanks

> > +struct sk_buff *wimax_pipe_msg_alloc(struct wimax_dev *wimax_dev,
> > +				     const void *msg, size_t size,
> > +				     gfp_t gfp_flags)
> > +{
> > +	int result;
> > +	struct device *dev = wimax_dev->net_dev->dev.parent;
> > +	void *genl_msg;
> > +	struct sk_buff *skb;
> > +
> > +	skb = genlmsg_new(nla_total_size(size), gfp_flags);
>
> This dosen't look right, genlmsg_new() expects the size of the
> family specific payload.

So I am going to create a message, with no family specific payload
but just an attribute with a buffer sized 'size'. What should
I pass to it so it preallocates correctly? 

That construct (at least now) seems to work.

> > +	result = nla_put(skb, WIMAX_GNL_MSG_DATA, size, msg);
> > +	if (result == -1) {
>
> nla_put() returns -EMSGSIZE so this check is useless, check against < 0.

Fixed

> > +const void *wimax_msg_data(struct sk_buff *msg)
> > +{
> > +	struct nlmsghdr *nlh = (void *) msg->head;
>
> You shouldn't access the netlink header via skb->head or skb->data as it
> is done in numerous places. The genetlink layer passes a struct
> genl_info to the doit() callback which conains a pointer to the netlink
> header genl_info->nlhdr.

This is mostly used before sending a message to user space, so genl_info 
doesn't apply. By default all notifications from the device are sent over
generic netlink to user space.

But some times we need to consume that information inside the kernel, so
instead of creating two separate formats, we just use the same. So we need
to extract, from an SKB that is packaged to be sent as generic netlink, 
the header. And at his point there is no genl_info :(

I've missed a couple that can get it from genl_info (in rfkill and msg), plus 
reset doesn't really needed. Updated them; the rest are contained in 
wimax_msg_data() and wimax_msg_len().

> > +/**
> > + * wimax_msg_len - Return a message's payload length
> > + *
> > + * @msg: Pointer to a message created with wimax_pipe_msg_alloc()
> > + */
> > +ssize_t wimax_msg_len(struct sk_buff *msg)
> > +{
> > +	struct nlmsghdr *nlh = (void *) msg->head;
> > +	struct nlattr *nla;
> > +
> > +	nla = nlmsg_find_attr(nlh, sizeof(struct genlmsghdr),
> > +			      WIMAX_GNL_MSG_DATA);
> > +	if (nla == NULL) {
> > +		printk(KERN_ERR "Cannot find attribute WIMAX_GNL_MSG_DATA\n");
> > +		return -EINVAL;
> > +	}
> > +	return nla_len(nla);
> > +}
>
> So users have to call both wimax_msg_data() and wimax_msg_len() which
> both walk through all attributes to find the attribute in question.
> You could simply return the nlattr and rely on users to call nla_data()
> respectively nla_len() to access data/length.

Good point; actually in most cases it either needs the pointer data
or both, so probably a wimax_msg_get_data_len() helper makes more sense.

> > +
> > +static
> > +struct nla_policy wimax_gnl_msg_policy[WIMAX_GNL_ATTR_MAX + 1] = {
> > +	[WIMAX_GNL_MSG_DATA] = {
> > +		.type = NLA_UNSPEC,	/* libnl doesn't grok BINARY yet */
> > +	},
> > +};
>
> This policy is completely pointless :-)

Why? Should I just use NLA_BINARY then? What do I use in user space to compose
it if libnl still doesn't know about NLA_BINARY?

I just need it to verify that there is an attribute with a buffer. That's it.

> > +	struct nlattr *tb[WIMAX_GNL_ATTR_MAX+1];
> > +	void *msg_buf;
> > +	size_t msg_len;
> > +
> > +	/* Parse the message to extract arguments */
> > +	result = nlmsg_parse(nlh, sizeof(struct genlmsghdr),
> > +			     tb, ARRAY_SIZE(tb),
> > +			     wimax_gnl_msg_policy);
>
> It's not wrong to parse the attributes yourself but it's a lot easier to
> define them as one sequence and have the genetlink layer parse and
> validate them for you. Simply assign the highest attribute number and
> policy to the family and they will be made available in the info
> structure.

So the policy is already set up like that, it has a pointer to the policy.
Are you saying it should be possible for me to just access genl_info->attrs[]?
[I didn't know that existed, just found out after your comment made me look
at it].

/me tries...

sweet, it works -- well, this cuts more code out, thanks.

-- 
Inaky

