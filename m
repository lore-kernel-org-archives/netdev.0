From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 4/6] kcm: Kernel Connection Multiplexor module
Date: Fri, 20 Nov 2015 15:19:02 -0800
Message-ID: <CALx6S36p3RAy+7ZO6G=MjAyLz95zr-UD7AUaFe8kS8EVUHHFNw@mail.gmail.com>
References: <1448054520-1464587-1-git-send-email-tom@herbertland.com>
	<1448054520-1464587-5-git-send-email-tom@herbertland.com>
	<20151120225012.GB10508@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>, davewatson@fb.com,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:33818 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751310AbbKTXTD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 18:19:03 -0500
Received: by igvg19 with SMTP id g19so42262989igv.1
        for <netdev@vger.kernel.org>; Fri, 20 Nov 2015 15:19:02 -0800 (PST)
In-Reply-To: <20151120225012.GB10508@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 20, 2015 at 2:50 PM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (11/20/15 13:21), Tom Herbert wrote:
>> +static int kcm_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
>    :
>> +
>> +             if (msg->msg_flags & MSG_BATCH) {
>> +                     kcm->tx_wait_more = true;
>> +             } else if (kcm->tx_wait_more || not_busy) {
>> +                     err = kcm_write_msgs(kcm);
>> +                     if (err < 0) {
>> +                             /* We got a hard error in write_msgs but have
>> +                              * already queued this message. Report an error
>> +                              * in the socket, but don't affect return value
>> +                              * from sendmsg
>> +                              */
>> +                             pr_warn("KCM: Hard failure on kcm_write_msgs\n");
>> +                             report_csk_error(&kcm->sk, -err);
>> +                     }
>> +             }
>
> It's interesting that kcm copies the user data to a skb and
> then invokes kernel_sendpage on the frag_list in that skb- was this
> specifically done with some perf goals in mind? If yes, do you happen
> to have some estimate of how much this approach buys you, as opposed
> to just setting up a sglist and calling tcp_sendpage later? (RDS uses
> the latter approach, and I've tried to use the changes introduced
> by Eric's commit in 5640f76, it helps slightly but I think there may
> be other bottlenecks to overcome first for the specific req-resp
> patterns that are common in DB workloads)
>
Hi Sowmini,

I did notice that RDS is just creating sglist, but I also noticed that
this requires allocating "struct rds_message" which holds pointers to
the sglist, list pointers for a queue, etc. This looks to me like its
emulating skbuffs anyway. I haven't looked if there's performance
issues otherwise in using the fraglist. It might be interesting if
there was an interface to send skbufs on a kernel socket.

> The other question I had when reading this code is: what if the
> application never sends that last MSG_BATCH-less message, e.g.,
> it lies about how its going send more messages? will something eventually
> time-out and send the data? Any estimates for a good batch size?
>
No time out. Sending will block. I don't think this behavior needs to
be any different than what happens if an application forgets to
complete a MSG_MORE.

Thanks,
Tom

> --Sowmini
