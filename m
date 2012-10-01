From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: network namespace and kernel bind issue
Date: Mon, 1 Oct 2012 15:57:02 -0700
Message-ID: <20121001155702.5b5e2188@nehalam.linuxnetplumber.net>
References: <20121001141609.14639bc0@nehalam.linuxnetplumber.net>
	<20121001145838.5eafef4c@nehalam.linuxnetplumber.net>
	<87fw5xeryf.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35022 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752833Ab2JAW5j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2012 18:57:39 -0400
In-Reply-To: <87fw5xeryf.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 01 Oct 2012 15:40:56 -0700
ebiederm@xmission.com (Eric W. Biederman) wrote:

> Stephen Hemminger <shemminger@vyatta.com> writes:
> 
> > On Mon, 1 Oct 2012 14:16:09 -0700
> > Stephen Hemminger <shemminger@vyatta.com> wrote:
> >
> >> When testing VXLAN I noticed that the kernel bind seems to be a problem for
> >> network tunnels. The init_net function is called repeatedly for the same
> >> network namespace!
> 
> It definitely should not be.
> 
> >> 1. Create vxlan device:
> >>  # ip li add vxlan0 type vxlan id 11 group 239.1.1.1 dev eth0
> >>  # dmesg | tail
> >> [11580.671016] vxlan: vxlan_init_net in net 1
> 
> Net 1?  What are you printing out?  It isn't the net_id by any chance?

Yes it is the net_id which is passed to net_generic() to find the
per-namespace data structure.

> 
> >> 2. Start Chrome (or other application using namespaces)
> >>  
> >>   dmesg | tail
> >> [11587.371195] vxlan: vxlan_init_net in net 1
> >> [11587.371211] vxlan: bind for UDP socket 0.0.0.0:8472 (-98)
> >> 
> >> 
> >> Isn't init_net supposed to be unique. The current semantics also break
> >> L2TP.
> 
> The init method should be called exactly once per network namespace.
> 
> The timing of the init methods you report seems correct.
> 
> The vxlan code isn't in net-next or I would take a look.
> 
> I took a quick look at l2tp and the code is doing some weird things.
> There are a bunch of references to &init_net that I would expect
> to references to either sk_net() or dev_net().  
> 
> Adding support for multiple network namespaces and then reaching
> out to the initial network namespace for things is definitely a recipe
> for getting confused.
> 
> So my blind guess would be that someone half implemented network
> namespace support for l2tp and vxlan copied the bugs.

The vxlan driver has one UDP socket per namespace.
There are no references to init_net in it.

I think the problem is the call chain
      copy_net_ns -> setup_net -> ops_init
There is nothing that nothing increments the id after register_pernet_operations.

Shouldn't there be an increment so each new namespace gets a unique id?

--- a/net/core/net_namespace.c	2012-08-15 08:59:22.938704423 -0700
+++ b/net/core/net_namespace.c	2012-10-01 15:54:50.293088913 -0700
@@ -161,6 +161,7 @@ static __net_init int setup_net(struct n
 #endif
 
 	list_for_each_entry(ops, &pernet_list, list) {
+		++*ops->id;
 		error = ops_init(ops, net);
 		if (error < 0)
 			goto out_undo;


Or maybe you need to keep track of IDR map for each pernet_operations structure?
