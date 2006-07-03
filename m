From: Jeremy Jackson <jerj@coplanar.net>
Subject: Re: netif_stop_queue() and multiple hardware queues
Date: Sun, 02 Jul 2006 22:36:03 -0400
Message-ID: <44A88293.7060000@coplanar.net>
References: <43A09D18.9040401@coplanar.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bob.coplanar.net ([206.222.78.116]:26774 "EHLO bob.coplanar.net")
	by vger.kernel.org with ESMTP id S1750999AbWGCCgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jul 2006 22:36:06 -0400
To: Jeremy Jackson <jerj@coplanar.net>
In-Reply-To: <43A09D18.9040401@coplanar.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'd like to raise the question again.  How can the network stack's flow 
control function with hardware that has multiple physical queues?  How 
can these queues be exposed to tc?

After scanning the netdev mailing list activity for the last 6 months, I 
can see no furthur discussion since my original post.  I did notice some 
churn in several 802.11 layer stacks trying to deal with multiple 
hardware queues, the IPW2200 in particular.

I propose that this is an architecture/framework/API issue that the 
Linux core networking code should be dealing with.

There is some fragmentation already; compare the QoS *policy* 
implemented by Madwifi vs IPW2200 vs devicescape's 80211 stack. It's 
worth noting that at the 80211 layer, the first 2 listed above have a 
"priority" argument to (80211)_hard_start_xmit().

It would seem ideal to expose the queues of Ethernet layer hardware 
(provide mechanism) and let userspace tc tools do the classifying 
(sysadmin can set the policy).

Jeremy

Jeremy Jackson wrote:
> Hi,
> 
> I posted this briefly on linux-net, before being redirected here.
> 
> Two pieces of hardware now have Linux driver support for multiple 
> hardware queues: Intel's e1000 (two queues from what I can see in the 
> code) and Atheros's 5212 and up, in support of 802.11e and WME (four 
> hardware queues).  In the GigE case, this just reduces latency due to 
> hardware queueing.  In the WiFi case, the queues actually have 
> significance in access to the shared medium. (ACKs can be disabled as 
> well)  It is also worthy of note that ADSL2, VDSL, and ADSL2+ have 4 
> different latency "queues".  These last two are significant; real-time 
> applications suffer the most from low speed, shared, and/or 
> non-deterministic media.  I wonder where DOCSIS 2 is in this regard.  
> Anyone?  Beuler?
> 
> So my question is, what's it going to take to get dev->hard_start_xmit() 
> to hook up tc queues directly to hardware/driver queues?
> 
> Right now, it seems no matter how elaborate a tc setup you have, 
> everything funnels through one queue, where the only thing that survives 
> from the classifying/queueing is skb-> priority (ie nothing).  The 
> hardware driver can then try to reclassify packets.   I suppose you 
> could hack up an iptables classifyer to set skb->priority...
> 
> The  Atheros driver tries to  do it's own classifying by first wiping 
> out skb->priority, then hard-coding  a mapping (tsk - policy is for the 
> sysadmin!) between VLAN tag priority, IP TOS/DSCP, and skb->priority, 
> then to one of the 4 queues and ACK states, blithely ignoring any fine 
> work done by tc.
> 
> It's be sweet to head this nonsense off at the pass, before others 
> discover the rabbit trail and make it into a trade route.
> 

