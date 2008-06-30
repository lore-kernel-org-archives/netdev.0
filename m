From: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Subject: Re: [PATCH] Prevent from potential dead lock for inet_listen_lock
Date: Mon, 30 Jun 2008 11:16:41 +0800
Message-ID: <48685019.90706@cn.fujitsu.com>
References: <485B7384.1090204@cn.fujitsu.com> <20080627.193234.134186954.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63230 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751229AbYF3DTc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Jun 2008 23:19:32 -0400
In-Reply-To: <20080627.193234.134186954.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
> Date: Fri, 20 Jun 2008 17:08:20 +0800
> 
>> hashinfo->lhash_lock might be acquired by write_lock() in softirq, 
> 
> How?
  
  How about the following call trace.
dccp_v4_rcv
  -> sk_receive_skb(sk, skb, 1);
    -> sk->sk_backlog_rcv(sk, skb);(dccp_v4_do_rcv)
      -> dccp_rcv_state_process()
	-> dccp_rcv_request_sent_state_process(sk, skb, dh, len);
	  -> icsk->icsk_af_ops->rebuild_header(sk); (inet_sk_rebuild_header)
	    -> inet_sk_reselect_saddr(sk))
	      -> __sk_prot_rehash(sk);
		-> sk->sk_prot->hash(sk);
		  -> inet_hash(struct sock *sk)
	            -> __inet_hash(struct sock *sk)
		      -> inet_listen_wlock(hashinfo);
			-> write_lock(&hashinfo->lhash_lock);

> 
>> so using read_lock() here isn't safe, just substitudes by read_lock_bh().
>>
>> Signed-off-by: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
> 
> I don't think this is necessary.
> 
> The only place the write lock is obtained, is via
> the ->hash() and ->unhash() sk_prot operation methods.
> 
> And for listening sockets that only occurs in normal base
> context.  Never from softirqs.
> 
> If there is a patch from softirqs where this can occur,
> that is a bug and must be fixed.
> 
> 
> 

-- 
Regards
Gui Jianfeng

