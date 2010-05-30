From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v2] act_nat: fix the wrong checksum when addr isn't in
	old_addr/mask
Date: Sun, 30 May 2010 21:33:22 +0800
Message-ID: <AANLkTinDe-AluGZx87q3nvxCfushfeH0jS35Fav95IXk@mail.gmail.com>
References: <1275179219-10424-1-git-send-email-xiaosuo@gmail.com>
	<1275223421.3587.0.camel@bigi> <20100530125811.GA8120@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jamal <hadi@cyberus.ca>, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:54104 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753831Ab0E3Ndm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 May 2010 09:33:42 -0400
Received: by pwj2 with SMTP id 2so376270pwj.19
        for <netdev@vger.kernel.org>; Sun, 30 May 2010 06:33:42 -0700 (PDT)
In-Reply-To: <20100530125811.GA8120@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 30, 2010 at 8:58 PM, Herbert Xu <herbert@gondor.apana.org.a=
u> wrote:
> On Sun, May 30, 2010 at 08:43:41AM -0400, jamal wrote:
>>
>> Copying Herbert, taking linux-kernel off...
>
> Thanks Jamal.
>
>> On Sun, 2010-05-30 at 08:26 +0800, Changli Gao wrote:
>> > fix the wrong checksum when addr isn't in old_addr/mask
>> >
>> > For TCP and UDP packets, when addr isn't in old_addr/mask we don't=
 do SNAT or
>> > DNAT, and we should not update layer 4 checksum.
>> >
>> > Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>> > ----
>> > =A0net/sched/act_nat.c | =A0 =A04 ++++
>> > =A01 file changed, 4 insertions(+)
>> > diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
>> > index d885ba3..5709494 100644
>> > --- a/net/sched/act_nat.c
>> > +++ b/net/sched/act_nat.c
>> > @@ -159,6 +159,9 @@ static int tcf_nat(struct sk_buff *skb, struct=
 tc_action *a,
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 iph->daddr =3D new_addr;
>> >
>> > =A0 =A0 =A0 =A0 =A0 =A0 csum_replace4(&iph->check, addr, new_addr)=
;
>> > + =A0 } else if ((iph->frag_off & htons(IP_OFFSET)) ||
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0iph->protocol !=3D IPPROTO_ICMP) {
>> > + =A0 =A0 =A0 =A0 =A0 goto out;
>> > =A0 =A0 }
>
> Yes the patch is correct.
>
> However, the fact that you need this patch means that your act_nat
> setup isn't perfect. =A0Ideally all the unNATed packets should be
> filtered out before you hit act_nat.

Thinking about this topologic:

client -> DNAT -> router -> server.

DNAT is used to map a public IP to server's private IP. If a
DEST_UNREACH ICMP packet is sent out by router, in order to handle
this ICMP packet correctly, I have to pass it to act_nat.c. How can I
filter out the other packets? By inspecting the inner IP destination
address of this ICMP packet? Maybe I can use u32 with complicate
parameters.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
