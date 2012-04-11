From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next PATCH v1 3/7] net: add fdb generic dump routine
Date: Wed, 11 Apr 2012 07:46:43 -0700
Message-ID: <4F859953.1070109@intel.com>
References: <20120409215419.3288.50790.stgit@jf-dev1-dcblab>  <20120409220030.3288.31389.stgit@jf-dev1-dcblab> <1334115901.7150.371.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, stephen.hemminger@vyatta.com, davem@davemloft.net,
	hadi@cyberus.ca, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gregory.v.rose@intel.com,
	krkumar2@in.ibm.com, sri@us.ibm.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:8844 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755299Ab2DKOqo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2012 10:46:44 -0400
In-Reply-To: <1334115901.7150.371.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/10/2012 8:45 PM, Ben Hutchings wrote:
> On Mon, 2012-04-09 at 15:00 -0700, John Fastabend wrote:
>> This adds a generic dump routine drivers can call. It
>> should be sufficient to handle any bridging model that
>> uses the unicast address list. This should be most SR-IOV
>> enabled NICs.
> [...]
>> +static int nlmsg_populate_fdb(struct sk_buff *skb,
>> +			      struct netlink_callback *cb,
>> +			      struct net_device *dev,
>> +			      int *idx,
>> +			      struct netdev_hw_addr_list *list)
>> +{
>> +	struct netdev_hw_addr *ha;
>> +	struct ndmsg *ndm;
>> +	struct nlmsghdr *nlh;
>> +	u32 pid, seq;
>> +
>> +	pid = NETLINK_CB(cb->skb).pid;
>> +	seq = cb->nlh->nlmsg_seq;
>> +
>> +	list_for_each_entry(ha, &list->list, list) {
>> +		if (*idx < cb->args[0])
>> +			goto skip;
>> +
>> +		nlh = nlmsg_put(skb, pid, seq,
>> +				RTM_NEWNEIGH, sizeof(*ndm), NLM_F_MULTI);
>> +		if (!nlh)
>> +			break;
> 
> This break is effectively return 0, but shouldn't we return an error?
> In practice this does no harm because any subsequent invocation of
> nlmsg_populate_fdb() for the same skb is also going to fail here with no
> change to *idx.  But it would be more obviously correct to return an
> error.
> 

sure returning -EMSGSIZE seems to be inline with rtnl_fill_ifinfo and
easier to read.

> [...]
>> +	}
>> +	return 0;
>> +nla_put_failure:
>> +	nlmsg_cancel(skb, nlh);
>> +	return -ENOMEM;
>> +}
> [...]
> 

also might be better to return -EMSGSIZE here as well. It seems to be
more inline with convention.

.John
