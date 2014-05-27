From: sowmini varadhan <sowmini05@gmail.com>
Subject: Scaling 'ip addr add' (was Re: What's the right way to use a *large*
 number of source addresses?)
Date: Tue, 27 May 2014 17:29:00 -0400
Message-ID: <CACP96tRSpop=Sf58qE6TXeF+a-5nqfCj5d12bwD9WaYue_6_UA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?Q?Niels_M=C3=B6ller?= <nisse@southpole.se>,
	netdev <netdev@vger.kernel.org>, Jonas Bonn <jonas@southpole.se>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:34792 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751466AbaE0V3B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 17:29:01 -0400
Received: by mail-la0-f48.google.com with SMTP id mc6so6898078lab.35
        for <netdev@vger.kernel.org>; Tue, 27 May 2014 14:29:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 24, 2014 at 8:06 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 05/23/14 10:14, Eric Dumazet wrote:
>
>> Use the batch mode, and it will be much faster than ifconfig, as
>> ifconfig does not support this mode (you need one fork()/exec() per IP
>> address)
>>
>> ip -batch filename
>>
>
> The address dumping algorithm is a very likely contributor as well.
> It tries to remember indices and then skips on the next iteration
> all the way to where it left off.... has never been a big deal until
> someone tries a substantial number of addresses.
>
> cheers,
> jamal

Niels (nisse@southpole.se) reported:

   I've done a simple benchmark with a script assigning n addresses
   using "ip address add", and this seems to have O(n^2) complexity.
   E.g, assigning n=25500 addresses took 26 s, and doubling n, assigning
   51000 addresses, took 122 s, 4.6 times longer. Which isn't
   necessarily a problems once all the addresses are assigned, but it
   sounds a bit like there's a linear datastructure in there, not
   intended for a large number of addresses.

And this bothered me, since the suggested workaround of
"ip -b", plus the comment about slow address dumping algorithm
are both saying that there may be some fundamental scaling
issues here.

Also, my earlier comment about netlink vs ioctl was possibly
a red-herring- when I compared my experiment with what Niels is
trying to do, the experiment was different- I was adding
an address to a (newly created) tunnel interface (thus
explodes both number of interfaces and addresses), whereas
Niels is addign all addresses to the same interface.

So I looked at Niels' test script with perf. Some observations:

perf tells me:

   80.13%       ip  [other]
                 |
                 |--30.12%-- fib_sync_up
                 |          |
                 |           --30.12%-- fib_inetaddr_event
                 |                     notifier_call_chain
                 |                     __blocking_notifier_call_chain
                 |                     blocking_notifier_call_chain
                 |                     __inet_insert_ifa
                 |                     inet_rtm_newaddr
                 |                     rtnetlink_rcv_msg
                 |                     netlink_rcv_skb
                 |                     rtnetlink_rcv
                 |                     netlink_unicast
                 |                     netlink_sendmsg
                 |                     sock_sendmsg
                 |                     ___sys_sendmsg
                 |                     __sys_sendmsg
                 |                     SyS_sendmsg
                 |                     SyS_socketcall
                 |                     syscall_call

thus fib_sync_up() itself doesn't scale very well. Not sure
how much tweak-potential exists here.

Further, in __inet_insert_ifa, we walk the ifa_list at least once
(which is probably unavoidable),

static int __inet_insert_ifa( /* .. */
                             u32 portid)
{

        /* ... */
       for (ifap = &in_dev->ifa_list; (ifa1 = *ifap) != NULL;
             ifap = &ifa1->ifa_next) {
        /* ... */
       blocking_notifier_call_chain(&inetaddr_chain, NETDEV_UP, ifa);

       return (0);
}

But in addition, The fib callback: fib_inetaddr_event() has another
potential ifa_list walk for SECONDARY addresses.

        switch (event) {
        case NETDEV_UP:
                fib_add_ifaddr(ifa);
#ifdef CONFIG_IP_ROUTE_MULTIPATH
                fib_sync_up(dev);
#endif

For Niels script, since there are many addresses in the same
subnet, we'll have a lot of cases of an IFA_F_SECONDARY address,
so fib_add_ifaddr will then do another walk of the ifa_list.

Has anyone looked at consolidating some of this?
All of this could easily become a factor when the system
has a large number of interfaces and addresses, and the
control plane only wants to modify a very small subset of
that state.

--Sowmini
