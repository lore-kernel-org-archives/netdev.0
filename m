From: Josef Bacik <jbacik@fb.com>
Subject: Re: Soft lockup in inet_put_port on 4.6
Date: Tue, 20 Dec 2016 04:59:22 +0000
Message-ID: <067589C4-361F-49FE-B493-83BC0EC38277@fb.com>
References: <1481928610.17731.0@smtp.office365.com>
         <e32b5375-38fb-1fd8-d97a-bf740e368205@stressinduktion.org>
         <286A21B1-2A15-4DDF-B334-A016DA3D52EA@fb.com>
         <20161219.205646.1955469060856026212.davem@davemloft.net>
         <CALx6S340vCsaymbx+CcKL3Zi2p9EvDSwc0fDAxKsSqs4C2p5kg@mail.gmail.com>
        ,<1482201702.1521.13.camel@edumazet-glaptop3.roam.corp.google.com>
         <9DF94C8E-1463-4C10-81E3-E6F4534097CB@fb.com>,<1482209536.1521.21.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Tom Herbert <tom@herbertland.com>,
        David Miller <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Craig Gallek <kraigatgoog@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:55718 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751734AbcLTE7b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2016 23:59:31 -0500
In-Reply-To: <1482209536.1521.21.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Dec 19, 2016, at 11:52 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote=
:
>=20
> On Tue, 2016-12-20 at 03:40 +0000, Josef Bacik wrote:
>>> On Dec 19, 2016, at 9:42 PM, Eric Dumazet <eric.dumazet@gmail.com> wrot=
e:
>>>=20
>>>> On Mon, 2016-12-19 at 18:07 -0800, Tom Herbert wrote:
>>>>=20
>>>> When sockets created SO_REUSEPORT move to TW state they are placed
>>>> back on the the tb->owners. fastreuse port is no longer set so we have
>>>> to walk potential long list of sockets in tb->owners to open a new
>>>> listener socket. I imagine this is happens when we try to open a new
>>>> listener SO_REUSEPORT after the system has been running a while and so
>>>> we hit the long tb->owners list.
>>>=20
>>> Hmm...  __inet_twsk_hashdance() does not change tb->fastreuse
>>>=20
>>> So where tb->fastreuse is cleared ?
>>>=20
>>> If all your sockets have SO_REUSEPORT set, this should not happen.
>>>=20
>>=20
>> The app starts out with no SO_REUSEPORT, and then we restart it with
>> that option enabled.
>=20
> But... why would the application do this dance ?
>=20
> I now better understand why we never had these issues...
>=20

It doesn't do it as a part of it's normal operation.  The old version didn'=
t use SO_REUSEPORT and then somebody added support for it, restarted the se=
rvice with the new option enabled and boom.  They immediately stopped doing=
 anything and gave it to me to figure out.

>=20
>>  What I suspect is we have all the twsks from the original service,
>> and the fastreuse stuff is cleared.  My naive patch resets it once we
>> add a reuseport sk to the tb and that makes the problem go away.  I'm
>> reworking all of this logic and adding some extra info to the tb to
>> make the reset actually safe.  I'll send those patches out tomorrow.
>> Thanks,
>=20
> Okay, we will review them ;)
>=20
> Note that Willy Tarreau wants some mechanism to be able to freeze a
> listener, to allow haproxy to be replaced without closing any sessions.
>=20

I assume that's what these guys would want as well.  They have some weird h=
andoff thing they do when the app starts but I'm not entirely convinced it =
does what they think it does.  Thanks,

Josef=
