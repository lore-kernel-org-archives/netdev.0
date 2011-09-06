From: "Yan, Zheng" <zheng.z.yan@linux.intel.com>
Subject: Re: [PATCH -next v2] unix stream: Fix use-after-free crashes
Date: Wed, 7 Sep 2011 07:09:17 +0800
Message-ID: <CAAM7YAnqLyK6JWPW_Y8wD=ykqWMn4fPdJ3_7yUUB+TQZWfDJzQ@mail.gmail.com>
References: <4E631032.6050606@intel.com>
	<1315326326.2576.2980.camel@schen9-DESK>
	<1315330805.2899.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1315335019.2576.3048.camel@schen9-DESK>
	<1315335660.3400.7.camel@edumazet-laptop>
	<1315337580.2576.3066.camel@schen9-DESK>
	<1315338186.3400.20.camel@edumazet-laptop>
	<1315339157.2576.3079.camel@schen9-DESK>
	<1315340388.3400.28.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tim Chen <tim.c.chen@linux.intel.com>,
	"Yan, Zheng" <zheng.z.yan@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"jirislaby@gmail.com" <jirislaby@gmail.com>,
	"sedat.dilek@gmail.com" <sedat.dilek@gmail.com>, alex.shi@intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:36710 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754868Ab1IFXJS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2011 19:09:18 -0400
Received: by vxi9 with SMTP id 9so275308vxi.19
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2011 16:09:18 -0700 (PDT)
In-Reply-To: <1315340388.3400.28.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 7, 2011 at 4:19 AM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le mardi 06 septembre 2011 =E0 12:59 -0700, Tim Chen a =E9crit :
>> On Tue, 2011-09-06 at 21:43 +0200, Eric Dumazet wrote:
>> > Le mardi 06 septembre 2011 =E0 12:33 -0700, Tim Chen a =E9crit :
>> >
>> > > Yes, I think locking the sendmsg for the entire duration of
>> > > unix_stream_sendmsg makes a lot of sense. =A0It simplifies the l=
ogic a lot
>> > > more. =A0I'll try to cook something up in the next couple of day=
s.
>> >
>> > Thats not really possible, we cant hold a spinlock and call
>> > sock_alloc_send_skb() and/or memcpy_fromiovec(), wich might sleep.
>> >
>> > You would need to prepare the full skb list, then :
>> > - stick the ref on the last skb of the list.
>> >
>> > Transfert the whole skb list in other->sk_receive_queue in one go,
>> > instead of one after another.
>> >
>> > Unfortunately, this would break streaming (big send(), and another
>> > thread doing the receive)
>> >
>> > Listen, I am wondering why hackbench even triggers SCM code. This =
is
>> > really odd. We should not have a _single_ pid/cred ref/unref at al=
l.
>> >
>>
>> Hackbench triggers the code because it has a bunch of threads sendin=
g
>> msgs on UNIX socket.
>> >
>>
>> Well, if the lock socket approach doesn't work, then my original pat=
ch
>> plus Yan Zheng's fix should still work. =A0I'll try to answer your
>> objections below:
>>
>>
>> > I was discussing of things after proposed patch, not current net-n=
ext.
>> >
>> > This reads :
>> >
>> > err =3D unix_scm_to_skb(siocb->scm, skb, !fds_sent, scm_ref);
>> >
>> > So first skb is sent without ref taken, as mentioned in Changelog =
?
>> >
>>
>> No. the first skb is sent *with* ref taken, as scm_ref is set to tru=
e for
>> first skb.
>>
>> >
>> > If second skb cannot be built, we exit this system call with an al=
ready
>> > queued skb. Receiver can then access to freed memory.
>> >
>>
>> No, we do have reference set. =A0For first skb, in unix_scm_to_skb. =
=A0For the
>> second skb (which is the last skb), in scm_sent. =A0Should the secon=
d skb alloc failed,
>> we'll release the ref in scm_destroy. =A0Otherwise, the receiver wil=
l release
>> the references will consuming the skb.
>>
>
> This is crap. This is not the intent of the code I read from the patc=
h.
>
> unless scm_ref really means scm_noref ?
>
> I really hate this patch. I mean it.
>
> I read it 10 times, spent 2 hours and still dont understand it.
>

Sorry, scm_ref means "sender hold a scm reference". I should add commen=
t for it.

>
> @@ -1577,6 +1577,7 @@ static int unix_stream_sendmsg(struct kiocb *ki=
ocb, struct socket *sock,
> =A0 =A0 =A0 =A0int sent =3D 0;
> =A0 =A0 =A0 =A0struct scm_cookie tmp_scm;
> =A0 =A0 =A0 =A0bool fds_sent =3D false;
> + =A0 =A0 =A0 bool scm_ref =3D true;
> =A0 =A0 =A0 =A0int max_level;
>
> =A0 =A0 =A0 =A0if (NULL =3D=3D siocb->scm)
> @@ -1637,12 +1638,15 @@ static int unix_stream_sendmsg(struct kiocb *=
kiocb, struct socket *sock,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0size =3D min_t(int, size, skb_tailroom=
(skb));
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* pass the scm reference to the very l=
ast skb */
>
> HERE: I understand : on the last skb, set scm_ref to false.
> So comment is wrong.
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sent + size >=3D len)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 scm_ref =3D false;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Only send the fds and no ref to pid =
in the first buffer */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D unix_scm_to_skb(siocb->scm, skb=
, !fds_sent, fds_sent);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Only send the fds in the first buffe=
r */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D unix_scm_to_skb(siocb->scm, skb=
, !fds_sent, scm_ref);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (err < 0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kfree_skb(skb);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_err;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
>
>
> As I said, we should revert the buggy patch, and rewrite a performanc=
e
> fix from scratch, with not a single get_pid()/put_pid() in fast path.
>
> read()/write() on AF_UNIX sockets should not use a single
> get_pid()/put_pid().
>
> This is a serious regression we should fix at 100%, not 50% or even 7=
5%,
> adding serious bugs.
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
