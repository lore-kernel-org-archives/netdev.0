From: Valentina Giusti <valentina.giusti@bmw-carit.de>
Subject: Re: [PATCH 1/2] netfilter_queue: enable UID/GID socket info retrieval
Date: Thu, 19 Dec 2013 09:59:33 +0100
Message-ID: <52B2B575.1050709@bmw-carit.de>
References: <1387389844-5263-1-git-send-email-valentina.giusti@bmw-carit.de> <1387389844-5263-2-git-send-email-valentina.giusti@bmw-carit.de> <20131218212430.GD15863@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netfilter-devel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<eric.dumazet@gmail.com>, <tgraf@redhat.com>, <jpa@google.com>,
	<pablo@netfilter.org>, <davem@davemloft.net>,
	<daniel.wagner@bmw-carit.de>
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20131218212430.GD15863@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

thank you very much for your review.

On 12/18/2013 10:24 PM, Florian Westphal wrote:
> valentina.giusti@bmw-carit.de <valentina.giusti@bmw-carit.de> wrote:
>> From: Valentina Giusti <valentina.giusti@bmw-carit.de>
>>
>> Thanks to commits 41063e9 (ipv4: Early TCP socket demux) and 421b388 (udp:
>> ipv4: Add udp early demux) it is now possible to get UID and GID socket info
>> also for incoming TCP and UDP connections. Having this info available, it
>> is convenient to let NFQUEUE retrieve it in order to improve and refine the
>> traffic analysis in userspace.
> No objections from me, except a few comments below.
>
>> diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
>> index 21258cf..7257ddb 100644
>> --- a/net/netfilter/nfnetlink_queue_core.c
>> +++ b/net/netfilter/nfnetlink_queue_core.c
>> @@ -328,7 +328,9 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
> [..]
>>   	if (entskb->tstamp.tv64)
>>   		size += nla_total_size(sizeof(struct nfqnl_msg_packet_timestamp));
>> @@ -484,6 +486,25 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
>>   			goto nla_put_failure;
>>   	}
>>   
>> +	if (entskb->sk) {
>> +		struct sock *sk = entskb->sk;
>> +		if (sk && sk->sk_state != TCP_TIME_WAIT) {
>> +			read_lock_bh(&sk->sk_callback_lock);
> nfqnl_build_packet_message is already a huge function, I think it
> might be useful to add a small helper function for this,
> e.g.  'nfqnl_skinfo_put(skb, entskb->sk)' or something like that.
>
> Also, it might be a good idea to only dump the sk info
> on userspace request (not sure how expensive the readlock is
> compared to the nfqueue cost...), see NFQA_CFG_F_CONNTRACK flag for
> instance.

I was actually wondering if there could be a better solution instead of 
always sending UID/GID to userspace, thanks for your suggestion.

>> +			if (sk->sk_socket && sk->sk_socket->file) {
>> +				struct file *file = sk->sk_socket->file;
>> +				const struct cred *cred = file->f_cred;
>> +				if (nla_put_u32(skb, NFQA_UID,
> nla_put_be32
>
>> +				    htonl(cred->fsuid)))
>> +					goto nla_put_failure;
> careful - the sk_callback_lock was taken.

Sorry, I totally overlooked this one.
I will send soon a new patchset that addresses all your comments.

--
BR,
Val

>
> Cheers,
> Florian

