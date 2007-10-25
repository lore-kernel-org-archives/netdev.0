From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [NETNS] Oops in register_pernet_operations() with CONFIG_NET_NS=n
Date: Thu, 25 Oct 2007 11:21:55 -0600
Message-ID: <m1bqan5cuk.fsf@ebiederm.dsl.xmission.com>
References: <47209317.8000802@bull.net> <4720A181.3060003@sw.ru>
	<4720AD20.5030902@bull.net> <m17ilb6xs9.fsf@ebiederm.dsl.xmission.com>
	<4720B1EE.8050507@bull.net> <m1y7dr5esy.fsf@ebiederm.dsl.xmission.com>
	<4720C9B9.80706@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Thery <benjamin.thery@bull.net>,
	Pavel Emelianov <xemul@openvz.org>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Cedric Le Goater <clg@fr.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: "Denis V. Lunev" <dlunev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:54110 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760898AbXJYRXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2007 13:23:40 -0400
In-Reply-To: <4720C9B9.80706@gmail.com> (Denis V. Lunev's message of "Thu, 25
	Oct 2007 20:52:09 +0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Denis V. Lunev" <dlunev@gmail.com> writes:

> Eric W. Biederman wrote:
>> Benjamin Thery <benjamin.thery@bull.net> writes:
>> 
>>> Eric W. Biederman wrote:
>>>> Benjamin Thery <benjamin.thery@bull.net> writes:
>>>>
>>>>> Denis V. Lunev wrote:
>>>>>> The patch attached should help. The idea is simple. The "init" should be
>>>>>> called only once without NETNS. Period. No need for any lists.
>>>>> This is the kind of idea I had but I didn't think it could be 
>>>>> that simple. :) 
>>>>> Thanks Denis.
>>>> It isn't.
>
> this will work due to INIT_LIST_HEAD with circles list to itself and a
> del operation will work.

Suppose I have this fragment of code in a module:

> static int __net_init xt_net_init(struct net *net)
> {
>         ...
> }
> 
> static void __net_exit xt_net_exit(struct net *net)
> {
>         ...
> }
> 
> static struct pernet_operations __net_initdata  xt_net_ops = {
> 	.init = xt_net_init,
> 	.exit = xt_net_exit,
> };
> 
> static int __init xt_init(void)
> {
> 	return register_pernet_subsys(&xt_net_ops);
> }
> 
> static void __exit xt_fini(void)
> {
> 	unregister_pernet_subsys(&xt_net_ops);
> }
> 
> module_init(xt_init);
> module_exit(xt_fini);

What happens during module removal when unregister_pernet_subys calls 
xt_net_ops.exit after xt_net_ops has been removed from the kernels
memory?


> By the way, I think that we can in the case of undefined CONFIG_NET_NS
> reduce register to calling ->init method and unregister to calling
> ->exit method.
>
> This is a correct thing at least for now and will be welcomed by the all
> embedded/etc people.

I'm not fundamentally opposed.  Earlier versions of my patchset
did that and more.   However I think the pain is greater then the
gain right now.  Especially since this concept seem to require
having quality inspected into it.

Eric
