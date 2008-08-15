From: Jonathan Day <imipak@yahoo.com>
Subject: Re: Multicast Routing Kernel option?
Date: Fri, 15 Aug 2008 01:41:51 -0700 (PDT)
Message-ID: <124178.76775.qm@web31502.mail.mud.yahoo.com>
References: <loom.20080815T073349-129@post.gmane.org>
Reply-To: imipak@yahoo.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, Daniel Ng <daniel_ng11@lycos.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web31502.mail.mud.yahoo.com ([68.142.198.131]:23310 "HELO
	web31502.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753555AbYHOIsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 04:48:33 -0400
In-Reply-To: <loom.20080815T073349-129@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Personally, I'd suggest using pimd rather than routed - partly because routed uses a largely discontinued protocol, but also because pimd was developed up to a more recent point in time, so is more likely to play nicely with newer Linux kernels.

As for the rest of my reply - it's been a while since I poked into those specific kernel internals. (I still think the headers need cleaning up.) Anything below, therefore, should be taken with either a pinch of salt or a pint of your favourite virtual beer. A keg of each of the 1000+ real ales from around the world are stored as microdots in each pixel of this email.

As best as I understand it, Linux can either be set up to route multicast traffic or act as a multicast client, but doesn't like to do both. Not quite sure on the reasoning for that, as an output is an output and it can't make that much difference at that level of abstraction is a physical device or a logical device going into userspace.

Multicast routing support does require some things that clients don't need. You need multicast routing tables, for example, as a simple upstream pointer for the multicast network isn't going to be good enough. A client only needs to care about the multicast group version being supported, group membership and (for IGMPv3) any special inclusion or exclusion rules per group. Routers need kernel-level packet forwarding and optionally support to link things like QoS functions (eg: RSVP) into that packet forwarding mechanism.

Multicast routers (mrouted, pimd, pimdd, multicast-enabled gated, and a few others) do not actually do the packet forwarding themselves. At least, not usually. They could, I guess, but context switches are expensive (think 20ms from kernel to user, and same in reverse) so offloading trivial operations to the kernel and reserving the computationally-expensive stuff for userspace actually makes more sense.

(This is not theoretically true of RNICs, which can place data anywhere in memory, so can bypass context switches entirely. It's also not theoretically true of memory with built-in NIC support - such memory does exist. However, nobody uses such memory, and no RNIC I know of has any offloaded IGMP capabilities or direct registering of applications. Therefore, theory doesn't apply in this case and therefore packets are kernel-processed.)

Enabling multicast routing provides you with the option of including the kernel components of the PIMv1 or PIMv2 protocols. As far as I understand it, PIMv1 has been deployed more and the software is more mature, but PIMv2 has explicit support for specific common and corner cases, so should perform better under just about any condition.

Finally, there is the question of what you want to use multicasting for and over what type of network. Infiniband multicasting is different from IETF's UDP-based IP multicasting, although frankly I can't see why you couldn't use the same algorithms for routing. Linux' multicasting options deal with IP multicasting, not other forms, as far as I know.

If you are going to be running standard multimedia fare over the network and be unicasting only for routing traffic and occasional remote admining, you would obviously want to configure other kernel options accordingly. On the other hand, if you're wanting to use SRM (scalable, reliable multicasting) or a derivative, then unicast traffic for repairs will be unpredictable and non-uniform. They too must be routed and to prevent their inclusion disrupting the multicast streams, you would need different kernel options to retain efficiency.

Then, even if you are using IP multicast and have sorted everything else out, think about whether it's over IPv4 or IPv6. They use different group membership protocols and different routing mechanisms.

After that, sit down with a nice cuppa tea or a beer and relax, safe in the knowledge that protocol gurus are busy rewriting the specs, obsoleting all that careful thought and work you have just done.

--- On Fri, 8/15/08, Daniel Ng <daniel_ng11@lycos.com> wrote:

> From: Daniel Ng <daniel_ng11@lycos.com>
> Subject: Multicast Routing Kernel option?
> To: netdev@vger.kernel.org
> Date: Friday, August 15, 2008, 12:37 AM
> Hi,
> 
> Would someone please tell me in general terms what the
> Multicast Routing 
> kernel option does?
> 
> I'm considering using mrouted (DVMRP) for now. I
> understand that mrouted does 
> the actual routing of multicast packets. If that is the
> case, what does the 
> Multicast Routing kernel option provide?
> 
> Cheers,
> Daniel
> 
> --
> To unsubscribe from this list: send the line
> "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at 
> http://vger.kernel.org/majordomo-info.html


      
