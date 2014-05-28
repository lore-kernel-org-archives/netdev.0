From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Scaling 'ip addr add' (was Re: What's the right way to use a
 *large* number of source addresses?)
Date: Wed, 28 May 2014 07:48:53 -0700
Message-ID: <1401288533.5367.271.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CACP96tRSpop=Sf58qE6TXeF+a-5nqfCj5d12bwD9WaYue_6_UA@mail.gmail.com>
	 <1401241268.5367.266.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CACP96tRBiANHxXSFZ_w7eKwO_zWk_AZv-7CDJFLSP6+bZJLZ5g@mail.gmail.com>
	 <1401284699.5367.268.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Niels =?ISO-8859-1?Q?M=F6ller?= <nisse@southpole.se>,
	netdev <netdev@vger.kernel.org>, Jonas Bonn <jonas@southpole.se>,
	Jiri Pirko <jiri@resnulli.us>
To: sowmini varadhan <sowmini05@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:60112 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752356AbaE1Osz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 10:48:55 -0400
Received: by mail-pa0-f46.google.com with SMTP id kq14so11111220pab.19
        for <netdev@vger.kernel.org>; Wed, 28 May 2014 07:48:54 -0700 (PDT)
In-Reply-To: <1401284699.5367.268.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-05-28 at 06:44 -0700, Eric Dumazet wrote:
> On Wed, 2014-05-28 at 08:18 -0400, sowmini varadhan wrote:
> > On Tue, May 27, 2014 at 9:41 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > 
> > > Last time I checked, we were spending _lot_ of time in check_lifetime()
> > 
> > Although check_lifetime() itself did not light up in my
> > perf output, i see your point- it has a few ifa_list walks
> > that might end up being expensive - but these are static
> > IPv4 addresses- they should be marked IFA_F_PERMANENT,
> > right? That's probably why they did not show up in my perf output?
> 
> 
> How did you run perf ?
> 
> If you run :
> 
> perf record ./your_script.sh
> 
> It wont catch all the load that is triggered from work queues.
> 
> If you do
> 
> ./your_script.sh &
> 
> perf top
> 
> Then you'll see check_lifetime() at first position.

Following patch helps a lot
(30 seconds to add 65536 addresses on lo interface instead of 52 seconds
on my host)

for i in `seq 0 255`; do for j in `seq 0 255`; do echo "addr add 127.2.$i.$j/8 dev lo"; done; done >batch
ip -b batch

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index bdbf68bb2e2d..9b9763f27607 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -474,7 +474,8 @@ static int __inet_insert_ifa(struct in_ifaddr *ifa, struct nlmsghdr *nlh,
 	inet_hash_insert(dev_net(in_dev->dev), ifa);
 
 	cancel_delayed_work(&check_lifetime_work);
-	queue_delayed_work(system_power_efficient_wq, &check_lifetime_work, 0);
+	queue_delayed_work(system_power_efficient_wq, &check_lifetime_work,
+			   HZ / 4);
 
 	/* Send message first, then call notifier.
 	   Notifier will trigger FIB update, so that
