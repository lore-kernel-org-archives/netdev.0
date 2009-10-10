From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: Real networking namespace
Date: Sat, 10 Oct 2009 11:14:52 -0700
Message-ID: <4AD0CF1C.2030709@schaufler-ca.com>
References: <20091009083807.16e55b08@nehalam> <1255106246.2182.219.camel@moss-pluto.epoch.ncsc.mil> <1255106692.2182.224.camel@moss-pluto.epoch.ncsc.mil> <200910091812.16046.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Stephen Smalley <sds@tycho.nsa.gov>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	linux-security-module@vger.kernel.org,
	Al Viro <viro@zeniv.linux.org.uk>, netdev@vger.kernel.org,
	James Morris <jmorris@namei.org>,
	Casey Schaufler <casey@schaufler-ca.com>
To: Paul Moore <paul.moore@hp.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <200910091812.16046.paul.moore@hp.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul Moore wrote:
> On Friday 09 October 2009 12:44:52 pm Stephen Smalley wrote:
>   
>> On Fri, 2009-10-09 at 12:37 -0400, Stephen Smalley wrote:
>>     
>>> On Fri, 2009-10-09 at 08:38 -0700, Stephen Hemminger wrote:
>>>       
>>>> The existing networking namespace model is unattractive for what I
>>>> want, has anyone investigated better alternatives?
>>>>
>>>> I would like to be able to allow access to a network interface and
>>>> associated objects (routing tables etc), to be controlled by Mandatory
>>>> Access Control API's.

As I'll mention later, getting agreement on what qualifies as an
object in the networking stack ain't going to happen anytime soon.
Sure, routing tables are important components of the system's
state, but they don't qualify as objects under any definition of
objects with which I'm familiar. Similarly, a network device is
more like a disk controller than a directory, and no one I know
of wants to start doing access checks based on the disk controller
(file system, yes, controller, no) that a file resides on.

The ad hoc security mechanisms for networking include firewalls,
netfilter, and routing schemes. These are very interesting and
useful things, but they don't have anything to do with the
"subject accesses object" mindset. Trying to shoehorn them in
always results in tears.


>>>>  I.e grant access to eth0 and to only certain
>>>> processes.  Some the issues with the existing models are:
>>>>   * eth0 and associated objects don't really exist in filesystem so
>>>>     not subject to LSM style control (SeLinux/SMACK/TOMOYO)
>>>>         
>
> As Stephen points out, SELinux does have the ability to assign security labels 
> to network interfaces, check out the 'semanage' command.  A while back I wrote 
> up something about the SELinux network "ingress/egress" access controls:
>
>  * http://paulmoore.livejournal.com/2128.html
>
> Smack doesn't support controlling network access at the interface level, but 
> that is due to a Smack design decision and not an inherent functionality gap 
> in the LSM.

Paul is correct. A security model that includes network interface
devices as policy components has all the tools it needs at its
disposal. The Smack model does not consider network interface devices
as policy components. Certainly there are data import/export issues
that get raised with the Smack model, but they center around the
question of whether sending a packet on the network is in fact an
export and whether receiving a packet is an import. You can argue
it either way, and the implications are kind of painful whichever
way you choose. You really only want network interface devices as
policy components if you consider network traffic as import/export,
in which case you have serious work to do explaining why it is
acceptable to do multi-label import/export over that media.

Smack treats incoming packets as IPC messages from subjects that
may be elsewhere. The label on the packet, which may be based on
the host the packet came from, is the only information that Smack
cares about.


>   TOMOYO is currently working on improved network access controls 
> (see patches posted earlier this week), I haven't had a chance to review them 
> yet so I don't know the state of TOMOYO's network access controls.
>
>   
>>>>   * network namespaces do not allow object to exist in multiple
>>>> namespaces. The current model is more restrictive than chroot jails. At
>>>> least with chroot, put filesystem objects in multiple jails.
>>>>         
>
> Perhaps I don't fully understand what you are getting at here, but I don't 
> think this should be an issue with a flexible LSM.
>
>   
>>> Is there something that prevents you from using the existing SELinux
>>> network access controls?  netif is a security class governed by SELinux
>>> policy, and routing table operations would be covered by the SELinux
>>> checks on netlink_route_socket.  SELinux uses a combination of LSM hooks
>>> and netfilter hooks to mediate network operations.
>>>       
>> Also, depending on what you want to do, SECMARK may be useful to you.
>> That allows you to mark packets with security contexts via iptables, and
>> then use SELinux policy to control their flow.
>> http://paulmoore.livejournal.com/4281.html
>> http://james-morris.livejournal.com/11010.html
>>     
>
> While we're at it, a few more links ... here is a presentation from last year 
> on Linux's labeled networking capabilities (which hits at a lot of your 
> questions):
>
>  * http://paulmoore.livejournal.com/964.html
>
> ... and there is a video too:
>
>  * http://paulmoore.livejournal.com/1329.html
>
>   

