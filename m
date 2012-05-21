From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: 3.3.0, 3.4-rc1 reproducible tun Oops
Date: Mon, 21 May 2012 18:51:32 +0400
Message-ID: <4FBA5674.9050508@parallels.com>
References: <20120404220525.GD21505@hostway.ca> <1333593664.18626.577.camel@edumazet-glaptop> <20120417020852.GA18875@hostway.ca> <4F8D5FAD.10304@parallels.com> <20120417183528.GA32726@hostway.ca> <4F8EA64B.2050208@parallels.com> <20120519010743.GA21427@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Simon Kirby <sim@hostway.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:39995 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753539Ab2EUOvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2012 10:51:39 -0400
In-Reply-To: <20120519010743.GA21427@hostway.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19.05.2012 05:07, Simon Kirby wrote:
> On Wed, Apr 18, 2012 at 03:32:27PM +0400, Stanislav Kinsbursky wrote:
>
>> 17.04.2012 22:35, Simon Kirby ??????????:
>>> On Tue, Apr 17, 2012 at 04:18:53PM +0400, Stanislav Kinsbursky wrote:
>>>>
>>>> Hi, Simon.
>>>> Could you please try to apply the patch below on top of your the
>>>> tree (with 1ab5ecb90cb6a3df1476e052f76a6e8f6511cb3d applied) and
>>>> check does it fix the problem:
>>>>
>>>> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
>>>> index bb8c72c..1fc4622 100644
>>>> --- a/drivers/net/tun.c
>>>> +++ b/drivers/net/tun.c
>>>> @@ -1540,13 +1540,10 @@ static int tun_chr_close(struct inode
>>>> *inode, struct file *file)
>>>>   			if (dev->reg_state == NETREG_REGISTERED)
>>>>   				unregister_netdevice(dev);
>>>>   			rtnl_unlock();
>>>> -		}
>>>> +		} else
>>>> +			sock_put(tun->socket.sk);
>>>>   	}
>>>>
>>>> -	tun = tfile->tun;
>>>> -	if (tun)
>>>> -		sock_put(tun->socket.sk);
>>>> -
>>>>   	put_net(tfile->net);
>>>>   	kfree(tfile);
>>>
>>> (Whitespace-damaged patch, applied manually)
>>>
>>> Yes, I no longer see crashes with this applied. I haven't tried with
>>> kmemleak or similar, but it seems to work.
>>>
>>> Thanks,
>>>
>>
>> This bug looks like double free, but I can't understand how does this can happen...
>> Simon, would be really great, if you'll describe in details some
>> simple way, how to reproduce the bug.
>
> Oh, sorry, I did not see this until now. I just noticed it was still
> floating in my tree with no upstream changes yet, then found your email.
> I still have not seen any issues since applying your patch.
>
> I was definitely seeing the issue on 3.4-rc3. I can try and see if it
> still occurs with your patch removed, if that would help.
>
> Do you have a box on which you can set up an SSH tunnel? In my case, I
> can reproduce it easily with three boxes. From home, I run ssh to my work
> box to establish the layer 2 tunnel. This goes through a ProxyCommand to
> jump through an entry box, but I don't think that should matter. I use a
> cheap tunnel start script similar to this:
>
> work_net=10.0.0.0/8
> work_tun_ip=10.x.x.x
> home_tun_ip=10.x.x.x
> echo 1>  /proc/sys/net/ipv4/conf/eth0/proxy_arp
> ssh -w any:any<work box>  "ifconfig tun0 $work_tun_ip pointopoint
> $home_tun_ip; echo 'ifconfig tun0 $home_tun_ip pointopoint $work_tun_ip
> &&  ip route add $work_net via $work_tun_ip'; sleep 1d" | sh -v
>
> ...there's probably a better way, but it works. To reproduce, I log in
> to a third box over this tunnel, and start a "vmstat 1", so that packets
> keep coming back to the tunnel host. ^C on the SSH session will then
> produce an Oops within a second.
>
> With CONFIG_SLUB_DEBUG=y and booting with slub_debug=FZPU, I got the
> Redzone overwritten notice. Without it, the box usually Oopses and
> hangs immediately. Sometimes, I might have to reconnect the tunnel and
> ^C it once more. If I don't have that vmstat session open, it usually
> doesn't crash.
>
> Does this work for you?
>

Hello, Simon.
Thanks for details.
I still can't reproduce the issue.
Here is my configuration:
1) three nodes: A, B and C.
2) A and B connected with a tunnel (your script - slightly modified).
3) Packets to C from A are routed through the tunnel.
4) Node B has 3.4.0-rc2 based kernel. A and C - rhel6 kernel.

So, I login to C from A by ssh, run "vmstat 1" and then cut off (^C) the tunnel 
between A and B. Connection hanged. No panic or oops occurred.

Is it the same you've done when panic occurred?
Or I'm doing something wrong?

> Simon-


-- 
Best regards,
Stanislav Kinsbursky
