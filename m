From: Douglas Leith <Doug.Leith@nuim.ie>
Subject: Re: [PATCH 2.6.27] tcp_htcp: last_cong bug fix
Date: Mon, 10 Nov 2008 10:07:32 +0000
Message-ID: <3739DC81-132E-44C6-8EF4-D93D7012C233@nuim.ie>
References: <0E5A87BC-8FA8-40A5-8032-9FA18D07D7CE@nuim.ie>
 <4917B0E9.2030304@room52.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Lachlan Andrew <lachlan.andrew@gmail.com>,
	grenville armitage <garmitage@swin.edu.au>
To: Lawrence Stewart <lstewart@room52.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from banyan.nuim.ie ([149.157.1.4]:44276 "EHLO banyan.nuim.ie"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752421AbYKJKHh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Nov 2008 05:07:37 -0500
Received: from [192.168.0.2] ([78.16.221.173])
 by mango.nuim.ie (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3
 2007; 32bit)) with ESMTPSA id <0KA40062F44NVND0@mango.nuim.ie> for
 netdev@vger.kernel.org; Mon, 10 Nov 2008 10:07:35 +0000 (GMT)
In-reply-to: <4917B0E9.2030304@room52.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> My familiarity with the Linux TCP stack is not up to scratch as you  
> know. I'm curious about the "if (ca->undo_last_cong)" condition you  
> added to htcp_cwnd_undo(). Is there a possibility of the stack  
> calling into this function multiple times without at least one  
> congestion control related state change in between?
>
It looks like this is possible, but in a limited way that seems  
safe.  The call to the undo code is from tcp_undo_cwr() which in turn  
is called from one of the following

* tcp_try_undo_recovery() - this is only called when the state is  
TCP_CA_Loss or TCP_CA_Recovery and the code path then makes a state  
change to TCP_CA_Open after calling undo.
* tcp_try_undo_loss() - this is called when the state is TCP_CA_Loss   
and after undo also enters TCP_CA_Open
* tcp_try_undo_dsack() - this is called from state TCP_CA_Disorder
* tcp_undo_spur_to_response() - part of the FRTO code which also  
seems to occur in the TCP_CA_Disorder state.

So calls to the undo code from the states TCP_CA_Loss or  
TCP_CA_Recovery always exit with a transition to state TCP_CA_Open.   
Therefore multiple calls to the undo code from the loss and recovery  
states without a state change don't seem to be possible.

Multiple calls to the undo code do seem to be possible from within  
the TCP_CA_Disorder state without a state transition.  But this is  
ok.  Cwnd is not backed off in this state and so there is no undo  
action to take (at least with respect to cwnd, ssthresh and last_cong  
- the undo calls seem to be related to other book-keeping).   Both  
the original htcp code and the new code only store undo information  
on entering CP_CA_Loss, TCP_CA_Recovery or TCP_CWR but not on a  
transition into TCP_CA_Disorder.  The proposed patch disables the  
undo functionality in this situation since there is no valid undo  
information stored - this fixes a bug in the original code which  
would have attempted an undo using spurious undo information.

Hope that makes sense ;-)

> I will test your patch and confirm it resolves the issue we reported.
>
Thanks.

> Also, while we're at it, any chance you might consider adding the  
> functionality in the attached patch so that we can control adaptive  
> backoff via a module tunable?
>
Makes sense to me.   Why not submit it as a patch via a separate email.

Doug

> Douglas Leith wrote:
>> This patch fixes a minor bug in tcp_htcp.c which has been  
>> highlighted by Lachlan Andrew and Lawrence Stewart.   Currently,  
>> the time since the last congestion event, which is stored in  
>> variable last_cong, is reset whenever there is a state change into  
>> TCP_CA_Open.  This includes transitions of the type TCP_CA_Open- 
>> >TCP_CA_Disorder->TCP_CA_Open which are not associated with  
>> backoff of cwnd.  The patch changes last_cong to be updated only  
>> on transitions into TCP_CA_Open that occur after experiencing the  
>> congestion-related states TCP_CA_Loss, TCP_CA_Recovery, TCP_CA_CWR.
>> Doug
>> --- tcp_htcp.c   2008-11-05 15:50:18.000000000 +0000
>> +++ tcp_htcp.c.new       2008-11-08 07:11:18.000000000 +0000
>> @@ -69,9 +69,12 @@
>>         const struct tcp_sock *tp = tcp_sk(sk);
>>         struct htcp *ca = inet_csk_ca(sk);
>> -       ca->last_cong = ca->undo_last_cong;
>> -       ca->maxRTT = ca->undo_maxRTT;
>> -       ca->old_maxB = ca->undo_old_maxB;
>> +       if (ca->undo_last_cong) {
>> +               ca->last_cong = ca->undo_last_cong;
>> +               ca->maxRTT = ca->undo_maxRTT;
>> +               ca->old_maxB = ca->undo_old_maxB;
>> +               ca->undo_last_cong=0; // flag that ca->last_cong  
>> is not to be reset when enter TCP_CA_Open state
>> +       }
>>         return max(tp->snd_cwnd, (tp->snd_ssthresh << 7) / ca->beta);
>>  }
>> @@ -265,12 +268,15 @@
>>  static void htcp_state(struct sock *sk, u8 new_state)
>>  {
>>         switch (new_state) {
>> -       case TCP_CA_Open:
>> +       case TCP_CA_Open:
>>                 {
>>                         struct htcp *ca = inet_csk_ca(sk);
>> -                       ca->last_cong = jiffies;
>> +                       if (ca->undo_last_cong) {
>> +                               ca->last_cong=jiffies;
>> +                               ca->undo_last_cong=0;
>> +                       }
>>                 }
>> -               break;
>> +               break;
>>         case TCP_CA_CWR:
>>         case TCP_CA_Recovery:
>>         case TCP_CA_Loss:
>
> --- /usr/src/linux-source-2.6.25/net/ipv4/tcp_htcp.c	2008-04-17  
> 12:49:44.000000000 +1000
> +++ tcp_htcp.c	2008-10-24 17:02:27.000000000 +1100
> @@ -22,6 +22,10 @@
>  module_param(use_bandwidth_switch, int, 0644);
>  MODULE_PARM_DESC(use_bandwidth_switch, "turn on/off bandwidth  
> switcher");
>
> +static int use_adaptive_backoff __read_mostly = 1;
> +module_param(use_adaptive_backoff, int, 0644);
> +MODULE_PARM_DESC(use_adaptive_backoff, "turn on/off adaptive  
> backoff");
> +
>  struct htcp {
>  	u32	alpha;		/* Fixed point arith, << 7 */
>  	u8	beta;           /* Fixed point arith, << 7 */
> @@ -155,7 +159,7 @@
>  		}
>  	}
>
> -	if (ca->modeswitch && minRTT > msecs_to_jiffies(10) && maxRTT) {
> +	if (use_adaptive_backoff && ca->modeswitch && minRTT >  
> msecs_to_jiffies(10) && maxRTT) {
>  		ca->beta = (minRTT << 7) / maxRTT;
>  		if (ca->beta < BETA_MIN)
>  			ca->beta = BETA_MIN;

