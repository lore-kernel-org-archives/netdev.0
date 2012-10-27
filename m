From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V2 1/1] tcp: Prevent needless syn-ack rexmt
 during TWHS
Date: Sat, 27 Oct 2012 15:32:05 +0200
Message-ID: <1351344725.30380.286.camel@edumazet-glaptop>
References: <1351238750-13611-1-git-send-email-subramanian.vijay@gmail.com>
	 <1351339032.30380.222.camel@edumazet-glaptop>
	 <alpine.LFD.2.00.1210271556250.1628@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vijay Subramanian <subramanian.vijay@gmail.com>,
	netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	ncardwell@google.com,
	Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	Elliott Hughes <enh@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:48749 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754808Ab2J0NcK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Oct 2012 09:32:10 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so1160313eaa.19
        for <netdev@vger.kernel.org>; Sat, 27 Oct 2012 06:32:09 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.00.1210271556250.1628@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-10-27 at 16:23 +0300, Julian Anastasov wrote:
> 	Hello,
> 
> On Sat, 27 Oct 2012, Eric Dumazet wrote:
> 

> > 
> > Author: Eric Dumazet <edumazet@google.com>
> > Date:   Tue Oct 2 02:21:12 2012 -0700
> > 
> > net-tcp: better retrans tracking for defer-accept
> > 
> > For passive TCP connections using TCP_DEFER_ACCEPT facility,
> > we incorrectly increment req->retrans each time timeout triggers
> > while no SYNACK is sent.
> > 
> > Decouple req->retrans field into two fields :
> > 
> > num_retrans : number of retransmit
> > num_timeout : number of timeouts
> > 
> > (retrans was renamed to make sure we didnt miss an occurrence)
> > 
> > introduce inet_rtx_syn_ack() helper to increment num_retrans
> > only if ->rtx_syn_ack() succeeded.
> 
> 	This is dangerous, the first of the cases is route
> failure, what if we just added reject route for some attacker?
> We will get error forever. May be it is difficult to decide
> which error should change the counter. IMHO, such reliability
> is not needed, we can be short of memory too.
> 


We increase num_timeout regardless of success or failure sending a
SYNACK (can be a route failure, a memory allocation failure, a full
qdisc...)

So its not 'forever'. The decision to abort a SYN_RECV is based on
num_timeouts only, not anymore on 'number of restransmits'

num_retrans is only counting number of SYNACKS that were sent.

num_retrans <= num_timeouts

(Usually its the same, unless you have errors, or DEFER_ACCEPT
mini-sockets)


> > Use inet_rtx_syn_ack() from tcp_check_req() to increment num_retrans
> > when we re-send a SYNACK in answer to a SYN. Prior to this patch,
> > we were not counting these retransmits.
> 
> 	Such change looks correct. Of course, it has
> side effect on current TCP_DEFER_ACCEPT calculations but
> it is a TCP_DEFER_ACCEPT implementation problem.

Better wait to see the patch, it changes nothing yet for
TCP_DEFER_ACCEPT

It only changes accounting problems, for more precise tracking of tcp
stack behavior.

TCP_DEFER_ACCEPT sockets have this strange accounting bug saying that
some packets were retransmitted, while its not true : We only were
waiting the user request.
