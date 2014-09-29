From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH net-next v2 0/5] netns: allow to identify peer netns
Date: Mon, 29 Sep 2014 14:06:38 +0200
Message-ID: <54294B4E.70501@6wind.com>
References: <1411478430-4989-1-git-send-email-nicolas.dichtel@6wind.com>	<87ppei45ig.fsf@x220.int.ebiederm.org>	<CALCETrX5e0cp4QFCv1eAqR1hjoROU9Rh=cRos9U35DaR-py3Eg@mail.gmail.com> <87y4t61a6v.fsf@x220.int.ebiederm.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Linux API <linux-api@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Cong Wang <cwang@twopensource.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87y4t61a6v.fsf@x220.int.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 26/09/2014 20:57, Eric W. Biederman a =C3=A9crit :
> Andy Lutomirski <luto@amacapital.net> writes:
>
>> On Fri, Sep 26, 2014 at 11:10 AM, Eric W. Biederman
>> <ebiederm@xmission.com> wrote:
>>> Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:
>>>
>>>> The goal of this serie is to be able to multicast netlink messages=
 with an
>>>> attribute that identify a peer netns.
>>>> This is needed by the userland to interpret some informations cont=
ained in
>>>> netlink messages (like IFLA_LINK value, but also some other attrib=
utes in case
>>>> of x-netns netdevice (see also
>>>> http://thread.gmane.org/gmane.linux.network/315933/focus=3D316064 =
and
>>>> http://thread.gmane.org/gmane.linux.kernel.containers/28301/focus=3D=
4239)).
>>>
>>> I want say that the problem addressed by patch 3/5 of this series i=
s a
>>> fundamentally valid problem.  We have network objects spanning netw=
ork
>>> namespaces and it would be very nice to be able to talk about them =
in
>>> netlink, and file descriptors are too local and argubably too heavy
>>> weight for netlink quires and especially for netlink broadcast mess=
ages.
>>>
>>> Furthermore the concept of ineternal concept of peernet2id seems va=
lid.
>>>
>>> However what you do not address is a way for CRIU (aka process
>>> migration) to be able to restore these ids after process migration.
>>> Going farther it looks like you are actively breaking process migra=
tion
>>> at this time, making this set of patches a no-go.
Ok, I will look more deeply into CRIU.

>>>
>>> When adding a new form of namespace id CRIU patches are just about
>>> as necessary as iproute patches.
Noted.

>>>
>>>> Ids are stored in the parent user namespace. These ids are valid o=
nly inside
>>>> this user namespace. The user can retrieve these ids via a new net=
link messages,
>>>> but only if peer netns are in the same user namespace.
>>>
>>> That does not describe what you have actually implemented in the
>>> patches.
>>>
>>> I see two ways to go with this.
>>>
>>> - A per network namespace table to that you can store ids for ``pee=
r''
>>>    network namespaces.  The table would need to be populated manual=
ly by
>>>    the likes of ip netns add.
>>>
>>>    That flips the order of assignment and makes this idea solid.
I have a preference for this solution, because it allows to have a full
broadcast messages. When you have a lot of network interfaces (> 10k),
it saves a lot of time to avoid another request to get all informations=
=2E

>>>
>>>    Unfortunately in the case of a fully referencing mesh of N netwo=
rk
>>>    namespaces such a mesh winds up taking O(N^2) space, which seems
>>>    undesirable.
Memory consumption vs performances ;-)
In fact, when you have a lot of netns, you already should have some mem=
ory
available (at least N lo interfaces + N interfaces (veth or a x-netns
interface)). I'm not convinced that this is really an obstacle.

>>>
>>> - Add a netlink attribute that says this network element is in a pe=
er
>>>    network namespace.
>>>
>>>    Add a unicast query message that let's you ask if the remote
>>>    end of a tunnel is in a network namespace specified by file
>>>    descriptor.
>>>
>>> I personally lean towards the second version as it is fundamentally
>>> simpler, and generally scales better, and the visibility controls a=
re
>>> the existing visibility controls.  The only downside is it requires
>>> a query after receiving a netlink broadcast message for the times t=
hat
>>> we care.
>>
>> The downside of that approach, and all the similar kcmp stuff, is th=
at
>> it scales poorly for applications using it.  This is probably not th=
e
>> end of the world, but it's not ideal.
>
> Agreed, the efficiency is not ideal and there is plenty of room for
> optimization.  We could certainly adopt some of kcmps ordering
> infrastructure to make it suck less, or even potentially work out how
> to return a file descriptor to the network namespace in question.
>
> The key insight of my second proposal is that we can get out of the
> broadcast message business, and only care about the remote namespace =
for
> unicast messages.  Putting the work in an infrequently used slow path
> instead of a comparitively common path gives us much more freedom in
> the implementation.
I think it's better to have a full netlink messages, instead a partial =
one.
There is already a lot of attributes added for each rtnl interface mess=
ages to
be sure to describe all parameters of these interfaces.
And if the user don't care about ids (user has not set any id with ipro=
ute2),
we can just add the same attribute with id 0 (let's say it's a reserved=
 id) to
indicate that the link part of this interface is in another netns.

The great benefit of your first proposal is that the ids are set by the
userspace and thus it allows a high flexibility.

Would you accept a patch that implements this first solution?
