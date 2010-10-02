From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [PATCH 8/8] net: Implement socketat.
Date: Sat, 02 Oct 2010 23:13:32 +0200
Message-ID: <4CA7A07C.5030504@free.fr>
References: <m1ocborgq7.fsf@fess.ebiederm.org>	 <m1bp7oq1u8.fsf@fess.ebiederm.org>  <4C9B162E.7040201@parallels.com>	 <1285240797.5036.5.camel@bigi>  <4C9B3B06.900@parallels.com> <1285242055.5036.9.camel@bigi> <4C9B3F9C.8080506@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, "Eric W. Biederman" <ebiederm@xmission.com>,
	linux-kernel@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Michael Kerrisk <mtk.manpages@gmail.com>,
	Ulrich Drepper <drepper@gmail.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	Ben Greear <greearb@candelatech.com>,
	Matt Helsley <matthltc@us.ibm.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Patrick McHardy <kaber@trash.net>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <4C9B3F9C.8080506@parallels.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/23/2010 01:53 PM, Pavel Emelyanov wrote:
> On 09/23/2010 03:40 PM, jamal wrote:
>    
>> On Thu, 2010-09-23 at 15:33 +0400, Pavel Emelyanov wrote:
>>
>>      
>>> This particular usecase is unneeded once you have the "enter" ability.
>>>        
>> Is that cheaper from a syscall count/cost?
>>      
> Why does it matter? You told, that the usage scenario was to
> add routes to container. If I do 2 syscalls instead of 1, is
> it THAT worse?
>
>    
>> i.e do I have to enter every time i want to write/read this fd?
>>      
> No - you enter once, create a socket and do whatever you need
> withing the enterned namespace.
>    

Just to clarify this point. You enter the namespace, create the socket 
and go back to the initial namespace (or create a new one). Further 
operations can be made against this fd because it is the network 
namespace stored in the sock struct which is used, not the current 
process network namespace which is used at the socket creation only.

We can actually already do that by unsharing and then create a socket. 
This socket will pin the namespace and can be used as a control socket 
for the namespace (assuming the socket domain will be ok for all the 
operations).

Jamal, I don't know what kind of application you want to use but if I 
assume you want to create a process controlling 1024 netns, let's try to 
identificate what happen with setns and with socketat :

With setns:

     * open /proc/self/ns/net (1)
     * unshare the netns
     * open /proc/self/ns/net (2)
     * setns (1)
     * create a virtual network device
     * move the virtual device to (2) (using the set netns by fd)
     * unshare the netns
     ...

With socketat:

     * open a socket (1)
     * unshare the netns
     * open a netlink with socketat(1) => (2)
     * create a virtual device using (2) (at this point it is init_net_ns)
     * move the virtual device to the current netns (using the set netns 
by pid)
     * open a socket (3)
     * unshare the netns
     ...

We have the same number of file descriptors kept opened. Except, with 
setns we can bind mount the directory somewhere, that will pin the 
namespace and then we can close the /proc/self/ns/net file descriptors 
and reopen them later.

If your application has to do a lot of specific network processing, 
during its life cycle, in different namespaces, the socketat syscall 
will be better because it will reduce the number of syscalls but at the 
cost of keeping the file descriptors opened (potentially a big number). 
Otherwise, setns should fit your needs.



>> How does poll/select work in that enter scenario?
>>      
> Just like it used to before the enter.
>
>    
>> cheers,
>> jamal
>>
>>
>>      
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
>    

