From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Weird DHCP related problems with net-next
Date: Wed, 10 Jun 2015 15:04:03 -0700
Message-ID: <5578B453.5080602@gmail.com>
References: <5577367A.50901@gmail.com> <20150609192242.GD16778@lunn.ch> <55774D23.1010508@gmail.com> <557780FF.1080606@gmail.com> <CAE4R7bB_J6eJ2CiLLHUkuhmGMPLA4dmhv_8kZeZjkLz5=tsQBg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Netdev <netdev@vger.kernel.org>,
	Jiri Pirko <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:32792 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752427AbbFJWFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 18:05:09 -0400
Received: by qgfa66 with SMTP id a66so20921778qgf.0
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 15:05:09 -0700 (PDT)
In-Reply-To: <CAE4R7bB_J6eJ2CiLLHUkuhmGMPLA4dmhv_8kZeZjkLz5=tsQBg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/06/15 14:44, Scott Feldman wrote:
> On Tue, Jun 9, 2015 at 5:12 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> 
> 
>> I see the problem now, DSA does not implement a port_obj_add callback,
>> so when net/ipv4/fib_trie.c::switchdev_fib_ipv4_add() gets to call
>> switchdev_port_obj_add, we return -EOPNOTSUPP, and take the error path
>> in fib_table_insert thus not inserting the route for this interface.
> 
> Yup, that's the problem.
> 
>> Now when I restart the DHCP client, we end-up inserting the default
>> route which is correct, still figuring out what is different here,
>> probably the deletion of the routes by the DHCP client script first is
>> the different condition.
> 
> After the first failure, ipv4.fib_offload_disabled is set, so the next
> time switchdev_fib_ipv4_add() just returns 0 and the route is
> installed.  That explains the one-off behavior.
> 
>> At any rate, since switchdev_fib_ipv4_add() returns something that make
>> us take an error path in the fib_trie, something like this seems to fix
>> it for me but I am not well versed enough into the IPv4 routing code to
>> be 100% confident this is the right fix. Also, there are other callers
>> of switchdev_port_obj_add() but a quick look seems to make them safe as
>> they are only called for "offloading" capable hardware.
> 
> Your fix looks good to me.  The other users of
> switchdev_port_obj_add() want to return -EOPNOTSUPP to user, so it's
> just this one case for IPv4 fib insert/del where we'll want to treat
> no support silently.  Are you going to resend as patch for net-next,
> or should I?

I would prefer if you submitted it since you explained how things are
working and now everything makes sense. I will be happy to test it and
provide the magic tags ;)
-- 
Florian
