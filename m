From: Andrew <nitr0@seti.kr.ua>
Subject: Re: Kernel 4.1.12 crash
Date: Thu, 3 Dec 2015 23:09:58 +0200
Message-ID: <5660AFA6.6040905@seti.kr.ua>
References: <5650287B.9070901@seti.kr.ua> <56514FF5.7060906@gmail.com>
 <5654EBE8.9030705@seti.kr.ua> <20151125141048.GA3868@alphalink.fr>
 <5655CCAE.6000300@seti.kr.ua> <20151126164452.GA2988@alphalink.fr>
 <565B7699.8030105@seti.kr.ua> <20151130150337.GC3059@alphalink.fr>
 <20151130204208.GA6046@alphalink.fr> <20151202172335.GB16101@alphalink.fr>
 <20151203153536.GC16101@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	netdev@vger.kernel.org, Simon Farnsworth <simon@farnz.org.uk>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.seti.kr.ua ([91.202.132.4]:45128 "EHLO mail.seti.kr.ua"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754493AbbLCVKF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 16:10:05 -0500
In-Reply-To: <20151203153536.GC16101@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

Thanks, I'll rebuild kernel with your patch "pppoe: fix memory 
corruption in padt work structure", tryto check it in test env, and try 
to update PPPoE servers.

03.12.2015 17:35, Guillaume Nault wrote:
> On Wed, Dec 02, 2015 at 06:23:35PM +0100, Guillaume Nault wrote:
>> You can try the following. It's not yet a proper fix as there are still
>> a few things that bug me in pppoe_connect().
>>
>> ---
>> diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
>> index 5e0b432..865b74d 100644
>> --- a/drivers/net/ppp/pppoe.c
>> +++ b/drivers/net/ppp/pppoe.c
>> @@ -568,6 +568,9 @@ static int pppoe_create(struct net *net, struct socket *sock, int kern)
>>   	sk->sk_family		= PF_PPPOX;
>>   	sk->sk_protocol		= PX_PROTO_OE;
>>   
>> +	INIT_WORK(&pppox_sk(sk)->proto.pppoe.padt_work,
>> +		  pppoe_unbind_sock_work);
>> +
>>   	return 0;
>>   }
>>   
>> @@ -632,8 +635,6 @@ static int pppoe_connect(struct socket *sock, struct sockaddr *uservaddr,
>>   
>>   	lock_sock(sk);
>>   
>> -	INIT_WORK(&po->proto.pppoe.padt_work, pppoe_unbind_sock_work);
>> -
>>   	error = -EINVAL;
>>   	if (sp->sa_protocol != PX_PROTO_OE)
>>   		goto end;
>> @@ -663,8 +664,6 @@ static int pppoe_connect(struct socket *sock, struct sockaddr *uservaddr,
>>   			po->pppoe_dev = NULL;
>>   		}
>>   
>> -		memset(sk_pppox(po) + 1, 0,
>> -		       sizeof(struct pppox_sock) - sizeof(struct sock));
>>   		sk->sk_state = PPPOX_NONE;
>>   	}
>>   
> Finally, I'm going to send something similar to -net and keep the rest
> of pppoe_connect() modifications for net-next. This will ease
> backporting to -stable.
