From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: qdisc spin lock
Date: Thu, 31 Mar 2016 20:44:05 -0700
Message-ID: <56FDEE85.3020505@gmail.com>
References: <CAAmHdhw9bQkCm7uehRZ9mTetMzafdXxWhYj16f8W-YvSz8V4=g@mail.gmail.com>
 <CAM_iQpVSHqLcGjrErAsh54+iD8uwGH5QNGwiJVOQOTsk=dwDbw@mail.gmail.com>
 <CAAmHdhxagKnLP1_5ZW7HTsVBu0TSFYKCvNstAEWN-NHrdnvvVQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Michael Ma <make0818@gmail.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33721 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751717AbcDADoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 23:44:20 -0400
Received: by mail-pf0-f181.google.com with SMTP id 4so84528392pfd.0
        for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 20:44:19 -0700 (PDT)
In-Reply-To: <CAAmHdhxagKnLP1_5ZW7HTsVBu0TSFYKCvNstAEWN-NHrdnvvVQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-03-31 04:48 PM, Michael Ma wrote:
> I didn't really know that multiple qdiscs can be isolated using MQ so
> that each txq can be associated with a particular qdisc. Also we don'=
t
> really have multiple interfaces...

MQ will assign a default qdisc to each txq and the default qdisc can
be changed to htb or any other qdisc of your choice.

>=20
> With this MQ solution we'll still need to assign transmit queues to
> different classes by doing some math on the bandwidth limit if I
> understand correctly, which seems to be less convenient compared with
> a solution purely within HTB.
>=20

Agreed.

> I assume that with this solution I can still share qdisc among
> multiple transmit queues - please let me know if this is not the case=
=2E

Nope sorry doesn't work that way unless you employ some sort of stacked
netdevice strategy which does start to get a bit complex. The basic hin=
t
would be to stack some type of virtual netdev on top of a device and
run the htb qdisc there. Push traffic onto the netdev depending on the
class it belongs to. Its ugly yes.

Noting all that I posted an RFC patch some time back to allow writing
qdiscs that do not require taking the lock. I'll try to respin these
and submit them when net-next opens again. The next logical step is to
write a "better" HTB probably using a shared counter and dropping the
requirement that it be exact.

Sorry I didn't get a chance to look at the paper in your post so not
sure if they suggest something similar or not.

Thanks,
John

>=20
> 2016-03-31 15:16 GMT-07:00 Cong Wang <xiyou.wangcong@gmail.com>:
>> On Wed, Mar 30, 2016 at 12:20 AM, Michael Ma <make0818@gmail.com> wr=
ote:
>>> As far as I understand the design of TC is to simplify locking sche=
ma
>>> and minimize the work in __qdisc_run so that throughput won=E2=80=99=
t be
>>> affected, especially with large packets. However if the scenario is
>>> that multiple classes in the queueing discipline only have the shap=
ing
>>> limit, there isn=E2=80=99t really a necessary correlation between d=
ifferent
>>> classes. The only synchronization point should be when the packet i=
s
>>> dequeued from the qdisc queue and enqueued to the transmit queue of
>>> the device. My question is =E2=80=93 is it worth investing on avoid=
ing the
>>> locking contention by partitioning the queue/lock so that this
>>> scenario is addressed with relatively smaller latency?
>>
>> If your HTB classes don't share bandwidth, why do you still make the=
m
>> under the same hierarchy? IOW, you can just isolate them either with=
 some
>> other qdisc or just separated interfaces.
