From: "Paul Congdon \(UC Davis\)" <ptcongdon@ucdavis.edu>
Subject: RE: [PATCH][RFC] net/bridge: add basic VEPA support
Date: Fri, 7 Aug 2009 11:58:00 -0700
Message-ID: <004e01ca1790$fec36c30$fc4a4490$@edu>
References: <0199E0D51A61344794750DC57738F58E67D2DCECBB@GVW1118EXC.americas.hpqcorp.net> <20090806210002.75beb7c6@nehalam>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <bridge@lists.linux-foundation.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<virtualization@lists.linux-foundation.org>, <evb@yahoogroups.com>,
	<davem@davemloft.net>, <kaber@trash.net>, <adobriyan@gmail.com>,
	"'Arnd Bergmann'" <arnd@arndb.de>
To: "'Stephen Hemminger'" <shemminger@linux-foundation.org>,
	"'Fischer, Anna'" <anna.fischer@hp.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932952AbZHGS6b@vger.kernel.org>
In-Reply-To: <20090806210002.75beb7c6@nehalam>
Content-Language: en-us
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 
> After reading more about this, I am not convinced this should be part 
> of the bridge code. The bridge code really consists of two parts:
> forwarding table and optional spanning tree. Well the VEPA code short 
> circuits both of these; it can't imagine it working with STP turned 
> on. The only part of bridge code that really gets used by this are the 
> receive packet hooks and the crufty old API.
> 
> So instead of adding more stuff to existing bridge code, why not have 
> a new driver for just VEPA. You could do it with a simple version of 
> macvlan type driver.

Stephen,

Thanks for your comments and questions.  We do believe the bridge code is
the right place for this, so I'd like to embellish on that a bit more to
help persuade you.  Sorry for the long winded response, but here are some
thoughts:

- First and foremost, VEPA is going to be a standard addition to the IEEE
802.1Q specification.  The working group agreed at the last meeting to
pursue a project to augment the bridge standard with hairpin mode (aka
reflective relay) and a remote filtering service (VEPA).  See for details:
http://www.ieee802.org/1/files/public/docs2009/new-evb-congdon-evbPar5C-0709
-v01.pdf

- The VEPA functionality was really a pretty small change to the code with
low risk and wouldn't seem to warrant an entire new driver or module.

- There are good use cases where VMs will want to have some of their
interfaces attached to bridges and others to bridges operating in VEPA mode.
In other words, we see simultaneous operation of the bridge code and VEPA
occurring, so having as much of the underlying code as common as possible
would seem to be beneficial. 

- By augmenting the bridge code with VEPA there is a great amount of re-use
achieved.  It works wherever the bridge code works and doesn't need anything
special to support KVM, XEN, and all the hooks, etc...

- The hardware vendors building SR-IOV NICs with embedded switches will be
adding VEPA mode, so by keeping the bridge module in sync would be
consistent with this trend and direction.  It will be possible to extend the
hardware implementations by cascading a software bridge and/or VEPA, so
being in sync with the architecture would make this more consistent.
 
- The forwarding table is still needed and used on inbound traffic to
deliver frames to the correct virtual interfaces and to filter any reflected
frames.  A new driver would have to basically implement an equivalent
forwarding table anyway.  As I understand the current macvlan type driver,
it wouldn't filter multicast frames properly without such a table.

- It seems the hairpin mode would be needed in the bridge module whether
VEPA was added to the bridge module or a new driver.  Having the associated
changes together in the same code could aid in understanding and deployment.

As I understand the macvlan code, it currently doesn't allow two VMs on the
same machine to communicate with one another.  I could imagine a hairpin
mode on the adjacent bridge making this possible, but the macvlan code would
need to be updated to filter reflected frames so a source did not receive
his own packet.  I could imagine this being done as well, but to also
support selective multicast usage, something similar to the bridge
forwarding table would be needed.  I think putting VEPA into a new driver
would cause you to implement many things the bridge code already supports.
Given that we expect the bridge standard to ultimately include VEPA, and the
new functions are basic forwarding operations, it seems to make most sense
to keep this consistent with the bridge module.

Paul
