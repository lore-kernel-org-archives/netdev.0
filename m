From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Race condition in ipv6 code
Date: Thu, 12 Jan 2012 23:40:52 -0800
Message-ID: <m1ipkgqccb.fsf@fess.ebiederm.org>
References: <CA+HUmGhJ-YvFMRnKzb8RqH6COZ=erp1SajVcb1rq1vi2k9OBGw@mail.gmail.com>
	<1326349911.2741.1.camel@edumazet-laptop>
	<m1pqeov4u1.fsf@fess.ebiederm.org>
	<1326434549.2617.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francesco Ruggeri <fruggeri@aristanetworks.com>,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:43234 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752151Ab2AMHib convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 02:38:31 -0500
In-Reply-To: <1326434549.2617.14.camel@edumazet-laptop> (Eric Dumazet's
	message of "Fri, 13 Jan 2012 07:02:29 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> Le jeudi 12 janvier 2012 =C3=A0 16:11 -0800, Eric W. Biederman a =C3=A9=
crit :
>
>> Because the rtnl_lock is broad and we have ABBA deadlocks if we don'=
t in
>> particular we hold the rtnl_lock over sysctl registration and remova=
l.
>> sysctl removal blocks until all of the callers into the sysctl metho=
ds
>> namely addrconf_sysctl_forward in this case finish executing.
>>=20
>> CPU 0                                         CPU 1
>>=20
>> rtnl_lock()                                   use_count++
>> unregister_netdevice()                           addrconf_ctl_foward
>>   unregister_sysctl_table()                        rtnl_lock()
>>      wait for use_count of addrconf_ctl_forward
>>        to =3D=3D 0
>>     =20
>>=20
>> I smacked lockdep around so it would warn about the sysfs ones.
>> The proc and sysctl ones I never did manage to get lockdep warnings
>> but a ABBA deadlock is most definitely possible.
>>=20
>> Any solutions better than simply restarting the system call are welc=
ome.
>>=20
>> Perhaps for these heavy weigh methods we should create a work struct
>> and go schedule work to perform the change instead of trying to do t=
he
>> work synchronously in the sysctl handler.
>>=20
>
> This idea was discussed in netconf 2011 (I focused on the ability to
> dismantle netdevices at high rates), and I admit I had not implemente=
d
> yet.

Interesting.  That is a discussion I would have been interested to be
a part of.

In my queue I have sysctl cleanup and speed improvements I should be
posting them for review in the next week or two.

That leaves /proc/net/dev_snmp6/.... as the scalability bottleneck for
the number of network devices.

I have gotten the rcu_barrier in device unregister out from under the
trylock.

At a practical level the rcu_barrier seems to be the primary bottleneck
to remove netdevices at a high rate, although I am certain there are
other issues that crop up.  If I go with a networking path that can
batch network devices, and am not bottlenecked by proc, sysfs or sysctl
I can remove 10,000 or so network devices a second.

I have been scratching my head trying to figure out if it is possible
to batch network device deletes that come in via a netlink DELLINK mess=
age.

> The problem with rtnl_trylock() is that we make very litle progress i=
f
> many tasks are competing for rtnl, and we have no fairness.

Yes.  That code path uses rtnl_trylock() simply because I needed a
simple and correct fix.  It was never intended to be the long term
solution, but rather a stop gap to at least remove the possibility of
deadlock in the kernel.  It is deployed fairly widely because I found
a lot of examples of that bug.

> The task holding RTNL might be descheduled and all cpus running other
> threads spinning in rtnl_trylock()/restart_syscall(). Almost a deadlo=
ck.
>
> Maybe waiting RTNL for at least a couple of ms would help, instead of
> instantly failing rtnl_trylock() and looping.

Yes.  If the rtnl_trylock and syscall_restart looping is a problem
we should use a lock other than the rtnl_lock for those variables
or we should use a work queue and take the rtnl_lock in a context
where we don't need the try lock.

I don't think there is much point in getting sophisticated about
rtnl_trylock().  It was a good stopgap but we really should remove
the ABBA deadlock.

As for Stephen Hemminger's suggestion to make a: proc_do_intvec_and_rtn=
l_lock
function.  We could make a helper that does what Francesco did but in a
slightly nicer fashion.  What we can't do is make a version that does
not have the ABBA deadlock, which makes the nasty rtnl_trylock feasible=
=2E
Given that we still would have the nasty effects of the rtnl_trylock an=
d
syscall_restart idiom I don't expect creating a helper and encouraging
people to build code that is going to need that logic is a particularly
good idea.

The other option is to look at dropping the rtnl_lock in addrconf_ifdow=
n
around the addrconf_sysctl_unregister call.  It doesn't seem obvious to
me that we can.

I just thought through the sysctl case just to be certain that we can't
take the locks in the other order, and I just don't see a way to do it.
The problem is that the use tracking guarantees that none of the user
supplied data is being used and it is safe to remove a module.  If the
lock comes from the module kaboom.

Hmm.  I partially take back my conclusion that I can't fix the problem
at the sysctl level.  If we want to take rtnl_lock for every
networking sysctl I think I could enhance the ctl_table_set or the
ctl_table_root concept to have a mutex we could take over every
networking sysctl.  With copy_from_user being in the middle of that
I'm not particularly fond of that idea.  Nor am I fond of taking
the rtnl_mutex in even more situations than we take it now.  Plus it
seems like more deep magic that will confuse people.

So I really think the best solution to avoid the locking craziness is t=
o
have a wrapper that gets the value from userspace and calls
schedule_work to get another thread to actually process the change.  I
don't see any problems with writing a helper function for that.  The
only downside with using schedule_work is that we return to userspace
before the change has been fully installed in the kernel.  I don't
expect that would be a problem but stranger things have happened.

Eric
