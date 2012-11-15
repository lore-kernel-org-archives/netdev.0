From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: stp issue and "bridge: send proper message_age in config BPDU"
Date: Thu, 15 Nov 2012 11:58:53 -0800
Message-ID: <20121115115853.6b9a3ec3@s6510.linuxnetplumber.net>
References: <20121115195200.GD730@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Steven Kath <steven.kath@vyatta.com>,
	Anatoly Kaplan <anatoly.kaplan@vyatta.com>,
	Arthur Xiong <arthur.xiong@vyatta.com>,
	Chris Healy <cphealy@gmail.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34035 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1768751Ab2KOT66 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2012 14:58:58 -0500
In-Reply-To: <20121115195200.GD730@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Nov 2012 20:52:00 +0100
Lennert Buytenhek <buytenh@wantstofly.org> wrote:

> Hi!
> 
> FWIW, I've been debugging an STP issue on an old product kernel tree
> that I couldn't find an upstream fix for, but after having debugged the
> issue, there does actually appear to be an upstream commit that makes
> the issue go away, but the commit message on that commit is somewhat
> unclear about what the issue is that it's fixing and why the given fix
> fixes it, and given that I spent considerable time debugging it I
> figured I'd send this out for the sake of the next person googling for
> this.
> 
> The symptoms are pretty much what's described in this bug:
> 
> 	https://bugzilla.vyatta.com/show_bug.cgi?id=7164
> 
> And the upstream commit is:
> 
> 	https://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=commit;h=0c03150e7ea8f7fcd03cfef29385e0010b22ee92
> 
> 	commit 0c03150e7ea8f7fcd03cfef29385e0010b22ee92
> 	Author: stephen hemminger <shemminger@vyatta.com>
> 	Date:   Fri Jul 22 07:47:06 2011 +0000
> 
> 	    bridge: send proper message_age in config BPDU
> 
> What I was seeing was that as a non-root bridge, Linux STP would often
> fail to transmit BPDUs out of designated ports upon reception of a BPDU
> from an upstream port.
> 
> br_received_config_bpdu() handles the received BPDU, and calls into
> br_record_config_information(), which resets the message age timer on
> this port to jiffies + (p->br->max_age - bpdu->message_age);
> 
> When br_received_config_bpdu() then calls br_config_bpdu_generation(),
> the latter will call into br_transmit_config() for each enabled
> designated port, which will send out BPDUs with age br->max_age
> - (root->message_age_timer.expires - jiffies) + MESSAGE_AGE_INCR if
> we're not the root bridge, which if you plug in the previously
> computed timeout simplifies to bpdu->message_age + MESSAGE_AGE_INCR,
> which is exactly what we want it to be and this computation isn't
> wrong per se.
> 
> The problem with the above logic, though, is that it fails to
> consider that mod_timer() can round up the timeout you give it (i.e.
> add timer slack), and that reading back root->message_age_timer.expires
> in br_transmit_config() won't necessarily return the value that was
> plugged into mod_timer() for this timer in br_record_config_information().
> 
> E.g. if mod_timer() decides to add 5 jiffies to the timeout, the message
> age value that br_transmit_config() will compute will be:
> 
> 	br->max_age - (root->message_age_timer.expires - jiffies) +
> 		MESSAGE_AGE_INCR
> 
> 	= br->max_age - (jiffies + (p->br->max_age - bpdu->message_age) + 5
> 		- jiffies) + MESSAGE_AGE_INCR
> 
> 	= br->max_age - (p->br->max_age - bpdu->message_age + 5) +
> 		MESSAGE_AGE_INCR
> 
> 	= bpdu->message_age - 5 + MESSAGE_AGE_INCR
> 
> Which will likely make the computed message age value negative.
> This message age is stored in a signed int, but is then compared
> against the bridge max age time:
> 
> 	if (bpdu.message_age < br->max_age) {
> 
> and br->max_age is an unsigned long, causing the comparison to be
> unsigned and always fail if the computed message age was negative,
> and no BPDU to be sent (causing our downstream neighbours to time
> us out after some time and etc).
> 
> Commit 0c03150e7ea fixes the issue because it avoids reading back the
> expiration time (possibly with timer slack included) of a previously
> set timer.  Disabling timer slack on the message age timer achieves
> the same thing (and is what I did initially):
> 
> --- a/net/bridge/br_stp_timer.c
> +++ b/net/bridge/br_stp_timer.c
> @@ -158,6 +158,7 @@ void br_stp_port_timer_init(struct net_bridge_port *p)
>  {
>         setup_timer(&p->message_age_timer, br_message_age_timer_expired,
>                       (unsigned long) p);
> +       set_timer_slack(&p->message_age_timer, 0);
>  
>         setup_timer(&p->forward_delay_timer, br_forward_delay_timer_expired,
>                       (unsigned long) p);
> 
> 
> thanks,
> Lennert

Disabling timer slack causes additional power consumption because
the tick wakeup has to be immediate. I prefer to handle late timer
in the code. 

P.s: not sure if timer slack existed back when I first saw the problem.
