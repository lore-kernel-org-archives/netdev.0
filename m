From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 10/39] wimax: Generic messaging interface between user
	space and driver/device
Date: Thu, 27 Nov 2008 13:35:12 +0100
Message-ID: <20081127123511.GP20815@postel.suug.ch>
References: <cover.1227691434.git.inaky@linux.intel.com>
	<802197ab7fc27af2e6e36ab83039cad6569997e1.1227691434.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, wimax@linuxwimax.org
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <wimax-bounces@linuxwimax.org>
Content-Disposition: inline
In-Reply-To: <802197ab7fc27af2e6e36ab83039cad6569997e1.1227691434.git.inaky@linux.intel.com>
List-Unsubscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.moblin.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

* Inaky Perez-Gonzalez <inaky@linux.intel.com> 2008-11-26 14:40
> + * By default, all devices get one default pipe ("the messaging
> + * pipe").

I think this is fundamentally wrong by design. There should be one
WiMAX genetlink family with a set of commands taking the interface
index as attribute. The number of genetlink families is critical
to its performance.

> + * GENERIC NETLINK ENCODING AND CAPACITY
> + *
> + * Messages are encoded as a binary netlink attribute using nla_put()
> + * using type NLA_UNSPEC (as some versions of libnl still in
> + * deployment don't yet understand NLA_BINARY).

Not sure what you mean by that, the attribute policies are not shared
between kernel and userspace. The attribute policy defines the semantics
on what you receive, not what or how you send it.

> + * The maximum capacity of this transport is undetermined. Sending of
> + * messages up to 4k has been tested with success. Bigger buffers
> + * beware.

All netlink messages are limited to the PAGESIZE.

> +struct sk_buff *wimax_pipe_msg_alloc(struct wimax_dev *wimax_dev,
> +				     const void *msg, size_t size,
> +				     gfp_t gfp_flags)
> +{
> +	int result;
> +	struct device *dev = wimax_dev->net_dev->dev.parent;
> +	void *genl_msg;
> +	struct sk_buff *skb;
> +
> +	skb = genlmsg_new(nla_total_size(size), gfp_flags);

This dosen't look right, genlmsg_new() expects the size of the
family specific payload.

> +	result = nla_put(skb, WIMAX_GNL_MSG_DATA, size, msg);
> +	if (result == -1) {

nla_put() returns -EMSGSIZE so this check is useless, check against < 0.

> +const void *wimax_msg_data(struct sk_buff *msg)
> +{
> +	struct nlmsghdr *nlh = (void *) msg->head;

You shouldn't access the netlink header via skb->head or skb->data as it
is done in numerous places. The genetlink layer passes a struct
genl_info to the doit() callback which conains a pointer to the netlink
header genl_info->nlhdr.


> +/**
> + * wimax_msg_len - Return a message's payload length
> + *
> + * @msg: Pointer to a message created with wimax_pipe_msg_alloc()
> + */
> +ssize_t wimax_msg_len(struct sk_buff *msg)
> +{
> +	struct nlmsghdr *nlh = (void *) msg->head;
> +	struct nlattr *nla;
> +
> +	nla = nlmsg_find_attr(nlh, sizeof(struct genlmsghdr),
> +			      WIMAX_GNL_MSG_DATA);
> +	if (nla == NULL) {
> +		printk(KERN_ERR "Cannot find attribute WIMAX_GNL_MSG_DATA\n");
> +		return -EINVAL;
> +	}
> +	return nla_len(nla);
> +}

So users have to call both wimax_msg_data() and wimax_msg_len() which
both walk through all attributes to find the attribute in question.
You could simply return the nlattr and rely on users to call nla_data()
respectively nla_len() to access data/length.

> +
> +static
> +struct nla_policy wimax_gnl_msg_policy[WIMAX_GNL_ATTR_MAX + 1] = {
> +	[WIMAX_GNL_MSG_DATA] = {
> +		.type = NLA_UNSPEC,	/* libnl doesn't grok BINARY yet */
> +	},
> +};

This policy is completely pointless :-)

> +	struct nlattr *tb[WIMAX_GNL_ATTR_MAX+1];
> +	void *msg_buf;
> +	size_t msg_len;
> +
> +	/* Parse the message to extract arguments */
> +	result = nlmsg_parse(nlh, sizeof(struct genlmsghdr),
> +			     tb, ARRAY_SIZE(tb),
> +			     wimax_gnl_msg_policy);

It's not wrong to parse the attributes yourself but it's a lot easier to
define them as one sequence and have the genetlink layer parse and
validate them for you. Simply assign the highest attribute number and
policy to the family and they will be made available in the info
structure.
