From: Shan Wei <shanwei88@gmail.com>
Subject: Re: [PATCH 1/2] netfilter: xtables: inclusion of xt_SYSRQ
Date: Thu, 05 Jan 2012 21:19:08 +0800
Message-ID: <4F05A34C.10405@gmail.com>
References: <1271845618-28569-1-git-send-email-jengelh@medozas.de> <1271845618-28569-2-git-send-email-jengelh@medozas.de> <4BCEF6B4.8090105@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Jan Engelhardt <jengelh@medozas.de>,
	netfilter-devel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	prarit@redhat.com, David Miller <davem@davemloft.net>
To: john.haxby@oracle.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4BCEF6B4.8090105@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote, at 2010/4/21 20:59:

> I really think this is pushing what netfilter is meant for a bit
> far. Its basically abusing the firewall ruleset to offer a network
> service.
> 
> I can see that its useful to have this in the kernel instead of
> userspace, but why isn't this implemented as a stand-alone module?
> That seems like a better design to me and also makes it more useful
> by not depending on netfilter.


It's very useful to remotely sysrq server machines in large data-center.
Another solution by Prarit Bhargava is denied by David Miller,
see discussion http://patchwork.ozlabs.org/patch/101284/.

xt_SYSRQ solution is more convenience for us to use in inner system.
I hope this solution can be merged to main tree. :-)
But before that, this code need to be fixed (may be need more hashing enhancement).

> 
>> Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
>> ---
>> +module_param_string(password, sysrq_password, sizeof(sysrq_password),
>> +	S_IRUSR | S_IWUSR);
>> +module_param_string(hash, sysrq_hash, sizeof(sysrq_hash), S_IRUSR);

Read only.
hash algorithm can be changed.

>> +module_param_named(seqno, sysrq_seqno, long, S_IRUSR | S_IWUSR);

sysrq_seqno is set using current time in sysrq_crypto_init.
Whatever we set, sysrq_seqno is not equal to what we set.

>> +	if (len == 0)
>> +		return NF_DROP;

malformed packet should be delivered to udp protocol handing.
 


>> +	if (i != 3) {
>> +		if (sysrq_debug)
>> +			pr_info("badly formatted request\n");
>> +		return NF_DROP;

Is there 1% possibility for user to send x,x,x,x, type data in udp payload?

>> +	do_gettimeofday(&now);
>> +	sysrq_seqno = now.tv_sec;
>> +	ret = xt_register_targets(sysrq_tg_reg, ARRAY_SIZE(sysrq_tg_reg));

register target.

>> +static int __init sysrq_tg_init(void)
>> +{
>> +	if (sysrq_crypto_init() < 0)
>> +		pr_info("starting without crypto\n");
>> +	return xt_register_targets(sysrq_tg_reg, ARRAY_SIZE(sysrq_tg_reg));

register again. This will cause target list dead loop.

--
Best Regards
Shan Wei
