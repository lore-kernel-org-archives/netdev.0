From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net] sctp: fix race on protocol/netns initialization
Date: Thu, 10 Sep 2015 11:22:59 -0300
Message-ID: <55F19243.3010006@gmail.com>
References: <27f20cc781cac28bc2ce7229719748a2f6824bd8.1441827818.git.marcelo.leitner@gmail.com>
 <55F096EB.7000204@gmail.com> <55F09F57.6080602@gmail.com>
 <55F1847A.9010801@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>, linux-sctp@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:33456 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751765AbbIJOXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 10:23:06 -0400
In-Reply-To: <55F1847A.9010801@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em 10-09-2015 10:24, Vlad Yasevich escreveu:
> On 09/09/2015 05:06 PM, Marcelo Ricardo Leitner wrote:
>> Em 09-09-2015 17:30, Vlad Yasevich escreveu:
>>> On 09/09/2015 04:03 PM, Marcelo Ricardo Leitner wrote:
>>>> Consider sctp module is unloaded and is being requested because an user
>>>> is creating a sctp socket.
>>>>
>>>> During initialization, sctp will add the new protocol type and then
>>>> initialize pernet subsys:
>>>>
>>>>           status = sctp_v4_protosw_init();
>>>>           if (status)
>>>>                   goto err_protosw_init;
>>>>
>>>>           status = sctp_v6_protosw_init();
>>>>           if (status)
>>>>                   goto err_v6_protosw_init;
>>>>
>>>>           status = register_pernet_subsys(&sctp_net_ops);
>>>>
>>>> The problem is that after those calls to sctp_v{4,6}_protosw_init(), it
>>>> is possible for userspace to create SCTP sockets like if the module is
>>>> already fully loaded. If that happens, one of the possible effects is
>>>> that we will have readers for net->sctp.local_addr_list list earlier
>>>> than expected and sctp_net_init() does not take precautions while
>>>> dealing with that list, leading to a potential panic but not limited to
>>>> that, as sctp_sock_init() will copy a bunch of blank/partially
>>>> initialized values from net->sctp.
>>>>
>>>> The race happens like this:
>>>>
>>>>        CPU 0                           |  CPU 1
>>>>     socket()                           |
>>>>      __sock_create                     | socket()
>>>>       inet_create                      |  __sock_create
>>>>        list_for_each_entry_rcu(        |
>>>>           answer, &inetsw[sock->type], |
>>>>           list) {                      |   inet_create
>>>>         /* no hits */                  |
>>>>        if (unlikely(err)) {            |
>>>>         ...                            |
>>>>         request_module()               |
>>>>         /* socket creation is blocked  |
>>>>          * the module is fully loaded  |
>>>>          */                            |
>>>>          sctp_init                     |
>>>>           sctp_v4_protosw_init         |
>>>>            inet_register_protosw       |
>>>>             list_add_rcu(&p->list,     |
>>>>                          last_perm);   |
>>>>                                        |  list_for_each_entry_rcu(
>>>>                                        |     answer, &inetsw[sock->type],
>>>>           sctp_v6_protosw_init         |     list) {
>>>>                                        |     /* hit, so assumes protocol
>>>>                                        |      * is already loaded
>>>>                                        |      */
>>>>                                        |  /* socket creation continues
>>>>                                        |   * before netns is initialized
>>>>                                        |   */
>>>>           register_pernet_subsys       |
>>>>
>>>> Inverting the initialization order between register_pernet_subsys() and
>>>> sctp_v4_protosw_init() is not possible because register_pernet_subsys()
>>>> will create a control sctp socket, so the protocol must be already
>>>> visible by then. Deferring the socket creation to a work-queue is not
>>>> good specially because we loose the ability to handle its errors.
>>>>
>>>> So the fix then is to invert the initialization order inside
>>>> register_pernet_subsys() so that the control socket is created by last
>>>> and also block socket creation if netns initialization wasn't yet
>>>> performed.
>>>>
>>>
>>> not sure how much I like that...  Wouldn't it be better
>>> to pull the control socket initialization stuff out into its
>>> own function that does something like
>>>
>>> for_each_net_rcu()
>>>      init_control_socket(net, ...)
>>>
>>>
>>> Or may be even pull the control socket creation
>>> stuff completely into its own per-net ops operations structure
>>> and initialize it after the the protosw stuff has been done.
>>>
>>> -vlad
>>
>> I'm afraid error handling won't be easy then.
>>
>> But still, the control socket is not really the problem, because we don't care (much?) if
>> it contains zeroed values and the panic happens only if you call connect() on it. I moved
>> it solely because of the protection on sctp_init_sock().
>>
>> The real problem is new sockets created by an user application while module is still
>> loading, because even if them don't trigger the panic, they may not be fully functional
>> due to improper values loaded. Can't see other good ways to protect sctp_init_sock() from
>> that early call (as in, prior to netns initialization).
>
> Right, I understand what the problem really is.  Like you said, the simple fix is to
> reorder the sctp defaults initialization with protosw registration.  However, that's
> not possible because control socket is created in the sctp defaults initialization code
> and needs protosw to be registered (chicken and egg issue).

Yes, same page then, cool.

> What I am saying is that it is kind of strange to create control socket during protocol
> default initialization.  The control socket has nothing  really to do with defaults.  So,
> we could pull it out of the defaults initialization (sctp_net_init()) code and into its
> own initialization path.

I don't really see sctp_net_init() as a pure defaults initialization 
routine. It's the callback for new netns's, so it should initialize 
anything needed for a new netns, no?

> Then you can order sctp_net_init() such that it happens first, then protosw registration
> happens, then control socket initialization happens, then inet protocol registration happens.
>
> This way, we are always guaranteed that by the time user calls socket(), protocol
> defaults are fully initialized.

Okay, that works for module loading stage, but then how would we handle 
new netns's? We have to create the control socket per netns and AFAICT 
sctp_net_init() is the only hook called when a new netns is being created.

Then if we move it a workqueue that is scheduled by sctp_net_init(), we 
loose the ability to handle its errors by propagating through 
sctp_net_init() return value, not good.

>> I used the list pointer because that's null as that memory is entirely zeroed when alloced
>> and, after initialization, it's never null again. Works like a lock/condition without
>> using an extra field.
>>
>
> I understand this a well.  What I don't particularly like is that we are re-using
> a list without really stating why it's now done this way.  Additionally, it's not really
> the last that happens so it's seems kind of hacky...  If we need to add new
> per-net initializers, we now need to make sure that the code is put in the right
> place.  I'd just really like to have a cleaner solution...

Ok, got you. We could add a dedicated flag/bit for that then, if reusing 
the list is not clear enough. Or, as we are discussing on the other part 
of thread, we could make it block and wait for the initialization, 
probably using some wait_queue. I'm still thinking on something this 
way, likely something more below than sctp then.

Thanks,
Marcelo
