From: Christian Bell <christian@myri.com>
Subject: Re: [PATCH 1/2] udp: introduce struct udp_table and multiple rwlocks
Date: Tue, 28 Oct 2008 14:23:55 -0700
Message-ID: <B7C6414D-7A69-48DA-8424-5D9F5FC50338@myri.com>
References: <20081007160729.60c076c4@speedy>	<20081007.135548.56141000.davem@davemloft.net>	<48ECBBD8.9060602@cosmosbay.com> <20081008.114527.189056050.davem@davemloft.net> <4907780F.1080808@cosmosbay.com>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1780 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752211AbYJ1VYR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Oct 2008 17:24:17 -0400
In-Reply-To: <4907780F.1080808@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Oct 28, 2008, at 1:37 PM, Eric Dumazet wrote:

> -extern struct hlist_head udp_hash[UDP_HTABLE_SIZE];
> -extern rwlock_t udp_hash_lock;
> +struct udp_hslot {
> +	struct hlist_head	head;
> +	rwlock_t		lock;
> +};

This structure should be aligned up to cacheline to reduce false  
sharing of more than one hslot.

> +	} else {
> +		hslot = &udptable->hash[udp_hashfn(net, snum)];
> +		write_lock_bh(&hslot->lock);
> +		if (udp_lib_lport_inuse(net, snum, hslot, sk, saddr_comp))
> +			goto fail;

The fail: label below should still unlock_bh when the above condition  
fails.

>
> +	}
> 	inet_sk(sk)->num = snum;
> 	sk->sk_hash = snum;
> 	if (sk_unhashed(sk)) {
> -		sk_add_node(sk, &udptable[udp_hashfn(net, snum)]);
> +		sk_add_node(sk, &hslot->head);
> 		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
> 	}
> +	write_unlock_bh(&hslot->lock);
> 	error = 0;
> fail:
> -	write_unlock_bh(&udp_hash_lock);
> 	return error;
> }

cheers,

	. . christian
