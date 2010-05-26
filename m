From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [RFC] IFLA_PORT_* iproute2 cmd line
Date: Wed, 26 May 2010 07:49:42 -0700
Message-ID: <C8228316.35508%scofeldm@cisco.com>
References: <201005261438.07004.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Chris Wright <chrisw@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Stefan Berger <stefanb@us.ibm.com>,
	Dirk Herrendoerfer <d.herrendoerfer@de.ibm.com>,
	Vivek Kashyap <vivk@us.ibm.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:18559 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753896Ab0EZOtp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 10:49:45 -0400
In-Reply-To: <201005261438.07004.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/26/10 5:38 AM, "Arnd Bergmann" <arnd@arndb.de> wrote:

> On Wednesday 26 May 2010, Scott Feldman wrote:
>> I need to provide an iproute2 patch for IFLA_PORT_* and I wanted to hash out
>> the cmd line before I submit it.  Here's what I think would work based on
>> previous input from Arnd:
>> 
>> Usage:  ip port associate DEVICE [ vf NUM ] {PROFILE|VSI}
>>         ip port pre-associate DEVICE [ vf NUM ] VSI
>>         ip port pre-associate-rr DEVICE [ vf NUM ] VSI
>>         ip port dis-associate DEVICE [ vf NUM ]
>>         ip port show [ DEVICE [ vf NUM ] ]
>> 
>>         PROFILE := port-profile PORT-PROFILE
>>                    [ instance-uuid INSTANCE-UUID ]
>>                    [ host-uuid HOST-UUID ]
>> 
>>         VSI := vsi managerid MGR typeid VTID typeidversion VER
>>                [ instance-uuid INSTANCE-UUID ]
>> 
>> Comments?
> 
> The syntax of the PROFILE and VSI arguments seems ok, but I'm
> not sure where exactly to put them.
> 
> When talking to the kernel, I think this should be part of
> link command, because that is the underlying protocol:
> 
> ip link set DEVICE [vf NUM] {associate {PROFILE|VSI}    |
>     pre-associate-rr VSI       |
>     pre-associate VSI          |
>     disassociate }
> ip link show [ DEVICE [ vf NUM ] ]
> 
> This will also let you combine the association with additional
> "vf mac" and "vf vlan" commands as needed.

How does this strike you?

  Usage: ip link add link DEV [ name ] NAME
                     [ txqueuelen PACKETS ]
                     [ address LLADDR ]
                     [ broadcast LLADDR ]
                     [ mtu MTU ]
                     type TYPE [ ARGS ]
         ip link delete DEV type TYPE [ ARGS ]

         ip link set DEVICE [ { up | down } ]
                            [ arp { on | off } ]
                            [ dynamic { on | off } ]
                            [ multicast { on | off } ]
                            [ allmulticast { on | off } ]
                            [ promisc { on | off } ]
                            [ trailers { on | off } ]
                            [ txqueuelen PACKETS ]
                            [ name NEWNAME ]
                            [ address LLADDR ]
                            [ broadcast LLADDR ]
                            [ mtu MTU ]
                            [ netns PID ]
                            [ alias NAME ]
+                           [ virtualport MODE {PROFILE|VSI} ]
                            [ vf NUM [ mac LLADDR ]
                                     [ vlan VLANID [ qos VLAN-QOS ] ]
-                                    [ rate TXRATE ] ]
+                                    [ rate TXRATE ]
+                                    [ virtualport MODE {PROFILE|VSI} ] ]
         ip link show [ DEVICE ]

  TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | can }
+
+ MODE := { associate | preassociate | preassociaterr | disassociate }
+
+ PROFILE := port-profile PORT-PROFILE
+            [ instance-uuid INSTANCE-UUID ]
+            [ host-uuid HOST-UUID ]
+ 
+ VSI := vsi managerid MGR typeid VTID typeidversion VER
+        [ instance-uuid INSTANCE-UUID ]


> The more interesting question is how to do this when we
> talk to lldpad. One idea was to use the same protocol
> but to direct the message to a specific pid (that of lldpad).
> That would require adding an option like '-p PID' to ip
> that lets us change who we talk to.

Let me get the user-to-kernel part working to establish the cmd line and you
can follow up with alternative addressing schemes.
 
> Alternatively, we could also create a top-level command like
> the one you described, but just use it for the case when
> we're talking to lldpad, finding out the PID from the
> /var/run/lldpdad.pid internally. Right now, I'm leaning
> towards the more flexible option of being able to direct
> the command anywhere.

