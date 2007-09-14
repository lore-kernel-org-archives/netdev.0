From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [git patches] net driver fixes
Date: Fri, 14 Sep 2007 12:19:32 -0700
Message-ID: <32620.1189797572@death>
References: <20070913053022.GA16891@havoc.gtf.org> <1189793598.2508.4.camel@xo-3E-67-34.localdomain> <46EAD049.4020107@garzik.org> <1189794677.2508.19.camel@xo-3E-67-34.localdomain>
Cc: Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Dan Williams <dcbw@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757886AbXINTTr@vger.kernel.org>
In-reply-to: <1189794677.2508.19.camel@xo-3E-67-34.localdomain> 
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dan Williams <dcbw@redhat.com> wrote:
[...]
>I admit that I probably don't understand the system architecture of
>where ehea would be used, but would this
>cause /sys/class/net/ethX/carrier to be TRUE even if the device has no
>carrier?  That seems quite wrong IMHO.  When does ehea not have a
>carrier?  And in that case, does sysfs say 1 or 0 for the carrier?

	I don't work on ehea, but I'm generally familiar with it, and
particularly with this patch.

	The usual environment for ehea devices is on large systems
subdivided into multiple logical partitions.  One ehea device serves
many partitions.  By having ehea always report "link up" to the logical
ports (the ports seen by the partitions), the partitions can communicate
amongst themselves even if the external ports (the ports that go to the
switch or whatever) have no link.  

	The ehea device, more or less, acts as a switch connecting the
partitions together.  This switch type of functionality is not dependent
upon the link state of the external ports (any more than the
functionality of any switch is dependent upon whether or not it is
connected to a gateway).

	This, if I'm not mistaken, is the way ehea has always operated
until this particular patch was added.

	This patch (to optionally pass carrier state to the logical
ports) was added largely for bonding, so that the bonding driver can
detect link failures on the external ports (when so desired).  The
default behavior remains the original behavior, i.e., do not pass
external port link state to the logical ports.

	Anyway, to answer your question, the carrier state reported for
the ehea interface on the partition will always be true.  Think of it as
reporting the link state from the logical interface to the "switch" that
connects the partitions; that link exists only within the ehea device
itself, and really can't fail unless the ehea device itself fails.

	With the new option enabled, then ehea is more or less mimicing
a trunk failover type of function, and passing the carrier state of the
"external switch port" to the internal port.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
