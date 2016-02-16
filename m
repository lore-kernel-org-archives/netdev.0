From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next 1/3] lwtunnel: autoload of lwt modules
Date: Tue, 16 Feb 2016 14:14:59 +0000
Message-ID: <56C32EE3.6090802@brocade.com>
References: <1455550923-23673-1-git-send-email-rshearma@brocade.com>
 <1455550923-23673-2-git-send-email-rshearma@brocade.com>
 <878u2l7j6p.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Tom Herbert <tom@herbertland.com>, Thomas Graf <tgraf@suug.ch>,
	Jiri Benc <jbenc@redhat.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:49911 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932614AbcBPOPO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 09:15:14 -0500
In-Reply-To: <878u2l7j6p.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/02/16 21:33, Eric W. Biederman wrote:
> Robert Shearman <rshearma@brocade.com> writes:
>> @@ -85,6 +109,14 @@ int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
>>   	ret = -EOPNOTSUPP;
>>   	rcu_read_lock();
>>   	ops = rcu_dereference(lwtun_encaps[encap_type]);
>> +#ifdef CONFIG_MODULES
>> +	if (!ops) {
>> +		rcu_read_unlock();
>> +		request_module("rtnl-lwt-%s", lwtunnel_encap_str(encap_type));
>> +		rcu_read_lock();
>> +		ops = rcu_dereference(lwtun_encaps[encap_type]);
>> +	}
>> +#endif
>>   	if (likely(ops && ops->build_state))
>>   		ret = ops->build_state(dev, encap, family, cfg, lws);
>>   	rcu_read_unlock();
>
> My memory is fuzzy on how this is done elsewhere but this looks like it
> needs a capability check to ensure that non-root user's can't trigger
> this.
>
> It tends to be problematic if a non-root user can trigger an autoload of
> a known-buggy module.  With a combination of user namespaces and network
> namespaces unprivileged users can cause just about every corner of the
> network stack to be exercised.

The same protections apply to this as to the IFLA_INFO_KIND module 
autoloading, namely by rtnetlink_rcv_msg ensuring that no messages other 
than gets can be done by an unprivileged user:

	type = nlh->nlmsg_type;
...
	type -= RTM_BASE;
...
	kind = type&3;

	if (kind != 2 && !netlink_net_capable(skb, CAP_NET_ADMIN))
		return -EPERM;

The lwtunnel_build_state function is only called by the processing of 
non-get message types.

Is this sufficient or are you looking for something in addition?

Thanks,
Rob
