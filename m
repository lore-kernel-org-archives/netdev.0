From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 1/1] net: reflect mark on tcp syn ack packets
Date: Sun, 18 Jun 2017 08:45:12 -0400
Message-ID: <40a9a6b3-927d-32c9-2037-0db3a75bf0ec@mojatatu.com>
References: <1497101461-20921-1-git-send-email-jhs@emojatatu.com>
 <CAKD1Yr1uGL-OPUJ76D=md8kCT0psreew20Em=BokHWEYdP9xOg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        mrv@mojatatu.com, Jamal Hadi Salim <hadi@mojatatu.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:34485 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753073AbdFRMpO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Jun 2017 08:45:14 -0400
Received: by mail-qt0-f195.google.com with SMTP id o21so16580970qtb.1
        for <netdev@vger.kernel.org>; Sun, 18 Jun 2017 05:45:14 -0700 (PDT)
In-Reply-To: <CAKD1Yr1uGL-OPUJ76D=md8kCT0psreew20Em=BokHWEYdP9xOg@mail.gmail.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Sorry for the latency.

On 17-06-13 09:58 AM, Lorenzo Colitti wrote:
> On Sat, Jun 10, 2017 at 10:31 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>>          skb->priority = sk->sk_priority;
>> -       skb->mark = sk->sk_mark;
>> +       if (!skb->mark)
>> +               skb->mark = sk->sk_mark;
> 
> It looks a bit iffy to take sk->sk_mark only if skb->mark is zero
> instead of relying on the callers to tell this function what they
> want. I think the patch is correct, but it might be better to fix the
> other callers (dccp_make_response and dccp_ctl_make_reset) to set
> skb->mark to what they want. Either way. 
>

I saw the DCCP call - but the systcl says "tcp" on it and the feature
is not used by dccp currently. i.e it looked like an unreasonably large
change to update ip_build_and_send_pkt() params in particular when
the skb already had the mark.

>>          tcp_ecn_make_synack(req, th);
>>          th->source = htons(ireq->ir_num);
>>          th->dest = ireq->ir_rmt_port;
>> +       if (sock_net(sk)->ipv4.sysctl_tcp_fwmark_accept)
>> +               skb->mark = ireq->ir_mark;
> 
> I think checking the sysctl here is unnecessary. It seems to me that
> ir_mark already takes that into account. Its semantics (see
> inet_request_mark) are:
> 
> - If listen socket has a nonzero mark, use that
> - Else if sysctl_tcp_fwmark_accept is set and inbound SYN packet has
> mark, use that
> - Else zero.
> 
> which is what you want.

I see it. I'll fix this part in next version.


> 
> Other than that,
> 
> Reviewed-By: Lorenzo Colitti <lorenzo@google.com>
> 
> Please disregard my earlier comment about fwmark_reflect - I didn't
> notice that the code sets ir_mark based on tcp_fwmark_accept, and
> doesn't look at fwmark_reflect at all.
> 

np.

cheers,
jamal
