From: Eric Dumazet <edumazet@google.com>
Subject: Re: [REGRESSION] Warning in tcp_fastretrans_alert() of net/ipv4/tcp_input.c
Date: Fri, 27 Oct 2017 13:38:28 -0700
Message-ID: <CANn89iKm6E6vJ6m81ULFZVoVO3B5-pshB0=wPdvYgbYS+Wg8eQ@mail.gmail.com>
References: <20170921014620.GA20906@castle> <CAK6E8=eBZ6XhRg7ihoQ_2=4bTk1RSdxT2zJ_Z7-4X-HzNeaiQQ@mail.gmail.com>
 <CAK6E8=c3mNnjuWDaA8rjnCjn8mAih=ReQiZwGUgB5X2xrjaRiA@mail.gmail.com>
 <2325466.Xo6SG5M5hd@natalenko.name> <CAK6E8=eju-MgROynJXntRCQ4KtXZ+qrgQC02bGJ27rp1wMmUjg@mail.gmail.com>
 <20171026020724.bgobtktvcpkhco4h@ast-mbp> <CAK6E8=ddfOpvr9wqb+3bo+-pQm2XLXuLhGSQk6xk0Tb8-UvHeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Oleksandr Natalenko <oleksandr@natalenko.name>,
        Roman Gushchin <guro@fb.com>, netdev <netdev@vger.kernel.org>,
        Neal Cardwell <ncardwell@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        Lawrence Brakmo <brakmo@fb.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f178.google.com ([209.85.161.178]:49933 "EHLO
        mail-yw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932103AbdJ0Uia (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 16:38:30 -0400
Received: by mail-yw0-f178.google.com with SMTP id z195so6773833ywz.6
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 13:38:30 -0700 (PDT)
In-Reply-To: <CAK6E8=ddfOpvr9wqb+3bo+-pQm2XLXuLhGSQk6xk0Tb8-UvHeA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 25, 2017 at 10:37 PM, Yuchung Cheng <ycheng@google.com> wrote:
> On Wed, Oct 25, 2017 at 7:07 PM, Alexei Starovoitov
> <alexei.starovoitov@gmail.com> wrote:
>>
>> On Thu, Sep 28, 2017 at 04:36:58PM -0700, Yuchung Cheng wrote:
>> > On Thu, Sep 28, 2017 at 1:14 AM, Oleksandr Natalenko
>> > <oleksandr@natalenko.name> wrote:
>> > > Hi.
>> > >
>> > > Won't tell about panic in tcp_sacktag_walk() since I cannot trigger it
>> > > intentionally, but setting net.ipv4.tcp_retrans_collapse to 0 *does not* fix
>> > > warning in tcp_fastretrans_alert() for me.
>> >
>> > Hi Oleksandr: no retrans_collapse should not matter for that warning
>> > in tcp_fstretrans_alert(). the warning as I explained earlier is
>> > likely false. Neal and I are more concerned the panic in
>> > tcp_sacktag_walk. This is just a blind shot but thx for retrying.
>> >
>> > We can submit a one-liner to remove the fast retrans warning but want
>> > to nail the bigger issue first.
>>
>> we're still seeing the warnings followed by crashes and it's very concerning.
>> We hoped that most recent Neal's patches from Sep 18 around this area may
>> magically fix the issue, but no. The panics are still there.
>> It's confirmed that net.ipv4.tcp_retrans_collapse=0 does not help
>> whereas net.ipv4.tcp_recovery=0 works, but obviously undesirable.
>> We're out of ideas on how to debug this.
> Can you try Eric's latest SACK rb-tree patches?
> https://patchwork.ozlabs.org/cover/822218/
>
> Roman's SNMP data suggests MTU probing is enabled. Another blind shot
> is to disable it.


Or alternatively try this fix :

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 1151870018e345592853b035a0902121c41e268d..6a849c7028f06f31b36a906be37995b28b579a40
100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2062,6 +2062,8 @@ static int tcp_mtu_probe(struct sock *sk)
        nskb->ip_summed = skb->ip_summed;

        tcp_insert_write_queue_before(nskb, skb, sk);
+       if (skb == tp->highest_sack)
+               tp->highest_sack = nskb;

        len = 0;
        tcp_for_write_queue_from_safe(skb, next, sk) {
