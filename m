From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH next v5 2/6] bonding: implement bond_poll_controller()
Date: Wed, 18 Feb 2015 21:06:25 -0800
Message-ID: <CAF2d9jhxZZ65mVyV0TcXt=YkKmbe3EKhEkEhx6LT+TA9h_Vt=g@mail.gmail.com>
References: <1424298682-18227-1-git-send-email-maheshb@google.com>
 <54E529E6.609@redhat.com> <CAF2d9jjUg1_SzoCNvTsGq5+UNuWnoreCB8dqk28TLgeT1tsO8w@mail.gmail.com>
 <CAF2d9ji7VqqB95nD=VezL6fAaGJKaHCJRYf+b1VsCCLFy4r7NA@mail.gmail.com> <CANP3RGe7a9hwDB5iUapNvxVS_TD0kkmA3rWJnku=j5tUZ9v6rQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nikolay Aleksandrov <nikolay@redhat.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: =?ISO-8859-2?Q?Maciej_=AFenczykowski?= <maze@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:44228 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740AbbBSFGq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 00:06:46 -0500
Received: by mail-ob0-f178.google.com with SMTP id uz6so10576847obc.9
        for <netdev@vger.kernel.org>; Wed, 18 Feb 2015 21:06:46 -0800 (PST)
In-Reply-To: <CANP3RGe7a9hwDB5iUapNvxVS_TD0kkmA3rWJnku=j5tUZ9v6rQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 18, 2015 at 6:26 PM, Maciej =C5=BBenczykowski <maze@google.=
com> wrote:
>>>> Hi Mahesh,
>>>> I should've explained more in my review, you cannot sleep in
>>>> bond_poll_controller() so you cannot acquire rtnl like that. I was=
 thinking
>>>> more about using rcu and switching to the _rcu version of
>>>> bond_for_each_slave instead.
>>>>
>>> That makes sense. The path that triggered this netpoll() could have
>>> been holding the rtnl  itself and this would be a problem. I think
>>> using the _rcu variant of the slave iterator is a good idea, my bad=
!
>>>
>> ... however we cannot use the _rcu variant either since there is the
>> netpoll mutex (ni->dev_lock)!
>> The fact that we are here itself means that something bad had happen=
ed
>> and trying to take additional lock(s) would complicate the situation
>> further.
>
> I think you might be incorrectly assuming that we only get here on
> kernel crashes,
> upstream (netconsole) [may] violate[s] this assumption.
>
> (background: internally we don't consider netconsole production
> worthy, but we do
> 'abuse' the netpoll support framework to generate a minimal network
> dump on kernel crash,
> in which case if we crash or otherwise violate assumptions while
> crashing, we're not any worse off...)
>
I think irrespective of how we use it, there are few contradictory thin=
gs here -
(a) If it can't sleep in netpoll() (which I agree with) then that
netpoll mutex does not make sense. But if it can then rtnl isn't a
wrong thing.
(b) If the netpoll mutex is right then slaves can not be iterated with
rcu protection.
(c) If we takeout the netpoll-mutex, then everything seems right but
can we really do that?

I'll take this patch out of this series for the time being and let
other patches proceed while I think about this patch some more.

--mahesh..

> - Maciej
