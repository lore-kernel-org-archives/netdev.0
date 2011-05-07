From: Alex Bligh <alex@alex.org.uk>
Subject: Re: Scalability of interface creation and deletion
Date: Sat, 07 May 2011 16:26:39 +0100
Message-ID: <0F4A638C2A523577CDBC295E@Ximines.local>
References: <891B02256A0667292521A4BF@Ximines.local>
 <1304770926.2821.1157.camel@edumazet-laptop>
Reply-To: Alex Bligh <alex@alex.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alex Bligh <alex@alex.org.uk>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.avalus.com ([89.16.176.221]:36501 "EHLO mail.avalus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755272Ab1EGP0n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 May 2011 11:26:43 -0400
In-Reply-To: <1304770926.2821.1157.camel@edumazet-laptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric,

>> 1. Interface creation slows down hugely with more interfaces
>
> sysfs is the problem, a very well known one.
> (sysfs_refresh_inode(),

Thanks

>> 2. Interface deletion is normally much slower than interface creation
>>
>> strace -T -ttt on the "ip" command used to do this does not show the
>> delay where I thought it would be - cataloguing the existing interfaces.
>> Instead, it's the final send() to the netlink socket which does the
>> relevant action which appears to be slow, for both addition and detion.
>> Adding the last interface takes 200ms in that syscall, the first is
>> quick (symptomatic of a slowdown); for deletion the last send syscall is
>> quick.
>
>> I am having difficulty seeing what might be the issue in interface
>> creation. Any ideas?
>>
>
> Actually a lot, just make
>
> git log net/core/dev.c
>
> and you'll see many commits to make this faster.

OK. I am up to 2.6.38.2 and see no improvement by then. I will
try something bleeding edge in a bit.

>> I am guessing that this is going to do the msleep 50% of the time,
>> explaining 125ms of the observed time. How would people react to
>> exponential backoff instead (untested):
>>
>> 	int backoff = 10;
>>         refcnt = netdev_refcnt_read(dev);
>>
>>         while (refcnt != 0) {
>>                 ...
>>                 msleep(backoff);
>>                 if ((backoff *= 2) > 250)
>>                   backoff = 250;
>> 		
>>                 refcnt = netdev_refcnt_read(dev);
>> 		....
>>         }
>>
>>
>
> Welcome to the club. This is what is discussed on netdev since many
> years. Lot of work had been done to make it better.

Well, I patched it (patch attached for what it's worth) and it made
no difference in this case. I would suggest however that it might
be the right think to do anyway.

> Interface deletion needs several rcu synch calls, they are very
> expensive. This is the price to pay to have lockless network stack in
> fast paths.

On the current 8 core box I am testing, I see 280ms per interface
delete **even with only 10 interfaces**. I see 260ms with one
interface. I know doing lots of rcu sync stuff can be slow, but
260ms to remove one veth pair sounds like more than rcu sync going
on. It sounds like a sleep (though I may not have found the
right one). I see no CPU load.

Equally, with one interface (remember I'm doing this in unshare -n
so there is only a loopback interface there), this bit surely
can't be sysfs.

-- 
Alex Bligh

Signed-off-by: Alex Bligh <alex@alex.org.uk>
diff --git a/net/core/dev.c b/net/core/dev.c
index 6561021..f55c95c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5429,6 +5429,7 @@ static void netdev_wait_allrefs(struct net_device 
*dev)
 {
        unsigned long rebroadcast_time, warning_time;
        int refcnt;
+       int backoff = 5;

        linkwatch_forget_dev(dev);

@@ -5460,7 +5461,9 @@ static void netdev_wait_allrefs(struct net_device 
*dev)
                        rebroadcast_time = jiffies;
                }

-               msleep(250);
+               msleep(backoff);
+               if ((backoff *= 2) > 250)
+                 backoff = 250;

                refcnt = netdev_refcnt_read(dev);




