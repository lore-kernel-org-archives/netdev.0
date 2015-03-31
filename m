From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: rps: fix data stall after hotplug
Date: Tue, 31 Mar 2015 16:44:20 -0700
Message-ID: <1427845460.25985.174.camel@edumazet-glaptop2.roam.corp.google.com>
References: <b3ecb218932daa656a796cfa6e9e62b9.squirrel@www.codeaurora.org>
	 <1426801839.25985.15.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1426852239.25985.33.camel@edumazet-glaptop2.roam.corp.google.com>
	 <b25a45de2cb43bbcfcaa84634d74533e.squirrel@www.codeaurora.org>
	 <744bbefe8859bf667eafc0de02729078.squirrel@www.codeaurora.org>
	 <1427149742.25985.84.camel@edumazet-glaptop2.roam.corp.google.com>
	 <49d5ac3130df29059f167a0401754c67.squirrel@www.codeaurora.org>
	 <6ef597cb521f6c9adf48562c72677415.squirrel@www.codeaurora.org>
	 <1427777316.25985.168.camel@edumazet-glaptop2.roam.corp.google.com>
	 <667cd94f1b58cc008ddcb91751f90fd7.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34555 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752228AbbCaXoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 19:44:25 -0400
Received: by pactp5 with SMTP id tp5so34033616pac.1
        for <netdev@vger.kernel.org>; Tue, 31 Mar 2015 16:44:25 -0700 (PDT)
In-Reply-To: <667cd94f1b58cc008ddcb91751f90fd7.squirrel@www.codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-03-31 at 22:02 +0000, subashab@codeaurora.org wrote:
> > Listen, I would rather disable RPS on your arch, instead of messing with
> > it.
> >
> > Reset NAPI state as you did is in direct violation of the rules.
> >
> > Only cpu owning the bit is allowed to reset it.
> >
> 
> Perhaps my understanding of the code in dev_cpu_callback() is incorrect?
> Please correct me if I am wrong.
> 
> The poll list is copied from an offline cpu to an online cpu.
> Specifically for process_backlog, I was under the impression that
> the online cpu tries to reset the state of NAPI of the offline cpu.
> The process and input queues are then always copied to the
> online cpu.
> 
> while (!list_empty(&oldsd->poll_list)) {
> 	struct napi_struct *napi = list_first_entry(&oldsd->poll_list,
> 						    struct napi_struct,
> 							     poll_list);
> 
> 	list_del_init(&napi->poll_list);
> 	if (napi->poll == process_backlog)
> 		napi->state = 0;
> 	else
> 		____napi_schedule(sd, napi);
> }
> 
> My request was to know why it would be incorrect to clear the offline cpu
> backlog NAPI state unconditionally.
> 

It is incorrect because the moment we chose to send an IPI to a cpu, we
effectively transfered NAPI bit ownership to this target cpu. Another
cpu cannot take over without risking tricky corruptions.

If your arch fails to send the IPI, we have no way to clear the bit in a
safe way.

Only target cpu is allowed to clear the bit by virtue of following being
called :

/* Called from hardirq (IPI) context */
static void rps_trigger_softirq(void *data)
{
        struct softnet_data *sd = data;

        ____napi_schedule(sd, &sd->backlog);
        sd->received_rps++;
}

If it is not called even in 0.000001% of the cases, all bets are off.

We are not going to add yet another atomic ops for every packet just to
solve this corner case. Just do not enable RPS on your arch, as it is by
default not enabled.

I am currently in vacations, I will not reply to another inquiry on this
topic.
