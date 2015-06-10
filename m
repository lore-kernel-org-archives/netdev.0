From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Weird DHCP related problems with net-next
Date: Tue, 09 Jun 2015 17:12:47 -0700
Message-ID: <557780FF.1080606@gmail.com>
References: <5577367A.50901@gmail.com> <20150609192242.GD16778@lunn.ch> <55774D23.1010508@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>, davem@davemloft.net
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f182.google.com ([209.85.216.182]:35723 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932653AbbFJANw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 20:13:52 -0400
Received: by qczw4 with SMTP id w4so11979148qcz.2
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2015 17:13:50 -0700 (PDT)
In-Reply-To: <55774D23.1010508@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/06/15 13:31, Florian Fainelli wrote:
> Hi Andrew,
> 
> On 09/06/15 12:22, Andrew Lunn wrote:
>> On Tue, Jun 09, 2015 at 11:54:50AM -0700, Florian Fainelli wrote:
>>> Hi,
>>>
>>> I am observing a strange problem on net-next (not observed with net,
>>> bisection in progress) where the initial DHCP configuration using
>>> busybox's udhcpc is able to configure the local interface address and
>>> DNS serer, but not the default gateway. Restarting udhcpc a second time
>>> does not exhibit this problem.
>>
>> Hi Florian
>>
>> I've seen something similar, but different, again with DSA involved,
>> on a WiFi Access point. I have debian, and i'm using isc dhcp. It gets
>> an address, sets the address on the interface, but does not add the
>> interface route to the routing table. Not sure about default route, i
>> would have to go check that.
> 
> Interesting, did you also observe this with 'net', or just with 'net-next'?
> 
> Contrary to what I reported above, this is only an issue with
> SYSTEMPORT/DSA/SF2, I could not reproduce this GENET or the Asix driver,
> I was just conflating two different systems here.
> 
> My bisection seems to point at this commit:
> 
> 58c2cb16b116d7feace621bd6b647bbabacfa225 ("switchdev: convert
> fib_ipv4_add/del over to switchdev_port_obj_add/del")
> 
> And indeed, hacking a bit the kernel to remove the SWITCHDEV/DSA
> dependencies to leave just DSA makes thing work again.
> 
> Scott, Jiri, any clues? I can instrument the kernel a bit more to help
> find what is the problem here. Note that I am observing this on ARM
> (Andrew probably is as well), where uninitialized stack variables are
> potentially garbage.

I see the problem now, DSA does not implement a port_obj_add callback,
so when net/ipv4/fib_trie.c::switchdev_fib_ipv4_add() gets to call
switchdev_port_obj_add, we return -EOPNOTSUPP, and take the error path
in fib_table_insert thus not inserting the route for this interface.

Now when I restart the DHCP client, we end-up inserting the default
route which is correct, still figuring out what is different here,
probably the deletion of the routes by the DHCP client script first is
the different condition.

At any rate, since switchdev_fib_ipv4_add() returns something that make
us take an error path in the fib_trie, something like this seems to fix
it for me but I am not well versed enough into the IPv4 routing code to
be 100% confident this is the right fix. Also, there are other callers
of switchdev_port_obj_add() but a quick look seems to make them safe as
they are only called for "offloading" capable hardware.

It still looks not being able to differentiate a hard failure from
-EOPNOTSUPP has side effects all over the place


diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index e008057dab46..b683e89b4caa 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -853,7 +853,7 @@ int switchdev_fib_ipv4_add(u32 dst, int dst_len,
struct fib_info *fi,
        if (!err)
                fi->fib_flags |= RTNH_F_OFFLOAD;

-       return err;
+       return err == -EOPNOTSUPP ? 0 : err;
 }
 EXPORT_SYMBOL_GPL(switchdev_fib_ipv4_add);

@@ -898,7 +898,7 @@ int switchdev_fib_ipv4_del(u32 dst, int dst_len,
struct fib_info *fi,
        if (!err)
                fi->fib_flags &= ~RTNH_F_OFFLOAD;

-       return err;
+       return err == -EOPNOTSUPP ? 0 : err;
 }
 EXPORT_SYMBOL_GPL(switchdev_fib_ipv4_del);

-- 
Florian
