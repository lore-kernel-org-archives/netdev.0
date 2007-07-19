From: patric <pakar@imperialnet.org>
Subject: Re: tg3 issues
Date: Thu, 19 Jul 2007 15:24:17 +0200
Message-ID: <469F6601.20800@imperialnet.org>
References: <469E78A2.80904@imperialnet.org> <366312910707190419se33ddd2o3870b5684e077276@mail.gmail.com> <20070719113755.GA1934@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailfront-6.lil-sth.crystone.net ([83.168.207.14]:55922 "HELO
	mailfront-6.lil-sth.se.crystone.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with SMTP id S1755468AbXGSNcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 09:32:09 -0400
In-Reply-To: <20070719113755.GA1934@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Neil Horman wrote:

> On Thu, Jul 19, 2007 at 04:49:13PM +0530, pradeep singh wrote:
>   
>> CCing: netdev
>>
>> On 7/19/07, patric <pakar@imperialnet.org> wrote:
>>     
>>> Hi,
>>>
>>>
>>> To start with, i'm not sure if this should go to the dev or user list,
>>> but i'll start here..
>>>
>>>
>>> I'm currently running a nfsroot via a Broadcom NetXtreme 1000-SX card
>>> (BCM5701) and i have a big problem with the tg3 drivers autonegotiation.
>>>
>>> The issue seems to be that when the kernel comes so far as it's trying
>>> to mount the boot the autonegotiation has not yet completed and then
>>> causes a panic since it cannot mount the nfsroot.
>>>
>>>
>>> From some debugging i have done here the issues seems to be related to
>>> the flowcontrol configuration, and just to make it a bit more fun it
>>> does work some of the time.. (around once every 5-10 attempts.)
>>>
>>>
>>> On the console it looks something like this when failing. (written from
>>> memory since i don't have netconsole enabled)
>>>
>>> tg3: eth0: Link is up at 1000 Mbps, full duplex.
>>> tg3: eth0: Flow control is off for TX and off for RX.
>>> IP-Config: Complete:
>>>      device=eth0, addr=192.168.1.10, mask=255.255.255.0,
>>> gw=255.255.255.255,
>>>     host=amd, domain=, nis-domain=(none),
>>>     bootserver=255.255.255.255, rootserver=192.168.1.1, rootpath=
>>> Root-NFS: unknown option: nolocks
>>> Looking up port of RPC 100003/3 on 192.168.1.1
>>> rpcbind: server 192.168.1.1 not responding, timed out
>>>
>>> Root-NFS: Unable to get nfsd port number from server, using default
>>>
>>> Looking up port of RPC 100003/3 on 192.168.1.1
>>> rpcbind: server 192.168.1.1 not responding, timed out
>>>
>>> Root-NFS: Unable to get nfsd port number from server, using default
>>>
>>>
>>> and so on until it panics...
>>>
>>>       
>
> IIRC, there are two main problems in this typ of situation
>
> 1) Spanning tree convergence
> 2) Firmware initalization latency
>
> If you are running spanning tree on your network, it can take up to 2 minutes
> before your port will forward frames properly.  if you have the options
> available, disable spanning tree on the switch port connected to your host
> system, or at least enable portfast if it is an option.  That should fix any
> spanning tree issues you have
>
> If the tg3 card is just taking a long time to initalize, there is not too much
> you can do about it.  If your goal is to use nfs root, I would, instead of
> enabling nfs-root as a kernel config option, I would create an initramfs that:
> A) Brings up your NIC
> B) Mounts your nfs partition
> C) executes a switch_root or pivot_root operation
>
> That way you can calibrate a delay between steps (A) and (B) in your initramfs
> init script
>
> Regards
> Neil
>
>   
Hi Neil and thanks for your quick reply, and thanks Pradeep for 
forwarding the question to the correct mailinglist.

Well, not using any switches and just a crossed cable between the 
machines. Did notice that it seems to get a 'good link' more often when 
cold-booting the client.
Have been thinking about using a initrd to get around the issue, but the 
problem is that you never know how long the init will be so there will 
always have to be a quite big delay before the system can boot. But 
don't really think the issue is that the card takes a long time to 
initialize since it does sometime work without delay during a warm-boot 
and the cards do report that they are up but they then are reporting 
different states of flow-control. Maybe set the flowcontrol static in 
the driver for a test, if i now can figure out how this driver works. :)

Just a hypothetical question. If the 2 network cards starts the 
autonegotiation would it be possible that they get into a loop where 
they are chasing each others state?  Maybe a fix could be to add a sleep 
of a random length that would enable them to catch up? Maybe you know if 
any of the fiber-cards so support running without flowcontrol too since 
the cards don't seem to be able to get a link with flowcontrol turned 
off at least in this setup.


Regards,
Patric



