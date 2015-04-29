From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH RFC net-next] pktgen: introduce 'rx' mode
Date: Wed, 29 Apr 2015 16:59:49 -0700
Message-ID: <55417075.9010601@plumgrid.com>
References: <1430273488-8403-1-git-send-email-ast@plumgrid.com>	 <1430273488-8403-2-git-send-email-ast@plumgrid.com>	 <1430280853.3711.19.camel@edumazet-glaptop2.roam.corp.google.com>	 <5541535E.1060908@plumgrid.com>	 <1430345993.3711.59.camel@edumazet-glaptop2.roam.corp.google.com>	 <55415D6B.7070009@plumgrid.com>	 <1430348211.3711.66.camel@edumazet-glaptop2.roam.corp.google.com>	 <55416905.7070308@plumgrid.com> <1430350786.3711.77.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Thomas Graf <tgraf@suug.ch>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:34871 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751944AbbD2X7w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 19:59:52 -0400
Received: by iejt8 with SMTP id t8so55450394iej.2
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 16:59:52 -0700 (PDT)
In-Reply-To: <1430350786.3711.77.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/29/15 4:39 PM, Eric Dumazet wrote:
>
> Zap the 'burst/clone' thing, this is not going to work for RX.
> TX was okay, not RX.
>
> You could for instance do :
>
> atomic_inc(&skb->users);
> netif_receive_skb(skb);
> if (atomic_read(skb->users) != 1) {
> 	/* This is too bad, I can not recycle this skb because it is still used */
> 	consume_skb(skb);
> 	/* allocate a fresh new skb */
> 	skb = ...
> } else {
> 	/* Yeah ! Lets celebrate, cost of reusing this skb was one atomic op */
> }

ahh, great! I think I'm starting to understand.
then the following should be ok as well?

atomic_add(burst, &skb->users);
do {
    netif_receive_skb(skb);
    if (atomic_read(skb->users) != burst) {
  	/* too bad, can not recycle */
         atomic_sub(burst - 1, &skb->users);
  	consume_skb(skb);
  	/* allocate a fresh new skb */
  	skb = ...
         /* and get out of this loop */
    } else {
	/* Yeah ! the cost of reusing this skb was
            one atomic op amortized over 'burst' iterations */
    }
} while (--burst > 0);
