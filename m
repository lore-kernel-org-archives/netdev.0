From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: [PATCH] tun driver use private linked list.
Date: Thu, 09 Oct 2003 11:45:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <5.1.0.14.2.20031009110604.05a541b0@unixmail.qualcomm.com>
References: <5.1.0.14.2.20030812092213.08dc6ea0@unixmail.qualcomm.com>
 <20030808113404.0e9e1e6d.shemminger@osdl.org>
 <200308051630.28552.bellucda@tiscali.it>
 <20030805090647.691daa7e.shemminger@osdl.org>
 <200308051910.55823.bellucda@tiscali.it>
 <20030807154524.4794ad45.shemminger@osdl.org>
 <20030807155901.49f1a424.davem@redhat.com>
 <20030808113404.0e9e1e6d.shemminger@osdl.org>
 <5.1.0.14.2.20030812092213.08dc6ea0@unixmail.qualcomm.com> <20030812100259.7d557bf3.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030812100259.7d557bf3.shemminger@osdl.org>
References: <5.1.0.14.2.20030812092213.08dc6ea0@unixmail.qualcomm.com>
 <20030808113404.0e9e1e6d.shemminger@osdl.org>
 <200308051630.28552.bellucda@tiscali.it>
 <20030805090647.691daa7e.shemminger@osdl.org>
 <200308051910.55823.bellucda@tiscali.it>
 <20030807154524.4794ad45.shemminger@osdl.org>
 <20030807155901.49f1a424.davem@redhat.com>
 <20030808113404.0e9e1e6d.shemminger@osdl.org>
 <5.1.0.14.2.20030812092213.08dc6ea0@unixmail.qualcomm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Stephen,

I just realized that I didn't reply to this one sorry.

At 10:02 AM 8/12/2003, Stephen Hemminger wrote:
>On Tue, 12 Aug 2003 09:48:50 -0700
>Max Krasnyansky <maxk@qualcomm.com> wrote:
>
>> At 01:18 AM 8/9/2003, David S. Miller wrote:
>> >On Fri, 8 Aug 2003 11:34:04 -0700
>> >Stephen Hemminger <shemminger@osdl.org> wrote:
>> >
>> >> Less grotty version, applies over earlier patch.
>> >>       - keep a private list.  
>> >>       - fix debug format strings.
>> >>       - drop the name entry in the private data structure since it already
>> >>         has a pointer to netdev that has name.
>> >
>> >Applied, thanks for following up on this Stephen.
>> 
>> Folks,
>> 
>> Sorry for jumping in late. 
>> I didn't implement cleanup logic in module_exit() because TUN module is not supposed 
>> to be unloaded if it has network devices, _even if those devices are down_.
>> TUN registers net device only when user application asks for it.
>>         fd = open("/dev/net/tun") -> ioctl(fd, CREATE_TUN_DEV) -> read(fd)/write(fd);
>> Net device must not be destroyed while fd is open.
>> 
>> So instead of cleaning up in tun_module_exit() we should fix misc driver to do refcounting 
>> for misc devices so that we could bump ref count for tun driver when application creates
>> net device.
>
>Not necessary to change anything.  If user process has /dev/net/tun open, then the owner
>field in the fops causes the module reference count to correctly increment.  Verified this
>and it works.  The issue is that it is possible to create TUN devices with TUN_PERSIST
>set and they have to be cleaned up upon. module_exit.
The fix is even simpler then. Basically MOD_INC_USE_COUNT should've been replaced with 
__module_get(THIS_MODULE). We don't have to keep list of devices.

Actually in case of persistent devices we can not let the module go away. Because it has
important info like user id of the owner and stuff which is not stored anywhere else. 
It also provides device name reservation, UML folks use it for example to reserve certain 
devices to a certain users. If module goes away admin will have to recreate those devices 
again. TUN/TAP devices are created in ioctl and since vfs layer already holds a reference, 
like you said, it's safe for us to just do __module_get()/module_put(). 

I'll make a new patch. I have some other patches for TUN driver that I wanted to apply 
anyway.   

Thanks
Max
