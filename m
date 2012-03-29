From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 2/3] tcp: Initial repair mode
Date: Thu, 29 Mar 2012 13:52:26 +0400
Message-ID: <4F7430DA.7050702@parallels.com>
References: <4F732FE1.9040906@parallels.com> <4F73302C.9030209@parallels.com> <4F734864.6000007@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Glauber Costa <glommer@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:19136 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752734Ab2C2Jwg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2012 05:52:36 -0400
In-Reply-To: <4F734864.6000007@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/28/2012 09:20 PM, Glauber Costa wrote:
>> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
>> index 9e7f9ba..65ae921 100644
>> --- a/net/ipv4/tcp.c
>> +++ b/net/ipv4/tcp.c
>> @@ -1935,7 +1935,9 @@ void tcp_close(struct sock *sk, long timeout)
>>   	 * advertise a zero window, then kill -9 the FTP client, wheee...
>>   	 * Note: timeout is always zero in such a case.
>>   	 */
>> -	if (data_was_unread) {
>> +	if (tcp_sk(sk)->repair) {
>> +		sk->sk_prot->disconnect(sk, 0);
>> +	} else if (data_was_unread) {
>>   		/* Unread data was tossed, zap the connection. */
>>   		NET_INC_STATS_USER(sock_net(sk), LINUX_MIB_TCPABORTONCLOSE);
>>   		tcp_set_state(sk, TCP_CLOSE);
>> @@ -2074,6 +2076,8 @@ int tcp_disconnect(struct sock *sk, int flags)
>>   	/* ABORT function of RFC793 */
>>   	if (old_state == TCP_LISTEN) {
>>   		inet_csk_listen_stop(sk);
>> +	} else if (unlikely(tp->repair)) {
>> +		sk->sk_err = ECONNABORTED;
>>   	} else if (tcp_need_reset(old_state) ||
>>   		   (tp->snd_nxt != tp->write_seq&&
>>   		(1<<  old_state)&  (TCPF_CLOSING | TCPF_LAST_ACK))) {
> 
> The patch looks good in general.
> Single nitpick is that maybe you should be consistent in your use of 
> unlikely. All of them seems equally unlikely, so I'd say you should wrap 
> both.

OK, will fix this.

>>
>> +	case TCP_REPAIR:
>> +		if (!tcp_can_repair_sock(sk))
>> +			err = -EPERM;
>> +		else if (val == 1) {
>> +			tp->repair = 1;
>> +			sk->sk_reuse = 2;
>> +			tp->repair_queue = TCP_NO_QUEUE;
>> +		} else if (val == 0) {
>> +			tp->repair = 0;
>> +			sk->sk_reuse = 0;
>> +			tcp_send_window_probe(sk);
>> +		} else
>> +			err = -EINVAL;
>> +
>> +		break;
>> +
>> +	case TCP_REPAIR_QUEUE:
> 
> Don't we need to test tcp_can_repair_sock() in all of them?
> I understand that TCP_REPAIR always comes before the other ones,
> so that means the socket is already in repair mode. But what
> should be the behavior in case the process drops privileges?
> Should it still be able to continue with the repair?

I believe it should. Because this model gives us the ability to do
both -- let others repair socket in non-root mode and keep one at
hands, giving it to anybody else only when the repair is complete.

> My first impression is that we need CAP_NET_ADMIN all along, so we 
> should make sure it's there.
> 
> .
> 
