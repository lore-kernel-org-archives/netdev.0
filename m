From: Alessandro Suardi <alessandro.suardi@gmail.com>
Subject: Re: inbound connection problems when "netlink: test for all flags of
 the NLM_F_DUMP composite" commit applied
Date: Tue, 18 Jan 2011 20:26:42 +0100
Message-ID: <AANLkTi=00FRr08NjeMLN75U_N-cb9F78=E26LmMY7-uV@mail.gmail.com>
References: <20110118172340.GB1843@del.dom.local>
	<AANLkTikUPRfYupw1-Py5mHeN+pFv-zMKhmK3DKixxsH4@mail.gmail.com>
	<alpine.LNX.2.01.1101181921320.17010@obet.zrqbmnf.qr>
	<20110118182852.GC4202@del.dom.local>
	<20110118184730.GD4202@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Engelhardt <jengelh@medozas.de>, jamal <hadi@cyberus.ca>,
	David Miller <davem@davemloft.net>, pablo@netfilter.org,
	arthur.marsh@internode.on.net, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:59095 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752572Ab1ART0n convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 14:26:43 -0500
Received: by qyj19 with SMTP id 19so3553180qyj.19
        for <netdev@vger.kernel.org>; Tue, 18 Jan 2011 11:26:42 -0800 (PST)
In-Reply-To: <20110118184730.GD4202@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 18, 2011 at 7:47 PM, Jarek Poplawski <jarkao2@gmail.com> wr=
ote:
> On Tue, Jan 18, 2011 at 07:28:52PM +0100, Jarek Poplawski wrote:
>> On Tue, Jan 18, 2011 at 07:24:40PM +0100, Jan Engelhardt wrote:
>> >
>> > On Tuesday 2011-01-18 19:10, Alessandro Suardi wrote:
>> > >On Tue, Jan 18, 2011 at 6:23 PM, Jarek Poplawski <jarkao2@gmail.c=
om> wrote:
>> > >>
>> > >> NLM_F_DUMP flags should be applied to GET requests only, eg. rt=
netlink
>> > >> tests message type to verify this. Since genetlink can't do the=
 same
>> > >> use "practical" test for ops->dumpit (assuming NEW request won'=
t be
>> > >> mixed with GET).
>> ...
>> > >2.6.37-git18 + netlink revert + this patch
>> > > - fixes Avahi
>> > > - breaks acpid
>> > >Starting acpi daemon: RTNETLINK1 answers: Operation not supported
>> > >acpid: error talking to the kernel via netlink
>> >
>> > Deducing from that, it is a GET-like request that was sent by acpi=
d,
>> > and the message type is one that has both a dumpit and a doit func=
tion.
>> > So if EOPNOTSUPP now occurs on all message types that have both du=
mpit
>> > and doit, you should have broken a lot more than just acpid.
>>
>> Right, we need something better here.
>
> On the other hand, until there is something better, we might try to
> fix it at least for "normal" dumpit cases?
>
> Alessandro, could you try (with the netlink revert)?
>
> Thanks,
> Jarek P.
>
> ---
> diff -Nurp a/net/netlink/genetlink.c b/net/netlink/genetlink.c
> --- a/net/netlink/genetlink.c =A0 2011-01-18 16:58:16.000000000 +0100
> +++ b/net/netlink/genetlink.c =A0 2011-01-18 19:36:25.000000000 +0100
> @@ -519,15 +519,14 @@ static int genl_rcv_msg(struct sk_buff *
> =A0 =A0 =A0 =A0 =A0 =A0security_netlink_recv(skb, CAP_NET_ADMIN))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EPERM;
>
> - =A0 =A0 =A0 if (nlh->nlmsg_flags & NLM_F_DUMP) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ops->dumpit =3D=3D NULL)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EOPNOTSUPP;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 genl_unlock();
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D netlink_dump_start(net->genl_so=
ck, skb, nlh,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0ops->dumpit, ops->done);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 genl_lock();
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
> + =A0 =A0 =A0 if (ops->dumpit) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nlh->nlmsg_flags & NLM_F_DUMP) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 genl_unlock();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D netlink_dump_st=
art(net->genl_sock, skb, nlh,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0ops->dumpit, ops->done);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 genl_lock();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0if (ops->doit =3D=3D NULL)
>

Sure enough :)


2.6.37-git18 + netlink revert + this 2nd attempt

 appears to be good for me - both Avahi and acpid start up fine and I
 can't see any other program misbehaving.


Thanks, ciao,

--alessandro

=A0"There's always a siren singing you to shipwreck"

=A0=A0 (Radiohead, "There There")
