From: Samir Bellabes <sam@synack.fr>
Subject: Re: [RFC 7/9] snet: introduce snet_netlink.c and snet_netlink.h
Date: Wed, 13 Jan 2010 07:03:21 +0100
Message-ID: <m2hbqqilsm.fsf@ssh.synack.fr>
References: <1262437456-24476-1-git-send-email-sam@synack.fr>
	<1262437456-24476-8-git-send-email-sam@synack.fr>
	<4B420464.3040301@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <4B420464.3040301@trash.net> (Patrick McHardy's message of "Mon,
	04 Jan 2010 16:08:20 +0100")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> writes:

> Samir Bellabes wrote:
>> +
>> +	msg_head = genlmsg_put(skb_rsp, snet_nl_pid,
>> +			       atomic_inc_return(&snet_nl_seq),
>> +			       &snet_genl_family, 0, SNET_C_VERDICT);
>> +	if (msg_head == NULL)
>> +		goto send_event_failure;
>> +
>> +	snet_dbg("verdict_id=0x%x syscall=%s protocol=%u "
>> +		 "family=%u uid=%u pid=%u\n",
>> +		 verdict_id, snet_syscall_name(syscall),
>> +		 protocol, family, current_uid(), current->pid);
>> +
>> +	if (verdict_id) {
>> +		ret = nla_put_u32(skb_rsp, SNET_A_VERDICT_ID, verdict_id);
>> +		if (ret != 0)
>> +			goto send_event_failure;
>> +	}
>> +	ret = nla_put_u8(skb_rsp, SNET_A_SYSCALL, syscall);
>> +	if (ret != 0)
>> +		goto send_event_failure;
>> +	ret = nla_put_u8(skb_rsp, SNET_A_PROTOCOL, protocol);
>> +	if (ret != 0)
>> +		goto send_event_failure;
>> +	ret = nla_put_u8(skb_rsp, SNET_A_FAMILY, family);
>> +	if (ret != 0)
>> +		goto send_event_failure;
>> +	ret = nla_put_u32(skb_rsp, SNET_A_UID, current_uid());
>> +	if (ret != 0)
>> +		goto send_event_failure;
>> +	ret = nla_put_u32(skb_rsp, SNET_A_PID, current->pid);
>> +	if (ret != 0)
>> +		goto send_event_failure;
>> +	ret = nla_put(skb_rsp, SNET_A_DATA_EXT, len, data);
>> +	if (ret != 0)
>> +		goto send_event_failure;
>
> I guess its a matter of taste, but the NLA_PUT macros already take
> care of exception handling and keep the code smaller.

indeed, I moved the code to use NLA_PUT and the hidden failure label

>> +
>> +	ret = genlmsg_end(skb_rsp, msg_head);
>> +	if (ret < 0)
>> +		goto send_event_failure;
>> +
>> +	genlmsg_unicast(&init_net, skb_rsp, snet_nl_pid);
>> +	return 0;
>> +
>> +send_event_failure:
>> +	kfree_skb(skb_rsp);
>> +	return 0;
>
> Shouldn't this error be returned to the caller to avoid waiting
> for the timeout to occur (same question for the return value of
> genlmsg_unicast, which can also fail).

indeed, if error occurred, no need to wait, we can apply the polocy
verdict.
genlmsg_unicast() is taking care of freeing the skb if error occured, so
we can return directly the value of genlmsg_unicast()

thanks Patrick

sam
