From: chenweilong <chenweilong@huawei.com>
Subject: Re: [PATCH] ipv4: avoid divide 0 error in tcp_incr_quickack
Date: Mon, 3 Nov 2014 13:31:33 +0800
Message-ID: <54571335.2060709@huawei.com>
References: <1414978173-6948-1-git-send-email-chenweilong@huawei.com> <1414986126.31792.43.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414986126.31792.43.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2014/11/3 11:42, Eric Dumazet wrote:
> On Mon, 2014-11-03 at 09:29 +0800, Chen Weilong wrote:
>> From: Weilong Chen <chenweilong@huawei.com>
>>
>> We got a problem like this:
> 
>> There was a wrong ack packet coming during TCP handshake. The socket's state
>> was TCP_SYN_RECV, its rcv_mss was not initialize yet. So
>> tcp_send_dupack -> tcp_enter_quickack_mode got a divide 0 error.
>> This patch add a state check before tcp_enter_quickack_mode.
>>
>> Signed-off-by: Weilong Chen <chenweilong@huawei.com>
>> ---
>>  net/ipv4/tcp_input.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
>> index 4e4617e..9eb56dc 100644
>> --- a/net/ipv4/tcp_input.c
>> +++ b/net/ipv4/tcp_input.c
>> @@ -3986,7 +3986,8 @@ static void tcp_send_dupack(struct sock *sk, const struct sk_buff *skb)
>>  	if (TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(skb)->seq &&
>>  	    before(TCP_SKB_CB(skb)->seq, tp->rcv_nxt)) {
>>  		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_DELAYEDACKLOST);
>> -		tcp_enter_quickack_mode(sk);
>> +		if (sk->sk_state != TCP_SYN_RECV)
>> +			tcp_enter_quickack_mode(sk);
>>  
>>  		if (tcp_is_sack(tp) && sysctl_tcp_dsack) {
>>  			u32 end_seq = TCP_SKB_CB(skb)->end_seq;
> 
> 
> Sorry I do not think this is the right fix.
> 
> We have to not simply avoid the divide, but fix this issue by
> understanding the missing steps.
> 
Hi Eric,

I check the code and find that:

1.In function "tcp_rcv_state_process",
the "tcp_initialize_rcv_mss" is called at "step 5: check the ACK field" when the sk->sk_state is TCP_SYN_RECV
and there is a "tcp_validate_incoming" just before it.
So when we call "tcp_validate_incoming", the rcv_mss may not been initialized.

2.In function "tcp_validate_incoming",
the "Step 1: check sequence number", according to RFC793 page 69,
If an incoming segment is not acceptable,an acknowledgment should be sent in reply (unless the RST
bit is set, if so drop the segment and return).
So we may call "tcp_send_dupack" while the rcv_mss hasn't been initialized.

3.In function "tcp_send_dupack",
when the condition is suitable, it'll enter quick ack mode. Notice it only check the seq !
So I think add another state check should be OK.

Any suggestion ?

Thanks,
Weilong
> 
> 
> 
> .
> 
