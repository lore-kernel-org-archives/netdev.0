From: jamal <hadi@cyberus.ca>
Subject: Re: [SET 2][PATCH 2/8][bonding] Propagating master's settings to
	slaves
Date: 11 Aug 2003 09:47:39 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1060607079.1050.144.camel@jzny.localdomain>
References: <E791C176A6139242A988ABA8B3D9B38A014C9474@hasmsx403.iil.intel.com>
	 <1060570284.1056.15.camel@jzny.localdomain>
	 <200308111308.48263.shmulik.hen@intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shmulik.hen@intel.com
In-Reply-To: <200308111308.48263.shmulik.hen@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2003-08-11 at 06:08, Shmulik Hen wrote:
> On Monday 11 August 2003 05:51 am, you wrote:
> > On Sat, 2003-08-09 at 06:29, Hen, Shmulik wrote:
> > > Not sure I fully understood the concerns above, but I'll try
> > > to explain what the change was all about.
> >
> > I think it wasnt the one specific change rather a few posted that i
> > spent a minute or two staring at. And you confirm my suspicion
> > below.
> 
> I probably didn't make myself clear - by "understood" I wanted to say 
> I probably didn't get the *meaning* of the whole sentence , and not 
> "I don't under stand why you are concerned".
> (English is not my native tongue :) ).
> 
> > I am not very familiar with the bonding code although i think you
> > guys have been doing very good work since you got involved.
> > In any case the approach you state above is wrong. Actually Stephen
> > Hemminger and I discussed this for bridging. Post 2.6 he is going
> > to remove a lot of the bridge policy (or "brain" as you call it)
> > out of the kernel. Netlink for kernel<->userspace not /proc. I
> > think we should head towards that direction so we can have more
> > sophisticated management.
> 
> I, on the other hand, am not familiar with the bridging code and I 
> don't know what it actually does internally, I just noticed that 
> regarding config operations, most of the code is done at the kernel 
> level as response to ioctl commands.
> 

Theres two main components to it: a control protocol and a forwarding
path. The control protocol known as STP tells the forwarding path how to
behave. Essentially, STP carries the policy implemented by the
forwarding path. This is the same breakdown to say routing protocols
like OSPF and regular forwarding path. At the moment STP sits in the
kernel. STP is really the "brains". 

> I'll try to clarify how that relates to bonding. The ifenslave utility 
> has very little "brain" as it is, and all it knows how to do 
> currently is enslave/release slave devices and change the current 
> active slave. It also has some ability to extract status info from 
> the bond and present it nicely for a user.
> 
> The "brain" I was referring to in the bonding module itself has to do 
> with timer functions monitoring link status or Tx/Rx activity of the 
> slaves, and once a faulty slave is detected, switch to use another 
> one instead according to the teaming mode. 
> There are no large scale 
> decision making nor major CPU consuming computations that are part of 
> the continuous operation of the module that is basically handle Rx/Tx 
> on slaves.
> 
> The bonding module doesn't need to access any special info that is 
> normally available to user space apps. What it does need is very 
> short response time and accessibility to kernel internal resources 
> like net devices info to make it a high availability intermediate 
> driver.
> 
> Trying to move that from the kernel module into the config application 
> seems to be a very hard task to implement since we'll have to find a 
> way to make the application constantly aware to the specifics like 
> current topology, slave-to-bond affiliation, updated status of each 
> slave, etc., etc. It would also mean that the driver will have to 
> wait for the application to tell it what to do each time it needs a 
> decision, and by that we'll surely suffer some performance hit and 
> probably get low availability or temporary loss of communications.
> 

Not at all. If you let some app control this i am sure whoever writes
the app has vested interest in getting fast failovers etc.

> Going back to the first problem, discussions on the bonding 
> development list pointed that it might be better if we moved the 
> configuration-time decisions making to the driver, so the application 
> wouldn't have to deal with situations like:
> 1) get the master's MTU settings, master's teaming mode, communication 
>    version, backwards compatibility issues, etc.
> 2) figure if need to set MTU to slave according to all that,
> 3) try to set that on the new slave being added,
> 4) if not successfull, decide if may enslave anyway or,
> 5) maybe undo all previous settings already done to the slave 
>    (needs a way to retrieve old values)
> 6) decide if should go on or fail any further operations
> 7) repeat the above for all other settings
> 
> On the other hand, what we want to get to is something more like:
> 1) tell bonding to add slave X to bond Y,
> 2) watch for error returns,
> 3) print a nice message according to the type of the error.
> 

Dont you think that anything thats "rich" like you list above should
stay out of the kernel? In any case, if you have a controlling app, you
could do more interesting things; example add or delete routes, firewall
rules, qos policies etc which all have very strong correlation with
availability - these are examples btw, not an exhaustive list. If all
you are satisfied with is link management alone, then by all means 
hardcoding behavior into the kernel is fine. I dont think it is
sufficient.

> While the driver, already aware of all possible relevant data, makes 
> all decisions, performs settings, handles compatibility issues, 
> checks for failures at each stage, handles any undo steps, and return 
> success/error values accordingly.
> 

Driver - actually bonding - should have minimal failover policy built in
for the lazy; example what i used to know about bonding - failover to
the next link, maybe send a grat arp etc. If I want more than basic,
then send me netlink events to user space and let me control how it
goes. Maybe i dont want to go to the second link but rather the 4th
link.

> >
> > Thoughts?
> 
> Mostly explanations :)
> 
> Is there anywhere I can see what you refereed to as discussions with 
> Stephen Hemminger ? I would really like to know how and what could 
> also be applied to bonding.
> 

Basically what i described at the top. Move any "richness" to user
space.

cheers,
jamal   
